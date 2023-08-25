package repository

import (
	"context"
	"fmt"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/product/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readconcern"
	"go.mongodb.org/mongo-driver/mongo/writeconcern"
)

type Repository struct {
	dbClient    *mongo.Client
	dbPriceList *mongo.Collection
	dbCatalog   *mongo.Collection
	dbProduct   *mongo.Collection
	dbHistory   *mongo.Collection
}

func NewRepository() (*mongo.Client, *Repository, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	client, err := mongo.Connect(ctx, options.Client().ApplyURI(os.Getenv("DB_URI")))
	if err != nil {
		return nil, nil, fmt.Errorf("failed connect db %s", err.Error())
	}
	dbCatalog := client.Database("product").Collection("catalog")
	if _, err := dbCatalog.Indexes().CreateOne(ctx, mongo.IndexModel{Keys: bson.D{
		{Key: "name", Value: "text"}, {Key: "updatedAt", Value: -1},
	}}); err != nil {
		return nil, nil, fmt.Errorf("failed index catalog %s", err.Error())
	}
	dbProduct := client.Database("product").Collection("product")
	if _, err := dbProduct.Indexes().CreateOne(ctx, mongo.IndexModel{Keys: bson.D{
		{Key: "name", Value: "text"}, {Key: "updatedAt", Value: -1},
	}}); err != nil {
		return nil, nil, fmt.Errorf("failed index product %s", err.Error())
	}
	dbHistory := client.Database("product").Collection("history")
	if _, err := dbHistory.Indexes().CreateOne(ctx, mongo.IndexModel{Keys: bson.D{
		{Key: "branchId", Value: 1}, {Key: "createdAt", Value: -1},
	}}); err != nil {
		return nil, nil, fmt.Errorf("failed index history %s", err.Error())
	}
	dbPriceList := client.Database("product").Collection("pricelist")
	if _, err := dbPriceList.Indexes().CreateOne(ctx, mongo.IndexModel{Keys: bson.D{{Key: "name", Value: 1}}}); err != nil {
		return nil, nil, fmt.Errorf("failed index pricelist %s", err.Error())
	}

	return client, &Repository{
		dbClient:    client,
		dbPriceList: dbPriceList,
		dbCatalog:   dbCatalog,
		dbProduct:   dbProduct,
		dbHistory:   dbHistory,
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
func (repo *Repository) FindPriceList(ctx context.Context) ([]*entity.PriceList, error) {
	cur, err := repo.dbPriceList.Find(ctx, bson.M{}, options.Find().SetSort(bson.M{"name": 1}))
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.PriceList, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}
func (repo *Repository) FindPriceListById(ctx context.Context, id string) (*entity.PriceList, error) {
	var result entity.PriceList
	if err := repo.dbPriceList.FindOne(ctx, bson.M{"_id": id}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) SavePriceList(ctx context.Context, id string, data entity.SavePriceList) (*entity.PriceList, error) {
	var result entity.PriceList
	if err := repo.dbPriceList.FindOneAndUpdate(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
		bson.M{
			"$setOnInsert": bson.M{"createdAt": time.Now()},
			"$set": bson.M{
				"name":      data.Name,
				"updatedAt": time.Now(),
			},
		},
		options.FindOneAndUpdate().SetUpsert(true).SetReturnDocument(options.After)).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) DeletePriceList(ctx context.Context, id string) (*entity.PriceList, error) {
	var result entity.PriceList
	if err := repo.dbPriceList.FindOneAndDelete(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func toListProduct(ctx context.Context, cur *mongo.Cursor, err error) ([]*entity.Product, error) {
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Product, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}
func (repo *Repository) FindCatalog(ctx context.Context, data entity.FindCatalog) ([]*entity.Product, error) {
	find := bson.M{}
	if data.IsBySearch() {
		find["$text"] = bson.M{"$search": data.Search}
	}
	if data.Query != "" {
		find["query"] = bson.M{"$all": strings.Split(data.Query, ",")}
	}
	cur, err := repo.dbCatalog.Find(ctx, find, options.Find().SetSort(bson.M{"updatedAt": -1}).SetSkip(int64(data.Num-1)*int64(data.Limit)).SetLimit(int64(data.Limit)))
	return toListProduct(ctx, cur, err)
}
func (repo *Repository) FindCatalogById(ctx context.Context, id string) (*entity.Product, error) {
	var result entity.Product
	if err := repo.dbCatalog.FindOne(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) SaveCatalog(ctx context.Context, id string, data entity.SaveCatalog) (*entity.Product, error) {
	var result entity.Product
	if err := repo.dbCatalog.FindOneAndUpdate(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
		bson.M{
			"$setOnInsert": bson.M{
				"branchId":   "",
				"productId":  id,
				"salesId":    "",
				"salesName":  "",
				"imageUrl":   os.Getenv("IMAGE_URL"),
				"price":      make([]*entity.Price, 0),
				"warehouse":  make([]*entity.Warehouse, 0),
				"orderCount": 0,
				"isVisible":  true,
				"createdAt":  time.Now(),
			},
			"$set": bson.M{
				"category":    data.Category,
				"brand":       data.Brand,
				"name":        data.Name,
				"description": data.Description,
				"size":        data.Size,
				"point":       data.Point,
				"query":       data.Query(),
				"updatedAt":   time.Now(),
			},
		},
		options.FindOneAndUpdate().SetUpsert(true).SetReturnDocument(options.After)).Decode(&result); err != nil {
		return nil, toError(err)
	}
	repo.dbProduct.UpdateMany(ctx, bson.M{"productId": id}, bson.A{bson.M{"$set": bson.M{
		"category":    data.Category,
		"brand":       data.Brand,
		"name":        data.Name,
		"description": data.Description,
		"size":        data.Size,
		"point":       data.Point,
		"query":       bson.A{"$branchId", "$brand._id", "$category._id", bson.M{"$toString": "$category.team"}},
		"updatedAt":   time.Now(),
	}}})
	return &result, nil
}
func (repo *Repository) UpdateCatalogImageUrl(ctx context.Context, id string, imageUrl string) error {
	if _, err := repo.dbCatalog.UpdateOne(ctx, bson.M{"_id": id}, bson.M{"$set": bson.M{"imageUrl": imageUrl, "updatedAt": time.Now()}}); err != nil {
		return toError(err)
	}
	repo.dbProduct.UpdateMany(ctx, bson.M{"productId": id}, bson.M{"$set": bson.M{
		"imageUrl":  imageUrl,
		"updatedAt": time.Now(),
	}})
	return nil
}
func (repo *Repository) DeleteCatalog(ctx context.Context, id string) (*entity.Product, error) {
	var result entity.Product
	if err := repo.dbCatalog.FindOneAndDelete(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) FindProduct(ctx context.Context, data entity.FindProduct) (*entity.PageProduct, error) {
	if data.IsBySearch() {
		cur, err := repo.dbProduct.Aggregate(ctx, bson.A{
			bson.M{"$match": bson.M{
				"query": bson.M{"$all": strings.Split(data.Query, ",")},
				"name":  bson.M{"$regex": primitive.Regex{Pattern: fmt.Sprintf("^%s.*", data.Search), Options: "i"}},
			}},
			bson.M{"$limit": 10},
		})
		return data.ToPage(toListProduct(ctx, cur, err))
	}
	option := options.Find().SetSort(bson.M{"updatedAt": -1}).SetSkip(int64(data.Num-1) * int64(data.Limit)).SetLimit(int64(data.Limit))
	query := bson.M{"query": bson.M{"$all": strings.Split(data.Query, ",")}}
	if data.IsSortOrder() {
		query["orderCount"] = bson.M{"$gt": 0}
		option = options.Find().SetSort(bson.M{"orderCount": -1}).SetSkip(int64(data.Num-1) * int64(data.Limit)).SetLimit(int64(data.Limit))
	} else if data.IsSortDiscount() {
		query["price"] = bson.M{"$elemMatch": bson.M{"discount": bson.M{"$elemMatch": bson.M{"expiredAt": bson.M{"$gt": time.Now()}}}}}
		option = options.Find().SetSort(bson.M{"price.discount.discount": -1}).SetSkip(int64(data.Num-1) * int64(data.Limit)).SetLimit(int64(data.Limit))
	}
	cur, err := repo.dbProduct.Find(ctx, query, option)
	return data.ToPage(toListProduct(ctx, cur, err))
}
func (repo *Repository) findProductBranch(ctx context.Context, wg *sync.WaitGroup, price []*entity.Price, items []*entity.Product, index int, branchId string) {
	defer wg.Done()
	items[index].Id = entity.ProductId(branchId, items[index].Id)
	items[index].BranchId = branchId
	items[index].Price = price
	var p entity.Product
	if err := repo.dbProduct.FindOne(ctx, bson.M{"_id": items[index].Id}).Decode(&p); err != nil {
		return
	}
	items[index].SalesId = p.SalesId
	items[index].SalesName = p.SalesName
	if items[index].Price == nil || len(items[index].Price) == 0 {
		items[index].Price = price
	}
	items[index].Price = append(items[index].Price, price...)
	idx := make(map[string]*entity.Price)
	for i := 0; i < len(items[index].Price); i++ {
		if it, ok := idx[items[index].Price[i].Id]; ok {
			it.Price += idx[items[index].Price[i].Id].Price
			continue
		}
		idx[items[index].Price[i].Id] = items[index].Price[i]
	}
	newPrice := make([]*entity.Price, 0)
	for _, r := range idx {
		newPrice = append(newPrice, r)
	}
	items[index].Price = newPrice
}
func (repo *Repository) findAllPriceList(ctx context.Context) ([]*entity.Price, error) {
	cur, err := repo.dbPriceList.Find(ctx, bson.M{})
	if err != nil {
		return nil, err
	}
	items := make([]*entity.PriceList, 0)
	if err = cur.All(ctx, &items); err != nil {
		return nil, err
	}
	result := make([]*entity.Price, 0)
	for _, it := range items {
		result = append(result, &entity.Price{Id: it.Id, Name: it.Name, Price: 0, Discount: make([]*entity.Discount, 0)})
	}
	return result, nil
}
func (repo *Repository) findAllCatalog(ctx context.Context) ([]*entity.Product, error) {
	cur, err := repo.dbCatalog.Find(ctx, bson.M{})
	if err != nil {
		return nil, err
	}
	result := make([]*entity.Product, 0)
	if err = cur.All(ctx, &result); err != nil {
		return nil, err
	}
	return result, nil
}

func (repo *Repository) FindProductImportPrice(ctx context.Context, branchId string) ([]*entity.Product, error) {
	priceList, err := repo.findAllPriceList(ctx)
	if err != nil {
		return nil, toError(err)
	}
	product, err := repo.findAllCatalog(ctx)
	if err != nil {
		return nil, toError(err)
	}
	var wg sync.WaitGroup
	for i := 0; i < len(product); i++ {
		wg.Add(1)
		go repo.findProductBranch(ctx, &wg, priceList, product, i, branchId)
	}
	wg.Wait()
	return product, nil
}
func (repo *Repository) FindProductImportQty(ctx context.Context, branchId string) ([]*entity.Product, error) {
	cur, err := repo.dbProduct.Find(ctx, bson.M{"branchId": branchId})
	if err != nil {
		return nil, toError(err)
	}
	result := make([]*entity.Product, 0)
	if err := cur.All(ctx, &result); err != nil {
		return nil, toError(err)
	}
	return result, nil
}

func (repo *Repository) FindProductById(ctx context.Context, id string) (*entity.Product, error) {
	var result entity.Product
	if err := repo.dbProduct.FindOne(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) SaveProduct(ctx context.Context, id string, data *entity.SaveProduct) (*entity.Product, error) {
	var result entity.Product
	if err := repo.dbProduct.FindOneAndUpdate(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
		bson.M{
			"$setOnInsert": bson.M{
				"branchId":   data.BranchId,
				"productId":  data.ProductId,
				"warehouse":  make([]*entity.Warehouse, 0),
				"orderCount": 0,
				"isVisible":  true,
				"createdAt":  time.Now(),
			},
			"$set": bson.M{
				"salesId":     data.SalesId,
				"salesName":   data.SalesName,
				"category":    data.Category,
				"brand":       data.Brand,
				"name":        data.Name,
				"description": data.Description,
				"size":        data.Size,
				"imageUrl":    data.ImageUrl,
				"point":       data.Point,
				"price":       data.Price,
				"query":       data.Query(),
				"updatedAt":   time.Now(),
			},
		},
		options.FindOneAndUpdate().SetUpsert(true).SetReturnDocument(options.After)).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) AddQtyProduct(ctx context.Context, id string, data entity.AddQty) (*entity.Product, error) {
	wc := writeconcern.New(writeconcern.WMajority())
	rc := readconcern.Snapshot()
	txnOpts := options.Transaction().SetWriteConcern(wc).SetReadConcern(rc)
	session, err := repo.dbClient.StartSession()
	if err != nil {
		return nil, toError(err)
	}
	defer session.EndSession(ctx)
	var result entity.Product
	err = mongo.WithSession(ctx, session, func(sessionContext mongo.SessionContext) error {
		if err = session.StartTransaction(txnOpts); err != nil {
			return err
		}
		if err := repo.dbProduct.FindOne(sessionContext, bson.M{"_id": bson.M{"$eq": id}}).Decode(&result); err != nil {
			return err
		}
		history := data.Create(&result)
		if err := repo.dbProduct.FindOneAndUpdate(
			sessionContext,
			bson.M{"_id": bson.M{"$eq": result.Id}},
			bson.M{"$set": bson.M{
				"warehouse": result.Warehouse,
				"updatedAt": result.UpdatedAt,
			}},
			options.FindOneAndUpdate().SetReturnDocument(options.After)).Decode(&result); err != nil {
			return err
		}
		if _, err := repo.dbHistory.InsertOne(sessionContext, history); err != nil {
			return err
		}
		return session.CommitTransaction(sessionContext)
	})
	if err != nil {
		if abortErr := session.AbortTransaction(ctx); abortErr != nil {
			return nil, toError(err)
		}
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) TransferQtyProduct(ctx context.Context, branchId, id string, data entity.TransferQty) (*entity.Product, error) {
	wc := writeconcern.New(writeconcern.WMajority())
	rc := readconcern.Snapshot()
	txnOpts := options.Transaction().SetWriteConcern(wc).SetReadConcern(rc)
	session, err := repo.dbClient.StartSession()
	if err != nil {
		return nil, toError(err)
	}
	defer session.EndSession(ctx)
	var result entity.Product
	err = mongo.WithSession(ctx, session, func(sessionContext mongo.SessionContext) error {
		if err = session.StartTransaction(txnOpts); err != nil {
			return err
		}
		if err := repo.dbProduct.FindOne(
			sessionContext,
			bson.M{
				"_id":       bson.M{"$eq": id},
				"branchId":  bson.M{"$eq": branchId},
				"warehouse": bson.M{"$elemMatch": bson.M{"_id": data.FromWarehouseId, "qty": bson.M{"$gte": data.Qty}}},
			}).Decode(&result); err != nil {
			return err
		}
		history := data.Create(&result)
		if err := repo.dbProduct.FindOneAndUpdate(
			sessionContext,
			bson.M{"_id": bson.M{"$eq": result.Id}},
			bson.M{"$set": bson.M{
				"warehouse": result.Warehouse,
				"updatedAt": result.UpdatedAt,
			}},
			options.FindOneAndUpdate().SetReturnDocument(options.After)).Decode(&result); err != nil {
			return err
		}
		if _, err := repo.dbHistory.InsertOne(sessionContext, history); err != nil {
			return err
		}
		return session.CommitTransaction(sessionContext)
	})
	if err != nil {
		if abortErr := session.AbortTransaction(ctx); abortErr != nil {
			return nil, toError(err)
		}
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) DeleteProduct(ctx context.Context, branchId, id string) (*entity.Product, error) {
	var result entity.Product
	if err := repo.dbProduct.FindOneAndUpdate(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}, "branchId": bson.M{"$eq": branchId}},
		bson.A{bson.M{"$set": bson.M{
			"isVisible": bson.M{"$cond": bson.A{bson.M{"$eq": bson.A{"$isVisible", false}}, true, false}},
			"updatedAt": time.Now(),
		}}},
		options.FindOneAndUpdate().SetReturnDocument(options.After)).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func toListHistoryQty(ctx context.Context, cur *mongo.Cursor, err error) ([]*entity.HistoryQty, error) {
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.HistoryQty, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}
func (repo *Repository) FindHistory(ctx context.Context, data entity.FindHistory) (*entity.PageHistoryQty, error) {
	option := options.Find().SetSort(bson.M{"createdAt": -1}).SetSkip(int64(data.Num-1) * int64(data.Limit)).SetLimit(int64(data.Limit))
	switch {
	case data.IsByBranch():
		cur, err := repo.dbHistory.Find(ctx, bson.M{"branchId": data.BranchId}, option)
		return data.ToPage(toListHistoryQty(ctx, cur, err))
	default:
		cur, err := repo.dbHistory.Find(ctx, bson.M{}, option)
		return data.ToPage(toListHistoryQty(ctx, cur, err))
	}
}
func (repo *Repository) FindHistoryById(ctx context.Context, id primitive.ObjectID) (*entity.HistoryQty, error) {
	var result entity.HistoryQty
	if err := repo.dbHistory.FindOne(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) FindSalesProduct(ctx context.Context, branchId string) ([]*entity.SalesProduct, error) {
	cur, err := repo.dbProduct.Aggregate(ctx, bson.A{
		bson.M{"$match": bson.M{"branchId": branchId}},
		bson.M{"$group": bson.M{
			"_id":          "$salesId",
			"name":         bson.M{"$first": "$salesName"},
			"totalProduct": bson.M{"$sum": 1},
		}},
	})
	if err != nil {
		return nil, toError(err)
	}
	result := make([]*entity.SalesProduct, 0)
	if err := cur.All(ctx, &result); err != nil {
		return nil, toError(err)
	}
	return result, nil
}
func (repo *Repository) UpdateSalesProduct(ctx context.Context, data entity.SaveSalesProduct) (*entity.Product, error) {
	var result entity.Product
	if err := repo.dbProduct.FindOneAndUpdate(ctx, bson.M{"_id": data.Id}, bson.M{"$set": bson.M{
		"salesId":   data.SalesId,
		"salesName": data.SalesName,
		"query":     data.Query(),
		"updatedAt": time.Now(),
	}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
