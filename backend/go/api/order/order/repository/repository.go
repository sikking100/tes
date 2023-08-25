package repository

import (
	"context"
	"fmt"
	"log"
	"strings"
	"time"

	delivery "github.com/grocee-project/dairyfood/backend/go/api/order/delivery/entity"
	invoice "github.com/grocee-project/dairyfood/backend/go/api/order/invoice/entity"
	"github.com/grocee-project/dairyfood/backend/go/api/order/order/entity"
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
	dbClient *mongo.Client
	dbOrder  *mongo.Collection
	dbApply  *mongo.Collection
}

func NewRepositry(dbClient *mongo.Client) *Repository {
	dbOrder := dbClient.Database("order").Collection("order")
	if _, err := dbOrder.Indexes().CreateOne(context.Background(), mongo.IndexModel{
		Keys: bson.D{
			{Key: "query", Value: 1},
			{Key: "status", Value: 1},
			{Key: "updatedAt", Value: -1},
		},
	}); err != nil {
		log.Fatalln(err.Error())
	}
	return &Repository{
		dbClient: dbClient,
		dbOrder:  dbOrder,
		dbApply:  dbClient.Database("order").Collection("apply"),
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
	find := bson.M{}
	if data.IsByQuery() {
		find = bson.M{"query": bson.M{"$all": strings.Split(data.Query, ",")}}
	}
	cur, err := repo.dbOrder.Find(ctx, find, options.Find().SetSort(bson.M{"updatedAt": -1}).SetSkip(int64(data.Num-1)*int64(data.Limit)).SetLimit(int64(data.Limit)))
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Order, 0)
	if err = cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return data.ToPage(items), nil
}
func createInvoice(sessionCtx mongo.SessionContext, orderId primitive.ObjectID, data entity.Create, status invoice.Status, paymethod invoice.PaymentMethod) (primitive.ObjectID, error) {
	return shared.CreateInvoice(sessionCtx, invoice.Create{
		OrderId:    orderId,
		RegionId:   data.RegionId,
		RegionName: data.RegionName,
		BranchId:   data.BranchId,
		BranchName: data.BranchName,
		Customer: &invoice.Customer{
			Id:    data.Customer.Id,
			Name:  data.Customer.Name,
			Phone: data.Customer.Phone,
			Email: data.Customer.Email,
		},
		Price: data.TotalPrice,
		Term:  time.Now().AddDate(0, 0, data.TermInvoice),
	}, status, paymethod)
}
func createDelivery(sessionCtx mongo.SessionContext, orderId primitive.ObjectID, data entity.Create, status delivery.Status) (primitive.ObjectID, error) {
	product := make([]*delivery.Product, 0)
	for _, it := range data.Product {
		product = append(product, &delivery.Product{
			Id:          it.Id,
			Warehouse:   nil,
			Category:    it.CategoryName,
			Brand:       it.BrandName,
			Name:        it.Name,
			Size:        it.Size,
			ImageUrl:    it.ImageUrl,
			PurcaseQty:  it.Qty,
			DeliveryQty: 0,
			ReciveQty:   0,
			BrokenQty:   0,
			Status:      int(status),
		})
	}
	return shared.CreateDelivery(sessionCtx, delivery.Create{
		OrderId:    orderId,
		RegionId:   data.RegionId,
		RegionName: data.RegionName,
		BranchId:   data.BranchId,
		BranchName: data.BranchName,
		Customer: &delivery.Customer{
			Id:            data.Customer.Id,
			Name:          data.Customer.Name,
			Phone:         data.Customer.Phone,
			AddressName:   data.Customer.AddressName,
			AddressLngLat: data.Customer.AddressLngLat,
		},
		CourierType: data.DeliveryType,
		Product:     product,
		Note:        data.Customer.Note,
		Price:       data.DeliveryPrice,
		DeliveryAt:  data.DeliveryAt,
	}, status)
}
func (repo *Repository) Create(ctx context.Context, data entity.Create) (*entity.Order, error) {
	var order *entity.Order = nil
	transaction := func(sessionCtx mongo.SessionContext) (interface{}, error) {
		if data.PaymentMethod == 0 {
			var err error
			order = data.NewOrder(entity.PENDING)
			if order.InvoiceId, err = createInvoice(sessionCtx, order.Id, data, invoice.WAITING_PAY, invoice.COD); err != nil {
				return nil, err
			}
			if order.DeliveryId, err = createDelivery(sessionCtx, order.Id, data, delivery.WAITING_CREATE_PACKING_LIST); err != nil {
				return nil, err
			}
			if _, err := repo.dbOrder.InsertOne(sessionCtx, order); err != nil {
				return nil, err
			}
			return order, nil
		} else if data.PaymentMethod == 1 && data.TransactionOverDue == 0 && data.CreditLimit-data.CreditUsed >= data.TotalPrice {
			var err error
			order = data.NewOrder(entity.PENDING)
			if order.InvoiceId, err = createInvoice(sessionCtx, order.Id, data, invoice.PENDING, invoice.TOP); err != nil {
				return nil, err
			}
			if order.DeliveryId, err = createDelivery(sessionCtx, order.Id, data, delivery.WAITING_CREATE_PACKING_LIST); err != nil {
				return nil, err
			}
			if err := shared.ChargePayLaterUsed(sessionCtx, data.Customer.Id, data.TotalPrice); err != nil {
				return nil, err
			}
			if _, err := repo.dbOrder.InsertOne(sessionCtx, order); err != nil {
				return nil, err
			}
			return order, nil
		} else if data.PaymentMethod == 1 {
			var err error
			var apply *entity.Apply = nil
			apply, order = data.NewApply(data.Customer.Id, (data.CreditLimit+data.TotalPrice+data.CreditUsed-data.CreditLimit)-data.CreditLimit, data.TransactionOverDue, data.TotalPrice)
			if order.InvoiceId, err = createInvoice(sessionCtx, order.Id, data, invoice.APPLY, invoice.TOP); err != nil {
				return nil, err
			}
			if order.DeliveryId, err = createDelivery(sessionCtx, order.Id, data, delivery.APPLY); err != nil {
				return nil, err
			}
			if err := shared.ChargePayLaterUsed(sessionCtx, data.Customer.Id, data.TotalPrice); err != nil {
				return nil, err
			}
			if _, err := repo.dbOrder.InsertOne(sessionCtx, order); err != nil {
				return nil, err
			}
			if _, err := repo.dbApply.InsertOne(sessionCtx, apply); err != nil {
				return nil, err
			}
			return order, nil
		} else if data.PaymentMethod == 2 {
			var err error
			order = data.NewOrder(entity.PENDING)
			if order.InvoiceId, err = createInvoice(sessionCtx, order.Id, data, invoice.PENDING, invoice.TRA); err != nil {
				return nil, err
			}
			if order.DeliveryId, err = createDelivery(sessionCtx, order.Id, data, delivery.PENDING); err != nil {
				return nil, err
			}
			if _, err := repo.dbOrder.InsertOne(sessionCtx, order); err != nil {
				return nil, err
			}
			return order, nil
		}
		return nil, fmt.Errorf("invalid payment method")
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
	return order, nil

}
func (repo *Repository) FindById(ctx context.Context, id primitive.ObjectID) (*entity.Order, error) {
	var result entity.Order
	if err := repo.dbOrder.FindOne(ctx, bson.M{"_id": id}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) CancelOrder(ctx context.Context, id primitive.ObjectID, data entity.Cancel) (*entity.Order, error) {
	return nil, nil
}
func (repo *Repository) FindReport(ctx context.Context, data entity.FindReport) ([]*entity.Report, error) {
	var match bson.M
	if data.Query != "" {
		match = bson.M{"$match": bson.M{
			"query":     bson.M{"$all": strings.Split(data.Query, ",")},
			"createdAt": bson.M{"$gte": data.StartAt, "$lte": data.EndAt},
			"status":    int(entity.COMPLETE),
		}}
	} else {
		match = bson.M{"$match": bson.M{
			"createdAt": bson.M{"$gte": data.StartAt, "$lte": data.EndAt},
			"status":    int(entity.COMPLETE),
		}}
	}
	cur, err := repo.dbOrder.Aggregate(ctx, bson.A{
		match,
		bson.M{"$unwind": "$product"},
		bson.M{"$project": bson.M{
			"orderId":           "$_id",
			"salesId":           "$product.salesId",
			"regionId":          "$regionId",
			"regionName":        "$regionName",
			"branchId":          "$branchId",
			"branchName":        "$branchName",
			"priceId":           "$priceId",
			"priceName":         "$priceName",
			"customerId":        "$customer._id",
			"customerName":      "$customer.name",
			"productId":         "$product._id",
			"productName":       "$product.name",
			"productQty":        "$product.qty",
			"productDiscount":   "$product.discount",
			"productUnitPrice":  "$product.unitPrice",
			"productTotalPrice": "$product.totalPrice",
			"productPoint":      "$product.point",
			"tax":               bson.M{"$divide": bson.A{"$product.unitPrice", 1.11}},
		}}})
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Report, 0)
	if err = cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}
func (repo *Repository) FindPerformace(ctx context.Context, data entity.FindPerformace) ([]*entity.Performance, error) {
	query := make([]string, 0)
	for _, q := range strings.Split(data.Query, ",") {
		if strings.TrimSpace(q) != "" {
			query = append(query, q)
		}
	}
	cur, err := repo.dbOrder.Aggregate(ctx, bson.A{
		bson.M{"$match": bson.M{
			"query":     bson.M{"$all": query},
			"createdAt": bson.M{"$gte": data.StartAt, "$lte": data.EndAt},
			"status":    int(entity.COMPLETE),
		}},
		bson.M{"$unwind": "$product"},
		bson.M{"$match": bson.M{"product.team": data.Team}},
		bson.M{"$group": bson.M{
			"_id": bson.M{"$concat": bson.A{
				"$regionId",
				"$branchId",
				"$product.categoryId",
			}},
			"regionId":       bson.M{"$first": "$regionId"},
			"regionName":     bson.M{"$first": "$regionName"},
			"branchId":       bson.M{"$first": "$branchId"},
			"branchName":     bson.M{"$first": "$branchName"},
			"categoryId":     bson.M{"$first": "$product.categoryId"},
			"categoryName":   bson.M{"$first": "$product.categoryName"},
			"categoryTarget": bson.M{"$sum": 0},
			"qty":            bson.M{"$sum": "$product.qty"},
		}}})
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Performance, 0)
	if err = cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}
