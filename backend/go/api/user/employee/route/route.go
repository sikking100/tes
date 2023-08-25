package route

import (
	"fmt"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/user/employee/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
)

func NewRoute(engine *gin.Engine, repo repository) {
	api := engine.Group("/user-employee/v1")
	api.GET("", auth.Validate(auth.RolesEmployee()...), find(repo))
	api.GET("/approver/credit", auth.Validate(auth.SALES_ADMIN), findApproverCredit(repo))
	api.GET("/approver/top", auth.Validate(), findApproverTop(repo))
	api.GET("/:id", auth.Validate(auth.RolesEmployee()...), findById(repo))
	api.POST("/:id", auth.Validate(auth.SYSTEM_ADMIN, auth.BRANCH_ADMIN, auth.BRANCH_WAREHOUSE_ADMIN), save(repo))
	api.PUT("/:id", auth.Validate(auth.RolesEmployee()...), updateAccount(repo))
	api.DELETE("/:id", auth.Validate(auth.SYSTEM_ADMIN, auth.BRANCH_ADMIN, auth.BRANCH_WAREHOUSE_ADMIN), delete(repo))
	api.POST("/event/image-url", updateImageUrl(repo))
}
func getParamId(ctx *gin.Context) (string, error) {
	if id := ctx.Param("id"); id != "" {
		return id, nil
	}
	return "", fmt.Errorf("id required")
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
func findApproverCredit(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.FindApprover
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindApproverCredit(ctx, auth.GetUser(ctx).Id, data)
		routes.Response(ctx, result, err)

	}
}
func findApproverTop(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.FindApprover
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindApproverTop(ctx, data)
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
func save(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := getParamId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.Save
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		if err := data.Save(); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		user := auth.GetUser(ctx)
		if user.Roles == int(auth.BRANCH_ADMIN) || user.Roles == int(auth.BRANCH_WAREHOUSE_ADMIN) {
			result, err := repo.SaveInBranch(ctx, id, data)
			routes.Response(ctx, result, err)
			return
		}
		result, err := repo.Save(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
func updateAccount(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.UpdateAccount
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.UpdateAccount(ctx, auth.GetUser(ctx).Id, data)
		routes.Response(ctx, result, err)
	}
}
func delete(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := getParamId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		user := auth.GetUser(ctx)
		if user.Roles == int(auth.BRANCH_ADMIN) || user.Roles == int(auth.BRANCH_WAREHOUSE_ADMIN) {
			result, err := repo.DeleteInBranch(ctx, id, user.LocationId)
			routes.Response(ctx, result, err)
			return
		}
		result, err := repo.Delete(ctx, id)
		routes.Response(ctx, result, err)

	}
}
func updateImageUrl(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		data := struct {
			Id          string `json:"id" binding:"required"`
			ContentType string `json:"contentType" binding:"required"`
		}{}
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, "invalid event data", nil)
			return
		}
		// bucket-name/employee/{id}/thumbs/{fileName.ext}/{file-id}
		lPath := strings.Split(data.Id, "/")
		switch {
		case len(lPath) != 6 || !strings.HasPrefix(data.ContentType, "image"):
			routes.Response(ctx, data.Id, nil)
			return
		case lPath[1] != "employee" || lPath[3] != "thumbs":
			routes.Response(ctx, data.Id, nil)
			return
		}
		url := fmt.Sprintf("https://storage.googleapis.com/%s", strings.Join(lPath[:len(lPath)-1], "/"))
		routes.Response(ctx, data, repo.UpdateImageUrl(ctx, lPath[2], url))
	}
}
