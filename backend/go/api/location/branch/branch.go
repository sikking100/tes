package branch

import (
	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/location/branch/repository"
	"github.com/grocee-project/dairyfood/backend/go/api/location/branch/route"
)

func New(engine *gin.Engine, repo *repository.Repository) {
	route.NewRoute(engine, repo)
}
