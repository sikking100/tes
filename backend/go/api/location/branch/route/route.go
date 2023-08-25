package route

import (
	"fmt"

	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/location/branch/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
)

func NewRoute(engine *gin.Engine, repo repository) {
	api := engine.Group("/location-branch/v1")
	api.GET("", auth.Validate(), find(repo))
	api.GET("/find/near", auth.Validate(), findNear(repo))
	api.GET("/:id", auth.Validate(), findById(repo))
	api.POST("/:id", auth.Validate(auth.SYSTEM_ADMIN), saveBranch(repo))
	api.PUT("/:id", auth.Validate(auth.BRANCH_ADMIN), updateWarehouse(repo))
	api.DELETE("/:id", auth.Validate(auth.SYSTEM_ADMIN), deleteBranch(repo))
}
func getParamId(ctx *gin.Context) (string, error) {
	id := ctx.Param("id")
	if id == "" {
		return "", fmt.Errorf("id required")
	}
	return id, nil
}
func find(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.Find
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Find(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func findNear(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		data := struct {
			Lng float64 `form:"lng" binding:"required,longitude"`
			Lat float64 `form:"lat" binding:"required,latitude"`
		}{}
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindByNear(ctx, []float64{data.Lng, data.Lat})
		routes.Response(ctx, result, err)
	}
}
func findById(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := getParamId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindById(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func saveBranch(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := getParamId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.SaveBranch
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Save(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}

func updateWarehouse(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data []*entity.SaveWarehouse
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.UpdateWarehouse(ctx, auth.GetUser(ctx).LocationId, data)
		routes.Response(ctx, result, err)
	}
}
func deleteBranch(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := getParamId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Delete(ctx, id)
		routes.Response(ctx, result, err)
	}
}
