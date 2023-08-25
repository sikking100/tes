package repository

import (
	"context"
	"os"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/activity/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readconcern"
	"go.mongodb.org/mongo-driver/mongo/writeconcern"
)

type Repository struct {
	dbClient   *mongo.Client
	dbActivity *mongo.Collection
	dbComment  *mongo.Collection
}

func NewRepository() (*mongo.Client, *Repository, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	client, err := mongo.Connect(ctx, options.Client().ApplyURI(os.Getenv("DB_URI")))
	if err != nil {
		return nil, nil, err
	}
	dbActivity := client.Database("activity").Collection("activity")
	if _, err := dbActivity.Indexes().CreateOne(ctx, mongo.IndexModel{
		Keys: bson.D{{Key: "updatedAt", Value: -1}},
	}); err != nil {
		return nil, nil, err

	}
	dbComment := client.Database("activity").Collection("comment")
	if _, err := dbComment.Indexes().CreateOne(ctx, mongo.IndexModel{
		Keys: bson.D{{Key: "createdAt", Value: -1}},
	}); err != nil {
		return nil, nil, err

	}
	return client, &Repository{
		dbClient:   client,
		dbActivity: dbActivity,
		dbComment:  dbComment,
	}, nil
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

func (repo *Repository) FindActivity(ctx context.Context, data entity.Find) (*entity.Page, error) {
	cur, err := repo.dbActivity.Find(ctx, bson.M{}, options.Find().SetSort(bson.M{"updatedAt": -1}).SetSkip(int64(data.Num-1)*int64(data.Limit)).SetLimit(int64(data.Limit)))
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Activity, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return data.ToPage(items), nil
}
func (repo *Repository) FindActivityById(ctx context.Context, id primitive.ObjectID) (*entity.Activity, error) {
	var result entity.Activity
	if err := repo.dbActivity.FindOne(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) CreateActivity(ctx context.Context, data entity.SaveActivity) (*entity.Activity, error) {
	result := entity.NewActivity(data)
	if _, err := repo.dbActivity.InsertOne(ctx, result); err != nil {
		return nil, toError(err)
	}
	return result, nil
}
func (repo *Repository) UpdateActivity(ctx context.Context, id primitive.ObjectID, data entity.SaveActivity) (*entity.Activity, error) {
	var result entity.Activity
	if err := repo.dbActivity.FindOneAndUpdate(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
		bson.D{{Key: "$set", Value: bson.D{
			{Key: "title", Value: data.Title},
			{Key: "videoUrl", Value: data.VideoUrl},
			{Key: "description", Value: data.Description},
		}}},
		options.FindOneAndUpdate().SetReturnDocument(options.After),
	).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) DeleteActivity(ctx context.Context, id primitive.ObjectID, creatorId string) (*entity.Activity, error) {
	var result entity.Activity
	if err := repo.dbActivity.FindOneAndDelete(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}, "creator._id": bson.M{"$eq": creatorId}},
	).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}

func (repo *Repository) UpdateImage(ctx context.Context, id primitive.ObjectID, path, url string) error {
	_, err := repo.dbActivity.UpdateOne(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
		bson.D{{Key: "$set",
			Value: bson.D{
				{Key: "imageUrl", Value: url},
				{Key: "imagePath", Value: path},
				{Key: "updatedAt", Value: time.Now()},
			},
		}})
	return toError(err)
}

