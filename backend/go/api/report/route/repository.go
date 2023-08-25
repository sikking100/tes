package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/report/entity"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type repository interface {
	Create(ctx context.Context, save entity.Save) (*entity.Report, error)
	Delete(ctx context.Context, id primitive.ObjectID) (*entity.Report, error)
	ById(ctx context.Context, id primitive.ObjectID) (*entity.Report, error)
	Find(ctx context.Context, data entity.Find) (*entity.Page, error)
	UpdateImageUrl(ctx context.Context, id primitive.ObjectID, url string) error
	UpdateFilePath(ctx context.Context, id primitive.ObjectID, path string) error
}
