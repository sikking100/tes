package shared

import (
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

func customerCollection(dbClient *mongo.Client) *mongo.Collection {
	return dbClient.Database("user").Collection("customer")
}

func ChargePayLaterUsed(sessionCtx mongo.SessionContext, customerId string, amount float64) error {
	return customerCollection(sessionCtx.Client()).FindOneAndUpdate(
		sessionCtx,
		bson.M{"_id": customerId, "business": bson.M{"$ne": nil}},
		bson.A{bson.M{"$set": bson.M{
			"business.credit.used": bson.M{"$add": bson.A{"$business.credit.used", amount}},
		}}},
	).Err()
}
func RefundPayLaterUsed(sessionCtx mongo.SessionContext, customerId string, amount float64) error {
	return customerCollection(sessionCtx.Client()).FindOneAndUpdate(
		sessionCtx,
		bson.M{"_id": customerId, "business": bson.M{"$ne": nil}},
		bson.A{bson.M{"$set": bson.M{
			"business.credit.used": bson.M{"$subtract": bson.A{"$business.credit.used", amount}},
		}}},
	).Err()
}
