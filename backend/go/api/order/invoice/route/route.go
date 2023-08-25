package route

import (
	"fmt"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/order/invoice/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func NewRoute(engine *gin.Engine, repo repository) {
	apiDelivery := engine.Group("/invoice/v1")
	apiDelivery.GET("", auth.Validate(), find(repo))
	apiDelivery.GET("/:id", auth.Validate(), findById(repo))
	apiDelivery.POST("/:id/make-payment", auth.Validate(), makePayment(repo))
	apiDelivery.POST("/:id/complete-payment", auth.Validate(auth.BRANCH_FINANCE_ADMIN, auth.FINANCE_ADMIN), completePayment(repo))
	apiDelivery.GET("/:id/by-order", auth.Validate(), findByOrderId(repo))
	apiDelivery.GET("/find/report", auth.Validate(auth.FINANCE_ADMIN, auth.BRANCH_FINANCE_ADMIN), report(repo))
	apiDelivery.POST("/callback", callback(repo))
}
func paramId(ctx *gin.Context) (primitive.ObjectID, error) {
	id, err := primitive.ObjectIDFromHex(ctx.Param("id"))
	if err != nil {
		return primitive.NilObjectID, err
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
func findById(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindById(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func findByOrderId(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindByOrderId(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func makePayment(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.MakePayment(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func completePayment(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.CompletePayment
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.CompletePayment(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
func report(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.FindReport
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindReport(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func callback(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		if ctx.GetHeader("x-callback-token") != os.Getenv("XENDIT_CALLBACK_TOKEN") {
			routes.Response(ctx, nil, errors.UnAuthorized(fmt.Errorf("invalid token")))
			return
		}
		var data entity.XenditCallback
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, err.Error(), nil)
			return
		}
		routes.Response(ctx, data.Id, repo.Callback(ctx, data))
	}
}
