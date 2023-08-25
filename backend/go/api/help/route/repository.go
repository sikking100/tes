package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/help/entity"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type repository interface {
	CreateHelp(ctx context.Context, save entity.SaveHelp) (*entity.Help, error)
	CreateQuestion(ctx context.Context, save entity.SaveQuestion) (*entity.Help, error)
	UpdateHelp(ctx context.Context, id primitive.ObjectID, data entity.SaveHelp) (*entity.Help, error)
	AnswerQuestion(ctx context.Context, id primitive.ObjectID, answer entity.Answer) (*entity.Help, error)
	DeleteHelp(ctx context.Context, id primitive.ObjectID) (*entity.Help, error)
	ByIdHelp(ctx context.Context, id primitive.ObjectID) (*entity.Help, error)
	FindHelp(ctx context.Context, data entity.Find) (*entity.Page, error)
	FindQuestion(ctx context.Context, data entity.Find) (*entity.Page, error)
}
