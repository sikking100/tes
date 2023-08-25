package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/product/entity"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type repository interface {
	FindPriceList(ctx context.Context) ([]*entity.PriceList, error)
	FindPriceListById(ctx context.Context, id string) (*entity.PriceList, error)
	SavePriceList(ctx context.Context, id string, data entity.SavePriceList) (*entity.PriceList, error)
	DeletePriceList(ctx context.Context, id string) (*entity.PriceList, error)
	FindCatalog(ctx context.Context, data entity.FindCatalog) ([]*entity.Product, error)
	FindCatalogById(ctx context.Context, id string) (*entity.Product, error)
	SaveCatalog(ctx context.Context, id string, data entity.SaveCatalog) (*entity.Product, error)
	UpdateCatalogImageUrl(ctx context.Context, id string, imageUrl string) error
	DeleteCatalog(ctx context.Context, id string) (*entity.Product, error)
	FindProduct(ctx context.Context, data entity.FindProduct) (*entity.PageProduct, error)
	FindProductImportPrice(ctx context.Context, branchId string) ([]*entity.Product, error)
	FindProductImportQty(ctx context.Context, branchId string) ([]*entity.Product, error)
	FindProductById(ctx context.Context, id string) (*entity.Product, error)
	SaveProduct(ctx context.Context, id string, data *entity.SaveProduct) (*entity.Product, error)
	AddQtyProduct(ctx context.Context, id string, data entity.AddQty) (*entity.Product, error)
	TransferQtyProduct(ctx context.Context, branchId, id string, data entity.TransferQty) (*entity.Product, error)
	DeleteProduct(ctx context.Context, branchId, id string) (*entity.Product, error)
	FindHistory(ctx context.Context, data entity.FindHistory) (*entity.PageHistoryQty, error)
	FindHistoryById(ctx context.Context, id primitive.ObjectID) (*entity.HistoryQty, error)
	FindSalesProduct(ctx context.Context, branchId string) ([]*entity.SalesProduct, error)
	UpdateSalesProduct(ctx context.Context, data entity.SaveSalesProduct) (*entity.Product, error)
}
