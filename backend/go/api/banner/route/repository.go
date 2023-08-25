package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/banner/entity"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type repository interface {
	Find(ctx context.Context, mType int) ([]*entity.Banner, error)
	Create(ctx context.Context, mType int, imageUrl string) error
	Delete(ctx context.Context, id primitive.ObjectID) (*entity.Banner, error)
}
