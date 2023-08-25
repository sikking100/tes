package route

import (
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
)

func NewRoute(repo repository) *http.Server {
	route := routes.NewRoutes()
	api := route.Group("/brand/v1")
	api.GET("", auth.Validate(), find(repo))
	api.POST("/:id", auth.Validate(auth.SYSTEM_ADMIN), save(repo))
	api.GET("/:id", auth.Validate(auth.SYSTEM_ADMIN), findById(repo))
	api.DELETE("/:id", auth.Validate(auth.SYSTEM_ADMIN), deleteById(repo))
	api.POST("/event/new-image", updateImage(repo))
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
		data := struct {
			Name string `json:"name" binding:"required"`
		}{}
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Save(ctx, id, data.Name)
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
func updateImage(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		data := struct {
			Id          string `json:"id" binding:"required"`
			ContentType string `json:"contentType" binding:"required"`
		}{}
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, "invalid event data", nil)
			return
		}
		lPath := strings.Split(data.Id, "/")
		switch {
		case len(lPath) != 6 || !strings.HasPrefix(data.ContentType, "image"):
			routes.Response(ctx, data.Id, nil)
			return
		case lPath[1] != "brand" || lPath[3] != "thumbs":
			routes.Response(ctx, data.Id, nil)
			return
		}
		url := fmt.Sprintf("https://storage.googleapis.com/%s", strings.Join(lPath[:len(lPath)-1], "/"))
		routes.Response(ctx, data.Id, repo.UpdateImage(ctx, lPath[2], url))
	}
}
