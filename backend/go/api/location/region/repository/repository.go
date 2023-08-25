package repository

import (
	"context"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/location/region/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Repository struct {
	db *mongo.Collection
}

func NewRepository(ctx context.Context, dbClient *mongo.Client) (*Repository, error) {
	db := dbClient.Database("location").Collection("region")
	if _, err := db.Indexes().CreateOne(ctx, mongo.IndexModel{Keys: bson.D{{Key: "name", Value: "text"}}}); err != nil {
		return nil, err
	}
	return &Repository{db: db}, nil
}
func toError(err error) error {
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
func listRegion(ctx context.Context, cur *mongo.Cursor, err error) ([]*entity.Region, error) {
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Region, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}
func (repo *Repository) Find(ctx context.Context, data entity.Find) (*entity.Page, error) {
	switch {
	case data.IsBySearch():
		cur, err := repo.db.Find(
			ctx,
			bson.M{
				"$text": bson.M{"$search": data.Search},
			},
			options.Find().SetLimit(5),
		)
		return data.ToPage(listRegion(ctx, cur, err))
	default:
		cur, err := repo.db.Find(
			ctx,
			bson.M{},
			options.Find().SetSort(bson.M{"name": 1}).SetSkip(int64(data.Num-1)*int64(data.Limit)).SetLimit(int64(data.Limit)),
		)
		return data.ToPage(listRegion(ctx, cur, err))
	}
}

func (repo *Repository) Save(ctx context.Context, id string, name string) (*entity.Region, error) {
	var result entity.Region
	if err := repo.db.FindOneAndUpdate(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
		bson.M{
			"$setOnInsert": bson.M{"createdAt": time.Now()},
			"$set": bson.M{
				"name":      name,
				"updatedAt": time.Now(),
			},
		}, options.FindOneAndUpdate().SetReturnDocument(options.After).SetUpsert(true)).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}

func (repo *Repository) FindById(ctx context.Context, id string) (*entity.Region, error) {
	var result entity.Region
	if err := repo.db.FindOne(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}

func (repo *Repository) Delete(ctx context.Context, id string) (*entity.Region, error) {
	var result entity.Region
	if err := repo.db.FindOneAndDelete(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
