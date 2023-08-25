package repository

import (
	"context"
	"log"
	"os"
	"strings"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/order/invoice/entity"
	"github.com/grocee-project/dairyfood/backend/go/api/order/shared"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"

	"github.com/xendit/xendit-go"
	pay "github.com/xendit/xendit-go/client"
	"github.com/xendit/xendit-go/invoice"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readconcern"
	"go.mongodb.org/mongo-driver/mongo/writeconcern"
)

type Repository struct {
	dbClient *mongo.Client
	db       *mongo.Collection
	pay      *pay.API
}

func NewRepository(dbClient *mongo.Client) *Repository {
	dbInvoice := dbClient.Database("order").Collection("invoice")
	if _, err := dbInvoice.Indexes().CreateOne(context.Background(), mongo.IndexModel{
		Keys: bson.D{
			{Key: "query", Value: 1},
			{Key: "status", Value: 1},
			{Key: "expiredAt", Value: 1},
			{Key: "paymentMethod", Value: 1},
			{Key: "createdAt", Value: -1},
		},
	}); err != nil {
		log.Fatalln(err.Error())
	}
	return &Repository{
		dbClient: dbClient,
		db:       dbInvoice,
		pay:      pay.New(os.Getenv("XENDIT_APY_KEY")),
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
func (repo *Repository) Create(ctx mongo.SessionContext, data *entity.Invoice) error {
	_, err := repo.db.InsertOne(ctx, data)
	return err
}
func (repo *Repository) Find(ctx context.Context, data entity.Find) (*entity.Page, error) {
	find := bson.M{}
	if data.IsByQuery() {
		find["query"] = bson.M{"$all": strings.Split(data.Query, ",")}
	}
	if data.IsByWaitingPay() {
		find["status"] = bson.M{"$eq": int(entity.WAITING_PAY)}
	} else if data.IsByOverdue() {
		find["$expr"] = bson.M{"$gte": bson.A{"$price", "$paid"}}
		find["expiredAt"] = bson.M{"$lte": time.Now()}
		find["paymentMethod"] = bson.M{"eq": int(entity.TOP)}
	}
	cur, err := repo.db.Find(ctx, find, options.Find().SetSort(bson.M{"createdAt": -1}).SetSkip(int64(data.Num-1)*int64(data.Limit)).SetLimit(int64(data.Limit)))
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Invoice, 0)
	if err = cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return data.ToPage(items), nil
}
func (repo *Repository) FindById(ctx context.Context, id primitive.ObjectID) (*entity.Invoice, error) {
	var inv entity.Invoice
	if err := repo.db.FindOne(ctx, bson.M{"_id": id}).Decode(&inv); err != nil {
		return nil, toError(err)
	}
	return &inv, nil
}
func (repo *Repository) MakePayment(ctx context.Context, id primitive.ObjectID) (*entity.Invoice, error) {
	var inv entity.Invoice
	if err := repo.db.FindOne(ctx, bson.M{"_id": id}).Decode(&inv); err != nil {
		return nil, toError(err)
	}
	if inv.IsCanMakePayment() {
		result, err := repo.pay.Invoice.CreateWithContext(ctx, &invoice.CreateParams{
			ExternalID: id.Hex(),
			Amount:     inv.Price,
			Customer: xendit.InvoiceCustomer{
				GivenNames:   inv.Customer.Name,
				Surname:      inv.Customer.Name,
				Email:        inv.Customer.Email,
				MobileNumber: inv.Customer.Phone,
			},
		})
		if err != nil {
			return nil, err
		}
		if err := repo.db.FindOneAndUpdate(
			ctx,
			bson.M{"_id": id},
			bson.M{"$set": bson.M{
				"transactionId": result.ID,
				"url":           result.InvoiceURL,
				"status":        int(entity.WAITING_PAY),
			}},
		).Decode(&inv); err != nil {
			repo.pay.Invoice.ExpireWithContext(ctx, &invoice.ExpireParams{ID: result.ID})
			return nil, toError(err)
		}
		return &inv, nil
	}
	return &inv, nil
}
func (repo *Repository) CompletePayment(ctx context.Context, id primitive.ObjectID, data entity.CompletePayment) (*entity.Invoice, error) {
	var invoice entity.Invoice
	transaction := func(sessionCtx mongo.SessionContext) (interface{}, error) {
		if err := repo.db.FindOneAndUpdate(
			sessionCtx,
			bson.M{
				"_id":           id,
				"status":        int(entity.WAITING_PAY),
				"paymentMethod": bson.M{"$in": []int{int(entity.COD), int(entity.TOP)}},
			},
			bson.M{"$set": bson.M{
				"paid":      data.Paid,
				"status":    int(entity.PAID),
				"paidAt":    time.Now(),
				"updatedAt": time.Now(),
			}},
			options.FindOneAndUpdate().SetReturnDocument(options.After),
		).Decode(&invoice); err != nil {
			return nil, err
		}
		if invoice.PaymentMethod == int(entity.TOP) && invoice.Status == int(entity.PAID) {
			if err := shared.RefundPayLaterUsed(sessionCtx, invoice.Customer.Id, data.Paid); err != nil {
				return nil, err
			}
		}
		if invoice.Price > invoice.Paid {
			invoiceId, err := shared.CreateInvoice(sessionCtx, entity.Create{
				OrderId:    invoice.OrderId,
				RegionId:   invoice.RegionId,
				RegionName: invoice.RegionName,
				BranchId:   invoice.BranchId,
				BranchName: invoice.BranchName,
				Customer:   invoice.Customer,
				Price:      invoice.Price - invoice.Paid,
				Term:       invoice.Term,
			}, entity.WAITING_PAY, entity.PaymentMethod(invoice.PaymentMethod))
			if err != nil {
				return nil, err
			}
			if err := shared.UpdateInvoiceId(sessionCtx, invoice.OrderId, invoiceId); err != nil {
				return nil, err
			}
		} else {
			isComplete, err := shared.IsCompleteDelivery(sessionCtx, invoice.OrderId)
			if err != nil {
				return nil, err
			} else if isComplete {
				if err := shared.CompleteOrder(sessionCtx, invoice.OrderId); err != nil {
					return nil, err
				}
			}
		}
		return &invoice, nil
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
	return &invoice, nil
}
func (repo *Repository) FindByOrderId(ctx context.Context, orderId primitive.ObjectID) ([]*entity.Invoice, error) {
	cur, err := repo.db.Find(ctx, bson.M{"orderId": orderId}, options.Find().SetSort(bson.M{"createdAt": -1}))
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Invoice, 0)
	if err = cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}
func (repo *Repository) FindReport(ctx context.Context, data entity.FindReport) ([]*entity.Invoice, error) {
	find := bson.M{"createdAt": bson.M{"$gt": data.StartAt, "$lt": data.EndAt}, "status": bson.M{"$in": []int{int(entity.PAID), int(entity.CANCEL)}}}
	if data.IsByQuery() {
		find["query"] = bson.M{"$all": strings.Split(data.Query, ",")}
	}
	cur, err := repo.db.Find(ctx, find, options.Find().SetSort(bson.M{"createdAt": -1}))
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Invoice, 0)
	if err = cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}
