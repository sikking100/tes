package route

import (
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/grocee-project/dairyfood/backend/go/api/product/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"github.com/grocee-project/dairyfood/backend/go/pkg/routes"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func NewRoute(repo repository) *http.Server {
	route := routes.NewRoutes()
	apiPriceList := route.Group("/product-pricelist/v1")
	apiPriceList.GET("", auth.Validate(), findPriceList(repo))
	apiPriceList.GET("/:id", auth.Validate(), findPriceListById(repo))
	apiPriceList.POST("/:id", auth.Validate(auth.SYSTEM_ADMIN), savePriceList(repo))
	apiPriceList.DELETE("/:id", auth.Validate(auth.SYSTEM_ADMIN), deletePriceList(repo))

	apiCatalog := route.Group("/product-catalog/v1")
	apiCatalog.GET("", auth.Validate(auth.SYSTEM_ADMIN, auth.SALES_ADMIN, auth.BRANCH_SALES_ADMIN, auth.FINANCE_ADMIN, auth.BRANCH_FINANCE_ADMIN), findCatalog(repo))
	apiCatalog.GET("/:id", auth.Validate(auth.SYSTEM_ADMIN, auth.SALES_ADMIN, auth.BRANCH_SALES_ADMIN, auth.FINANCE_ADMIN, auth.BRANCH_FINANCE_ADMIN), findCatalogById(repo))
	apiCatalog.POST("/:id", auth.Validate(auth.SYSTEM_ADMIN, auth.SALES_ADMIN), saveCatalog(repo))
	apiCatalog.DELETE("/:id", auth.Validate(auth.SYSTEM_ADMIN), deleteCatalog(repo))
	apiCatalog.POST("/event/image-url", updateCatalogImageUrl(repo))

	apiInBranch := route.Group("/product-branch/v1")
	apiInBranch.GET("", auth.Validate(), findProductInBranch(repo))
	apiInBranch.GET("/:id/find-import-price", auth.Validate(auth.SYSTEM_ADMIN), findProductImportPrice(repo))
	apiInBranch.GET("/:id/find-import-qty", auth.Validate(auth.SYSTEM_ADMIN, auth.BRANCH_WAREHOUSE_ADMIN), findProductImportQty(repo))
	apiInBranch.GET("/:id", auth.Validate(), findProductInBranchById(repo))
	apiInBranch.POST("/:id", auth.Validate(auth.SYSTEM_ADMIN), saveProductInBranchPrice(repo))
	apiInBranch.PUT("/:id", auth.Validate(auth.SYSTEM_ADMIN), addQtyProductInBranch(repo))
	apiInBranch.PATCH("/:id", auth.Validate(auth.BRANCH_WAREHOUSE_ADMIN), transferQtyProductInBranch(repo))
	apiInBranch.DELETE("/:id", auth.Validate(auth.BRANCH_WAREHOUSE_ADMIN, auth.BRANCH_ADMIN), deleteProductInBranch(repo))

	apiHistory := route.Group("/product-history/v1")
	apiHistory.GET("", auth.Validate(auth.SYSTEM_ADMIN, auth.BRANCH_WAREHOUSE_ADMIN), findHistory(repo))
	apiHistory.GET("/:id", auth.Validate(auth.SYSTEM_ADMIN, auth.BRANCH_WAREHOUSE_ADMIN), findHistoryById(repo))

	apiSales := route.Group("/product-sales/v1")
	apiSales.GET("", auth.Validate(auth.BRANCH_SALES_ADMIN, auth.SALES_ADMIN), findSales(repo))
	apiSales.PUT("", auth.Validate(auth.BRANCH_SALES_ADMIN, auth.SALES_ADMIN), saveSalesProduct(repo))
	srv := &http.Server{
		Addr:    ":" + os.Getenv("PORT"),
		Handler: route,
	}
	return srv
}
func paramId(ctx *gin.Context) (string, error) {
	id := ctx.Param("id")
	if id == "" {
		return "", fmt.Errorf("id required")
	}
	return id, nil
}
func findPriceList(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		result, err := repo.FindPriceList(ctx)
		routes.Response(ctx, result, err)
	}
}
func findPriceListById(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindPriceListById(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func savePriceList(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.SavePriceList
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.SavePriceList(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
func deletePriceList(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.DeletePriceList(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func findCatalog(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.FindCatalog
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindCatalog(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func findCatalogById(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindCatalogById(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func saveCatalog(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.SaveCatalog
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.SaveCatalog(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
func deleteCatalog(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.DeleteCatalog(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func updateCatalogImageUrl(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		data := struct {
			Id          string `json:"id" binding:"required"`
			ContentType string `json:"contentType" binding:"required"`
		}{}
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, "invalid event data", nil)
			return
		}
		// bucket-name/product/{id}/thumbs/{file-name.ext}/{file-id}
		lPath := strings.Split(data.Id, "/")
		switch {
		case len(lPath) != 6 || !strings.HasPrefix(data.ContentType, "image"):
			routes.Response(ctx, data.Id, nil)
			return
		case lPath[1] != "product" || lPath[3] != "thumbs":
			routes.Response(ctx, data.Id, nil)
			return
		}
		url := fmt.Sprintf("https://storage.googleapis.com/%s", strings.Join(lPath[:len(lPath)-1], "/"))
		routes.Response(ctx, data, repo.UpdateCatalogImageUrl(ctx, lPath[2], url))
	}
}
func findProductInBranch(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.FindProduct
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindProduct(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func findProductImportPrice(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindProductImportPrice(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func findProductImportQty(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindProductImportQty(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func findProductInBranchById(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindProductById(ctx, id)
		routes.Response(ctx, result, err)
	}
}
func saveProductInBranchPrice(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}

		var data entity.SaveProduct
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.SaveProduct(ctx, id, &data)
		routes.Response(ctx, result, err)
	}
}
func addQtyProductInBranch(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.AddQty
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.AddQtyProduct(ctx, id, data)
		routes.Response(ctx, result, err)
	}
}
func transferQtyProductInBranch(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		var data entity.TransferQty
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.TransferQtyProduct(ctx, auth.GetUser(ctx).LocationId, id, data)
		routes.Response(ctx, result, err)
	}
}
func deleteProductInBranch(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := paramId(ctx)
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.DeleteProduct(ctx, auth.GetUser(ctx).LocationId, id)
		routes.Response(ctx, result, err)
	}
}
func findHistory(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.FindHistory
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindHistory(ctx, data)
		routes.Response(ctx, result, err)
	}
}
func findHistoryById(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		id, err := primitive.ObjectIDFromHex(ctx.Param("id"))
		if err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindHistoryById(ctx, id)
		routes.Response(ctx, result, err)
	}
}

func findSales(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		data := struct {
			BranchId string `form:"branchId" binding:"required"`
		}{}
		if err := ctx.ShouldBindQuery(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.FindSalesProduct(ctx, data.BranchId)
		routes.Response(ctx, result, err)
	}
}
func saveSalesProduct(repo repository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		var data entity.SaveSalesProduct
		if err := ctx.ShouldBindJSON(&data); err != nil {
			routes.Response(ctx, nil, errors.BadRequest(err))
			return
		}
		result, err := repo.UpdateSalesProduct(ctx, data)
		routes.Response(ctx, result, err)
	}
}
