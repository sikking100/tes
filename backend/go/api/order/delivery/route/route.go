package route

import (
	"fmt"
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/order/delivery/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func NewRoute(engine *gin.Engine, repo repository) {
	apiDelivery := engine.Group("/delivery/v1")
	apiDelivery.GET("", auth.Validate(), find(repo))
	apiDelivery.GET("/:id", auth.Validate(), findById(repo))
	apiDelivery.GET("/:id/by-order", auth.Validate(), findByOrderId(repo))
	apiDelivery.PUT("/:id/packing-list", auth.Validate(auth.BRANCH_WAREHOUSE_ADMIN), createPackingList(repo))
	apiDelivery.PUT("/:id/courier-internal", auth.Validate(auth.BRANCH_WAREHOUSE_ADMIN), courierInternal(repo))
	apiDelivery.PUT("/:id/courier-external", auth.Validate(auth.BRANCH_WAREHOUSE_ADMIN), courierExternal(repo))
	apiDelivery.PUT("/:id/update-qty", auth.Validate(auth.BRANCH_WAREHOUSE_ADMIN), updateQty(repo))
	apiDelivery.PUT("/:id/deliver", auth.Validate(auth.COURIER), updateToDeliver(repo))
	apiDelivery.PUT("/:id/restock", auth.Validate(auth.BRANCH_WAREHOUSE_ADMIN), restock(repo))
	apiDelivery.PUT("/:id/complete", auth.Validate(auth.COURIER), complete(repo))
	apiDelivery.GET("/paking-list/warehouse", auth.Validate(auth.BRANCH_WAREHOUSE_ADMIN), findPackingListWarehouse(repo))
	apiDelivery.GET("/paking-list/courier", auth.Validate(auth.COURIER), findPackingListCourier(repo))
	apiDelivery.GET("/paking-list/destination", auth.Validate(auth.COURIER), findPackingListDestination(repo))
	apiDelivery.PUT("/paking-list/loaded", auth.Validate(auth.COURIER), loaded(repo))
	apiDelivery.GET("/product/find", auth.Validate(auth.BRANCH_WAREHOUSE_ADMIN, auth.COURIER), findProduct(repo))
	apiDelivery.GET("/gosend/price", auth.Validate(), goSendPrice(repo))
	apiDelivery.POST("/gosend-callback", goSendCallback(repo))
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
		if data.BranchId == "" && data.CourierId == "" {
			routes.Response(ctx, nil, errors.BadRequest(fmt.Errorf("branch id or courier id required")))
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
func createPackingList(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.CreatePackingList
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.CreatePackingList(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
func courierInternal(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.Courier
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.CourierInteral(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
func courierExternal(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.BookingCourierExternal
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.CourierExternal(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
func updateQty(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.UpdateQty
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.UpdateQty(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
func updateToDeliver(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.UpdateToDeliver(ctx, id, auth.GetUser(ctx).Id)
		routes.Response(ctx, result, err)
	}
}
func loaded(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.PackingListLoaded
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.PackingListLoaded(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func restock(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.Restock
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Restock(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
func complete(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.Complete
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.Complete(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
func findPackingListWarehouse(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.FindPackingListWarehouse
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindPackingListWarehouse(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func findPackingListCourier(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.FindPackingListCourier
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindPackingListCourier(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func findPackingListDestination(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.FindPackingListDestination
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindPackingListDestination(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func findProduct(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.FindProduct
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		if data.WarehouseId == "" && data.CourierId == "" {
			routes.Response(ctx, nil, errors.BadRequest(fmt.Errorf("warehouse id or courier id required")))
			return
		} else if data.WarehouseId != "" && data.BranchId == "" {
			routes.Response(ctx, nil, errors.BadRequest(fmt.Errorf("branch id required")))
			return
		}
		result, err := repo.FindProduct(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func goSendPrice(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.GetGoSendPrice
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.GoSendPrice(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func goSendCallback(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		if ctx.GetHeader("x-callback-token") != os.Getenv("GOSEND_CALLBACK_TOKEN") {
			routes.Response(ctx, nil, errors.UnAuthorized(fmt.Errorf("invalid token")))
			return
		}
		var data entity.GoSendCallback
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		// ctx.
		log.Printf("%+v\n", data)
		routes.Response(ctx, data, repo.GoSendCallback(ctx, data))
	}
}
