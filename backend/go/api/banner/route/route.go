package route

import (
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/banner/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func NewRoute(repo repository) *http.Server {
	route := routes.NewRoutes()
	banner := route.Group("/banner/v1")
	banner.GET("", auth.Validate(), find(repo))
	banner.POST("", create(repo))
	banner.DELETE("/:id", auth.Validate(auth.SYSTEM_ADMIN), delete(repo))

	srv := &http.Server{
		Addr:    ":" + os.Getenv("PORT"),
		Handler: route,
	}
	return srv
}

func find(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		data := struct {
			Type int `form:"type" binding:"required,gte=1,lte=2"`
		}{}
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Find(ctx, data.Type)
		routes.Response(ctx, result, err)
	}
}
func create(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		data := struct {
			Id          string `json:"id" binding:"required"`
			ContentType string `json:"contentType" binding:"required"`
		}{}
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, "invalid event data", nil)
			return
		}
		//bucket-name/banner/thumbs/{internal-name.ext}/{file-id}
		//bucket-name/banner/thumbs/{external-name.ext}/{file-id}
		lPath := strings.Split(data.Id, "/")
		switch {
		case len(lPath) != 5 || !strings.HasPrefix(data.ContentType, "image"):
			routes.Response(ctx, data.Id, nil)
			return
		case lPath[1] != "banner" || lPath[2] != "thumbs":
			routes.Response(ctx, data.Id, nil)
			return
		case strings.HasPrefix(lPath[3], "internal-"):
			url := fmt.Sprintf("https://storage.googleapis.com/%s", strings.Join(lPath[:len(lPath)-1], "/"))
			routes.Response(ctx, data, repo.Create(ctx, int(entity.INTERNAL), url))
			return
		case strings.HasPrefix(lPath[3], "external-"):
			url := fmt.Sprintf("https://storage.googleapis.com/%s", strings.Join(lPath[:len(lPath)-1], "/"))
			routes.Response(ctx, data, repo.Create(ctx, int(entity.EXTERNAL), url))
			return
		default:
			routes.Response(ctx, data.Id, nil)
			return
		}
	}
}
func delete(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := primitive.ObjectIDFromHex(ctx.Param("id"))
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Delete(ctx, id)
		routes.Response(ctx, result, err)
	}
}
