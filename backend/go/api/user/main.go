package main

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/user/auth"
	authRepo "github.com/grocee-project/dairyfood/backend/go/api/user/auth/repository"

	"github.com/grocee-project/dairyfood/backend/go/api/user/customer"
	customerRepo "github.com/grocee-project/dairyfood/backend/go/api/user/customer/repository"

	"github.com/grocee-project/dairyfood/backend/go/api/user/employee"
	employeeRepo "github.com/grocee-project/dairyfood/backend/go/api/user/employee/repository"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func loadSecret() {
	b, err := base64.StdEncoding.DecodeString(os.Getenv("SECRET"))
	if err != nil {
		log.Fatalf("env secret base64 %s", err.Error())
	}
	secret := struct {
		DbUri       string `json:"dbUri"`
		SmsApiKey   string `json:"smsApiKey"`
		SmsApiToken string `json:"smsApiToken"`
	}{}
	if err := json.Unmarshal(b, &secret); err != nil {
		log.Fatalf("env secret json %s", err.Error())
	}
	os.Setenv("DB_URI", secret.DbUri)
	os.Setenv("SMS_API_KEY", secret.SmsApiKey)
	os.Setenv("SMS_API_TOKEN", secret.SmsApiToken)
}
func shutdown(ctx context.Context, srv *http.Server, db *mongo.Client) {
	if err := srv.Shutdown(ctx); err != nil {
		log.Println("failed shutdown server")
		return
	}
	if err := db.Disconnect(ctx); err != nil {
		log.Println("failed shutdown database")
		return
	}
	log.Println("shutdown server")
}
func dbClient() *mongo.Client {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	client, err := mongo.Connect(ctx, options.Client().ApplyURI(os.Getenv("DB_URI")))
	if err != nil {
		log.Fatalln(err)
	}
	return client
}
func main() {
	loadSecret()
	client := dbClient()
	engine := routes.NewRoutes()
	ctx := context.Background()
	authRepo, err := authRepo.NewRepository(ctx, client)
	if err != nil {
		log.Fatalln(err.Error())
	}
	customerRepo, err := customerRepo.NewRepository(ctx, client)
	if err != nil {
		log.Fatalln(err.Error())
	}
	employeeRepo, err := employeeRepo.NewRepository(ctx, client)
	if err != nil {
		log.Fatalln(err.Error())
	}

	auth.New(engine, authRepo)
	employee.New(engine, employeeRepo)
	customer.New(engine, customerRepo)
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
	shutdown(ctx, srv, client)
}
