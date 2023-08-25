package customer

import (
	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/user/customer/repository"
	"github.com/grocee-project/dairyfood/backend/go/api/user/customer/route"
)

func New(engine *gin.Engine, repo *repository.Repository) {
	route.NewRoute(engine, repo)
}
