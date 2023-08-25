package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/brand/entity"
)

type repository interface {
	Find(ctx context.Context) ([]*entity.Brand, error)
	Save(ctx context.Context, id string, name string) (*entity.Brand, error)
	UpdateImage(ctx context.Context, id, url string) error
	FindById(ctx context.Context, id string) (*entity.Brand, error)
	Delete(ctx context.Context, id string) (*entity.Brand, error)
}
