package route

import (
	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/order/order/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func NewRoute(engine *gin.Engine, repo repository) {
	orderApi := engine.Group("/order/v1")
	orderApi.GET("", auth.Validate(), find(repo))
	orderApi.POST("", auth.Validate(), create(repo))
	orderApi.GET("/:id", auth.Validate(), findById(repo))
	orderApi.PUT("/:id", auth.Validate(auth.SALES_ADMIN, auth.BRANCH_SALES_ADMIN), cancel(repo))
	orderApi.GET("/find/report", auth.Validate(auth.RolesEmployee()...), findReport(repo))
	orderApi.GET("/find/performance", auth.Validate(auth.RolesEmployee()...), findPerformance(repo))
	orderApi.GET("/transaction/last-month", auth.Validate(), findTransactionLastMonth(repo))
	orderApi.GET("/transaction/per-month", auth.Validate(), findTransactionPerMonth(repo))
	applyApi := engine.Group("/order-apply/v1")
	applyApi.GET("", auth.Validate(auth.RolesEmployee()...), findApply(repo))
	applyApi.GET("/:id", auth.Validate(auth.RolesEmployee()...), findApplyById(repo))
	applyApi.PUT("/:id", auth.Validate(auth.RolesEmployee()...), approve(repo))
	applyApi.PATCH("/:id", auth.Validate(auth.RolesEmployee()...), reject(repo))

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
func create(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.Create
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Create(ctx, data)
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
func cancel(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.Cancel
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.CancelOrder(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
func findReport(repo repository) gin.HandlerFunc {
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
func findPerformance(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.FindPerformace
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindPerformace(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func findTransactionLastMonth(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		result, err := repo.TransactionLastMonth(ctx, ctx.Query("customerId"))
		routes.Response(ctx, result, err)
	}
}
func findTransactionPerMonth(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		result, err := repo.TransactionPerMonth(ctx, ctx.Query("customerId"))
		routes.Response(ctx, result, err)
	}
}
func findApply(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.FindApply
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindApply(ctx, auth.GetUser(ctx).Id, data)
		routes.Response(ctx, result, err)
	}
}
func findApplyById(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindApplyById(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func approve(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.MakeApprove
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Approve(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
func reject(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.MakeApprove
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Reject(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
