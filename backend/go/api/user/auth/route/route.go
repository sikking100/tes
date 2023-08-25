package route

import (
	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/user/auth/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
)

func NewRoute(engine *gin.Engine, repo repository) {
	api := engine.Group("/user-auth/v1")
	api.POST("", login(repo))
	api.PUT("", verify(repo))
}
func login(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.Login
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Login(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func verify(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.Verify
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Verify(ctx, data)
		routes.Response(ctx, result, err)
	}
}
