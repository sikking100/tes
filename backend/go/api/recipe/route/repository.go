package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/recipe/entity"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type repository interface {
	Create(ctx context.Context, save entity.Save) (*entity.Recipe, error)
	Update(ctx context.Context, id primitive.ObjectID, data entity.Save) (*entity.Recipe, error)
	Delete(ctx context.Context, id primitive.ObjectID) (*entity.Recipe, error)
	Find(ctx context.Context, data entity.Find) (*entity.Page, error)
	Categories(ctx context.Context) ([]string, error)
	ById(ctx context.Context, id primitive.ObjectID) (*entity.Recipe, error)
	UpdateImage(ctx context.Context, id primitive.ObjectID, url string) error
}
