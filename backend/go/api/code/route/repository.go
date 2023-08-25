package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/code/entity"
)

type repository interface {
	Find(ctx context.Context, data entity.Find) (*entity.Page, error)
	FindById(ctx context.Context, id string) (*entity.Code, error)
	Save(ctx context.Context, id string, data entity.Save) (*entity.Code, error)
	Delete(ctx context.Context, id string) (*entity.Code, error)
}
