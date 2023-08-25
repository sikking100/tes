package route

import (
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/activity/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func NewRoute(repo repository) *http.Server {
	route := routes.NewRoutes()
	activity := route.Group("/activity/v1")
	activity.GET("", auth.Validate(), actFind(repo))
	activity.POST("", auth.Validate(auth.RolesEmployee()...), actCreate(repo))
	activity.GET("/:id", auth.Validate(auth.RolesEmployee()...), actfindById(repo))
	activity.PUT("/:id", auth.Validate(auth.RolesEmployee()...), actUpdate(repo))
	activity.DELETE("/:id", auth.Validate(auth.RolesEmployee()...), actDelete(repo))
	activity.POST("/event/new-image", actNewImage(repo))

	comment := route.Group("/comment/v1")
	comment.GET("", auth.Validate(), comFind(repo))
	comment.POST("", auth.Validate(auth.RolesEmployee()...), comCreate(repo))
	comment.GET("/:id", auth.Validate(auth.RolesEmployee()...), comfindById(repo))
	comment.PUT("/:id", auth.Validate(auth.RolesEmployee()...), comUpdate(repo))
	comment.DELETE("/:id", auth.Validate(auth.RolesEmployee()...), comDelete(repo))
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
func actFind(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.Find
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindActivity(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func actCreate(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.SaveActivity
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.CreateActivity(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func actfindById(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindActivityById(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func actUpdate(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.SaveActivity
		if err := ctx.ShouldBind(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.UpdateActivity(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
func actDelete(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.DeleteActivity(ctx, id, auth.GetUser(ctx).Id)
		routes.Response(ctx, result, err)
	}
}
func actNewImage(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		data := struct {
			Id          string `json:"id" binding:"required"`
			ContentType string `json:"contentType" binding:"required"`
		}{}
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, "invalid event data", nil)
			return
		}
		// bucket-name/activity/{id}/thumbs/{fileName.ext}/{file-id}
		lPath := strings.Split(data.Id, "/")
		switch {
		case len(lPath) != 6 || !strings.HasPrefix(data.ContentType, "image"):
			routes.Response(ctx, data.Id, nil)
			return
		case lPath[1] != "activity" || lPath[3] != "thumbs":
			routes.Response(ctx, data.Id, nil)
			return
		}
		//
		id, err := primitive.ObjectIDFromHex(lPath[2])
		if err != nil {
			routes.Response(ctx, data.Id, nil)
			return
		}
		path := strings.Join(lPath[1:len(lPath)-1], "/")
		url := fmt.Sprintf("https://storage.googleapis.com/%s", strings.Join(lPath[:len(lPath)-1], "/"))
		routes.Response(ctx, data, repo.UpdateImage(ctx, id, path, url))
	}
}
func comFind(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := primitive.ObjectIDFromHex(ctx.Query("activityId"))
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindComment(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func comCreate(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.SaveComment
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.CreateComment(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func comfindById(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindCommentById(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func comUpdate(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.SaveComment
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.UpdateComment(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
func comDelete(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.DeleteComment(ctx, id, auth.GetUser(ctx).Id)
		routes.Response(ctx, result, err)
	}
}
