package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/order/delivery/entity"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type repository interface {
	Find(ctx context.Context, data entity.Find) (*entity.Page, error)
	FindById(ctx context.Context, id primitive.ObjectID) (*entity.Delivery, error)
	FindByOrderId(ctx context.Context, orderId primitive.ObjectID) ([]*entity.Delivery, error)
	CreatePackingList(ctx context.Context, id primitive.ObjectID, data entity.CreatePackingList) (*entity.Delivery, error)
	CourierInteral(ctx context.Context, id primitive.ObjectID, data entity.Courier) (*entity.Delivery, error)
	CourierExternal(ctx context.Context, id primitive.ObjectID, data entity.BookingCourierExternal) (*entity.BookingCourierExternal, error)
	UpdateQty(ctx context.Context, id primitive.ObjectID, data entity.UpdateQty) (*entity.Delivery, error)
	UpdateToDeliver(ctx context.Context, id primitive.ObjectID, courierId string) (*entity.Delivery, error)
	FindPackingListWarehouse(ctx context.Context, data entity.FindPackingListWarehouse) ([]*entity.PackingListWarehouse, error)
	FindPackingListCourier(ctx context.Context, data entity.FindPackingListCourier) ([]*entity.PackingListCourier, error)
	FindPackingListDestination(ctx context.Context, data entity.FindPackingListDestination) ([]*entity.PackingListDestination, error)
	PackingListLoaded(ctx context.Context, data entity.PackingListLoaded) (*entity.PackingListLoaded, error)
	Restock(ctx context.Context, deliveryId primitive.ObjectID, data entity.Restock) (*entity.Restock, error)
	Complete(ctx context.Context, deliveryId primitive.ObjectID, data entity.Complete) (*entity.Delivery, error)
	FindProduct(ctx context.Context, data entity.FindProduct) ([]*entity.Product, error)
	GoSendPrice(ctx context.Context, data entity.GetGoSendPrice) (int, error)
	GoSendCallback(ctx context.Context, data entity.GoSendCallback) error
}
