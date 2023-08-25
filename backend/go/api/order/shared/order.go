package shared

import (
	"strconv"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/order/order/entity"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

func collectionOrder(dbClient *mongo.Client) *mongo.Collection {
	return dbClient.Database("order").Collection("order")
}
func CompleteOrder(sessionCtx mongo.SessionContext, orderId primitive.ObjectID) error {
	return collectionOrder(sessionCtx.Client()).FindOneAndUpdate(
		sessionCtx,
		bson.M{"_id": orderId},
		bson.A{bson.M{"$set": bson.M{
			"query":     []string{"$regionId", "$branchId", "$customer._id", "$creator._id", strconv.Itoa(int(entity.COMPLETE))},
			"status":    int(entity.COMPLETE),
			"updatedAt": time.Now(),
		}}},
	).Err()
}
func CancelOrder(sessionCtx mongo.SessionContext, orderId primitive.ObjectID) error {
	return collectionOrder(sessionCtx.Client()).FindOneAndUpdate(
		sessionCtx,
		bson.M{"_id": orderId},
		bson.A{bson.M{"$set": bson.M{
			"query":     []string{"$regionId", "$branchId", "$customer._id", "$creator._id", strconv.Itoa(int(entity.CANCEL))},
			"status":    int(entity.CANCEL),
			"updatedAt": time.Now(),
		}}},
	).Err()
}
func UpdateInvoiceId(sessionCtx mongo.SessionContext, orderId primitive.ObjectID, invoiceId primitive.ObjectID) error {
	return collectionOrder(sessionCtx.Client()).FindOneAndUpdate(
		sessionCtx,
		bson.M{"_id": orderId},
		bson.A{bson.M{"$set": bson.M{
			"invoiceId": invoiceId,
			"updatedAt": time.Now(),
		}}},
	).Err()
}
func UpdateDeliveryId(sessionCtx mongo.SessionContext, orderId primitive.ObjectID, deliveryId primitive.ObjectID) error {
	return collectionOrder(sessionCtx.Client()).FindOneAndUpdate(
		sessionCtx,
		bson.M{"_id": orderId},
		bson.A{bson.M{"$set": bson.M{
			"deliveryId": deliveryId,
			"updatedAt":  time.Now(),
		}}},
	).Err()
}
func OrderTopApprove(sessionCtx mongo.SessionContext, orderId primitive.ObjectID) error {
	return collectionOrder(sessionCtx.Client()).FindOneAndUpdate(
		sessionCtx,
		bson.M{"_id": orderId},
		bson.A{bson.M{"$set": bson.M{
			"query":     []string{"$regionId", "$branchId", "$customer._id", "$creator._id", strconv.Itoa(int(entity.PENDING))},
			"status":    int(entity.PENDING),
			"updatedAt": time.Now(),
		}}},
	).Err()
}
