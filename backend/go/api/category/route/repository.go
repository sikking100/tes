package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/category/entity"
)

type repository interface {
	Find(ctx context.Context) ([]*entity.Category, error)
	Save(ctx context.Context, id string, data entity.Save) (*entity.Category, error)
	FindById(ctx context.Context, id string) (*entity.Category, error)
	Delete(ctx context.Context, id string) (*entity.Category, error)
}
