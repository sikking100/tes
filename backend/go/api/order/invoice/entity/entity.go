package entity

import (
	"strconv"
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Status int

const (
	APPLY Status = iota
	PENDING
	WAITING_PAY
	PAID
	CANCEL
)

type PaymentMethod int

const (
	COD PaymentMethod = iota
	TOP
	TRA
)

type Customer struct {
	Id    string `json:"id" bson:"_id"`
	Name  string `json:"name" bson:"name"`
	Phone string `json:"phone" bson:"phone"`
	Email string `json:"email" bson:"email"`
}
type Invoice struct {
	Id            primitive.ObjectID `json:"id" bson:"_id"`
	TransactionId string             `json:"transactionId" bson:"transactionId"`
	OrderId       primitive.ObjectID `json:"orderId" bson:"orderId"`
	RegionId      string             `json:"regionId" bson:"regionId"`
	RegionName    string             `json:"regionName" bson:"regionName"`
	BranchId      string             `json:"branchId" bson:"branchId"`
	BranchName    string             `json:"branchName" bson:"branchName"`
	Customer      *Customer          `json:"customer" bson:"customer"`
	Price         float64            `json:"price" bson:"price"`
	Paid          float64            `json:"paid" bson:"paid"`
	Channel       string             `json:"channel" bson:"channel"`
	Method        string             `json:"method" bson:"method"`
	Destination   string             `json:"destination" bson:"destination"`
	PaymentMethod int                `json:"paymentMethod" bson:"paymentMethod"`
	Url           string             `json:"url" bson:"url"`
	Status        int                `json:"status" bson:"status"`
	Query         []string           `json:"-" bson:"query"`
	Term          time.Time          `json:"term" bson:"term"`
	CreatedAt     time.Time          `json:"createdAt" bson:"createdAt"`
	PaidAt        time.Time          `json:"paidAt" bson:"paidAt"`
}
type Create struct {
	OrderId    primitive.ObjectID
	RegionId   string
	RegionName string
	BranchId   string
	BranchName string
	Customer   *Customer
	Price      float64
	Term       time.Time
}

func (c Create) NewInvoice(paymentMehod PaymentMethod, status Status) *Invoice {
	return &Invoice{
		Id:            primitive.NewObjectID(),
		TransactionId: "",
		OrderId:       c.OrderId,
		RegionId:      c.RegionId,
		RegionName:    c.RegionName,
		BranchId:      c.BranchId,
		BranchName:    c.BranchName,
		Customer:      c.Customer,
		Price:         c.Price,
		Paid:          0,
		Channel:       "",
		Method:        "",
		Destination:   "",
		PaymentMethod: int(paymentMehod),
		Url:           "",
		Status:        int(status),
		Query:         []string{c.RegionId, c.BranchId, c.Customer.Id, strconv.Itoa(int(paymentMehod))},
		Term:          c.Term,
		CreatedAt:     time.Now(),
		PaidAt:        time.Now(),
	}
}

func (inv *Invoice) IsCanMakePayment() bool {
	isTra := inv.Status == int(PENDING) && inv.PaymentMethod == int(TRA)
	isTop := inv.Status == int(WAITING_PAY) && inv.PaymentMethod == int(TOP) && inv.TransactionId == ""
	return isTra || isTop
}

type Page struct {
	Back  *int       `json:"back"`
	Next  *int       `json:"next"`
	Limit int        `json:"limit"`
	Query string     `json:"query"`
	Items []*Invoice `json:"items"`
}
type CompletePayment struct {
	Paid float64 `json:"paid" binding:"required,gte=1"`
}
type XenditCallback struct {
	Id          string  `json:"external_id"`
	Amount      float64 `json:"amount"`
	Status      string  `json:"status"`
	Method      string  `json:"payment_method"`
	Channel     string  `json:"payment_channel"`
	Destination string  `json:"payment_destination"`
}

type Find struct {
	Num   int    `form:"num" binding:"gte=1"`
	Limit int    `form:"limit" binding:"gte=1,lte=100"`
	Type  int    `form:"type" binding:"gte=0,lte=2"`
	Query string `form:"query"`
}

func (f *Find) IsByWaitingPay() bool {
	return f.Type == 0
}
func (f *Find) IsByOverdue() bool {
	return f.Type == 1
}
func (f *Find) IsByHistory() bool {
	return f.Type == 2
}
func (f *Find) IsByQuery() bool {
	return f.Query != ""
}
func (f *Find) ToPage(items []*Invoice) *Page {
	page := &Page{Back: nil, Next: nil, Limit: f.Limit, Query: f.Query, Items: items}
	if f.Num > 1 {
		back := f.Num - 1
		page.Back = &back
	}
	if f.Limit == len(items) {
		next := f.Num + 1
		page.Next = &next
	}
	return page
}

type FindReport struct {
	StartAt time.Time `form:"startAt" binding:"required"`
	EndAt   time.Time `form:"endAt" binding:"required,gtfield=StartAt"`
	Query   string    `form:"query"`
}

func (f *FindReport) IsByQuery() bool {
	return f.Query != ""
}
