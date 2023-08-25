package repository

import (
	"context"
	"log"
	"strconv"
	"strings"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/user/customer/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readconcern"
	"go.mongodb.org/mongo-driver/mongo/writeconcern"
)

type Repository struct {
	dbClient   *mongo.Client
	dbCustomer *mongo.Collection
	dbApply    *mongo.Collection
	dbEmployee *mongo.Collection
}

func NewRepository(ctx context.Context, client *mongo.Client) (*Repository, error) {
	dbCustomer := client.Database("user").Collection("customer")
	if _, err := dbCustomer.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{Keys: bson.D{{Key: "phone", Value: 1}, {Key: "email", Value: 1}}, Options: options.Index().SetUnique(true)},
		{Keys: bson.D{{Key: "name", Value: "text"}, {Key: "email", Value: "text"}, {Key: "updatedAt", Value: -1}}},
	}); err != nil {
		return nil, err
	}
	dbApply := client.Database("user").Collection("customer-apply")
	if _, err := dbApply.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{Keys: bson.D{{Key: "customer.phone", Value: 1}, {Key: "customer.email", Value: 1}}, Options: options.Index().SetUnique(true)},
		{Keys: bson.D{{Key: "name", Value: "text"}, {Key: "email", Value: "text"}, {Key: "updatedAt", Value: -1}}},
	}); err != nil {
		return nil, err
	}
	return &Repository{
		dbClient:   client,
		dbCustomer: dbCustomer,
		dbApply:    dbApply,
		dbEmployee: client.Database("user").Collection("employee"),
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
func listCustomer(ctx context.Context, cur *mongo.Cursor, err error) ([]*entity.Customer, error) {
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Customer, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}
func (repo *Repository) FindCustomer(ctx context.Context, data entity.FindCustomer) (*entity.PageCustomer, error) {
	log.Print(repo.dbCustomer.Name())
	if data.IsBySearch() {
		if data.IsByQuery() {
			cur, err := repo.dbCustomer.Find(ctx, bson.M{
				"$text": bson.M{"$search": data.Search},
				"query": bson.M{"$all": strings.Split(data.Query, ",")},
			}, options.Find().SetLimit(5))
			return data.ToPage(listCustomer(ctx, cur, err))
		} else {
			cur, err := repo.dbCustomer.Find(ctx, bson.M{
				"$text": bson.M{"$search": data.Search},
			}, options.Find().SetLimit(5))
			return data.ToPage(listCustomer(ctx, cur, err))
		}
	}
	query := bson.M{}
	if data.IsByQuery() {
		query = bson.M{"query": bson.M{"$all": strings.Split(data.Query, ",")}}
	}
	cur, err := repo.dbCustomer.Find(
		ctx,
		query,
		options.Find().SetSort(bson.M{"updatedAt": -1}).SetSkip(int64(data.Num-1)*int64(data.Limit)).SetLimit(int64(data.Limit)),
	)
	return data.ToPage(listCustomer(ctx, cur, err))
}
func (repo *Repository) CreateCustomer(ctx context.Context, data entity.SaveAccount) (*entity.Customer, error) {
	result := data.NewAccount()
	if _, err := repo.dbCustomer.InsertOne(ctx, result); err != nil {
		return nil, toError(err)
	}
	return result, nil
}
func (repo *Repository) FindOrCreateCustomer(ctx context.Context, data entity.SaveAccount) (*entity.Customer, error) {
	var result entity.Customer
	if err := repo.dbCustomer.FindOne(ctx, bson.M{"phone": data.Phone}).Decode(&result); err != nil {
		if err == mongo.ErrNoDocuments {
			return repo.CreateCustomer(ctx, data)
		}
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) FindCustomerById(ctx context.Context, id string) (*entity.Customer, error) {
	var result entity.Customer
	if err := repo.dbCustomer.FindOne(ctx, bson.M{"_id": id}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) UpdateAccount(ctx context.Context, id string, data entity.SaveAccount) (*entity.Customer, error) {
	var result entity.Customer
	if err := repo.dbCustomer.FindOneAndUpdate(ctx, bson.M{"_id": id}, bson.M{"$set": bson.M{
		"phone":     data.Phone,
		"email":     data.Email,
		"name":      data.Name,
		"updatedAt": time.Now(),
	}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) UpdateBusiness(ctx context.Context, id string, data entity.UpdateBusiness) (*entity.Customer, error) {
	var cus entity.Customer
	if err := repo.dbCustomer.FindOne(ctx, bson.M{"_id": id}).Decode(&cus); err != nil {
		return nil, err
	}
	query := []string{strconv.Itoa(data.Viewer), cus.Business.Location.RegionId, cus.Business.Location.BranchId}
	var result entity.Customer
	if err := repo.dbCustomer.FindOneAndUpdate(
		ctx,
		bson.M{
			"_id":      bson.M{"$eq": id},
			"business": bson.M{"$ne": nil},
		},
		bson.M{"$set": bson.M{
			"business.location": data.Location,
			"business.pic":      data.Pic,
			"business.address":  data.Address,
			"business.viewer":   data.Viewer,
			"business.tax":      data.Tax,
			"query":             query,
			"updatedAt":         time.Now(),
		}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) UpdateImage(ctx context.Context, id string, imageUrl string) error {
	query := bson.M{"_id": bson.M{"$eq": id}}
	if _, err := repo.dbCustomer.UpdateOne(ctx, query, bson.M{"$set": bson.M{
		"imageUrl":  imageUrl,
		"updatedAt": time.Now(),
	}}); err != nil {
		return toError(err)
	}
	if _, err := repo.dbApply.UpdateOne(ctx, query, bson.M{"$set": bson.M{"customer.imageUrl": imageUrl}}); err != nil {
		return toError(err)
	}
	return nil
}
func listApply(ctx context.Context, cur *mongo.Cursor, err error) ([]*entity.Apply, error) {
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Apply, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}
func (repo *Repository) FindApply(ctx context.Context, data entity.FindApply) (*entity.PageApply, error) {
	switch {
	case data.IsByWaitingLimit():
		cur, err := repo.dbApply.Find(ctx, bson.M{"userApprover": bson.M{"$eq": make([]*entity.ApplyUserApprover, 0)}}, options.Find().SetSort(bson.M{"expiredAt": 1}))
		return data.ToPage(listApply(ctx, cur, err))
	case data.IsByWaitingApprove():
		cur, err := repo.dbApply.Find(ctx, bson.M{"userApprover": bson.M{"$elemMatch": bson.M{"_id": bson.M{"$eq": data.UserId}, "status": bson.M{"$eq": int(entity.APPLY_WAITING_APPROVE)}}}}, options.Find().SetSort(bson.M{"expiredAt": 1}))
		return data.ToPage(listApply(ctx, cur, err))
	case data.IsByWaitingCreate():
		cur, err := repo.dbApply.Find(ctx, bson.M{"status": int(entity.APPLY_APPROVE), "type": int(entity.NEW_BUSINESS)}, options.Find().SetSort(bson.M{"expiredAt": 1}))
		return data.ToPage(listApply(ctx, cur, err))
	default:
		cur, err := repo.dbApply.Find(ctx, bson.M{"userApprover": bson.M{"$elemMatch": bson.M{"_id": bson.M{"$eq": data.UserId}}}}, options.Find().SetSort(bson.M{"expiredAt": 1}).SetSkip(int64(data.Num-1)*int64(data.Limit)).SetLimit(int64(data.Limit)))
		return data.ToPage(listApply(ctx, cur, err))
	}
}
func (repo *Repository) CreateBusiness(ctx context.Context, data entity.CreateBusiness) (*entity.Apply, error) {
	var result entity.Apply
	transaction := func(sessionContext mongo.SessionContext) (interface{}, error) {
		if err := repo.dbApply.FindOneAndDelete(
			sessionContext,
			bson.M{"_id": data.ApplyId, "status": int(entity.APPLY_APPROVE)},
		).Decode(&result); err != nil {
			return nil, err
		}
		if err := repo.dbCustomer.FindOneAndDelete(sessionContext, bson.M{"_id": data.ApplyId, "business": bson.M{"$eq": nil}}).Err(); err != nil {
			return nil, err
		}
		if _, err := repo.dbCustomer.InsertOne(sessionContext, entity.NewCreateBusiness(data, &result)); err != nil {
			return nil, err
		}
		return &result, nil
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
	return &result, nil
}
func (repo *Repository) FindApplyById(ctx context.Context, id string) (*entity.Apply, error) {
	var result entity.Apply
	if err := repo.dbApply.FindOne(ctx, bson.M{"_id": id}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) ApplyNewBusiness(ctx context.Context, data entity.ApplyNewBusiness) (*entity.Apply, error) {
	var result *entity.Apply
	transaction := func(sessionContext mongo.SessionContext) (interface{}, error) {
		var customer entity.Customer
		if err := repo.dbCustomer.FindOne(
			sessionContext,
			bson.M{"_id": data.Customer.Id, "business": bson.M{"$eq": nil}},
		).Decode(&customer); err != nil {
			return nil, err
		}
		result = entity.CreateNewApplyBusiness(data, &customer)
		if _, err := repo.dbApply.InsertOne(sessionContext, result); err != nil {
			return nil, err
		}
		return result, nil
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
	return result, nil
}
func (repo *Repository) ApplyNewLimit(ctx context.Context, data entity.ApplyNewLimit) (*entity.Apply, error) {
	result, err := data.CreateApplyNewLimit()
	if err != nil {
		return nil, toError(errors.BadRequest(err))
	}
	transaction := func(sessionContext mongo.SessionContext) (interface{}, error) {
		if err := repo.dbCustomer.FindOne(
			sessionContext,
			bson.M{"_id": data.Id, "business": bson.M{"$ne": nil}},
		).Err(); err != nil {
			return nil, err
		}
		if _, err := repo.dbApply.InsertOne(sessionContext, result); err != nil {
			return nil, err
		}
		if result.Status == int(entity.APPLY_APPROVE) {
			if err := repo.dbCustomer.FindOneAndUpdate(sessionContext, bson.M{"_id": data.Id}, bson.A{bson.M{"$set": bson.M{
				"business.credit.limit":       data.CreditProposal.Limit,
				"business.credit.term":        data.CreditProposal.Term,
				"business.credit.termInvoice": data.CreditProposal.TermInvoice,
			}}}).Err(); err != nil {
				return nil, toError(err)
			}
		}
		return result, nil
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
	return result, nil
}

func (repo *Repository) ApproveBySalesAdmin(ctx context.Context, data entity.Approve) (*entity.Apply, error) {
	status, err := entity.MakeApprove(&data)
	if err != nil {
		return nil, errors.Internal(err)
	}
	var result entity.Apply
	if err := repo.dbApply.FindOneAndUpdate(
		ctx,
		bson.M{"_id": data.Id, "userApprover": bson.M{"$size": 0}},
		bson.M{"$set": bson.M{
			"userApprover":   data.UserApprover,
			"creditProposal": data.CreditProposal,
			"status":         status,
			"priceList":      data.PriceList,
			"team":           data.Team,
			"updatedAt":      time.Now(),
		}},
	).Decode(&result); err != nil {
		return nil, err
	}
	return &result, nil
}
func (repo *Repository) RejectBySalesAdmin(ctx context.Context, data entity.Reject) (*entity.Apply, error) {
	var result entity.Apply
	if err := repo.dbApply.FindOneAndUpdate(
		ctx,
		bson.M{"_id": data.Id, "userApprover": bson.M{"$size": 0}},
		bson.M{"$set": bson.M{
			"status":    int(entity.APPLY_REJECT),
			"updatedAt": time.Now(),
		}},
	).Decode(&result); err != nil {
		return nil, err
	}
	return &result, nil
}
func (repo *Repository) Approve(ctx context.Context, userId string, data entity.Approve) (*entity.Apply, error) {
	status, err := entity.MakeApprove(&data)
	if err != nil {
		return nil, errors.Internal(err)
	}
	var result entity.Apply
	if err := repo.dbApply.FindOneAndUpdate(
		ctx,
		bson.M{"_id": data.Id, "userApprover": bson.M{"$elemMatch": bson.M{
			"_id":    userId,
			"status": int(entity.APPLY_WAITING_APPROVE),
		}}},
		bson.M{"$set": bson.M{
			"userApprover":   data.UserApprover,
			"creditProposal": data.CreditProposal,
			"status":         status,
			"updatedAt":      time.Now(),
		}},
		options.FindOneAndUpdate().SetReturnDocument(options.After),
	).Decode(&result); err != nil {
		return nil, toError(err)
	}
	if result.Status == int(entity.APPLY_APPROVE) && result.Type == int(entity.NEW_LIMIT) {
		if err := repo.dbCustomer.FindOneAndUpdate(ctx, bson.M{"_id": data.Id}, bson.A{bson.M{"$set": bson.M{
			"business.credit.limit":       data.CreditProposal.Limit,
			"business.credit.term":        data.CreditProposal.Term,
			"business.credit.termInvoice": data.CreditProposal.TermInvoice,
		}}}).Err(); err != nil {
			return nil, toError(err)
		}
	}
	return &result, nil
}
func (repo *Repository) Reject(ctx context.Context, userId string, data entity.Reject) (*entity.Apply, error) {
	entity.MakeReject(&data)
	var result entity.Apply
	if err := repo.dbApply.FindOneAndUpdate(
		ctx,
		bson.M{"_id": data.Id, "userApprover": bson.M{"$elemMatch": bson.M{
			"_id":    userId,
			"status": int(entity.APPLY_WAITING_APPROVE),
		}}},
		bson.M{"$set": bson.M{
			"userApprover": data.UserApprover,
			"status":       int(entity.APPLY_REJECT),
			"updatedAt":    time.Now(),
		}},
	).Decode(&result); err != nil {
		return nil, err
	}
	return &result, nil
}