func (repo *Repository) TransactionLastMonth(ctx context.Context, customerId string) (float64, error) {
	cur, err := repo.dbOrder.Aggregate(ctx, bson.A{
		bson.M{"$match": bson.M{
			"customer._id": customerId,
			"status":       int(entity.COMPLETE),
			"createdAt":    bson.M{"$gte": time.Now().AddDate(0, -1, 0)},
		}},
		bson.M{"$group": bson.M{
			"_id":        "$customer._id",
			"totalPrice": bson.M{"$sum": "$totalPrice"},
		}}})
	if err != nil {
		return 0, toError(err)
	}
	type Result struct {
		TotalPrice float64 `bson:"totalPrice"`
	}
	items := make([]*Result, 0)
	if err = cur.All(ctx, &items); err != nil {
		return 0, toError(err)
	}
	if len(items) > 0 {
		return items[0].TotalPrice, nil
	}
	return 0, nil
}
func (repo *Repository) TransactionPerMonth(ctx context.Context, customerId string) (float64, error) {
	cur, err := repo.dbOrder.Aggregate(ctx, bson.A{
		bson.M{"$match": bson.M{
			"customer._id": customerId,
			"status":       int(entity.COMPLETE),
			"createdAt":    bson.M{"$gte": time.Now().AddDate(-1, 0, 0)},
		}},
		bson.M{"$group": bson.M{
			"_id":        "$customer._id",
			"totalPrice": bson.M{"$avg": "$totalPrice"},
		}}})
	if err != nil {
		return 0, toError(err)
	}
	type Result struct {
		TotalPrice float64 `bson:"totalPrice"`
	}
	items := make([]*Result, 0)
	if err = cur.All(ctx, &items); err != nil {
		return 0, toError(err)
	}
	if len(items) > 0 {
		return items[0].TotalPrice, nil
	}
	return 0, nil
}
func (repo *Repository) FindApply(ctx context.Context, userId string, data entity.FindApply) ([]*entity.Apply, error) {
	find := bson.M{"userApprover": bson.M{"$elemMatch": bson.M{"_id": userId}}}
	if data.Type == 0 {
		find = bson.M{"userApprover": bson.M{"$elemMatch": bson.M{"_id": userId, "status": int(entity.APPLY_WAITING_APPROVE)}}}
	}
	cur, err := repo.dbApply.Find(ctx, find)
	if err != nil {
		return nil, toError(err)
	}
	result := make([]*entity.Apply, 0)
	if err = cur.All(ctx, &result); err != nil {
		return nil, toError(err)
	}
	return result, nil
}
func (repo *Repository) FindApplyById(ctx context.Context, id primitive.ObjectID) (*entity.Apply, error) {
	var result entity.Apply
	if err := repo.dbApply.FindOne(ctx, bson.M{"_id": id}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) Approve(ctx context.Context, id primitive.ObjectID, data entity.MakeApprove) (*entity.Apply, error) {
	status, err := data.Approve()
	if err != nil {
		return nil, toError(errors.BadRequest(err))
	}
	var apply entity.Apply
	transaction := func(sessionCtx mongo.SessionContext) (interface{}, error) {
		if err := repo.dbApply.FindOneAndUpdate(
			sessionCtx,
			bson.M{
				"_id": id,
				"userApprover": bson.M{"$elemMatch": bson.M{
					"_id":    data.UserId,
					"status": int(entity.APPLY_WAITING_APPROVE),
				}},
			},
			bson.M{"$set": bson.M{
				"userApprover": data.UserApprover,
				"status":       status,
				"updatedAt":    time.Now(),
			}},
			options.FindOneAndUpdate().SetReturnDocument(options.After),
		).Decode(&apply); err != nil {
			return nil, err
		}
		if status == entity.APPLY_APPROVE {
			if err := shared.OrderTopApprove(sessionCtx, id); err != nil {
				return nil, err
			}
			if err := shared.DeliveryTopApprove(sessionCtx, id); err != nil {
				return nil, err
			}
			if err := shared.InvoiceTopApprove(sessionCtx, id); err != nil {
				return nil, err
			}
		}
		return &apply, nil
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
	return &apply, nil
}
func (repo *Repository) Reject(ctx context.Context, id primitive.ObjectID, data entity.MakeApprove) (*entity.Apply, error) {
	if err := data.Reject(); err != nil {
		return nil, toError(errors.BadRequest(err))
	}
	var apply entity.Apply
	transaction := func(sessionCtx mongo.SessionContext) (interface{}, error) {
		if err := repo.dbApply.FindOneAndUpdate(
			sessionCtx,
			bson.M{
				"_id": id,
				"userApprover": bson.M{"$elemMatch": bson.M{
					"_id":    data.UserId,
					"status": int(entity.APPLY_WAITING_APPROVE),
				}},
			},
			bson.M{"$set": bson.M{
				"userApprover": data.UserApprover,
				"status":       int(entity.APPLY_REJECT),
				"updatedAt":    time.Now(),
			}},
			options.FindOneAndUpdate().SetReturnDocument(options.After),
		).Decode(&apply); err != nil {
			return nil, err
		}
		if err := shared.CancelOrder(sessionCtx, id); err != nil {
			return nil, err
		}
		if err := shared.CancelDelivery(sessionCtx, id); err != nil {
			return nil, err
		}
		if err := shared.CancelInvoice(sessionCtx, id); err != nil {
			return nil, err
		}
		if err := shared.RefundPayLaterUsed(sessionCtx, apply.CustomerId, apply.TotalPrice); err != nil {
			return nil, err
		}
		return &apply, nil
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
	return &apply, nil
}
