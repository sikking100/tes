package route

import (
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/report/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func NewRoute(repo repository) *http.Server {
	route := routes.NewRoutes()
	report := route.Group("/report/v1")
	report.GET("", auth.Validate(auth.RolesLeader()...), find(repo))
	report.POST("", auth.Validate(auth.RolesLeader()...), create(repo))
	report.DELETE("/:id", auth.Validate(auth.RolesLeader()...), delete(repo))
	report.GET("/:id", auth.Validate(auth.RolesLeader()...), byId(repo))
	report.POST("/event/new-image", newImage(repo))

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

func delete(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		data, err := repo.ById(ctx, id)
		if err != nil {
			routes.Response(ctx, nil, err)
			return
		}
		if auth.GetUser(ctx).Id == data.From.Id || auth.GetUser(ctx).Id == data.To.Id {
			data, err := repo.Delete(ctx, id)
			routes.Response(ctx, data, err)
			return
		}
		routes.Response(ctx, nil, errors.Forbidden(nil))
	}
}

func newImage(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		req := struct {
			Id          string `json:"id" binding:"required"`
			ContentType string `json:"contentType" binding:"required"`
		}{}
		if err := ctx.ShouldBindJSON(&req); err != nil {
			routes.Response(ctx, "invalid event data", nil)
			return
		}

		if strings.HasPrefix(req.ContentType, "application/") {
			// bucket/private/{path}/{id}/fileName/{idx-storage}
			lPath := strings.Split(req.Id, "/")
			if len(lPath) != 6 {
				routes.Response(ctx, req.Id, nil)
				return
			} else if lPath[2] != "report" {
				routes.Response(ctx, req.Id, nil)
				return
			}
			id, err := primitive.ObjectIDFromHex(lPath[3])
			if err != nil {
				routes.Response(ctx, req.Id, nil)
				return
			}
			path := strings.Join(lPath[1:len(lPath)-1], "/")
			//url := fmt.Sprintf("https://storage.googleapis.com/%s", strings.Join(lPath[:len(lPath)-1], "/"))
			routes.Response(ctx, req.Id, repo.UpdateFilePath(ctx, id, path))
			return
		}
		if strings.HasPrefix(req.ContentType, "image/") {
			// bucket/{path}/id/thumbs/fileName/{idx-storage}
			lPath := strings.Split(req.Id, "/")
			if len(lPath) != 6 {
				routes.Response(ctx, req.Id, nil)
				return
			} else if lPath[3] != "thumbs" {
				routes.Response(ctx, req.Id, nil)
				return
			}
			id, err := primitive.ObjectIDFromHex(lPath[2])
			if err != nil {
				routes.Response(ctx, req.Id, nil)
				return
			}
			//path := strings.Join(lPath[1:len(lPath)-1], "/")
			url := fmt.Sprintf("https://storage.googleapis.com/%s", strings.Join(lPath[:len(lPath)-1], "/"))
			routes.Response(ctx, req.Id, repo.UpdateImageUrl(ctx, id, url))
			return
		}
		routes.Response(ctx, nil, nil)
	}
}
