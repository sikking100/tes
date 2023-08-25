package route

import (
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/recipe/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func NewRoute(repo repository) *http.Server {
	route := routes.NewRoutes()
	recipe := route.Group("/recipe/v1")
	recipe.GET("/recipe", auth.Validate(auth.SALES_ADMIN, auth.CUSTOMER), find(repo))
	recipe.POST("/recipe", auth.Validate(auth.SALES_ADMIN), create(repo))
	recipe.GET("/recipe/:id", auth.Validate(auth.SALES_ADMIN, auth.CUSTOMER), byId(repo))
	recipe.PUT("/recipe/:id", auth.Validate(auth.SALES_ADMIN), update(repo))
	recipe.DELETE("/recipe/:id", auth.Validate(auth.SALES_ADMIN), delete(repo))
	recipe.POST("/event/new-image", newImage(repo))
	srv := &http.Server{
		Addr:    ":" + os.Getenv("PORT"),
		Handler: route,
	}
	return srv
}

func paramId(ctx *gin.Context) (primitive.ObjectID, error) {
	id, err := primitive.ObjectIDFromHex(ctx.Param("id"))
	if err != nil {
		return id, err
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
		if data.Categories {
			result, err := repo.Categories(ctx)
			routes.Response(ctx, result, err)
			return
		}
		result, err := repo.Find(ctx, data)
		routes.Response(ctx, result, err)
	}
}

func byId(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.ById(ctx, id)
		routes.Response(ctx, result, err)
	}
}

func create(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.Save
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Create(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func update(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.Save
		if err := ctx.ShouldBind(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Update(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}

func delete(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Delete(ctx, id)
		routes.Response(ctx, result, err)
	}
}

func newImage(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		data := struct {
			Id          string `json:"id" binding:"required"`
			ContentType string `json:"contentType" binding:"required"`
		}{}
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, "invalid event data", nil)
			return
		}
		// bucket-name/recipe/{id}/thumbs/{fileName.ext}/{file-id}
		lPath := strings.Split(data.Id, "/")
		switch {
		case len(lPath) != 6 || !strings.HasPrefix(data.ContentType, "image"):
			routes.Response(ctx, data.Id, nil)
			return
		case lPath[1] != "recipe" || lPath[3] != "thumbs":
			routes.Response(ctx, data.Id, nil)
			return
		}
		//
		id, err := primitive.ObjectIDFromHex(lPath[2])
		if err != nil {
			routes.Response(ctx, data.Id, nil)
			return
		}
		//path := strings.Join(lPath[1:len(lPath)-1], "/")
		url := fmt.Sprintf("https://storage.googleapis.com/%s", strings.Join(lPath[:len(lPath)-1], "/"))
		routes.Response(ctx, data, repo.UpdateImage(ctx, id, url))
	}
}
