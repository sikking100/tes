package repository

import (
	"context"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/location/branch/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Repository struct {
	db *mongo.Collection
}

func NewRepository(ctx context.Context, dbClient *mongo.Client) (*Repository, error) {
	db := dbClient.Database("location").Collection("branch")
	if _, err := db.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{Keys: bson.D{{Key: "address.location", Value: "2dsphere"}}},
		{Keys: bson.D{{Key: "region._id", Value: 1}, {Key: "name", Value: "text"}}},
	}); err != nil {
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
func listBranch(ctx context.Context, cur *mongo.Cursor, err error) ([]*entity.Branch, error) {
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Branch, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}
func (repo *Repository) Find(ctx context.Context, data entity.Find) (*entity.Page, error) {
	switch {
	case data.IsBySearch() && data.IsByRegion():
		cur, err := repo.db.Find(ctx, bson.M{
			"region._id": bson.M{"$eq": data.RegionId},
			"$text":      bson.M{"$search": data.Search},
		}, options.Find().SetLimit(5))
		return data.ToPage(listBranch(ctx, cur, err))
	case data.IsBySearch():
		cur, err := repo.db.Find(ctx, bson.M{"$text": bson.M{"$search": data.Search}}, options.Find().SetLimit(5))
		return data.ToPage(listBranch(ctx, cur, err))
	case data.IsByRegion():
		cur, err := repo.db.Find(ctx, bson.M{"region._id": bson.M{"$eq": data.RegionId}}, options.Find().SetSort(bson.M{"name": 1}).SetSkip(int64(data.Num-1)*int64(data.Limit)).SetLimit(int64(data.Limit)))
		return data.ToPage(listBranch(ctx, cur, err))
	default:
		cur, err := repo.db.Find(ctx, bson.M{}, options.Find().SetSort(bson.M{"name": 1}).SetSkip(int64(data.Num-1)*int64(data.Limit)).SetLimit(int64(data.Limit)))
		return data.ToPage(listBranch(ctx, cur, err))
	}
}
func (repo *Repository) FindByNear(ctx context.Context, lngLat []float64) (*entity.Branch, error) {
	var result entity.Branch
	if err := repo.db.FindOne(
		ctx,
		bson.M{"address.location": bson.M{"$near": bson.M{
			"$geometry":    bson.M{"type": "Point", "coordinates": lngLat},
			"$maxDistance": 20 * 1000, // 20 km
		}}},
	).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) FindById(ctx context.Context, id string) (*entity.Branch, error) {
	var branch entity.Branch
	if err := repo.db.FindOne(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&branch); err != nil {
		return nil, toError(err)
	}
	return &branch, nil
}
func (repo *Repository) Save(ctx context.Context, id string, data entity.SaveBranch) (*entity.Branch, error) {
	var result entity.Branch
	if err := repo.db.FindOneAndUpdate(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
		bson.M{
			"$setOnInsert": bson.M{
				"warehouse": make([]*entity.Warehouse, 0),
				"createdAt": time.Now(),
			},
			"$set": bson.M{
				"region._id":                   data.RegionId,
				"region.name":                  data.RegionName,
				"name":                         data.Name,
				"address.name":                 data.Address,
				"address.lngLat":               []float64{data.AddressLng, data.AddressLat},
				"address.location.type":        "Point",
				"address.location.coordinates": []float64{data.AddressLng, data.AddressLat},
				"updatedAt":                    time.Now(),
			},
		}, options.FindOneAndUpdate().SetReturnDocument(options.After).SetUpsert(true)).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}

func (repo *Repository) Delete(ctx context.Context, id string) (*entity.Branch, error) {
	var branch entity.Branch
	if err := repo.db.FindOneAndDelete(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&branch); err != nil {
		return nil, toError(err)
	}
	return &branch, nil
}
func (repo *Repository) UpdateWarehouse(ctx context.Context, id string, data []*entity.SaveWarehouse) (*entity.Branch, error) {
	var result entity.Branch
	if err := repo.db.FindOneAndUpdate(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
		bson.M{
			"$set": bson.M{
				"warehouse": entity.NewWarehouse(data),
				"updatedAt": time.Now(),
			},
		}, options.FindOneAndUpdate().SetReturnDocument(options.After).SetUpsert(true)).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
