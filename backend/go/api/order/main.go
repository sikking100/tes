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

	"github.com/grocee-project/dairyfood/backend/go/api/order/delivery"
	"github.com/grocee-project/dairyfood/backend/go/api/order/invoice"
	"github.com/grocee-project/dairyfood/backend/go/api/order/order"
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
		DbUri                string `json:"dbUri"`
		GoSendHost           string `json:"gosendHost"`
		GosendCallbackToken  string `json:"gosendCallbackToken"`
		GoSendPassKey        string `json:"gosendPassKey"`
		GoSendClientId       string `json:"gosendClientId"`
		XenditApiKey         string `json:"xenditApiKey"`
		XenditCallabackToken string `json:"xenditCallbackToken"`
	}{}
	if err := json.Unmarshal(b, &secret); err != nil {
		log.Fatalf("env secret json %s", err.Error())
	}
	os.Setenv("DB_URI", secret.DbUri)
	os.Setenv("XENDIT_APY_KEY", secret.XenditApiKey)
	os.Setenv("XENDIT_CALLBACK_TOKEN", secret.XenditCallabackToken)
	os.Setenv("GO_SEND_HOST", secret.GoSendHost)
	os.Setenv("GOSEND_CLIENT_ID", secret.GoSendClientId)
	os.Setenv("GOSEND_PASS_KEY", secret.GoSendPassKey)
	os.Setenv("GOSEND_CALLBACK_TOKEN", secret.GosendCallbackToken)
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
	delivery.NewDelivery(engine, client)
	invoice.NewInvoice(engine, client)
	order.NewOrder(engine, client)
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
