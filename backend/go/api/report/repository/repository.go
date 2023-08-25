package repository

import (
	"context"
	"os"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/report/entity"
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
	db := client.Database("report").Collection("report")
	if _, err := db.Indexes().CreateOne(ctx, mongo.IndexModel{Keys: bson.D{
		{Key: "to.id", Value: 1}, {Key: "from.id", Value: 1}, {Key: "updatedAt", Value: -1},
	}}); err != nil {
		return nil, nil, err
	}
	return client, &Repository{db: db}, nil
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
func (repo *Repository) Find(ctx context.Context, data entity.Find) (*entity.Page, error) {
	if data.To != "" {
		cur, err := repo.db.Find(ctx, bson.M{"to.id": bson.M{"$eq": data.To}}, options.Find().SetSort(bson.M{"updatedAt": -1}).SetSkip(int64(data.Num-1)*int64(data.Limit)).SetLimit(int64(data.Limit)))
		if err != nil {
			return nil, dbError(err)
		}
		items := make([]*entity.Report, 0)
		if err := cur.All(ctx, &items); err != nil {
			return nil, dbError(err)
		}
		return data.ToPage(items), nil
	} else if data.From != "" {
		cur, err := repo.db.Find(ctx, bson.M{"from.id": bson.M{"$eq": data.From}}, options.Find().SetSort(bson.M{"updatedAt": -1}).SetSkip(int64(data.Num-1)*int64(data.Limit)).SetLimit(int64(data.Limit)))
		if err != nil {
			return nil, dbError(err)
		}
		items := make([]*entity.Report, 0)
		if err := cur.All(ctx, &items); err != nil {
			return nil, dbError(err)
		}
		return data.ToPage(items), nil
	}
	cur, err := repo.db.Find(ctx, bson.M{}, options.Find().SetSort(bson.M{"updatedAt": -1}).SetSkip(int64(data.Num-1)*int64(data.Limit)).SetLimit(int64(data.Limit)))
	if err != nil {
		return nil, dbError(err)
	}
	items := make([]*entity.Report, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, dbError(err)
	}
	return data.ToPage(items), nil
}

func (repo *Repository) Create(ctx context.Context, save entity.Save) (*entity.Report, error) {
	r := entity.Create(save)
	if _, err := repo.db.InsertOne(ctx, r); err != nil {
		return nil, dbError(err)
	}
	return r, nil
}

func (repo *Repository) Delete(ctx context.Context, id primitive.ObjectID) (*entity.Report, error) {
	var r entity.Report
	if err := repo.db.FindOneAndDelete(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&r); err != nil {
		return nil, dbError(err)
	}
	return &r, nil
}

func (repo *Repository) ById(ctx context.Context, id primitive.ObjectID) (*entity.Report, error) {
	var r entity.Report
	err := repo.db.FindOne(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&r)
	if err != nil {
		return nil, dbError(err)
	}
	return &r, nil
}

func (repo *Repository) UpdateImageUrl(ctx context.Context, id primitive.ObjectID, imageUrl string) error {
	if _, err := repo.db.UpdateByID(ctx, id, bson.M{
		"$set": bson.M{
			"imageUrl": imageUrl,
			"sendDate": time.Now(),
		},
	}); err != nil {
		if err != mongo.ErrNoDocuments {
			return dbError(err)
		}
	}
	return nil
}

func (repo *Repository) UpdateFilePath(ctx context.Context, id primitive.ObjectID, filePath string) error {
	if _, err := repo.db.UpdateByID(ctx, id, bson.M{
		"$set": bson.M{
			"filePath": filePath,
			"sendDate": time.Now(),
		},
	}); err != nil {
		if err != mongo.ErrNoDocuments {
			return dbError(err)
		}
	}
	return nil
}
