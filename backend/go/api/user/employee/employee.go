package employee

import (
	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/user/employee/repository"
	"github.com/grocee-project/dairyfood/backend/go/api/user/employee/route"
)

func New(engine *gin.Engine, repo *repository.Repository) {
	route.NewRoute(engine, repo)
}
