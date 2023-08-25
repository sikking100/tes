package repository

import (
	"context"
	"os"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/help/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Repository struct {
	dbHelp *mongo.Collection
}

func NewRepository() (*mongo.Client, *Repository, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	client, err := mongo.Connect(ctx, options.Client().ApplyURI(os.Getenv("DB_URI")))
	if err != nil {
		return nil, nil, err
	}
	dbHelp := client.Database("help").Collection("help")
	if _, err := dbHelp.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{Keys: bson.D{{Key: "updatedAt", Value: -1}}},
		{Keys: bson.D{{Key: "topic", Value: "text"}, {Key: "question", Value: "text"}}},
	}); err != nil {
		return nil, nil, err
	}
	return client, &Repository{dbHelp: dbHelp}, nil
}

func dbError(err error) error {
	switch {
	case err == nil:
		return nil
	case errors.IsError(err):
		return err
	case mongo.IsDuplicateKeyError(err):
		return errors.Conflict(err)
	case err == mongo.ErrNoDocuments:
		return errors.NotFound(err)
	default:
		return errors.Internal(err)
	}
}
func (repo *Repository) CreateHelp(ctx context.Context, save entity.SaveHelp) (*entity.Help, error) {
	help := entity.CreateHelp(save)
	if _, err := repo.dbHelp.InsertOne(ctx, help); err != nil {
		return nil, dbError(err)
	}
	return help, nil
}

func (repo *Repository) CreateQuestion(ctx context.Context, save entity.SaveQuestion) (*entity.Help, error) {
	question := entity.CreateQuestion(save)
	if _, err := repo.dbHelp.InsertOne(ctx, question); err != nil {
		return nil, dbError(err)
	}
	return question, nil
}

func (repo *Repository) DeleteHelp(ctx context.Context, id primitive.ObjectID) (*entity.Help, error) {
	var h entity.Help
	if err := repo.dbHelp.FindOneAndDelete(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&h); err != nil {
		return nil, dbError(err)
	}
	return &h, nil
}

func (repo *Repository) ByIdHelp(ctx context.Context, id primitive.ObjectID) (*entity.Help, error) {
	var h entity.Help
	err := repo.dbHelp.FindOne(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&h)
	if err != nil {
		return nil, dbError(err)
	}
	return &h, nil
}

func (repo *Repository) UpdateHelp(ctx context.Context, id primitive.ObjectID, save entity.SaveHelp) (*entity.Help, error) {
	var a entity.Help
	err := repo.dbHelp.FindOneAndUpdate(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
		bson.D{{Key: "$set", Value: bson.D{
			{Key: "topic", Value: save.Topic},
			{Key: "question", Value: save.Question},
			{Key: "answer", Value: save.Answer},
			{Key: "creator", Value: save.Creator},
			{Key: "updatedAt", Value: time.Now()},
		}}}, options.FindOneAndUpdate().SetReturnDocument(options.After)).Decode(&a)
	if err != nil {
		return nil, dbError(err)
	}
	return &a, nil
}

func (repo *Repository) AnswerQuestion(ctx context.Context, id primitive.ObjectID, answer entity.Answer) (*entity.Help, error) {
	var h entity.Help
	err := repo.dbHelp.FindOneAndUpdate(ctx,
		bson.M{"_id": bson.M{"$eq": id}},
		bson.D{{Key: "$set", Value: bson.D{
			{Key: "answer", Value: answer.Answer},
			{Key: "updatedAt", Value: time.Now()},
		}}}, options.FindOneAndUpdate().SetReturnDocument(options.After)).Decode(&h)
	if err != nil {
		return nil, dbError(err)
	}
	return &h, nil
}

func (repo *Repository) FindHelp(ctx context.Context, data entity.Find) (*entity.Page, error) {
	if data.Search != "" {
		cur, err := repo.dbHelp.Find(ctx, bson.M{"$text": bson.M{"$search": data.Search}}, options.Find().SetLimit(5))
		if err != nil {
			return nil, dbError(err)
		}
		items := make([]*entity.Help, 0)
		if err := cur.All(ctx, &items); err != nil {
			return nil, dbError(err)
		}
		return data.ToPage(items), nil
	}
	opts := options.Find().SetSort(bson.M{"updatedAt": -1}).SetSkip(int64(data.Num-1) * int64(data.Limit)).SetLimit(int64(data.Limit))
	cur, err := repo.dbHelp.Find(ctx, bson.M{"creator.roles": bson.M{"$eq": 1}}, opts)
	if err != nil {
		return nil, dbError(err)
	}
	items := make([]*entity.Help, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, dbError(err)
	}
	return data.ToPage(items), nil
}

func (repo *Repository) FindQuestion(ctx context.Context, data entity.Find) (*entity.Page, error) {
	opts := options.Find().SetSort(bson.M{"updatedAt": -1}).SetSkip(int64(data.Num-1) * int64(data.Limit)).SetLimit(int64(data.Limit))
	//For All User
	if data.UserId != "" {
		if data.IsAnswered {
			cur, err := repo.dbHelp.Find(ctx, bson.M{"creator.id": bson.M{"$eq": data.UserId}, "answer": bson.M{"$ne": ""}}, opts)
			if err != nil {
				return nil, dbError(err)
			}
			items := make([]*entity.Help, 0)
			if err := cur.All(ctx, &items); err != nil {
				return nil, dbError(err)
			}
			return data.ToPage(items), nil
		}
		cur, err := repo.dbHelp.Find(ctx, bson.M{"creator.id": bson.M{"$eq": data.UserId}, "answer": bson.M{"$eq": ""}}, opts)
		if err != nil {
			return nil, dbError(err)
		}
		items := make([]*entity.Help, 0)
		if err := cur.All(ctx, &items); err != nil {
			return nil, dbError(err)
		}
		return data.ToPage(items), nil
		//FOR SYSTEM ADMIN
	} else if data.IsAnswered {
		cur, err := repo.dbHelp.Find(ctx, bson.M{"answer": bson.M{"$ne": ""}}, opts)
		if err != nil {
			return nil, dbError(err)
		}
		items := make([]*entity.Help, 0)
		if err := cur.All(ctx, &items); err != nil {
			return nil, dbError(err)
		}
		return data.ToPage(items), nil
	}
	cur, err := repo.dbHelp.Find(ctx, bson.M{"answer": bson.M{"$eq": ""}}, opts)
	if err != nil {
		return nil, dbError(err)
	}
	items := make([]*entity.Help, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, dbError(err)
	}
	return data.ToPage(items), nil
}
