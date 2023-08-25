package shared

import (
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/order/invoice/entity"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

func invoiceCollection(dbClient *mongo.Client) *mongo.Collection {
	return dbClient.Database("order").Collection("invoice")
}

func IsCompleteInvoice(sessionCtx mongo.SessionContext, orderId primitive.ObjectID) (bool, error) {
	cur, err := invoiceCollection(sessionCtx.Client()).Aggregate(sessionCtx, bson.A{
		bson.M{"$match": bson.M{"orderId": orderId}},
		bson.M{"$group": bson.M{
			"_id":   "$orderId",
			"price": bson.M{"$sum": "$price"},
			"paid":  bson.M{"$sum": "$paid"},
		}},
		bson.M{"$project": bson.M{
			"result": bson.M{"$subtract": bson.A{"$price", "$paid"}},
		}},
		bson.M{"$match": bson.M{
			"result": bson.M{"$gt": 0},
		}},
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
func CreateInvoice(sessionCtx mongo.SessionContext, data entity.Create, status entity.Status, paymentMethod entity.PaymentMethod) (primitive.ObjectID, error) {
	inv := data.NewInvoice(paymentMethod, status)
	if _, err := invoiceCollection(sessionCtx.Client()).InsertOne(sessionCtx, inv); err != nil {
		return primitive.NilObjectID, err
	}
	return inv.Id, nil
}

func CancelInvoice(sessionCtx mongo.SessionContext, orderId primitive.ObjectID) error {
	return invoiceCollection(sessionCtx.Client()).FindOneAndUpdate(
		sessionCtx,
		bson.M{"orderId": orderId, "status": bson.M{"$in": []int{int(entity.APPLY), int(entity.WAITING_PAY)}}},
		bson.M{"$set": bson.M{
			"status":    int(entity.CANCEL),
			"updatedAt": time.Now(),
		}},
	).Err()
}
func InvoiceTopApprove(sessionCtx mongo.SessionContext, orderId primitive.ObjectID) error {
	return invoiceCollection(sessionCtx.Client()).FindOneAndUpdate(
		sessionCtx,
		bson.M{"orderId": orderId, "status": bson.M{"$eq": int(entity.APPLY)}},
		bson.A{bson.M{"$set": bson.M{
			"status":    int(entity.WAITING_PAY),
			"updatedAt": time.Now(),
		}}},
	).Err()
}
