package repository

import (
	"context"
	"os"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/category/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Repository struct {
	db *mongo.Collection
}

func NewRepository() (*mongo.Client, *Repository, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	client, err := mongo.Connect(ctx, options.Client().ApplyURI(os.Getenv("DB_URI")))
	if err != nil {
		return nil, nil, err
	}
	db := client.Database("category").Collection("category")
	if _, err := db.Indexes().CreateOne(ctx, mongo.IndexModel{Keys: bson.D{
		{Key: "name", Value: 1},
	}}); err != nil {
		return nil, nil, err
	}
	return client, &Repository{db: db}, nil
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
func (repo *Repository) Find(ctx context.Context) ([]*entity.Category, error) {
	cur, err := repo.db.Find(ctx, bson.M{}, options.Find().SetSort(bson.M{"name": 1}))
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Category, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}

func (repo *Repository) Save(ctx context.Context, id string, data entity.Save) (*entity.Category, error) {
	var result entity.Category
	if err := repo.db.FindOneAndUpdate(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
		bson.M{
			"$setOnInsert": bson.M{"createdAt": time.Now()},
			"$set": bson.M{
				"name":      data.Name,
				"team":      data.Team,
				"target":    data.Target,
				"updatedAt": time.Now(),
			},
		}, options.FindOneAndUpdate().SetReturnDocument(options.After).SetUpsert(true)).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}

func (repo *Repository) FindById(ctx context.Context, id string) (*entity.Category, error) {
	var result entity.Category
	if err := repo.db.FindOne(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}

func (repo *Repository) Delete(ctx context.Context, id string) (*entity.Category, error) {
	var result entity.Category
	if err := repo.db.FindOneAndDelete(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