func (repo *Repository) FindComment(ctx context.Context, activityId primitive.ObjectID) ([]*entity.Comment, error) {
	cur, err := repo.dbComment.Find(
		ctx,
		bson.M{"activityId": bson.M{"$eq": activityId}},
		options.Find().SetSort(bson.M{"createdAt": -1}),
	)
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Comment, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}
func (repo *Repository) FindCommentById(ctx context.Context, id primitive.ObjectID) (*entity.Comment, error) {
	var result entity.Comment
	if err := repo.dbComment.FindOne(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) CreateComment(ctx context.Context, data entity.SaveComment) (*entity.Comment, error) {
	wc := writeconcern.New(writeconcern.WMajority())
	rc := readconcern.Snapshot()
	txnOpts := options.Transaction().SetWriteConcern(wc).SetReadConcern(rc)
	session, err := repo.dbClient.StartSession()
	if err != nil {
		panic(err)
	}
	defer session.EndSession(ctx)
	result := entity.NewComment(data)
	if err = mongo.WithSession(ctx, session, func(sessionContext mongo.SessionContext) error {
		if err = session.StartTransaction(txnOpts); err != nil {
			return err
		}
		if err := repo.dbActivity.FindOneAndUpdate(
			sessionContext,
			bson.M{"_id": bson.M{"$eq": data.ActivityId}},
			bson.A{bson.M{"$set": bson.M{
				"comment":      bson.M{"$slice": bson.A{bson.M{"$concatArrays": bson.A{[]*entity.Comment{result}, "$comment"}}, 5}},
				"commentCount": bson.M{"$add": bson.A{"$commentCount", 1}},
				"updatedAt":    time.Now(),
			}}},
		).Err(); err != nil {
			return err
		}
		if _, err := repo.dbComment.InsertOne(sessionContext, result); err != nil {
			return err
		}
		return session.CommitTransaction(sessionContext)
	}); err != nil {
		if abortErr := session.AbortTransaction(ctx); abortErr != nil {
			return nil, toError(abortErr)
		}
		return nil, toError(err)
	}
	return result, nil
}
func (repo *Repository) UpdateComment(ctx context.Context, id primitive.ObjectID, data entity.SaveComment) (*entity.Comment, error) {
	wc := writeconcern.New(writeconcern.WMajority())
	rc := readconcern.Snapshot()
	txnOpts := options.Transaction().SetWriteConcern(wc).SetReadConcern(rc)
	session, err := repo.dbClient.StartSession()
	if err != nil {
		panic(err)
	}
	defer session.EndSession(ctx)
	var result entity.Comment
	if err = mongo.WithSession(ctx, session, func(sessionContext mongo.SessionContext) error {
		if err = session.StartTransaction(txnOpts); err != nil {
			return err
		}
		if err := repo.dbActivity.FindOneAndUpdate(
			sessionContext,
			bson.M{"_id": bson.M{"$eq": data.ActivityId}},
			bson.A{bson.M{"$set": bson.M{
				"comment": bson.M{"$map": bson.M{
					"input": "$comment",
					"in": bson.M{"$cond": bson.A{
						bson.M{"$and": bson.A{bson.M{"$eq": bson.A{"$$this._id", id}}, bson.M{"$eq": bson.A{"$$this.creator._id", data.Creator.Id}}}},
						bson.M{"$mergeObjects": bson.A{"$$this", bson.M{
							"comment": data.Comment,
						}}},
						"$$this",
					}},
				}},
			}}},
		).Err(); err != nil {
			return err
		}
		if err := repo.dbComment.FindOneAndUpdate(
			sessionContext,
			bson.M{"_id": bson.M{"$eq": id}, "creator._id": bson.M{"$eq": data.Creator.Id}},
			bson.M{"$set": bson.M{
				"comment": data.Comment,
				"creator": data.Creator,
			}},
			options.FindOneAndUpdate().SetReturnDocument(options.After),
		).Decode(&result); err != nil {
			return err
		}
		return session.CommitTransaction(sessionContext)
	}); err != nil {
		if abortErr := session.AbortTransaction(ctx); abortErr != nil {
			return nil, toError(abortErr)
		}
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) DeleteComment(ctx context.Context, id primitive.ObjectID, creatorId string) (*entity.Comment, error) {
	wc := writeconcern.New(writeconcern.WMajority())
	rc := readconcern.Snapshot()
	txnOpts := options.Transaction().SetWriteConcern(wc).SetReadConcern(rc)
	session, err := repo.dbClient.StartSession()
	if err != nil {
		panic(err)
	}
	defer session.EndSession(ctx)
	var result entity.Comment
	if err = mongo.WithSession(ctx, session, func(sessionContext mongo.SessionContext) error {
		if err = session.StartTransaction(txnOpts); err != nil {
			return err
		}
		if err := repo.dbComment.FindOneAndDelete(
			sessionContext,
			bson.M{"_id": bson.M{"$eq": id}, "creator._id": bson.M{"$eq": creatorId}},
		).Decode(&result); err != nil {
			return err
		}
		if err := repo.dbActivity.FindOneAndUpdate(
			sessionContext,
			bson.M{"_id": bson.M{"$eq": result.ActivityId}},
			bson.A{bson.M{"$set": bson.M{
				"comment":      bson.M{"$filter": bson.M{"input": "$comment", "cond": bson.M{"$ne": bson.A{"$$this._id", id}}}},
				"commentCount": bson.M{"$subtract": bson.A{"$commentCount", 1}},
			}}},
		).Err(); err != nil {
			return err
		}
		return session.CommitTransaction(sessionContext)
	}); err != nil {
		if abortErr := session.AbortTransaction(ctx); abortErr != nil {
			return nil, toError(abortErr)
		}
		return nil, toError(err)
	}
	return &result, nil
}
