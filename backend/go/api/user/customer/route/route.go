package route

import (
	"fmt"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/user/customer/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
)

func NewRoute(engine *gin.Engine, repo repository) {
	apiCustomer := engine.Group("/user-customer/v1")
	apiCustomer.GET("", auth.Validate(auth.RolesEmployee()...), findCustomer(repo))
	apiCustomer.POST("", createCustomer(repo))
	apiCustomer.PUT("", auth.Validate(auth.RolesEmployee()...), findOrCreateCustomer(repo))
	apiCustomer.GET("/:id", auth.Validate(), findCustomerById(repo))
	apiCustomer.PUT("/:id", auth.Validate(auth.CUSTOMER), updateAccount(repo))
	apiCustomer.PATCH("/:id", auth.Validate(auth.CUSTOMER, auth.SALES_ADMIN), updateBusiness(repo))
	apiCustomer.POST("/event/new-image", updateImage(repo))

	apiApply := engine.Group("/user-customer-apply/v1")
	apiApply.GET("", auth.Validate(auth.RolesEmployee()...), findApply(repo))
	apiApply.POST("", auth.Validate(auth.BRANCH_ADMIN), createBusiness(repo))
	apiApply.GET("/:id", auth.Validate(), findApplyById(repo))
	apiApply.POST("/new-business", auth.Validate(), applyNewBusiness(repo))
	apiApply.POST("/new-limit", auth.Validate(auth.SALES_ADMIN), applyNewLimit(repo))
	apiApply.POST("/approve", auth.Validate(auth.RolesEmployee()...), approve(repo))
	apiApply.POST("/reject", auth.Validate(auth.RolesEmployee()...), reject(repo))
}
func getParamId(ctx *gin.Context) (string, error) {
	id := ctx.Param("id")
	if id == "" {
		return "", fmt.Errorf("id required")
	}
	return id, nil
}
func findCustomer(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.FindCustomer
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindCustomer(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func createCustomer(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.SaveAccount
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.CreateCustomer(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func findOrCreateCustomer(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.SaveAccount
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindOrCreateCustomer(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func findCustomerById(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := getParamId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		if auth.GetUser(ctx).Roles == int(auth.CUSTOMER) {
			id = auth.GetUser(ctx).Id
		}
		result, err := repo.FindCustomerById(ctx, id)
		routes.Response(ctx, result, err)

	}
}
func updateAccount(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.SaveAccount
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.UpdateAccount(ctx, auth.GetUser(ctx).Id, data)
		routes.Response(ctx, result, err)
	}
}
func updateBusiness(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := getParamId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.UpdateBusiness
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		if auth.GetUser(ctx).Roles == int(auth.CUSTOMER) {
			id = auth.GetUser(ctx).Id
		}
		result, err := repo.UpdateBusiness(ctx, id, data)
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
		// bucket-name/customer/{id}/thumbs/{file-name.ext}/{file-id}
		lPath := strings.Split(data.Id, "/")
		switch {
		case len(lPath) != 6 || !strings.HasPrefix(data.ContentType, "image"):
			routes.Response(ctx, data.Id, nil)
			return
		case lPath[1] != "customer" || lPath[3] != "thumbs":
			routes.Response(ctx, data.Id, nil)
			return
		}
		url := fmt.Sprintf("https://storage.googleapis.com/%s", strings.Join(lPath[:len(lPath)-1], "/"))
		routes.Response(ctx, data.Id, repo.UpdateImage(ctx, lPath[2], url))
	}
}
func findApply(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.FindApply
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindApply(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func createBusiness(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.CreateBusiness
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.CreateBusiness(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func findApplyById(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := getParamId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		if auth.GetUser(ctx).Roles == int(auth.CUSTOMER) {
			id = auth.GetUser(ctx).Id
		}
		result, err := repo.FindApplyById(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func applyNewBusiness(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.ApplyNewBusiness
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.ApplyNewBusiness(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func applyNewLimit(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.ApplyNewLimit
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.ApplyNewLimit(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func approve(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.Approve
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		if auth.GetUser(ctx).Roles == int(auth.SALES_ADMIN) {
			result, err := repo.ApproveBySalesAdmin(ctx, data)
			routes.Response(ctx, result, err)
			return
		}

		result, err := repo.Approve(ctx, auth.GetUser(ctx).Id, data)
		routes.Response(ctx, result, err)
	}
}
func reject(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.Reject
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		if auth.GetUser(ctx).Roles == int(auth.SALES_ADMIN) {
			result, err := repo.RejectBySalesAdmin(ctx, data)
			routes.Response(ctx, result, err)
			return
		}
		result, err := repo.Reject(ctx, auth.GetUser(ctx).Id, data)
		routes.Response(ctx, result, err)
	}
}
