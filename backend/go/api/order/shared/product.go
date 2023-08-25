package shared

import (
	"fmt"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

func productCollection(dbClient *mongo.Client) *mongo.Collection {
	return dbClient.Database("product").Collection("product")
}

func AddQtyProduct(sessionCtx mongo.SessionContext, branchId string, warehouseId string, qtys map[string]int) error {
	for id, qty := range qtys {
		if err := productCollection(sessionCtx.Client()).FindOneAndUpdate(
			sessionCtx,
			bson.M{
				"_id": fmt.Sprintf("%s-%s", branchId, id),
				"warehouse": bson.M{"$elemMatch": bson.M{
					"_id": warehouseId,
				}},
			},
			bson.A{bson.M{"$set": bson.M{
				"warehouse": bson.M{"$map": bson.M{
					"input": "$warehouse",
					"in": bson.M{"$cond": bson.A{
						bson.M{"$eq": bson.A{"$$this._id", warehouseId}},
						bson.M{"$mergeObjects": bson.A{"$$this", bson.M{"qty": bson.M{"$add": bson.A{"$$this.qty", qty}}}}},
						"$$this",
					}},
				}},
			}}},
		).Err(); err != nil {
			return err
		}
	}
	return nil
}
func SubtractQtyProduct(sessionCtx mongo.SessionContext, branchId string, warehouseId string, product map[string]int) error {
	for id, qty := range product {
		if err := productCollection(sessionCtx.Client()).FindOneAndUpdate(
			sessionCtx,
			bson.M{
				"_id": fmt.Sprintf("%s-%s", branchId, id),
				"warehouse": bson.M{"$elemMatch": bson.M{
					"_id": warehouseId,
					"qty": bson.M{"$gte": qty},
				}},
			},
			bson.A{bson.M{"$set": bson.M{
				"warehouse": bson.M{"$map": bson.M{
					"input": "$warehouse",
					"in": bson.M{"$cond": bson.A{
						bson.M{"$eq": bson.A{"$$this._id", warehouseId}},
						bson.M{"$mergeObjects": bson.A{"$$this", bson.M{"qty": bson.M{"$subtract": bson.A{"$$this.qty", qty}}}}},
						"$$this",
					}},
				}},
			}}},
		).Err(); err != nil {
			return err
		}
	}
	return nil
}
