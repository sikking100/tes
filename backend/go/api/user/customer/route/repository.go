package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/user/customer/entity"
)

type repository interface {
	FindCustomer(ctx context.Context, data entity.FindCustomer) (*entity.PageCustomer, error)
	CreateCustomer(ctx context.Context, data entity.SaveAccount) (*entity.Customer, error)
	FindOrCreateCustomer(ctx context.Context, data entity.SaveAccount) (*entity.Customer, error)
	FindCustomerById(ctx context.Context, id string) (*entity.Customer, error)
	UpdateAccount(ctx context.Context, id string, data entity.SaveAccount) (*entity.Customer, error)
	UpdateBusiness(ctx context.Context, id string, data entity.UpdateBusiness) (*entity.Customer, error)
	UpdateImage(ctx context.Context, id string, imageUrl string) error
	FindApply(ctx context.Context, data entity.FindApply) (*entity.PageApply, error)
	CreateBusiness(ctx context.Context, data entity.CreateBusiness) (*entity.Apply, error)
	FindApplyById(ctx context.Context, id string) (*entity.Apply, error)
	ApplyNewBusiness(ctx context.Context, data entity.ApplyNewBusiness) (*entity.Apply, error)
	ApplyNewLimit(ctx context.Context, data entity.ApplyNewLimit) (*entity.Apply, error)
	ApproveBySalesAdmin(ctx context.Context, data entity.Approve) (*entity.Apply, error)
	RejectBySalesAdmin(ctx context.Context, data entity.Reject) (*entity.Apply, error)
	Approve(ctx context.Context, userId string, data entity.Approve) (*entity.Apply, error)
	Reject(ctx context.Context, userId string, data entity.Reject) (*entity.Apply, error)
}
