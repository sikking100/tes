package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/location/branch/entity"
)

type repository interface {
	Find(ctx context.Context, data entity.Find) (*entity.Page, error)
	FindByNear(ctx context.Context, lngLat []float64) (*entity.Branch, error)
	FindById(ctx context.Context, id string) (*entity.Branch, error)
	Save(ctx context.Context, id string, data entity.SaveBranch) (*entity.Branch, error)
	Delete(ctx context.Context, id string) (*entity.Branch, error)
	UpdateWarehouse(ctx context.Context, id string, data []*entity.SaveWarehouse) (*entity.Branch, error)
}
