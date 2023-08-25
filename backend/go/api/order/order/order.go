package order

import (
	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/order/order/repository"
	"github.com/grocee-project/dairyfood/backend/go/api/order/order/route"
	"go.mongodb.org/mongo-driver/mongo"
)

func NewOrder(engin *gin.Engine, dbClient *mongo.Client) {
	// repoInvoice := repoInvoice.NewRepository(dbClient, )

	// create route
	route.NewRoute(engin, repository.NewRepositry(dbClient))
}