func (repo *Repository) Callback(ctx context.Context, data entity.XenditCallback) error {
	id, err := primitive.ObjectIDFromHex(data.Id)
	if err != nil {
		return nil
	}
	status := int(entity.PAID)
	paid := data.Amount
	if data.Status == "EXPIRED" {
		status = int(entity.CANCEL)
		paid = 0
	}
	var invoice entity.Invoice
	transaction := func(sessionCtx mongo.SessionContext) (interface{}, error) {
		if err := repo.db.FindOneAndUpdate(
			sessionCtx,
			bson.M{"_id": id, "status": int(entity.WAITING_PAY)},
			bson.M{"$set": bson.M{
				"paid":        paid,
				"method":      data.Method,
				"channel":     data.Channel,
				"destination": data.Destination,
				"status":      status,
				"paidAt":      time.Now(),
				"updatedAt":   time.Now(),
			}},
			options.FindOneAndUpdate().SetReturnDocument(options.After),
		).Decode(&invoice); err != nil {
			if err == mongo.ErrNoDocuments {
				return &invoice, nil
			}
			return nil, err
		}
		if invoice.PaymentMethod == int(entity.TRA) && invoice.Status == int(entity.PAID) {
			if err := shared.WaitingCreatePackingListDelivery(sessionCtx, invoice.OrderId); err != nil {
				return nil, err
			}
			return &invoice, nil
		} else if invoice.PaymentMethod == int(entity.TRA) && invoice.Status == int(entity.CANCEL) {
			if err := shared.CancelOrder(sessionCtx, invoice.OrderId); err != nil {
				return nil, err
			}
			if err := shared.CancelDelivery(sessionCtx, invoice.OrderId); err != nil {
				return nil, err
			}
			return &invoice, nil
		} else if invoice.Paid == invoice.Price {
			if invoice.PaymentMethod == int(entity.TOP) && invoice.Status == int(entity.PAID) {
				if err := shared.RefundPayLaterUsed(sessionCtx, invoice.Customer.Id, invoice.Paid); err != nil {
					return nil, err
				}
			}
			isDeliveryComplete, err := shared.IsCompleteDelivery(sessionCtx, invoice.OrderId)
			if err != nil {
				return nil, err
			} else if isDeliveryComplete {
				if err := shared.CompleteOrder(sessionCtx, invoice.OrderId); err != nil {
					return nil, err
				}
			}
			return &invoice, nil
		} else {
			newInvoiceId, err := shared.CreateInvoice(sessionCtx, entity.Create{
				OrderId:    invoice.OrderId,
				RegionId:   invoice.RegionId,
				RegionName: invoice.RegionName,
				BranchId:   invoice.BranchId,
				BranchName: invoice.BranchName,
				Customer:   invoice.Customer,
				Price:      invoice.Price - invoice.Paid,
				Term:       invoice.Term,
			}, entity.PENDING, entity.PaymentMethod(invoice.PaymentMethod))
			if err != nil {
				return nil, err
			}
			if err := shared.UpdateInvoiceId(sessionCtx, invoice.OrderId, newInvoiceId); err != nil {
				return nil, err
			}
			if invoice.PaymentMethod == int(entity.TOP) && invoice.Status == int(entity.PAID) {
				if err := shared.RefundPayLaterUsed(sessionCtx, invoice.Customer.Id, invoice.Paid); err != nil {
					return nil, err
				}
			}
			return &invoice, nil
		}
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
