package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/order/order/entity"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type repository interface {
	Find(ctx context.Context, data entity.Find) (*entity.Page, error)
	Create(ctx context.Context, data entity.Create) (*entity.Order, error)
	FindById(ctx context.Context, id primitive.ObjectID) (*entity.Order, error)
	CancelOrder(ctx context.Context, id primitive.ObjectID, data entity.Cancel) (*entity.Order, error)
	FindReport(ctx context.Context, data entity.FindReport) ([]*entity.Report, error)
	FindPerformace(ctx context.Context, data entity.FindPerformace) ([]*entity.Performance, error)
	TransactionLastMonth(ctx context.Context, customerId string) (float64, error)
	TransactionPerMonth(ctx context.Context, customerId string) (float64, error)
	FindApply(ctx context.Context, userId string, data entity.FindApply) ([]*entity.Apply, error)
	FindApplyById(ctx context.Context, id primitive.ObjectID) (*entity.Apply, error)
	Approve(ctx context.Context, id primitive.ObjectID, data entity.MakeApprove) (*entity.Apply, error)
	Reject(ctx context.Context, id primitive.ObjectID, data entity.MakeApprove) (*entity.Apply, error)
}
