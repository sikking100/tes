package auth

import (
	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/user/auth/repository"
	"github.com/grocee-project/dairyfood/backend/go/api/user/auth/route"
)

func New(engine *gin.Engine, repo *repository.Repository) {
	route.NewRoute(engine, repo)
}
