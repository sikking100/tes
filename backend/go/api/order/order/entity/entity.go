package entity

import (
	"fmt"
	"strconv"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Status int

const (
	APPLY Status = iota
	PENDING
	COMPLETE
	CANCEL
)

type ApplyStatus int

const (
	APPLY_PENDING         ApplyStatus = iota
	APPLY_WAITING_APPROVE ApplyStatus = iota
	APPLY_APPROVE         ApplyStatus = iota
	APPLY_REJECT          ApplyStatus = iota
)

type Product struct {
	Id           string  `json:"id" bson:"_id"`
	CategoryId   string  `json:"categoryId" bson:"categoryId"`
	CategoryName string  `json:"categoryName" bson:"categoryName"`
	Team         int     `json:"team" bson:"team"`
	BrandId      string  `json:"brandId" bson:"brandId"`
	BrandName    string  `json:"brandName" bson:"brandName"`
	SalesId      string  `json:"salesId" bson:"salesId"`
	SalesName    string  `json:"salesName" bson:"salesName"`
	Name         string  `json:"name" bson:"name"`
	Description  string  `json:"description" bson:"description"`
	Size         string  `json:"size" bson:"size"`
	ImageUrl     string  `json:"imageUrl" bson:"imageUrl"`
	Point        float32 `json:"point" bson:"point"`
	UnitPrice    float64 `json:"unitPrice" bson:"unitPrice"`
	Discount     float64 `json:"discount" bson:"discount"`
	Qty          int     `json:"qty" bson:"qty"`
	TotalPrice   float64 `json:"totalPrice" bson:"totalPrice"`
	Tax          float64 `json:"tax" bson:"tax"`
}
type Customer struct {
	Id            string    `json:"id" bson:"_id" binding:"required"`
	Name          string    `json:"name" bson:"name" binding:"required"`
	Phone         string    `json:"phone" bson:"phone" binding:"required,e164"`
	Email         string    `json:"email" bson:"email" binding:"required,email"`
	ImageUrl      string    `json:"imageUrl" bson:"imageUrl" binding:"required,url"`
	PicName       string    `json:"picName" bson:"picName" binding:"required"`
	PicPhone      string    `json:"picPhone" bson:"picPhone" binding:"required,e164"`
	AddressName   string    `json:"addressName" bson:"addressName" binding:"required"`
	AddressLngLat []float64 `json:"addressLngLat" bson:"addressLngLat" binding:"required,len=2"`
	Note          string    `json:"note" bson:"note"`
}
type Creator struct {
	Id       string `json:"id" bson:"_id" binding:"required"`
	Name     string `json:"name" bson:"name" binding:"required"`
	Phone    string `json:"phone" bson:"phone" binding:"required,e164"`
	Email    string `json:"email" bson:"email" binding:"required,email"`
	ImageUrl string `json:"imageUrl" bson:"imageUrl" binding:"required,url"`
	Roles    int    `json:"roles" bson:"roles" binding:"gte=0"`
}
type Cancel struct {
	Id       string `json:"id" bson:"_id" binding:"required"`
	Name     string `json:"name" bson:"name" binding:"required"`
	Phone    string `json:"phone" bson:"phone" binding:"required,e164"`
	Email    string `json:"email" bson:"email" binding:"required,email"`
	ImageUrl string `json:"imageUrl" bson:"imageUrl" binding:"required,url"`
	Note     string `json:"note" bson:"note" binding:"required"`
	Roles    int    `json:"roles" bson:"roles" binding:"gte=0"`
}

type Order struct {
	Id            primitive.ObjectID `json:"id" bson:"_id"`
	InvoiceId     primitive.ObjectID `json:"invoiceId" bson:"invoiceId"`
	DeliveryId    primitive.ObjectID `json:"deliveryId" bson:"deliveryId"`
	RegionId      string             `json:"regionId" bson:"regionId"`
	RegionName    string             `json:"regionName" bson:"regionName"`
	BranchId      string             `json:"branchId" bson:"branchId"`
	BranchName    string             `json:"branchName" bson:"branchName"`
	PriceId       string             `json:"priceId" bson:"priceId"`
	PriceName     string             `json:"priceName" bson:"priceName"`
	Code          string             `json:"code" bson:"code"`
	Customer      *Customer          `json:"customer" bson:"customer"`
	Creator       *Creator           `json:"creator" bson:"creator"`
	Cancel        *Cancel            `json:"cancel" bson:"cancel"`
	Product       []*Product         `json:"product" bson:"product"`
	DeliveryPrice float64            `json:"deliveryPrice" bson:"deliveryPrice"`
	ProductPrice  float64            `json:"productPrice" bson:"productPrice"`
	TotalPrice    float64            `json:"totalPrice" bson:"totalPrice"`
	PoFilePath    string             `json:"poFilePath" bson:"poFilePath"`
	Status        int                `json:"status" bson:"status"`
	Query         []string           `json:"-" bson:"query"`
	CreatedAt     time.Time          `json:"createdAt" bson:"createdAt"`
	UpdatedAt     time.Time          `json:"updatedAt" bson:"updatedAt"`
}
type Page struct {
	Back  *int     `json:"back"`
	Next  *int     `json:"next"`
	Limit int      `json:"limit"`
	Query string   `json:"query"`
	Items []*Order `json:"items"`
}
type Create struct {
	RegionId             string          `json:"regionId" binding:"required"`
	RegionName           string          `json:"regionName" binding:"required"`
	BranchId             string          `json:"branchId" binding:"required"`
	BranchName           string          `json:"branchName" binding:"required"`
	PriceId              string          `json:"priceId" binding:"required"`
	PriceName            string          `json:"priceName" binding:"required"`
	Code                 string          `json:"code"`
	Customer             *Customer       `json:"customer" binding:"required"`
	Creator              *Creator        `json:"creator" binding:"required"`
	Product              []*Product      `json:"product" binding:"required,min=1"`
	PaymentMethod        int             `json:"paymentMethod" binding:"gte=0,lte=2"`
	DeliveryType         int             `json:"deliveryType" binding:"gte=0,lte=1"`
	DeliveryPrice        float64         `json:"deliveryPrice" binding:"gte=0"`
	ProductPrice         float64         `json:"productPrice" binding:"gte=0"`
	TotalPrice           float64         `json:"totalPrice" binding:"gte=0"`
	DeliveryAt           time.Time       `json:"deliveryAt" binding:"required"`
	PoFilePath           string          `json:"poFilePath"`
	TermInvoice          int             `json:"termInvoice" binding:"gte=0"`
	CreditLimit          float64         `json:"creditLimit" binding:"gte=0"`
	CreditUsed           float64         `json:"creditUsed" binding:"gte=0"`
	TransactionOverDue   float64         `json:"transactionOverDue" binding:"gte=0"`
	TransactionLastMonth float64         `json:"transactionLastMonth" binding:"gte=0"`
	TransactionPerMonth  float64         `json:"transactionPerMonth" binding:"gte=0"`
	UserApprover         []*UserApprover `json:"userApprover"`
}

func (c Create) NewOrder(status Status) *Order {
	return &Order{
		Id:            primitive.NewObjectID(),
		RegionId:      c.RegionId,
		RegionName:    c.RegionName,
		BranchId:      c.BranchId,
		BranchName:    c.BranchName,
		PriceId:       c.PriceId,
		PriceName:     c.PriceName,
		Code:          c.Code,
		Customer:      c.Customer,
		Creator:       c.Creator,
		Cancel:        nil,
		Product:       c.Product,
		DeliveryPrice: c.DeliveryPrice,
		ProductPrice:  c.ProductPrice,
		TotalPrice:    c.TotalPrice,
		PoFilePath:    c.PoFilePath,
		Status:        int(status),
		Query:         NewQuery(c.RegionId, c.BranchId, c.Customer.Id, c.Creator.Id, status),
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
	}
}
func toMilion(v float64) float64 {
	return v * 1000000
}
func getTeam(listProduct []*Product) auth.Team {
	food, retail := 0, 0
	for _, p := range listProduct {
		if p.Team == int(auth.FOOD) {
			food += int(p.TotalPrice)
		} else {
			retail += int(p.TotalPrice)
		}
	}
	if food >= retail {
		return auth.FOOD
	}
	return auth.RETAIL
}
func fixUserApproverAccepRoles(userApprover []*UserApprover, roles ...auth.Roles) []*UserApprover {
	result := make([]*UserApprover, 0)
	mapRoles := make(map[int]bool)
	for _, r := range roles {
		mapRoles[int(r)] = true
	}
	for _, u := range userApprover {
		if _, ok := mapRoles[u.Roles]; ok {
			result = append(result, u)
		}
	}
	result[0].Status = int(APPLY_WAITING_APPROVE)
	return result
}
func (c Create) NewApply(customerId string, overLimit float64, overDue float64, totalPrice float64) (*Apply, *Order) {
	order := c.NewOrder(APPLY)
	team := getTeam(c.Product)
	termInvoice := c.TermInvoice
	switch {
	case team == auth.FOOD && overLimit > toMilion(100) || overDue > toMilion(100) || termInvoice > 45:
		c.UserApprover = fixUserApproverAccepRoles(c.UserApprover, auth.AREA_MANAGER, auth.REGIONAL_MANAGER, auth.NASIONAL_SALES_MANAGER, auth.FINANCE_ADMIN, auth.GENERAL_MANAGER)
	case team == auth.FOOD && overLimit > toMilion(50) || overDue > toMilion(50) || termInvoice > 45:
		c.UserApprover = fixUserApproverAccepRoles(c.UserApprover, auth.AREA_MANAGER, auth.REGIONAL_MANAGER, auth.NASIONAL_SALES_MANAGER)
	case team == auth.FOOD && overLimit > toMilion(20) || overDue > toMilion(20) || (termInvoice >= 31 && termInvoice <= 44):
		c.UserApprover = fixUserApproverAccepRoles(c.UserApprover, auth.AREA_MANAGER, auth.REGIONAL_MANAGER)
	case team == auth.FOOD:
		c.UserApprover = fixUserApproverAccepRoles(c.UserApprover, auth.AREA_MANAGER)

	case team == auth.RETAIL && overLimit > toMilion(100) || overDue > toMilion(100) || termInvoice > 30:
		c.UserApprover = fixUserApproverAccepRoles(c.UserApprover, auth.AREA_MANAGER, auth.REGIONAL_MANAGER, auth.GENERAL_MANAGER, auth.FINANCE_ADMIN, auth.DIREKTUR)
	case team == auth.RETAIL && overLimit > toMilion(50) || overDue > toMilion(50) || termInvoice == 30:
		c.UserApprover = fixUserApproverAccepRoles(c.UserApprover, auth.AREA_MANAGER, auth.REGIONAL_MANAGER, auth.GENERAL_MANAGER)
	case team == auth.RETAIL && overLimit >= toMilion(10) && overLimit <= toMilion(20) || (overDue >= toMilion(10) && overDue <= toMilion(20)) || (termInvoice >= 8 && termInvoice <= 29):
		c.UserApprover = fixUserApproverAccepRoles(c.UserApprover, auth.AREA_MANAGER, auth.REGIONAL_MANAGER)
	case team == auth.RETAIL:
		c.UserApprover = fixUserApproverAccepRoles(c.UserApprover, auth.AREA_MANAGER)
	}
	return &Apply{
		Id:           order.Id,
		UserApprover: c.UserApprover,
		CustomerId:   customerId,
		OverLimit:    overLimit,
		OverDue:      overDue,
		TotalPrice:   totalPrice,
		Status:       int(APPLY_WAITING_APPROVE),
		ExpiredAt:    time.Now().AddDate(0, 0, 1),
	}, order
}

func NewQuery(regionId, branchId, customerId, creatorId string, status Status) []string {
	return []string{regionId, branchId, customerId, creatorId, strconv.Itoa(int(status))}
}

func (c *Create) IsCod() bool {
	return c.PaymentMethod == 0
}
func (c *Create) IsApply() bool {
	return c.PaymentMethod == 1 && (c.CreditLimit < c.CreditUsed+c.TotalPrice || c.TransactionOverDue > 0)
}
func (c *Create) IsTop() bool {
	return c.PaymentMethod == 1 && c.CreditLimit > c.CreditUsed+c.TotalPrice && c.TransactionOverDue == 0
}
func (c *Create) IsTra() bool {
	return c.PaymentMethod == 2
}

type Report struct {
	Id                primitive.ObjectID `json:"orderId" bson:"_id"`
	SalesId           string             `json:"salesId" bson:"salesId"`
	SalesName         string             `json:"salesName" bson:"salesName"`
	RegionId          string             `json:"regionId" bson:"regionId"`
	RegionName        string             `json:"regionName" bson:"regionName"`
	BranchId          string             `json:"branchId" bson:"branchId"`
	BranchName        string             `json:"branchName" bson:"branchName"`
	PriceId           string             `json:"priceId" bson:"priceId"`
	PriceName         string             `json:"priceName" bson:"priceName"`
	Code              string             `json:"code" bson:"code"`
	CustomerId        string             `json:"customerId" bson:"customerId"`
	CustomerName      string             `json:"customerName" bson:"customerName"`
	ProductId         string             `json:"productId" bson:"productId"`
	ProductName       string             `json:"productName" bson:"productName"`
	ProductQty        int                `json:"productQty" bson:"productQty"`
	ProductDiscount   float64            `json:"productDiscount" bson:"productDiscount"`
	ProductUnitPrice  float64            `json:"productUnitPrice" bson:"productUnitPrice"`
	ProductTotalPrice float64            `json:"productTotalPrice" bson:"productTotalPrice"`
	ProductPoint      float32            `json:"productPoint" bson:"productPoint"`
	Tax               float64            `json:"tax" bson:"tax"`
	CreatedAt         time.Time          `json:"createdAt" bson:"createdAt"`
}

type Performance struct {
	RegionId       string `json:"regionId" bson:"regionId"`
	RegionName     string `json:"regionName" bson:"regionName"`
	BranchId       string `json:"branchId" bson:"branchId"`
	BranchName     string `json:"branchName" bson:"branchName"`
	CategoryId     string `json:"categoryId" bson:"categoryId"`
	CategoryName   string `json:"categoryName" bson:"categoryName"`
	CategoryTarget int    `json:"categoryTarget" bson:"categoryTarget"`
	Qty            int    `json:"qty" bson:"qty"`
}
type Find struct {
	Num   int    `form:"num" binding:"gte=1"`
	Limit int    `form:"limit" binding:"gte=1,lte=100"`
	Query string `form:"query"`
}

func (f *Find) ToPage(items []*Order) *Page {
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
func (f *Find) IsByQuery() bool {
	return f.Query != ""
}

type FindReport struct {
	StartAt time.Time `form:"startAt" binding:"required"`
	EndAt   time.Time `form:"endAt" binding:"required"`
	Query   string    `form:"query"`
}
type FindPerformace struct {
	StartAt time.Time `form:"startAt" binding:"required"`
	EndAt   time.Time `form:"endAt" binding:"required"`
	Team    int       `form:"team" binding:"gte=1,lte=2"`
	Query   string    `form:"query"`
}
type UserApprover struct {
	Id        string    `json:"id" bson:"_id"`
	Phone     string    `json:"phone" bson:"phone"`
	Email     string    `json:"email" bson:"email"`
	Name      string    `json:"name" bson:"name"`
	ImageUrl  string    `json:"imageUrl" bson:"imageUrl"`
	Roles     int       `json:"roles" bson:"roles"`
	FcmToken  string    `json:"fcmToken" bson:"fcmToken"`
	Status    int       `json:"status" bson:"status"`
	Note      string    `json:"note" bson:"note"`
	UpdatedAt time.Time `json:"updatedAt" bson:"updatedAt"`
}

type Apply struct {
	Id           primitive.ObjectID `json:"id" bson:"_id"`
	UserApprover []*UserApprover    `json:"userApprover" bson:"userApprover"`
	CustomerId   string             `json:"customerId" bson:"customerId"`
	OverLimit    float64            `json:"overLimit" bson:"overLimit"`
	OverDue      float64            `json:"overDue" bson:"overDue"`
	TotalPrice   float64            `json:"totalPrice" bson:"totalPrice"`
	Status       int                `json:"status" bson:"status"`
	ExpiredAt    time.Time          `json:"expiredAt" bson:"expiredAt"`
}
type FindApply struct {
	UserId string
	Type   int `form:"type" binding:"gte=0"`
}

type MakeApprove struct {
	UserId       string          `json:"userId" binding:"required"`
	Note         string          `json:"note" binding:"required"`
	UserApprover []*UserApprover `json:"userApprover" binding:"required"`
}

func (m *MakeApprove) Approve() (ApplyStatus, error) {
	for i := 0; i < len(m.UserApprover); i++ {
		user := m.UserApprover[i]
		if user.Id == m.UserId && user.Status == int(APPLY_WAITING_APPROVE) {
			user.Status = int(APPLY_APPROVE)
			user.Note = m.Note
			if i+1 < len(m.UserApprover) {
				// set next approver
				m.UserApprover[i+1].Status = int(APPLY_WAITING_APPROVE)
				m.UserApprover[i] = user
				return APPLY_WAITING_APPROVE, nil
			} else {
				// last approver
				m.UserApprover[i] = user
				return APPLY_APPROVE, nil
			}
		}
	}
	return APPLY_PENDING, fmt.Errorf("invalid user approver")
}

func (m *MakeApprove) Reject() error {
	for i := 0; i < len(m.UserApprover); i++ {
		user := m.UserApprover[i]
		if user.Id == m.UserId && user.Status == int(APPLY_WAITING_APPROVE) {
			user.Status = int(APPLY_REJECT)
			user.Note = m.Note
			m.UserApprover[i] = user
		} else if user.Status == int(PENDING) {
			user.Status = int(APPLY_REJECT)
			m.UserApprover[i] = user
		}
	}
	return nil
}
