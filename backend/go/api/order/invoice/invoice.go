package invoice

import (
	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/order/invoice/repository"
	"github.com/grocee-project/dairyfood/backend/go/api/order/invoice/route"
	"go.mongodb.org/mongo-driver/mongo"
)

func NewInvoice(engin *gin.Engine, dbClient *mongo.Client) {
	route.NewRoute(engin, repository.NewRepository(dbClient))
}
