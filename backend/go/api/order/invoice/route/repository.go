package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/order/invoice/entity"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type repository interface {
	Find(ctx context.Context, data entity.Find) (*entity.Page, error)
	FindById(ctx context.Context, id primitive.ObjectID) (*entity.Invoice, error)
	MakePayment(ctx context.Context, id primitive.ObjectID) (*entity.Invoice, error)
	CompletePayment(ctx context.Context, id primitive.ObjectID, data entity.CompletePayment) (*entity.Invoice, error)
	FindByOrderId(ctx context.Context, orderId primitive.ObjectID) ([]*entity.Invoice, error)
	FindReport(ctx context.Context, data entity.FindReport) ([]*entity.Invoice, error)
	Callback(ctx context.Context, data entity.XenditCallback) error
}
