package route

import (
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/category/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
)

func NewRoute(repo repository) *http.Server {
	route := routes.NewRoutes()
	api := route.Group("/category/v1")
	api.GET("", auth.Validate(), find(repo))
	api.POST("/:id", auth.Validate(auth.SYSTEM_ADMIN, auth.SALES_ADMIN), save(repo))
	api.GET("/:id", auth.Validate(), findById(repo))
	api.DELETE("/:id", auth.Validate(auth.SYSTEM_ADMIN), deleteById(repo))
	srv := &http.Server{
		Addr:    ":" + os.Getenv("PORT"),
		Handler: route,
	}
	return srv
}
func getParamId(ctx *gin.Context) (string, error) {
	id := struct {
		Id string `uri:"id" binding:"required"`
	}{}
	if err := ctx.ShouldBindUri(&id); err != nil {
		return "", err
	}
	return id.Id, nil
}
func find(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		result, err := repo.Find(ctx)
		routes.Response(ctx, result, err)
	}
}
func save(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := getParamId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.Save
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Save(ctx, id, data)
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
func deleteById(repo repository) gin.HandlerFunc {
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
