package delivery

import (
	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/order/delivery/repository"
	"github.com/grocee-project/dairyfood/backend/go/api/order/delivery/route"
	"go.mongodb.org/mongo-driver/mongo"
)

func NewDelivery(engin *gin.Engine, dbClient *mongo.Client) {
	route.NewRoute(engin, repository.NewRepository(dbClient))
}
