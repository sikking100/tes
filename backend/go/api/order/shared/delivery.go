package shared

import (
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/order/delivery/entity"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

func deliveryCollection(dbClient *mongo.Client) *mongo.Collection {
	return dbClient.Database("order").Collection("delivery")
}
func CreateDelivery(sessionCtx mongo.SessionContext, data entity.Create, status entity.Status) (primitive.ObjectID, error) {
	delivery := data.NewDelivery(status)
	if _, err := deliveryCollection(sessionCtx.Client()).InsertOne(sessionCtx, delivery); err != nil {
		return primitive.NilObjectID, err
	}
	return delivery.Id, nil
}
func WaitingCreatePackingListDelivery(sessionCtx mongo.SessionContext, orderId primitive.ObjectID) error {
	return deliveryCollection(sessionCtx.Client()).FindOneAndUpdate(
		sessionCtx,
		bson.M{"orderId": orderId, "status": int(entity.PENDING)},
		bson.M{"$set": bson.M{
			"status":    int(entity.WAITING_CREATE_PACKING_LIST),
			"updatedAt": time.Now(),
		}},
	).Err()
}
func IsCompleteDelivery(sessionCtx mongo.SessionContext, orderId primitive.ObjectID) (bool, error) {
	cur, err := deliveryCollection(sessionCtx.Client()).Aggregate(sessionCtx, bson.A{
		bson.M{"$match": bson.M{"orderId": orderId}},
		bson.M{"$unwind": bson.M{"path": "$product"}},
		bson.M{"$group": bson.M{
			"_id":     "$product._id",
			"purcase": bson.M{"$sum": "$product.purcaseQty"},
			"recive":  bson.M{"$sum": "$product.reciveQty"},
			"broken":  bson.M{"$sum": "$product.brokenQty"},
		}},
		bson.M{"$project": bson.M{"result": bson.M{"$subtract": bson.A{bson.M{"$subtract": bson.A{"$purcase", "$recive"}}, "$broken"}}}},
		bson.M{"$match": bson.M{"result": bson.M{"$gt": 0}}},
	})
	if err != nil {
		return false, err
	}
	var result []bson.M
	if err := cur.All(sessionCtx, &result); err != nil {
		return false, err
	}
	return len(result) == 0, nil
}
func CancelDelivery(sessionCtx mongo.SessionContext, orderId primitive.ObjectID) error {
	return deliveryCollection(sessionCtx.Client()).FindOneAndUpdate(
		sessionCtx,
		bson.M{"orderId": orderId, "status": bson.M{"$in": []int{int(entity.APPLY), int(entity.PENDING)}}},
		bson.A{bson.M{"$set": bson.M{
			"product":   bson.M{"$map": bson.M{"input": "$product", "in": bson.M{"$mergeObjects": bson.A{"$$this", bson.M{"status": int(entity.CANCEL)}}}}},
			"status":    int(entity.CANCEL),
			"updatedAt": time.Now(),
		}}},
	).Err()
}
func DeliveryTopApprove(sessionCtx mongo.SessionContext, orderId primitive.ObjectID) error {
	return deliveryCollection(sessionCtx.Client()).FindOneAndUpdate(
		sessionCtx,
		bson.M{"orderId": orderId, "status": bson.M{"$eq": int(entity.APPLY)}},
		bson.A{bson.M{"$set": bson.M{
			"status":    int(entity.WAITING_CREATE_PACKING_LIST),
			"updatedAt": time.Now(),
		}}},
	).Err()
}
