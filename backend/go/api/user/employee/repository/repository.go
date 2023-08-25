package repository

import (
	"context"
	"fmt"
	"os"
	"strconv"
	"sync"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/api/user/employee/entity"
	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Repository struct {
	db *mongo.Collection
}

func NewRepository(ctx context.Context, client *mongo.Client) (*Repository, error) {
	dbEmployee := client.Database("user").Collection("employee")
	if _, err := dbEmployee.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{Keys: bson.D{{Key: "phone", Value: 1}, {Key: "email", Value: 1}}, Options: options.Index().SetUnique(true)},
		{Keys: bson.D{{Key: "name", Value: "text"}, {Key: "email", Value: "text"}, {Key: "updatedAt", Value: -1}}},
	}); err != nil {
		return nil, err
	}
	return &Repository{
		db: dbEmployee,
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
func listEmployee(ctx context.Context, cur *mongo.Cursor, err error) ([]*entity.Employee, error) {
	if err != nil {
		return nil, toError(err)
	}
	items := make([]*entity.Employee, 0)
	if err := cur.All(ctx, &items); err != nil {
		return nil, toError(err)
	}
	return items, nil
}
func (repo *Repository) Find(ctx context.Context, data entity.Find) (*entity.Page, error) {
	if data.IsBySearch() {
		if data.IsByQuery() {
			cur, err := repo.db.Find(ctx, bson.M{
				"$text": bson.M{"$search": data.Search},
				"query": bson.M{"$all": data.GetQuery()},
			}, options.Find().SetLimit(5))
			return data.ToPage(listEmployee(ctx, cur, err))
		} else {
			cur, err := repo.db.Find(ctx, bson.M{
				"$text": bson.M{"$search": data.Search},
			}, options.Find().SetLimit(5))
			return data.ToPage(listEmployee(ctx, cur, err))
		}
	}
	query := bson.M{}
	if data.IsByQuery() {
		query = bson.M{"query": bson.M{"$all": data.GetQuery()}}
	}
	cur, err := repo.db.Find(
		ctx,
		query,
		options.Find().SetSort(bson.M{"updatedAt": -1}).SetSkip(int64(data.Num-1)*int64(data.Limit)).SetLimit(int64(data.Limit)),
	)
	return data.ToPage(listEmployee(ctx, cur, err))
}
func (repo *Repository) findEmployee(ctx context.Context, wg *sync.WaitGroup, find bson.M, employee []*entity.Employee, index int) {
	defer wg.Done()
	var u entity.Employee
	if err := repo.db.FindOne(ctx, find).Decode(&u); err != nil {
		employee[index] = nil
		return
	}
	employee[index] = &u
}
func (repo *Repository) FindApproverCredit(ctx context.Context, userId string, data entity.FindApprover) ([]*entity.UserApprover, error) {
	find := []bson.M{
		{"_id": userId},
		{"query": bson.M{"$all": []string{strconv.Itoa(int(auth.AREA_MANAGER)), strconv.Itoa(data.Team), data.BranchId}}},
		{"query": bson.M{"$all": []string{strconv.Itoa(int(auth.REGIONAL_MANAGER)), strconv.Itoa(data.Team), data.RegionId}}},
		{"query": bson.M{"$all": []string{strconv.Itoa(int(auth.NASIONAL_SALES_MANAGER)), strconv.Itoa(data.Team)}}},
		{"query": bson.M{"$all": []string{strconv.Itoa(int(auth.FINANCE_ADMIN))}}},
		{"query": bson.M{"$all": []string{strconv.Itoa(int(auth.GENERAL_MANAGER)), strconv.Itoa(data.Team)}}},
	}
	if data.Team == 2 {
		find[3] = bson.M{"query": bson.M{"$all": []string{strconv.Itoa(int(auth.GENERAL_MANAGER)), strconv.Itoa(data.Team)}}}
		find[5] = bson.M{"query": bson.M{"$all": []string{strconv.Itoa(int(auth.DIREKTUR)), strconv.Itoa(data.Team)}}}
	}

	employee := make([]*entity.Employee, len(find))
	var wg sync.WaitGroup
	for i, f := range find {
		wg.Add(1)
		go repo.findEmployee(ctx, &wg, f, employee, i)
	}
	wg.Wait()
	if employee[0] == nil {
		return nil, fmt.Errorf("sales admin not found")
	}
	return entity.ToUserApprover(employee), nil
}
func (repo *Repository) FindApproverTop(ctx context.Context, data entity.FindApprover) ([]*entity.UserApprover, error) {
	find := []bson.M{
		{"_id": bson.M{"$all": []string{strconv.Itoa(int(auth.SALES_ADMIN))}}},
		{"query": bson.M{"$all": []string{strconv.Itoa(int(auth.AREA_MANAGER)), strconv.Itoa(data.Team), data.BranchId}}},
		{"query": bson.M{"$all": []string{strconv.Itoa(int(auth.REGIONAL_MANAGER)), strconv.Itoa(data.Team), data.RegionId}}},
		{"query": bson.M{"$all": []string{strconv.Itoa(int(auth.NASIONAL_SALES_MANAGER)), strconv.Itoa(data.Team)}}},
		{"query": bson.M{"$all": []string{strconv.Itoa(int(auth.FINANCE_ADMIN))}}},
		{"query": bson.M{"$all": []string{strconv.Itoa(int(auth.GENERAL_MANAGER)), strconv.Itoa(data.Team)}}},
	}
	if data.Team == 2 {
		find[3] = bson.M{"query": bson.M{"$all": []string{strconv.Itoa(int(auth.GENERAL_MANAGER)), strconv.Itoa(data.Team)}}}
		find[5] = bson.M{"query": bson.M{"$all": []string{strconv.Itoa(int(auth.DIREKTUR)), strconv.Itoa(data.Team)}}}
	}
	employee := make([]*entity.Employee, len(find))
	var wg sync.WaitGroup
	for i, f := range find {
		wg.Add(1)
		go repo.findEmployee(ctx, &wg, f, employee, i)
	}
	wg.Wait()
	return entity.ToUserApprover(employee), nil
}
func (repo *Repository) FindById(ctx context.Context, id string) (*entity.Employee, error) {
	var result entity.Employee
	if err := repo.db.FindOne(ctx, bson.M{"_id": bson.M{"$eq": id}}).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func toSave(data entity.Save) bson.M {
	return bson.M{
		"$setOnInsert": bson.M{
			"imageUrl":  os.Getenv("IMAGE_URL"),
			"fcmToken":  "",
			"createdAt": time.Now(),
		},
		"$set": bson.M{
			"phone":     data.Phone,
			"email":     data.Email,
			"name":      data.Name,
			"roles":     data.Roles,
			"location":  data.Location,
			"team":      data.Team,
			"query":     data.Query,
			"updatedAt": time.Now(),
		},
	}
}
func (repo *Repository) Save(ctx context.Context, id string, data entity.Save) (*entity.Employee, error) {
	var result entity.Employee
	if err := repo.db.FindOneAndUpdate(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
		toSave(data),
		options.FindOneAndUpdate().SetUpsert(true).SetReturnDocument(options.After),
	).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) SaveInBranch(ctx context.Context, id string, data entity.Save) (*entity.Employee, error) {
	var result entity.Employee
	if err := repo.db.FindOneAndUpdate(
		ctx,
		bson.M{
			"_id":          bson.M{"$eq": id},
			"location._id": bson.M{"$eq": data.Location.Id},
		},
		toSave(data),
		options.FindOneAndUpdate().SetUpsert(true).SetReturnDocument(options.After),
	).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) UpdateAccount(ctx context.Context, id string, data entity.UpdateAccount) (*entity.Employee, error) {
	var result entity.Employee
	if err := repo.db.FindOneAndUpdate(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
		bson.M{
			"$set": bson.M{
				"phone":     data.Phone,
				"name":      data.Name,
				"email":     data.Email,
				"updatedAt": time.Now(),
			},
		},
		options.FindOneAndUpdate().SetReturnDocument(options.After),
	).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) UpdateImageUrl(ctx context.Context, id, imageUrl string) error {
	_, err := repo.db.UpdateOne(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
		bson.M{
			"$set": bson.M{
				"imageUrl":  imageUrl,
				"updatedAt": time.Now(),
			},
		},
	)
	return toError(err)
}
func (repo *Repository) Delete(ctx context.Context, id string) (*entity.Employee, error) {
	var result entity.Employee
	if err := repo.db.FindOneAndDelete(
		ctx,
		bson.M{"_id": bson.M{"$eq": id}},
	).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
func (repo *Repository) DeleteInBranch(ctx context.Context, id, locationId string) (*entity.Employee, error) {
	var result entity.Employee
	if err := repo.db.FindOneAndDelete(
		ctx,
		bson.M{
			"_id":          bson.M{"$eq": id},
			"location._id": bson.M{"$eq": locationId},
		},
	).Decode(&result); err != nil {
		return nil, toError(err)
	}
	return &result, nil
}
