package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/activity/entity"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type repository interface {
	FindActivity(ctx context.Context, data entity.Find) (*entity.Page, error)
	FindActivityById(ctx context.Context, id primitive.ObjectID) (*entity.Activity, error)
	CreateActivity(ctx context.Context, data entity.SaveActivity) (*entity.Activity, error)
	UpdateActivity(ctx context.Context, id primitive.ObjectID, data entity.SaveActivity) (*entity.Activity, error)
	DeleteActivity(ctx context.Context, id primitive.ObjectID, creatorId string) (*entity.Activity, error)
	UpdateImage(ctx context.Context, id primitive.ObjectID, path, url string) error
	FindComment(ctx context.Context, activityId primitive.ObjectID) ([]*entity.Comment, error)
	FindCommentById(ctx context.Context, id primitive.ObjectID) (*entity.Comment, error)
	CreateComment(ctx context.Context, data entity.SaveComment) (*entity.Comment, error)
	UpdateComment(ctx context.Context, id primitive.ObjectID, data entity.SaveComment) (*entity.Comment, error)
	DeleteComment(ctx context.Context, id primitive.ObjectID, creatorId string) (*entity.Comment, error)
}
