package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/location/region/entity"
)

type repository interface {
	Find(ctx context.Context, data entity.Find) (*entity.Page, error)

	Save(ctx context.Context, id string, name string) (*entity.Region, error)

	FindById(ctx context.Context, id string) (*entity.Region, error)

	Delete(ctx context.Context, id string) (*entity.Region, error)
}
