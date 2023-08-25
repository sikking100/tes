package repository

import (
	"context"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"github.com/grocee-project/dairyfood/backend/go/api/user/auth/entity"
	pkgAuth "github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"github.com/grocee-project/dairyfood/backend/go/pkg/errors"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Repository struct {
	auth       *auth.Client
	dbOtp      *mongo.Collection
	dbCustomer *mongo.Collection
	dbEmployee *mongo.Collection
}

func NewRepository(ctx context.Context, client *mongo.Client) (*Repository, error) {
	fApp, err := firebase.NewApp(ctx, &firebase.Config{})
	if err != nil {
		return nil, err
	}
	auth, err := fApp.Auth(ctx)
	if err != nil {
		return nil, err
	}
	dbOtp := client.Database("user").Collection("otp")
	if _, err := dbOtp.Indexes().CreateOne(ctx, mongo.IndexModel{
		Keys:    bson.D{{Key: "expiredAt", Value: 1}},
		Options: options.Index().SetExpireAfterSeconds(0),
	}); err != nil {
		return nil, err
	}
	return &Repository{
		auth:       auth,
		dbOtp:      dbOtp,
		dbCustomer: client.Database("user").Collection("customer"),
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
func sendSms(ctx context.Context, phone, message string) error {
	if os.Getenv("ENV") != "production" {
		return nil
	}
	reqData := url.Values{}
	reqData.Set("usertoken_", os.Getenv("SMS_API_TOKEN"))
	reqData.Set("userkey_", os.Getenv("SMS_API_KEY"))
	reqData.Set("mask_", "DAIRYFOOD - Premium")
	reqData.Set("msisdn_", phone)
	reqData.Set("content_", message)
	client := http.Client{}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, "https://api.aptana.co.id/v1/trans_bulk", strings.NewReader(reqData.Encode()))
	if err != nil {
		return err
	}
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded;charset=utf-8")
	req.Header.Add("Content-Length", strconv.Itoa(len(reqData.Encode())))
	res, err := client.Do(req)
	if err != nil {
		return err
	}
	defer client.CloseIdleConnections()
	defer res.Body.Close()
	return nil
}
func (repo *Repository) employee(ctx context.Context, data entity.Login, roles []int) (string, error) {
	var u entity.User
	if err := repo.dbEmployee.FindOne(
		ctx,
		bson.M{
			"phone": bson.M{"$eq": data.Phone},
			"roles": bson.M{"$in": roles},
		},
	).Decode(&u); err != nil {
		return "", toError(err)
	}
	otp := entity.NewOtp(&u, data.FcmToken)
	if _, err := repo.dbOtp.InsertOne(ctx, otp); err != nil {
		return "", toError(err)
	}
	if err := sendSms(ctx, otp.Phone, otp.Message); err != nil {
		return "", toError(errors.Internal(err))
	}
	return otp.Id.Hex(), nil
}
func (repo *Repository) customer(ctx context.Context, data entity.Login) (string, error) {
	var u entity.User
	if err := repo.dbCustomer.FindOne(
		ctx,
		bson.M{
			"phone": bson.M{"$eq": data.Phone},
		},
	).Decode(&u); err != nil {
		return "", toError(err)
	}
	otp := entity.NewOtp(&u, data.FcmToken)
	if _, err := repo.dbOtp.InsertOne(ctx, otp); err != nil {
		return "", toError(err)
	}
	if err := sendSms(ctx, otp.Phone, otp.Message); err != nil {
		return "", toError(errors.Internal(err))
	}
	return otp.Id.Hex(), nil
}

func (repo *Repository) Login(ctx context.Context, data entity.Login) (string, error) {
	switch {
	case data.IsSystemAdmin():
		return repo.employee(ctx, data, []int{int(pkgAuth.SYSTEM_ADMIN)})
	case data.IsFinanceAdmin():
		return repo.employee(ctx, data, []int{int(pkgAuth.FINANCE_ADMIN), int(pkgAuth.BRANCH_FINANCE_ADMIN)})
	case data.IsSalesAdmin():
		return repo.employee(ctx, data, []int{int(pkgAuth.SALES_ADMIN), int(pkgAuth.BRANCH_SALES_ADMIN)})
	case data.IsBranchAdmin():
		return repo.employee(ctx, data, []int{int(pkgAuth.BRANCH_ADMIN)})
	case data.IsWarehouseAdmin():
		return repo.employee(ctx, data, []int{int(pkgAuth.WAREHOUSE_ADMIN), int(pkgAuth.BRANCH_WAREHOUSE_ADMIN)})
	case data.IsLeader():
		return repo.employee(ctx, data, []int{
			int(pkgAuth.DIREKTUR),
			int(pkgAuth.GENERAL_MANAGER),
			int(pkgAuth.NASIONAL_SALES_MANAGER),
			int(pkgAuth.REGIONAL_MANAGER),
			int(pkgAuth.AREA_MANAGER),
		})
	case data.IsSales():
		return repo.employee(ctx, data, []int{int(pkgAuth.SALES)})
	case data.IsCourier():
		return repo.employee(ctx, data, []int{int(pkgAuth.COURIER)})
	default:
		return repo.customer(ctx, data)
	}
}
func (repo *Repository) createToken(ctx context.Context, otp *entity.Otp) (string, error) {
	locationId := ""
	if otp.Location != nil {
		locationId = otp.Location.Id
	}
	token, err := repo.auth.CustomTokenWithClaims(ctx, otp.UserId, map[string]interface{}{
		"roles":      otp.Roles,
		"phone":      otp.Phone,
		"locationId": locationId,
		"team":       otp.Team,
	})
	if err != nil {
		return "", toError(err)
	}
	return token, nil
}

func (repo *Repository) Verify(ctx context.Context, data entity.Verify) (string, error) {
	var otp entity.Otp
	if err := repo.dbOtp.FindOneAndDelete(
		ctx,
		bson.M{
			"_id": bson.M{"$eq": data.Id},
			"otp": bson.M{"$eq": data.Otp},
		},
	).Decode(&otp); err != nil {
		if err == mongo.ErrNoDocuments {
			return "", errors.NotAcceptable(err)
		}
		return "", toError(err)
	}
	if otp.ExpiredAt.Before(time.Now()) {
		return "", errors.NotAcceptable(fmt.Errorf("otp is expired"))
	}
	if otp.IsCustomer() {
		if err := repo.dbCustomer.FindOneAndUpdate(
			ctx,
			bson.M{"_id": bson.M{"$eq": otp.UserId}},
			bson.M{"$set": bson.M{"fcmToken": otp.FcmToken}},
		).Err(); err != nil {
			return "", toError(err)
		}
		return repo.createToken(ctx, &otp)
	}
	if err := repo.dbEmployee.FindOneAndUpdate(
		ctx,
		bson.M{"_id": bson.M{"$eq": otp.UserId}},
		bson.M{"$set": bson.M{"fcmToken": otp.FcmToken}},
	).Err(); err != nil {
		return "", toError(err)
	}
	return repo.createToken(ctx, &otp)
}
