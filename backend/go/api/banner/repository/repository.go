package repository

import (
	"context"
	"os"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/banner/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
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
	db := client.Database("banner").Collection("banner")
	if _, err := db.Indexes().CreateOne(ctx, mongo.IndexModel{
		Keys: bson.D{{Key: "createdAt", Value: -1}},
	}); err != nil {
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

func (repo *Repository) Find(ctx context.Context, mType int) ([]*entity.Banner, error) {
	cur, err := repo.db.Find(ctx, bson.M{"type": bson.M{"$eq": mType}}, options.Find().SetSort(bson.M{"createdAt": -1}))
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Banner, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}

func (repo *Repository) Create(ctx context.Context, mType int, imageUrl string) error {
	if _, err := repo.db.InsertOne(ctx, bson.M{
		"type":      mType,
		"imageUrl":  imageUrl,
		"createdAt": time.Now(),
	}); err != nil {
		return toError(err)
	}
	return nil
}

func (repo *Repository) Delete(ctx context.Context, id primitive.ObjectID) (*entity.Banner, error) {
	var result entity.Banner
	if err := repo.db.FindOneAndDelete(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil

}
