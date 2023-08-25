package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/user/employee/entity"
)

type repository interface {
	Find(ctx context.Context, data entity.Find) (*entity.Page, error)
	FindApproverCredit(ctx context.Context, userId string, data entity.FindApprover) ([]*entity.UserApprover, error)
	FindApproverTop(ctx context.Context, data entity.FindApprover) ([]*entity.UserApprover, error)
	FindById(ctx context.Context, id string) (*entity.Employee, error)
	Save(ctx context.Context, id string, data entity.Save) (*entity.Employee, error)
	SaveInBranch(ctx context.Context, id string, data entity.Save) (*entity.Employee, error)
	UpdateAccount(ctx context.Context, id string, data entity.UpdateAccount) (*entity.Employee, error)
	UpdateImageUrl(ctx context.Context, id, imageUrl string) error
	Delete(ctx context.Context, id string) (*entity.Employee, error)
	DeleteInBranch(ctx context.Context, id, locationId string) (*entity.Employee, error)
}
