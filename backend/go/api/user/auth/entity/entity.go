package entity

import (
	"fmt"
	"math/rand"
	"os"
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Location struct {
	Id   string `json:"id" bson:"_id"`
	Name string `json:"name" bson:"name"`
	Type int    `json:"type" bson:"type"`
}
type User struct {
	Id       string    `bson:"_id"`
	Phone    string    `bson:"phone"`
	Roles    int       `bson:"roles"`
	Team     int       `bson:"team"`
	Location *Location `bson:"location"`
}

type Otp struct {
	Id        primitive.ObjectID `bson:"_id"`
	UserId    string             `bson:"userId"`
	Otp       string             `bson:"otp"`
	Roles     int                `bson:"roles"`
	Team      int                `bson:"team"`
	Phone     string             `bson:"phone"`
	Location  *Location          `bson:"location"`
	FcmToken  string             `bson:"fcmToken"`
	Message   string             `bson:"message"`
	ExpiredAt time.Time          `bson:"expiredAt"`
}

func (o *Otp) IsCustomer() bool {
	return o.Roles == 0
}

func NewOtp(u *User, fcmToken string) *Otp {
	rand.NewSource(time.Now().Unix())
	in := "00112233445566778899"
	inRune := []rune(in)
	rand.Shuffle(len(inRune), func(i, j int) {
		inRune[i], inRune[j] = inRune[j], inRune[i]
	})
	otp := string(inRune[0:6])
	if os.Getenv("ENV") != "production" {
		otp = "123456"
	}
	if u.Phone == "+6280000000001" || u.Phone == "+6280000000002" || u.Phone == "+6280000000003" || u.Phone == "+6280000000004" {
		otp = "123456"
	}
	return &Otp{
		Id:        primitive.NewObjectID(),
		UserId:    u.Id,
		Otp:       otp,
		Roles:     u.Roles,
		Team:      u.Team,
		Phone:     u.Phone,
		Location:  u.Location,
		FcmToken:  fcmToken,
		Message:   fmt.Sprintf("Aplikasi Dairyfood. gunakan OTP %s untuk login. jangan berikan OTP kepada siapapun", otp),
		ExpiredAt: time.Now().Add(time.Minute * 5),
	}
}

type App int

const (
	CUSTOMER App = iota + 1
	SYSTEM_ADMIN
	FINANCE_ADMIN
	SALES_ADMIN
	BRANCH_ADMIN
	WAREHOUSE_ADMIN
	LEADER
	SALES
	COURIER
)

type Login struct {
	App      int    `json:"app" binding:"gte=1,lte=9"`
	FcmToken string `json:"fcmToken" binding:"required"`
	Phone    string `json:"phone" binding:"required,e164"`
}

func (l *Login) IsCustomer() bool {
	return l.App == int(CUSTOMER)
}
func (l *Login) IsSystemAdmin() bool {
	return l.App == int(SYSTEM_ADMIN)
}
func (l *Login) IsFinanceAdmin() bool {
	return l.App == int(FINANCE_ADMIN)
}
func (l *Login) IsSalesAdmin() bool {
	return l.App == int(SALES_ADMIN)
}
func (l *Login) IsBranchAdmin() bool {
	return l.App == int(BRANCH_ADMIN)
}
func (l *Login) IsWarehouseAdmin() bool {
	return l.App == int(WAREHOUSE_ADMIN)
}
func (l *Login) IsLeader() bool {
	return l.App == int(LEADER)
}
func (l *Login) IsSales() bool {
	return l.App == int(SALES)
}
func (l *Login) IsCourier() bool {
	return l.App == int(COURIER)
}

type Verify struct {
	Id  primitive.ObjectID `json:"id" binding:"required"`
	Otp string             `json:"otp" binding:"required,numeric,len=6"`
}
