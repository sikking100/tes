package repository

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/order/delivery/entity"
	"github.com/grocee-project/dairyfood/backend/go/api/order/shared"
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
	dbDelivery *mongo.Collection
}

func NewRepository(dbClient *mongo.Client) *Repository {
	dbDelivery := dbClient.Database("order").Collection("delivery")
	if _, err := dbDelivery.Indexes().CreateOne(context.Background(), mongo.IndexModel{
		Keys: bson.D{
			{Key: "branchId", Value: 1},
			{Key: "status", Value: 1},
			{Key: "courier._id", Value: 1},
			{Key: "deliveryAt", Value: 1},
			{Key: "createdAt", Value: -1},
		},
	}); err != nil {
		log.Fatalln(err.Error())
	}
	return &Repository{
		dbClient:   dbClient,
		dbDelivery: dbDelivery,
	}
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
func (repo *Repository) Find(ctx context.Context, data entity.Find) (*entity.Page, error) {
	q := bson.M{"branchId": data.BranchId, "status": data.Status, "deliveryAt": bson.M{"$lte": time.Now().AddDate(0, 0, 7)}}
	if data.CourierId != "" {
		q = bson.M{"courier._id": data.CourierId, "status": data.Status, "deliveryAt": bson.M{"$lte": time.Now().AddDate(0, 0, 7)}}
	}
	opt := options.Find().SetSort(bson.M{"deliveryAt": 1}).SetSkip(int64(data.Num-1) * int64(data.Limit)).SetLimit(int64(data.Limit))
	if data.Status == int(entity.COMPLETE) {
		opt = options.Find().SetSort(bson.M{"createdAt": -1}).SetSkip(int64(data.Num-1) * int64(data.Limit)).SetLimit(int64(data.Limit))
	}
	cur, err := repo.dbDelivery.Find(
		ctx,
		q,
		opt,
	)
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Delivery, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return data.ToPage(items), nil
}
func (repo *Repository) FindById(ctx context.Context, id primitive.ObjectID) (*entity.Delivery, error) {
	var result entity.Delivery
	if err := repo.dbDelivery.FindOne(
		ctx,
		bson.M{"_id": id},
	).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) FindByOrderId(ctx context.Context, orderId primitive.ObjectID) ([]*entity.Delivery, error) {
	cur, err := repo.dbDelivery.Find(
		ctx,
		bson.M{"orderId": orderId},
		options.Find().SetSort(bson.M{"createdAt": -1}),
	)
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Delivery, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}
func (repo *Repository) CreatePackingList(ctx context.Context, id primitive.ObjectID, data entity.CreatePackingList) (*entity.Delivery, error) {
	var result entity.Delivery
	warehouseId := ""
	for i := 0; i < len(data.Product); i++ {
		data.Product[i].Status = int(entity.WAITING_ADD_COURIER)
		if data.Product[i].PurcaseQty < data.Product[i].DeliveryQty {
			return nil, toError(errors.BadRequest(fmt.Errorf("delivery qty cannot more then purcase qty")))
		}
		if data.Product[i].DeliveryQty == 0 {
			data.Product[i].Status = int(entity.COMPLETE)
		}
		if data.CourierType == int(entity.EXTERNAL) {
			if warehouseId == "" {
				warehouseId = data.Product[i].Warehouse.Id
			}
			if warehouseId != data.Product[i].Warehouse.Id {
				return nil, toError(errors.BadRequest(fmt.Errorf("courier external must be use one warehouse")))
			}
		}
	}
	if err := repo.dbDelivery.FindOneAndUpdate(
		ctx,
		bson.M{"_id": id, "status": int(entity.WAITING_CREATE_PACKING_LIST), "courierType": data.CourierType},
		bson.M{"$set": bson.M{
			"product": data.Product,
			"status":  int(entity.WAITING_ADD_COURIER),
		}},
		options.FindOneAndUpdate().SetReturnDocument(options.After),
	).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) CourierInteral(ctx context.Context, id primitive.ObjectID, data entity.Courier) (*entity.Delivery, error) {
	var result entity.Delivery
	if err := repo.dbDelivery.FindOneAndUpdate(
		ctx,
		bson.M{
			"_id":          id,
			"status":       bson.M{"$in": []int{int(entity.WAITING_ADD_COURIER), int(entity.PICKED_UP)}},
			"courierType":  int(entity.INTERNAL),
			"isBeenLoaded": false,
		},
		bson.A{bson.M{"$set": bson.M{
			"courier": data,
			"product": bson.M{
				"$map": bson.M{
					"input": "$product",
					"as":    "p",
					"in": bson.M{"$cond": bson.A{
						bson.M{"$eq": bson.A{"$$p.status", int(entity.COMPLETE)}},
						"$$p",
						bson.M{"$mergeObjects": bson.A{"$$p", bson.M{"status": int(entity.PICKED_UP)}}},
					}},
				}},
			"status": int(entity.PICKED_UP),
		}}},
		options.FindOneAndUpdate().SetReturnDocument(options.After),
	).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) CourierExternal(ctx context.Context, id primitive.ObjectID, data entity.BookingCourierExternal) (*entity.BookingCourierExternal, error) {
	b, err := json.Marshal(map[string]interface{}{
		"paymentType":         "3",
		"collection_location": "pickup",
		"shipment_method":     "Instant",
		"routes": []interface{}{
			map[string]interface{}{
				"originContactName":       data.WarehousePicName,
				"originContactPhone":      data.WarehousePicPhone,
				"originLatLong":           fmt.Sprintf("%f,%f", data.WarehouseAddressLat, data.WarehouseAddressLng),
				"originAddress":           data.WarehouseAddressName,
				"destinationContactName":  data.CustomerPicName,
				"destinationContactPhone": data.CustomerPicPhone,
				"destinationLatLong":      fmt.Sprintf("%f,%f", data.CustomerAddressLat, data.CustomerAddressLng),
				"destinationAddress":      data.CustomerAddressName,
				"item":                    data.Item,
				"storeOrderId":            id.Hex(),
			},
		},
	})
	if err != nil {
		return nil, toError(errors.BadRequest(err))
	}
	request, err := http.NewRequest("POST", os.Getenv("GO_SEND_HOST")+"/booking", bytes.NewBuffer(b))
	if err != nil {
		return nil, toError(errors.Internal(err))
	}
	request.Header.Set("Client-ID", os.Getenv("GOSEND_CLIENT_ID"))
	request.Header.Set("Pass-Key", os.Getenv("GOSEND_PASS_KEY"))
	request.Header.Set("Content-Type", "application/json")
	client := &http.Client{}
	res, err := client.Do(request)
	if err != nil {
		return nil, toError(err)
	} else if res.StatusCode != 201 {
		return nil, toError(errors.Internal(fmt.Errorf("error status %d : %s", res.StatusCode, res.Header.Get("error-message"))))
	}
	return &data, nil
}
func (repo *Repository) UpdateQty(ctx context.Context, id primitive.ObjectID, data entity.UpdateQty) (*entity.Delivery, error) {
	var result entity.Delivery
	if err := repo.dbDelivery.FindOneAndUpdate(
		ctx,
		bson.M{
			"_id":         id,
			"status":      bson.M{"$in": []int{int(entity.WAITING_ADD_COURIER), int(entity.PICKED_UP)}},
			"courierType": int(entity.INTERNAL),
			"product": bson.M{"$elemMatch": bson.M{
				"_id":        data.ProductId,
				"purcaseQty": bson.M{"$gte": data.DeliveryQty},
				"status":     bson.M{"$in": []int{int(entity.WAITING_ADD_COURIER), int(entity.PICKED_UP)}},
			}},
		},
		bson.A{bson.M{"$set": bson.M{
			"product": bson.M{"$map": bson.M{"input": "$product", "as": "product", "in": bson.M{"$cond": bson.A{
				bson.M{"$eq": bson.A{"$$product._id", data.ProductId}},
				bson.M{"$mergeObjects": bson.A{"$$product", bson.M{
					"deliveryQty": data.DeliveryQty,
				}}},
				"$$product",
			}}}},
		}}},
		options.FindOneAndUpdate().SetReturnDocument(options.After),
	).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) UpdateToDeliver(ctx context.Context, id primitive.ObjectID, courierId string) (*entity.Delivery, error) {
	var result entity.Delivery
	if err := repo.dbDelivery.FindOneAndUpdate(
		ctx,
		bson.M{
			"_id":         id,
			"courier._id": courierId,
			"status":      int(entity.WAITING_DELIVER),
		},
		bson.A{bson.M{"$set": bson.M{
			"status": int(entity.DELIVER),
			"product": bson.M{"$map": bson.M{
				"input": "$product",
				"in": bson.M{"$cond": bson.A{
					bson.M{"$eq": bson.A{"$$this.status", int(entity.COMPLETE)}},
					"$$this",
					bson.M{"$mergeObjects": bson.A{"$$this", bson.M{"status": int(entity.DELIVER)}}},
				}},
			}},
		}}},
		options.FindOneAndUpdate().SetReturnDocument(options.After),
	).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) FindPackingListWarehouse(ctx context.Context, data entity.FindPackingListWarehouse) ([]*entity.PackingListWarehouse, error) {
	cur, err := repo.dbDelivery.Aggregate(ctx, bson.A{
		bson.M{"$match": bson.M{"branchId": data.BranchId}},
		bson.M{"$unwind": "$product"},
		bson.M{"$match": bson.M{"product.warehouse._id": data.WarehouseId, "product.status": data.Status}},
		bson.M{"$group": bson.M{
			"_id":         bson.M{"$concat": bson.A{"$courier._id", "$product._id"}},
			"courier":     bson.M{"$first": "$courier"},
			"product":     bson.M{"$first": "$product"},
			"purcaseQty":  bson.M{"$sum": "$product.purcaseQty"},
			"deliveryQty": bson.M{"$sum": "$product.deliveryQty"},
			"reciveQty":   bson.M{"$sum": "$product.reciveQty"},
			"brokenQty":   bson.M{"$sum": "$product.brokenQty"},
		}},
		bson.M{"$group": bson.M{
			"_id":     "$courier._id",
			"courier": bson.M{"$first": "$courier"},
			"product": bson.M{"$push": bson.M{"$mergeObjects": bson.A{"$product", bson.M{
				"purcaseQty":  "$purcaseQty",
				"deliveryQty": "$deliveryQty",
				"reciveQty":   "$reciveQty",
				"brokenQty":   "$brokenQty",
			}}}},
		}},
	})
	if err != nil {
		return nil, toError(err)
	}
	result := make([]*entity.PackingListWarehouse, 0)
	if err := cur.All(ctx, &result); err != nil {
		return nil, toError(err)
	}
	return result, nil
}
func (repo *Repository) FindPackingListCourier(ctx context.Context, data entity.FindPackingListCourier) ([]*entity.PackingListCourier, error) {
	cur, err := repo.dbDelivery.Aggregate(ctx, bson.A{
		bson.M{"$match": bson.M{"courier._id": data.CourierId}},
		bson.M{"$unwind": "$product"},
		bson.M{"$match": bson.M{"product.status": data.Status, "product.warehouse": bson.M{"$ne": nil}}},
		bson.M{"$group": bson.M{
			"_id":         bson.M{"$concat": bson.A{"$product.warehouse._id", "$product._id"}},
			"product":     bson.M{"$first": "$product"},
			"purcaseQty":  bson.M{"$sum": "$product.purcaseQty"},
			"deliveryQty": bson.M{"$sum": "$product.deliveryQty"},
			"reciveQty":   bson.M{"$sum": "$product.reciveQty"},
			"brokenQty":   bson.M{"$sum": "$product.brokenQty"},
		}},
		bson.M{"$group": bson.M{
			"_id":       "$product.warehouse._id",
			"warehouse": bson.M{"$first": "$product.warehouse"},
			"product": bson.M{"$push": bson.M{"$mergeObjects": bson.A{"$product", bson.M{
				"purcaseQty":  "$purcaseQty",
				"deliveryQty": "$deliveryQty",
				"reciveQty":   "$reciveQty",
				"brokenQty":   "$brokenQty",
			}}}},
		}},
	})
	if err != nil {
		return nil, toError(err)
	}
	result := make([]*entity.PackingListCourier, 0)
	if err := cur.All(ctx, &result); err != nil {
		return nil, toError(err)
	}
	return result, nil
}
func (repo *Repository) FindPackingListDestination(ctx context.Context, data entity.FindPackingListDestination) ([]*entity.PackingListDestination, error) {
	cur, err := repo.dbDelivery.Aggregate(ctx, bson.A{
		bson.M{"$match": bson.M{
			"courier._id": data.CourierId,
			"status":      bson.M{"$in": []int{int(entity.PICKED_UP), int(entity.LOADED), int(entity.WAITING_DELIVER), int(entity.DELIVER)}},
		}},
		bson.M{"$project": bson.M{
			"_id":      "$_id",
			"orderId":  "$orderId",
			"customer": "$customer",
		}},
	})
	if err != nil {
		return nil, toError(err)
	}
	result := make([]*entity.PackingListDestination, 0)
	if err := cur.All(ctx, &result); err != nil {
		return nil, toError(err)
	}
	return result, nil
}

func (repo *Repository) PackingListLoaded(ctx context.Context, data entity.PackingListLoaded) (*entity.PackingListLoaded, error) {
	// productBeforeUpdate := bson.M{"$filter": bson.M{"input": "$product", "cond": bson.M{"$ne": bson.A{"$$this.warehouse._id", data.WarehouseId}}}}
	productLoaded := bson.M{"$size": bson.M{"$filter": bson.M{"input": "$product", "cond": bson.M{
		"$or": bson.A{
			bson.M{"$eq": bson.A{"$$this.status", int(entity.LOADED)}},
			bson.M{"$eq": bson.A{"$$this.status", int(entity.COMPLETE)}},
			bson.M{"$eq": bson.A{"$$this.warehouse", nil}},
			bson.M{"$eq": bson.A{"$$this.warehouse._id", data.WarehouseId}},
		},
	}}}}

	// sizeProduct := bson.M{"$size": bson.M{"$concatArrays": bson.A{productBeforeUpdate, productLoaded}}}

	transaction := func(sessionCtx mongo.SessionContext) (interface{}, error) {
		result, err := repo.dbDelivery.UpdateMany(
			sessionCtx,
			bson.M{
				"courier._id": data.CourierId,
				"product": bson.M{"$elemMatch": bson.M{
					"warehouse._id": data.WarehouseId,
					"status":        int(entity.PICKED_UP),
				}},
				"status": int(entity.PICKED_UP),
			},
			bson.A{bson.M{"$set": bson.M{
				"product": bson.M{"$map": bson.M{"input": "$product", "as": "product", "in": bson.M{"$cond": bson.A{
					bson.M{"$eq": bson.A{"$$product.warehouse._id", data.WarehouseId}},
					bson.M{"$mergeObjects": bson.A{"$$product", bson.M{"status": int(entity.LOADED)}}},
					"$$product",
				}}}},
				"isBeenLoaded": true,
				"status": bson.M{"$cond": bson.A{
					bson.M{"$eq": bson.A{productLoaded, bson.M{"$size": "$product"}}},
					int(entity.WAITING_DELIVER),
					"$status",
				}},
			}}},
		)
		if err != nil {
			return nil, err
		}
		if err := shared.SubtractQtyProduct(sessionCtx, data.BranchId, data.WarehouseId, data.Product); err != nil {
			return nil, err
		}
		return result.ModifiedCount, nil
	}
	session, err := repo.dbClient.StartSession()
	if err != nil {
		return nil, toError(err)
	}
	defer session.EndSession(ctx)
	_, err = session.WithTransaction(
		ctx,
		transaction,
		options.Transaction().SetWriteConcern(writeconcern.New(writeconcern.WMajority())).SetReadConcern(readconcern.Snapshot()),
	)
	if err != nil {
		return nil, toError(err)
	}
	return &data, nil
}

func (repo *Repository) Restock(ctx context.Context, deliveryId primitive.ObjectID, data entity.Restock) (*entity.Restock, error) {
	listProductComplete := bson.M{"$size": bson.M{"$filter": bson.M{
		"input": "$product",
		"cond": bson.M{"$or": bson.A{
			bson.M{"$eq": bson.A{"$$this.status", int(entity.COMPLETE)}},
			bson.M{"$eq": bson.A{"$$this.warehouse._id", data.WarehouseId}},
		}},
	}}}
	listAllProduct := bson.M{"$size": "$product"}
	isAllRestock := bson.M{"$eq": bson.A{listProductComplete, listAllProduct}}

	transaction := func(sessionCtx mongo.SessionContext) (interface{}, error) {
		var delivery entity.Delivery
		if err := repo.dbDelivery.FindOneAndUpdate(
			sessionCtx,
			bson.M{
				"_id":      deliveryId,
				"branchId": data.BranchId,
				"status":   bson.M{"$eq": int(entity.RESTOCK)},
				"product": bson.M{"$elemMatch": bson.M{
					"warehouse._id": data.WarehouseId,
					"status":        int(entity.RESTOCK),
				}},
			},
			bson.A{bson.M{"$set": bson.M{
				"product": bson.M{"$map": bson.M{
					"input": "$product",
					"in": bson.M{"$cond": bson.A{
						bson.M{"$and": bson.A{
							bson.M{"$eq": bson.A{"$$this.warehouse._id", data.WarehouseId}},
							bson.M{"$eq": bson.A{"$$this.status", int(entity.RESTOCK)}},
						}},
						bson.M{"$mergeObjects": bson.A{"$$this", bson.M{"status": int(entity.COMPLETE)}}},
						"$$this",
					}},
				}},
				"status": bson.M{"$cond": bson.A{isAllRestock, int(entity.COMPLETE), "$status"}},
			}}},
			options.FindOneAndUpdate().SetReturnDocument(options.After),
		).Decode(&delivery); err != nil {
			return nil, err
		}
		qtys := make(map[string]int)
		newDeliveryProduct := make([]*entity.Product, 0)
		for _, p := range delivery.Product {
			product := *p
			if product.Warehouse.Id == data.WarehouseId && product.BrokenQty > 0 {
				qtys[product.Id] = product.BrokenQty
			}
			if delivery.Status == int(entity.COMPLETE) && product.PurcaseQty > product.ReciveQty {
				product.PurcaseQty = p.PurcaseQty - p.ReciveQty
				product.Warehouse = nil
				product.DeliveryQty = 0
				product.ReciveQty = 0
				product.BrokenQty = 0
				product.Status = int(entity.WAITING_CREATE_PACKING_LIST)
				newDeliveryProduct = append(newDeliveryProduct, &product)
			}
		}

		if len(qtys) > 0 {
			if err := shared.AddQtyProduct(sessionCtx, data.BranchId, data.WarehouseId, qtys); err != nil {
				return nil, err
			}
		}
		if delivery.Status == int(entity.RESTOCK) {
			return &delivery, nil
		} else if delivery.Status == int(entity.COMPLETE) && len(newDeliveryProduct) != 0 {
			newDeliveryId, err := shared.CreateDelivery(sessionCtx, entity.Create{
				OrderId:     delivery.OrderId,
				RegionId:    delivery.RegionId,
				RegionName:  delivery.RegionName,
				BranchId:    delivery.BranchId,
				BranchName:  delivery.BranchName,
				Customer:    delivery.Customer,
				CourierType: delivery.CourierType,
				Note:        delivery.Note,
				Price:       delivery.Price,
				DeliveryAt:  delivery.DeliveryAt,
				Product:     newDeliveryProduct,
			}, entity.WAITING_CREATE_PACKING_LIST)
			if err != nil {
				return nil, err
			}
			if err := shared.UpdateDeliveryId(sessionCtx, delivery.OrderId, newDeliveryId); err != nil {
				return nil, err
			}
		} else if delivery.Status == int(entity.COMPLETE) && len(newDeliveryProduct) == 0 {
			// delivery is complete
			isInvoiceComplete, err := shared.IsCompleteInvoice(sessionCtx, delivery.OrderId)
			if err != nil {
				return nil, err
			} else if isInvoiceComplete {
				if err := shared.CompleteOrder(sessionCtx, delivery.OrderId); err != nil {
					return nil, err
				}
			}
		}
		return &delivery, nil
	}
	session, err := repo.dbClient.StartSession()
	if err != nil {
		return nil, toError(err)
	}
	defer session.EndSession(ctx)
	_, err = session.WithTransaction(
		ctx,
		transaction,
		options.Transaction().SetWriteConcern(writeconcern.New(writeconcern.WMajority())).SetReadConcern(readconcern.Snapshot()),
	)
	if err != nil {
		return nil, toError(err)
	}
	return &data, nil
}

func (repo *Repository) Complete(ctx context.Context, deliveryId primitive.ObjectID, data entity.Complete) (*entity.Delivery, error) {
	var delivery entity.Delivery
	transaction := func(sessionCtx mongo.SessionContext) (interface{}, error) {
		if err := repo.dbDelivery.FindOneAndUpdate(
			sessionCtx,
			bson.M{
				"_id":         deliveryId,
				"courier._id": data.CourierId,
				"status":      bson.M{"$eq": int(entity.DELIVER)},
			},
			bson.M{"$set": bson.M{
				"product":   data.Product,
				"status":    data.Status,
				"note":      data.Note,
				"updatedAt": time.Now(),
			}},
			options.FindOneAndUpdate().SetReturnDocument(options.After),
		).Decode(&delivery); err != nil {
			return nil, err
		}
		if delivery.Status == int(entity.COMPLETE) {
			// check is split order
			newProduct := make([]*entity.Product, 0)
			for _, p := range delivery.Product {
				if p.PurcaseQty > p.ReciveQty {
					product := *p
					product.PurcaseQty = product.PurcaseQty - product.ReciveQty
					product.DeliveryQty = 0
					product.BrokenQty = 0
					product.ReciveQty = 0
					product.Status = int(entity.WAITING_CREATE_PACKING_LIST)
					newProduct = append(newProduct, &product)
				}
			}
			if len(newProduct) != 0 {
				// split order
				newDeliveryId, err := shared.CreateDelivery(sessionCtx, entity.Create{
					OrderId:     delivery.OrderId,
					RegionId:    delivery.RegionId,
					RegionName:  delivery.RegionName,
					BranchId:    delivery.BranchId,
					BranchName:  delivery.BranchName,
					Customer:    delivery.Customer,
					CourierType: delivery.CourierType,
					Product:     newProduct,
					Note:        delivery.Note,
					Price:       delivery.Price,
					DeliveryAt:  delivery.DeliveryAt,
				}, entity.WAITING_CREATE_PACKING_LIST)
				if err != nil {
					return nil, err
				}
				if err := shared.UpdateDeliveryId(sessionCtx, delivery.OrderId, newDeliveryId); err != nil {
					return nil, err
				}
			} else {
				// complete
				isInvoiceComplete, err := shared.IsCompleteInvoice(sessionCtx, delivery.OrderId)
				if err != nil {
					return nil, err
				} else if isInvoiceComplete {
					if err := shared.CompleteOrder(sessionCtx, delivery.OrderId); err != nil {
						return nil, err
					}
				}
			}
		}
		return &delivery, nil
	}
	session, err := repo.dbClient.StartSession()
	if err != nil {
		return nil, toError(err)
	}
	defer session.EndSession(ctx)
	if _, err = session.WithTransaction(
		ctx,
		transaction,
		options.Transaction().SetWriteConcern(writeconcern.New(writeconcern.WMajority())).SetReadConcern(readconcern.Snapshot()),
	); err != nil {
		return nil, toError(err)
	}
	return &delivery, nil
}
func (repo *Repository) FindProduct(ctx context.Context, data entity.FindProduct) ([]*entity.Product, error) {
	if data.CourierId != "" {
		cur, err := repo.dbDelivery.Aggregate(ctx, bson.A{
			bson.M{"$match": bson.M{"courier._id": data.CourierId}},
			bson.M{"$unwind": "$product"},
			bson.M{"$match": bson.M{"product.status": data.Status}},
			bson.M{"$group": bson.M{
				"_id":         bson.M{"$concat": bson.A{"$courier._id", "$product._id"}},
				"courier":     bson.M{"$first": "$courier"},
				"product":     bson.M{"$first": "$product"},
				"purcaseQty":  bson.M{"$sum": "$product.purcaseQty"},
				"deliveryQty": bson.M{"$sum": "$product.deliveryQty"},
				"reciveQty":   bson.M{"$sum": "$product.reciveQty"},
				"brokenQty":   bson.M{"$sum": "$product.brokenQty"},
			}},
			bson.M{"$group": bson.M{
				"_id": nil,
				"product": bson.M{"$push": bson.M{"$mergeObjects": bson.A{"$product", bson.M{
					"purcaseQty":  "$purcaseQty",
					"deliveryQty": "$deliveryQty",
					"reciveQty":   "$reciveQty",
					"brokenQty":   "$brokenQty",
				}}}},
			}},
		})
		if err != nil {
			return nil, toError(err)
		}
		type Result struct {
			Product []*entity.Product `bson:"product"`
		}
		result := make([]*Result, 0)
		if err = cur.All(ctx, &result); err != nil {
			return nil, toError(err)
		}
		if len(result) == 1 {
			return result[0].Product, nil
		}
		return []*entity.Product{}, nil
	}
	cur, err := repo.dbDelivery.Aggregate(ctx, bson.A{
		bson.M{"$match": bson.M{"branchId": data.BranchId}},
		bson.M{"$unwind": "$product"},
		bson.M{"$match": bson.M{"product.status": data.Status, "product.warehouse._id": data.WarehouseId}},
		bson.M{"$group": bson.M{
			"_id":         bson.M{"$concat": bson.A{"$product.warehouse._id", "$product._id"}},
			"product":     bson.M{"$first": "$product"},
			"purcaseQty":  bson.M{"$sum": "$product.purcaseQty"},
			"deliveryQty": bson.M{"$sum": "$product.deliveryQty"},
			"reciveQty":   bson.M{"$sum": "$product.reciveQty"},
			"brokenQty":   bson.M{"$sum": "$product.brokenQty"},
		}},
		bson.M{"$group": bson.M{
			"_id": nil,
			"product": bson.M{"$push": bson.M{"$mergeObjects": bson.A{"$product", bson.M{
				"purcaseQty":  "$purcaseQty",
				"deliveryQty": "$deliveryQty",
				"reciveQty":   "$reciveQty",
				"brokenQty":   "$brokenQty",
			}}}},
		}},
	})
	if err != nil {
		return nil, toError(err)
	}
	type Result struct {
		Product []*entity.Product `bson:"product"`
	}
	result := make([]*Result, 0)
	if err = cur.All(ctx, &result); err != nil {
		return nil, toError(err)
	}
	if len(result) == 1 {
		return result[0].Product, nil
	}
	return []*entity.Product{}, nil

}
func (repo *Repository) GoSendPrice(ctx context.Context, data entity.GetGoSendPrice) (int, error) {
	path := fmt.Sprintf("/calculate/price?origin=%s&destination=%s&paymentType=3", fmt.Sprintf("%f,%f", data.OriginLat, data.OriginLng), fmt.Sprintf("%f,%f", data.DestinationLat, data.DestinationLng))
	request, err := http.NewRequest("GET", os.Getenv("GO_SEND_HOST")+path, nil)
	if err != nil {
		return 0, toError(errors.Internal(err))
	}
	request.Header.Set("Client-ID", os.Getenv("GOSEND_CLIENT_ID"))
	request.Header.Set("Pass-Key", os.Getenv("GOSEND_PASS_KEY"))
	request.Header.Set("Content-Type", "application/json")
	client := &http.Client{}
	res, err := client.Do(request)
	if err != nil {
		return 0, toError(errors.Internal(err))
	} else if res.StatusCode != 200 {
		return 0, toError(errors.Internal(fmt.Errorf("error status %d", res.StatusCode)))
	}
	result := struct {
		Instant struct {
			Price struct {
				TotalPrice int `json:"total_price"`
			} `json:"price"`
			Serviceable bool `json:"serviceable"`
			Active      bool `json:"active"`
		} `json:"Instant"`
	}{}
	b, err := io.ReadAll(res.Body)
	if err != nil {
		return 0, toError(errors.Internal(err))
	}
	if err := json.Unmarshal(b, &result); err != nil {
		return 0, toError(errors.Internal(err))
	}
	return result.Instant.Price.TotalPrice, nil
}
func (repo *Repository) GoSendCallback(ctx context.Context, data entity.GoSendCallback) error {
	if data.Status == "allocated" {
		if _, err := repo.dbDelivery.UpdateOne(ctx, bson.M{"_id": data.StoreOrderId},
			bson.M{"$set": bson.M{
				"courier": &entity.Courier{
					Id:       data.EntityId,
					Name:     data.DriverName,
					Phone:    data.DriverPhone,
					ImageUrl: data.DriverPhotoUrl,
				},
				"courierType": entity.EXTERNAL,
				"price":       data.Price,
				"url":         data.LiveTrackingUrl,
			}}); err != nil {
			return err
		}
		return nil
	} else if data.Status == "no_driver" {
		if _, err := repo.dbDelivery.UpdateOne(ctx, bson.M{"_id": data.StoreOrderId},
			bson.M{"$set": bson.M{
				"courier": nil,
				"status":  int(entity.WAITING_ADD_COURIER),
			}}); err != nil {
			return err
		}
		return nil
	} else if data.Status == "out_for_pickup" {
		if _, err := repo.dbDelivery.UpdateOne(
		ctx,
		bson.M{"_id": data.StoreOrderId},
		bson.A{bson.M{"$set": bson.M{
			"status":    int(entity.PICKED_UP),
			"updatedAt": time.Now(),
			"product": bson.M{
				"$map": bson.M{
					"input": "$product",
					"as":    "p",
					"in": bson.M{"$cond": bson.A{
						bson.M{"$eq": bson.A{"$$p.status", int(entity.COMPLETE)}},
						"$$p",
						bson.M{"$mergeObjects": bson.A{"$$p", bson.M{"status": int(entity.PICKED_UP)}}},
					}},
				},
			}}}}); err != nil {
			return err
		}
		return nil
	} else if data.Status == "picked" {
		var delivery entity.Delivery
		transaction := func(sessionContext mongo.SessionContext) (interface{}, error) {
			if err := repo.dbDelivery.FindOneAndUpdate(
				sessionContext,
				bson.M{"_id": data.StoreOrderId},
				// bson.M{"$set": bson.M{
				// 	"status":    int(entity.DELIVER),
				// 	"updatedAt": time.Now(),
				// }},
				bson.A{bson.M{"$set": bson.M{
					"product": bson.M{
						"$map": bson.M{
							"input": "$product",
							"as":    "p",
							"in": bson.M{"$cond": bson.A{
								bson.M{"$eq": bson.A{"$$p.status", int(entity.COMPLETE)}},
								"$$p",
								bson.M{"$mergeObjects": bson.A{"$$p", bson.M{"status": int(entity.DELIVER)}}},
							}},
						}},
					"status":    int(entity.DELIVER),
					"updatedAt": time.Now(),
				}}},
			).Decode(&delivery); err != nil {
				return nil, err
			}
			product := make(map[string]int)
			for _, p := range delivery.Product {
				product[p.Id] = p.DeliveryQty
			}
			if err := shared.SubtractQtyProduct(sessionContext, delivery.BranchId, delivery.Product[0].Warehouse.Id, product); err != nil {
				return nil, err
			}
			return &delivery, nil
		}
		session, err := repo.dbClient.StartSession()
		if err != nil {
			return toError(err)
		}
		defer session.EndSession(ctx)
		if _, err = session.WithTransaction(
			ctx,
			transaction,
			options.Transaction().SetWriteConcern(writeconcern.New(writeconcern.WMajority())).SetReadConcern(readconcern.Snapshot()),
		); err != nil {
			return toError(err)
		}
		return nil
	} else if data.Status == "rejected" {
		if _, err := repo.dbDelivery.UpdateOne(ctx, bson.M{"_id": data.StoreOrderId},
			bson.M{"$set": bson.M{
				"courier": nil,
				"status":  int(entity.RESTOCK),
			}}); err != nil {
			return err
		}
		return nil
	} else if data.Status == "cancelled" {
		if _, err := repo.dbDelivery.UpdateOne(ctx, bson.M{"_id": data.StoreOrderId},
			bson.M{"$set": bson.M{
				"courier": nil,
				"status":  int(entity.WAITING_ADD_COURIER),
			}}); err != nil {
			return err
		}
		return nil
	} else if data.Status == "delivered" {
		var delivery entity.Delivery
		transaction := func(sessionCtx mongo.SessionContext) (interface{}, error) {
			if err := repo.dbDelivery.FindOneAndUpdate(
				sessionCtx,
				bson.M{
					"_id": data.StoreOrderId,
				},
				bson.A{
					bson.M{"$set": bson.M{
						"product": bson.M{
							"$map": bson.M{
								"input": "$product",
								"as":    "p",
								"in": bson.M{"$cond": bson.A{
									bson.M{"$eq": bson.A{"$$p.status", int(entity.COMPLETE)}},
									"$$p",
									bson.M{"$mergeObjects": bson.A{"$$p",
										bson.M{"status": int(entity.COMPLETE), "reciveQty": "$$p.deliveryQty"}}},
								}}},
						},
						"status":    int(entity.COMPLETE),
						"updatedAt": time.Now()}}},
				options.FindOneAndUpdate().SetReturnDocument(options.After),
			).Decode(&delivery); err != nil {
				return nil, err
			}
			newProduct := make([]*entity.Product, 0)
			for _, p := range delivery.Product {
				if p.PurcaseQty > p.ReciveQty {
					product := *p
					product.PurcaseQty = product.PurcaseQty - product.ReciveQty
					product.DeliveryQty = 0
					product.BrokenQty = 0
					product.ReciveQty = 0
					product.Status = int(entity.WAITING_CREATE_PACKING_LIST)
					newProduct = append(newProduct, &product)
				}
			}
			if len(newProduct) != 0 {
				newDeliveryId, err := shared.CreateDelivery(sessionCtx, entity.Create{
					OrderId:     delivery.OrderId,
					RegionId:    delivery.RegionId,
					RegionName:  delivery.RegionName,
					BranchId:    delivery.BranchId,
					BranchName:  delivery.BranchName,
					Customer:    delivery.Customer,
					CourierType: delivery.CourierType,
					Product:     newProduct,
					Note:        delivery.Note,
					Price:       delivery.Price,
					DeliveryAt:  delivery.DeliveryAt,
				}, entity.WAITING_CREATE_PACKING_LIST)
				if err != nil {
					return nil, err
				}
				if err := shared.UpdateDeliveryId(sessionCtx, delivery.OrderId, newDeliveryId); err != nil {
					return nil, err
				}
			} else {
				if err := shared.CompleteOrder(sessionCtx, delivery.OrderId); err != nil {
					return nil, err
				}
			}
			return &delivery, nil
		}
		session, err := repo.dbClient.StartSession()
		if err != nil {
			return toError(err)
		}
		defer session.EndSession(ctx)
		if _, err = session.WithTransaction(
			ctx,
			transaction,
			options.Transaction().SetWriteConcern(writeconcern.New(writeconcern.WMajority())).SetReadConcern(readconcern.Snapshot()),
		); err != nil {
			return toError(err)
		}
		return nil
	}
	return nil
}
