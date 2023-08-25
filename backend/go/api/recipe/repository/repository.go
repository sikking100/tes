package repository

import (
	"context"
	"os"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/recipe/entity"
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
	db := client.Database("recipe").Collection("recipe")
	if _, err := db.Indexes().CreateOne(ctx, mongo.IndexModel{Keys: bson.D{
		{Key: "category", Value: 1}, {Key: "title", Value: "text"}, {Key: "updatedAt", Value: -1},
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

func toCategories(ctx context.Context, cur *mongo.Cursor, err error) ([]string, error) {
	if err != nil {
		return nil, err
	}
	result := make([]string, 0)
	for cur.Next(ctx) {
		var row entity.Categories
		err := cur.Decode(&row)
		if err != nil {
			return nil, err
		}
		result = append(result, row.Category)
	}
	return result, nil
}

func (repo *Repository) Find(ctx context.Context, data entity.Find) (*entity.Page, error) {
	if data.Search != "" {
		cur, err := repo.db.Find(ctx, bson.M{"$text": bson.M{"$search": data.Search}}, options.Find().SetLimit(int64(5)))
		if err != nil {
			return nil, toError(err)
		}
		items := make([]*entity.Recipe, 0)
		if err := cur.All(ctx, &items); err != nil {
			return nil, toError(err)
		}
		return data.ToPage(items), nil
	} else if data.Category != "" {
		cur, err := repo.db.Find(ctx, bson.M{"category": bson.M{"$eq": data.Category}}, options.Find().SetSort(bson.M{"updatedAt": -1}).SetSkip(int64(data.Num-1)*int64(data.Limit)).SetLimit(int64(data.Limit)))
		if err != nil {
			return nil, toError(err)
		}
		items := make([]*entity.Recipe, 0)
		if err := cur.All(ctx, &items); err != nil {
			return nil, toError(err)
		}
		return data.ToPage(items), nil
	}
	cur, err := repo.db.Find(ctx, bson.M{}, options.Find().SetSort(bson.M{"updatedAt": -1}).SetSkip(int64(data.Num-1)*int64(data.Limit)).SetLimit(int64(data.Limit)))
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Recipe, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return data.ToPage(items), nil
}

func (repo *Repository) Categories(ctx context.Context) ([]string, error) {
	opts := options.Find().SetProjection(bson.M{"category": 1, "_id": 0})
	cur, err := repo.db.Find(ctx, bson.M{}, opts)
	return toCategories(ctx, cur, err)
}

func (repo *Repository) Delete(ctx context.Context, id primitive.ObjectID) (*entity.Recipe, error) {
	var result entity.Recipe
	if err := repo.db.FindOneAndDelete(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
	).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}

func (repo *Repository) ById(ctx context.Context, id primitive.ObjectID) (*entity.Recipe, error) {
	var recipe entity.Recipe
	if err := repo.db.FindOne(ctx, bson.M{"_id": id}).Decode(&recipe); err != nil {
		return nil, toError(err)
	}
	return &recipe, nil
}

func (repo *Repository) Create(ctx context.Context, save entity.Save) (*entity.Recipe, error) {
	result := entity.Create(save)
	if _, err := repo.db.InsertOne(ctx, result); err != nil {
		return nil, toError(err)
	}
	return result, nil
}

func (repo *Repository) Update(ctx context.Context, id primitive.ObjectID, save entity.Save) (*entity.Recipe, error) {
	var recipe entity.Recipe
	err := repo.db.FindOneAndUpdate(ctx, bson.M{"_id": bson.M{"$eq": id}}, bson.M{"$set": save}).Decode(&recipe)
	if err != nil {
		return nil, toError(err)
	}
	return &recipe, nil
}

func (repo *Repository) UpdateImage(ctx context.Context, id primitive.ObjectID, url string) error {
	_, err := repo.db.UpdateOne(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
		bson.D{{Key: "$set",
			Value: bson.D{
				{Key: "imageUrl", Value: url},
			},
		}})
	return toError(err)
}
