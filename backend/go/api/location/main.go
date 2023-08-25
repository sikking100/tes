package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/location/branch"
	branchRepo "github.com/grocee-project/dairyfood/backend/go/api/location/branch/repository"
	"github.com/grocee-project/dairyfood/backend/go/api/location/region"
	regionRepo "github.com/grocee-project/dairyfood/backend/go/api/location/region/repository"

	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

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
	ctx := context.Background()
	client := dbClient()
	engine := routes.NewRoutes()
	repoRegion, err := regionRepo.NewRepository(ctx, client)
	if err != nil {
		log.Fatalln(err.Error())
	}
	repoBranch, err := branchRepo.NewRepository(ctx, client)
	if err != nil {
		log.Fatalln(err.Error())
	}
	branch.New(engine, repoBranch)
	region.New(engine, repoRegion)
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
