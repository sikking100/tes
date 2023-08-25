package route

import (
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/help/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func NewRoute(repo repository) *http.Server {
	route := routes.NewRoutes()
	help := route.Group("/help/v1")
	help.POST("/help", auth.Validate(auth.RolesAdmin()...), createHelp(repo))
	help.POST("/question", auth.Validate(auth.RolesAdmin()...), createQuestion(repo))
	help.PUT("/help/:id", auth.Validate(auth.SYSTEM_ADMIN), updateHelp(repo))
	help.PUT("/question/:id", auth.Validate(auth.SYSTEM_ADMIN), answerQuestion(repo))
	help.DELETE("/help/:id", auth.Validate(auth.RolesAdmin()...), deleteHelp(repo))
	help.GET("/help", auth.Validate(auth.RolesAdmin()...), find(repo))
	help.GET("/help/:id", auth.Validate(auth.RolesAdmin()...), byIdHelp(repo))

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
		if err := ctx.ShouldBind(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		if !data.IsHelp {
			result, err := repo.FindQuestion(ctx, data)
			routes.Response(ctx, result, err)
			return
		}
		result, err := repo.FindHelp(ctx, data)
		routes.Response(ctx, result, err)
	}
}

func createHelp(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var save entity.SaveHelp
		if err := ctx.ShouldBind(&save); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		data, err := repo.CreateHelp(ctx, save)
		routes.Response(ctx, data, err)
	}
}

func createQuestion(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var save entity.SaveQuestion
		if err := ctx.ShouldBind(&save); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		data, err := repo.CreateQuestion(ctx, save)
		routes.Response(ctx, data, err)
	}
}
func updateHelp(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var save entity.SaveHelp
		if err := ctx.ShouldBind(&save); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		data, err := repo.UpdateHelp(ctx, id, save)
		routes.Response(ctx, data, err)
	}
}
func answerQuestion(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var req entity.Answer
		if err := ctx.ShouldBind(&req); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		data, err := repo.AnswerQuestion(ctx, id, req)
		routes.Response(ctx, data, err)
	}
}
func deleteHelp(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		data, err := repo.ByIdHelp(ctx, id)
		if err != nil {
			routes.Response(ctx, nil, err)
			return
		}
		if auth.GetUser(ctx).Roles == int(auth.SYSTEM_ADMIN) || auth.GetUser(ctx).Id == data.Creator.Id {
			data, err := repo.DeleteHelp(ctx, id)
			routes.Response(ctx, data, err)
			return
		}
		routes.Response(ctx, nil, errors.Forbidden(nil))
	}
}

func byIdHelp(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		data, err := repo.ByIdHelp(ctx, id)
		routes.Response(ctx, data, err)
	}
}
