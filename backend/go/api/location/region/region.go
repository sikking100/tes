package region

import (
	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/location/region/repository"
	"github.com/grocee-project/dairyfood/backend/go/api/location/region/route"
)

func New(engine *gin.Engine, repo *repository.Repository) {
	route.NewRoute(engine, repo)
}
