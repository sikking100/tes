package main

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"github.com/gin-gonic/gin"
	"google.golang.org/api/idtoken"
	"gopkg.in/yaml.v3"
)

var svc map[string]string

func init() {
	// init svc
	svc = map[string]string{}
}

type Endpoint struct {
	Path   string   `yaml:"path"`
	Method []string `yaml:"method"`
	IsAuth bool     `yaml:"isAuth"`
}

type Route struct {
	Name     string
	Host     *url.URL
	Endpoint []*Endpoint
}

func (r *Route) UnmarshalYAML(unmarshal func(interface{}) error) error {
	mRoute := struct {
		Name       string      `yaml:"name"`
		Local      string      `yaml:"local"`
		Develop    string      `yaml:"develop"`
		Production string      `yaml:"production"`
		Endpoint   []*Endpoint `yaml:"endpoint"`
	}{}
	err := unmarshal(&mRoute)
	if err != nil {
		return err
	}
	var host *url.URL = nil
	if os.Getenv("ENV") == "PRODUCTION" {
		host, err = url.Parse(mRoute.Production)
		if err != nil {
			return err
		}
	} else if os.Getenv("ENV") == "DEVELOP" {
		host, err = url.Parse(mRoute.Develop)
		if err != nil {
			return err
		}
	} else {
		host, err = url.Parse(mRoute.Local)
		if err != nil {
			return err
		}
	}
	r.Name = mRoute.Name
	r.Host = host
	r.Endpoint = mRoute.Endpoint
	return nil
}
func getRoute() []*Route {
	file, err := os.ReadFile("./route.yml")
	if err != nil {
		log.Fatalln(err.Error())
	}
	result := make([]*Route, 0)
	if err = yaml.Unmarshal(file, &result); err != nil {
		log.Fatalln(err.Error())
	}
	return result

}
func cors() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Credentials", "true")
		c.Header("Access-Control-Allow-Headers", "Auth-User, x-callback-token, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Header("Access-Control-Allow-Methods", "POST,HEAD,PATCH,OPTIONS,GET,PUT,DELETE")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatusJSON(204, gin.H{"code": 204, "error": "cors origin", "data": nil})
			return
		}
		c.Next()
	}
}
func encodedAuthUser(jwtToken *auth.Token) (string, error) {
	roles, _ := jwtToken.Claims["roles"].(float64)
	phone, _ := jwtToken.Claims["phone"].(string)
	locationId, _ := jwtToken.Claims["locationId"].(string)
	team, _ := jwtToken.Claims["team"].(float64)
	j, err := json.Marshal(map[string]interface{}{
		"id":         jwtToken.UID,
		"roles":      int(roles),
		"phone":      phone,
		"locationId": locationId,
		"team":       int(team),
	})
	if err != nil {
		return "", err
	}
	return base64.StdEncoding.EncodeToString(j), nil

}
func authentication(auth *auth.Client, name string, host *url.URL, isAuth bool) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		if isAuth && os.Getenv("ENV") == "LOCAL" {
			token := strings.Split(ctx.GetHeader("Authorization"), " ")
			if len(token) != 2 {
				ctx.AbortWithStatusJSON(401, gin.H{"code": 401, "data": nil, "errors": fmt.Errorf("token required")})
				return
			}
			ctx.Request.Header.Set("Auth-User", token[1])
		} else if isAuth {
			token := strings.Split(ctx.GetHeader("Authorization"), " ")
			if len(token) != 2 {
				ctx.AbortWithStatusJSON(401, gin.H{"code": 401, "data": nil, "errors": fmt.Errorf("token required")})
				return
			}
			jwtToken, err := auth.VerifyIDToken(ctx, token[1])
			if err != nil {
				ctx.AbortWithStatusJSON(401, gin.H{"code": 401, "data": nil, "errors": err.Error()})
				return
			}
			user, err := encodedAuthUser(jwtToken)
			if err != nil {
				ctx.AbortWithStatusJSON(401, gin.H{"code": 401, "data": nil, "errors": err.Error()})
				return
			}
			ctx.Request.Header.Set("Auth-User", user)
		} else {
			if xenToken := ctx.GetHeader("x-callback-token"); xenToken != "" {
				ctx.Request.Header.Set("x-callback-token", xenToken)
			} else if gosendToken := ctx.GetHeader("Authorization"); gosendToken != "" {
				ctx.Request.Header.Set("x-callback-token", gosendToken)
			}
		}
		if svcToken, ok := svc[name]; ok && svcToken != "" {
			payload, err := idtoken.Validate(ctx, svcToken, host.String())
			if payload != nil && err == nil {
				if payload.Expires > time.Now().Add(time.Minute*5).Unix() {
					ctx.Request.Header.Set("Authorization", fmt.Sprintf("Bearer %s", svcToken))
					ctx.Next()
					return
				}
			}
		}
		tokenSource, err := idtoken.NewTokenSource(ctx.Request.Context(), host.String())
		if err != nil {
			ctx.AbortWithStatusJSON(401, gin.H{"code": 401, "data": nil, "errors": err.Error()})
			return
		}
		mToken, err := tokenSource.Token()
		if err != nil {
			ctx.AbortWithStatusJSON(401, gin.H{"code": 401, "data": nil, "errors": err.Error()})
			return
		}
		svc[name] = mToken.AccessToken
		ctx.Request.Header.Set("Authorization", fmt.Sprintf("Bearer %s", mToken.AccessToken))
		ctx.Next()
	}
}
func proxy(host *url.URL) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		proxy := httputil.NewSingleHostReverseProxy(host)
		proxy.Director = func(req *http.Request) {
			req.Header = ctx.Request.Header
			req.Host = host.Host
			req.URL.Scheme = host.Scheme
			req.URL.Host = host.Host
		}
		proxy.ServeHTTP(ctx.Writer, ctx.Request)
	}
}
func shutdown(ctx context.Context, srv *http.Server) {
	if err := srv.Shutdown(ctx); err != nil {
		log.Println(err.Error())
	}
	log.Println("shutdown server")
}
func setupFirebase() *auth.Client {
	ctx := context.Background()
	fApp, err := firebase.NewApp(ctx, &firebase.Config{})
	if err != nil {
		log.Fatalln(err.Error())
	}
	mAuth, err := fApp.Auth(ctx)
	if err != nil {
		log.Fatalln(err.Error())
	}
	return mAuth
}
func main() {
	gin.SetMode(gin.ReleaseMode)
	engine := gin.New()
	engine.Use(cors())
	engine.Use(gin.Logger())
	route := getRoute()
	auth := setupFirebase()
	for _, r := range route {
		for _, e := range r.Endpoint {
			for _, m := range e.Method {
				switch {
				case m == "GET":
					engine.GET(e.Path, authentication(auth, r.Name, r.Host, e.IsAuth), proxy(r.Host))
				case m == "POST":
					engine.POST(e.Path, authentication(auth, r.Name, r.Host, e.IsAuth), proxy(r.Host))
				case m == "PUT":
					engine.PUT(e.Path, authentication(auth, r.Name, r.Host, e.IsAuth), proxy(r.Host))
				case m == "DELETE":
					engine.DELETE(e.Path, authentication(auth, r.Name, r.Host, e.IsAuth), proxy(r.Host))
				case m == "PATCH":
					engine.PATCH(e.Path, authentication(auth, r.Name, r.Host, e.IsAuth), proxy(r.Host))
				}
			}
		}
	}
	if os.Getenv("PORT") == "" {
		os.Setenv("PORT", "8080")
	}
	srv := &http.Server{
		Addr:    ":" + os.Getenv("PORT"),
		Handler: engine,
	}
	go func() {
		log.Printf("run server on PORT %s\n", os.Getenv("PORT"))
		if err := srv.ListenAndServe(); err != http.ErrServerClosed {
			log.Fatalln(err.Error())
		}
	}()
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM, syscall.SIGQUIT)
	<-quit
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	shutdown(ctx, srv)
}
