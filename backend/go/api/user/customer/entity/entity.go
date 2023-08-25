package entity

import (
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type BusinessAddress struct {
	Name   string    `json:"name" bson:"name" binding:"required"`
	LngLat []float64 `json:"lngLat" bson:"lngLat" binding:"required,len=2"`
}
type BusinessLocation struct {
	RegionId   string `json:"regionId" bson:"regionId" binding:"required"`
	RegionName string `json:"regionName" bson:"regionName" binding:"required"`
	BranchId   string `json:"branchId" bson:"branchId" binding:"required"`
	BranchName string `json:"branchName" bson:"branchName" binding:"required"`
}
type BusinessPriceList struct {
	Id   string `json:"id" bson:"_id" binding:"required"`
	Name string `json:"name" bson:"name" binding:"required"`
}
type BusinessCredit struct {
	Term        int     `json:"term" bson:"term" binding:"gte=0"`
	TermInvoice int     `json:"termInvoice" bson:"termInvoice" binding:"gte=0"`
	Limit       float64 `json:"limit" bson:"limit" binding:"gte=0"`
	Used        float64 `json:"used" bson:"used" binding:"gte=0"`
}
type BusinessTax struct {
	ExchangeDay  int    `json:"exchangeDay" bson:"exchangeDay" binding:"gte=0,lte=6"`
	LegalityPath string `json:"legalityPath" bson:"legalityPath" binding:"required"`
	Type         int    `json:"type" bson:"type" binding:"gte=0,lte=1"`
}
type BusinessCustomer struct {
	Id           string `json:"id" bson:"_id" binding:"required"`
	IdCardPath   string `json:"idCardPath" bson:"idCardPath" binding:"required"`
	IdCardNumber string `json:"idCardNumber" bson:"idCardNumber" binding:"required"`
	Address      string `json:"address" bson:"address" binding:"required"`
}
type BusinessPic struct {
	IdCardPath   string `json:"idCardPath" bson:"idCardPath" binding:"required"`
	IdCardNumber string `json:"idCardNumber" bson:"idCardNumber" binding:"required"`
	Name         string `json:"name" bson:"name" binding:"required"`
	Phone        string `json:"phone" bson:"phone" binding:"required,e164"`
	Email        string `json:"email" bson:"email" binding:"required,email"`
	Address      string `json:"address" bson:"address" binding:"required"`
}

type Business struct {
	Location  *BusinessLocation  `json:"location" bson:"location"`
	PriceList *BusinessPriceList `json:"priceList" bson:"priceList"`
	Customer  *BusinessCustomer  `json:"customer" bson:"customer"`
	Pic       *BusinessPic       `json:"pic" bson:"pic"`
	Address   []*BusinessAddress `json:"address" bson:"address"`
	Viewer    int                `json:"viewer" bson:"viewer"`
	Credit    *BusinessCredit    `json:"credit" bson:"credit"`
	Tax       *BusinessTax       `json:"tax" bson:"tax"`
}
type Customer struct {
	Id        string    `json:"id" bson:"_id"`
	Phone     string    `json:"phone" bson:"phone"`
	Email     string    `json:"email" bson:"email"`
	Name      string    `json:"name" bson:"name"`
	ImageUrl  string    `json:"imageUrl" bson:"imageUrl"`
	Business  *Business `json:"business" bson:"business"`
	Query     []string  `json:"-" bson:"query"`
	CreatedAt time.Time `json:"createdAt" bson:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt" bson:"updatedAt"`
}

type PageCustomer struct {
	Back   *int        `json:"back"`
	Next   *int        `json:"next"`
	Limit  int         `json:"limit"`
	Query  string      `json:"query"`
	Search string      `json:"search"`
	Items  []*Customer `json:"items"`
}
type FindCustomer struct {
	Num    int    `form:"num" binding:"gte=1"`
	Limit  int    `form:"limit" binding:"gte=1,lte=100"`
	Query  string `form:"query"`
	Search string `form:"search"`
}

func (f *FindCustomer) IsBySearch() bool {
	return f.Search != ""
}
func (f *FindCustomer) IsByQuery() bool {
	return f.Query != ""
}
func (f *FindCustomer) ToPage(items []*Customer, err error) (*PageCustomer, error) {
	if err != nil {
		return nil, err
	}
	result := &PageCustomer{Back: nil, Next: nil, Limit: f.Limit, Query: f.Query, Search: f.Search, Items: items}
	if f.Num > 1 && !f.IsBySearch() {
		back := f.Num - 1
		result.Back = &back
	}
	if f.Limit == len(items) && !f.IsBySearch() {
		next := f.Num + 1
		result.Next = &next
	}
	return result, nil
}

type SaveAccount struct {
	Phone string `json:"phone" binding:"required,e164"`
	Email string `json:"email" binding:"required,email"`
	Name  string `json:"name" binding:"required"`
}

func (s *SaveAccount) NewAccount() *Customer {
	return &Customer{
		Id:        primitive.NewObjectID().Hex(),
		Phone:     s.Phone,
		Email:     s.Email,
		Name:      s.Name,
		ImageUrl:  os.Getenv("IMAGE_URL"),
		Business:  nil,
		Query:     make([]string, 0),
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

type UpdateBusiness struct {
	Location *BusinessLocation  `json:"location" binding:"required"`
	Pic      *BusinessPic       `json:"pic" binding:"required"`
	Address  []*BusinessAddress `json:"address" binding:"required,min=1"`
	Viewer   int                `json:"viewer" binding:"gte=0"`
	Tax      *BusinessTax       `json:"tax"`
}
type ApplyNewBusiness struct {
	Location             *BusinessLocation  `json:"location" binding:"required"`
	PriceList            *BusinessPriceList `json:"priceList" binding:"required"`
	Customer             *BusinessCustomer  `json:"customer" binding:"required"`
	Pic                  *BusinessPic       `json:"pic" binding:"required"`
	Address              []*BusinessAddress `json:"address" binding:"required,min=1"`
	Viewer               int                `json:"viewer" binding:"gte=0"`
	CreditProposal       *BusinessCredit    `json:"creditProposal" binding:"required"`
	Tax                  *BusinessTax       `json:"tax"`
	TransactionLastMonth int                `json:"transactionLastMonth" binding:"gte=0"`
	TransactionPerMonth  int                `json:"transactionPerMonth" binding:"gte=0"`
}

func CreateNewApplyBusiness(data ApplyNewBusiness, c *Customer) *Apply {
	return &Apply{
		Id:        c.Id,
		Location:  data.Location,
		PriceList: data.PriceList,
		Customer: &ApplyCustomer{
			IdCardPath:   data.Customer.IdCardPath,
			IdCardNumber: data.Customer.IdCardNumber,
			Name:         c.Name,
			Phone:        c.Phone,
			Email:        c.Email,
			Address:      data.Customer.Address,
			ImageUrl:     c.ImageUrl,
		},
		Pic:                  data.Pic,
		Address:              data.Address,
		Viewer:               data.Viewer,
		CreditProposal:       data.CreditProposal,
		CreditActual:         &BusinessCredit{Limit: 0, Term: 0, TermInvoice: 0, Used: 0},
		Tax:                  data.Tax,
		TransactionLastMonth: data.TransactionLastMonth,
		TransactionPerMonth:  data.TransactionPerMonth,
		UserApprover:         make([]*ApplyUserApprover, 0),
		Type:                 int(NEW_BUSINESS),
		Status:               int(APPLY_WAITING_APPROVE),
		ExpiredAt:            time.Now().AddDate(0, 0, 1),
	}
}

type ApplyUserApprover struct {
	Id        string    `json:"id" bson:"_id"`
	Phone     string    `json:"phone" bson:"phone"`
	Email     string    `json:"email" bson:"email"`
	Name      string    `json:"name" bson:"name"`
	ImageUrl  string    `json:"imageUrl" bson:"imageUrl"`
	FcmToken  string    `json:"fcmToken" bson:"fcmToken"`
	Note      string    `json:"note" bson:"note"`
	Roles     int       `json:"roles" bson:"roles"`
	Status    int       `json:"status" bson:"status"`
	UpdatedAt time.Time `json:"updatedAt" bson:"updatedAt"`
}
type ApplyCustomer struct {
	IdCardPath   string `json:"idCardPath" bson:"idCardPath"`
	IdCardNumber string `json:"idCardNumber" bson:"idCardNumber"`
	Name         string `json:"name" bson:"name"`
	Phone        string `json:"phone" bson:"phone"`
	Email        string `json:"email" bson:"email"`
	Address      string `json:"address" bson:"address"`
	ImageUrl     string `json:"imageUrl" bson:"imageUrl"`
}
type ApplyType int

const (
	NEW_BUSINESS ApplyType = iota + 1
	NEW_LIMIT
)

type Apply struct {
	Id                   string               `json:"id" bson:"_id"`
	Location             *BusinessLocation    `json:"location" bson:"location"`
	PriceList            *BusinessPriceList   `json:"priceList" bson:"priceList"`
	Customer             *ApplyCustomer       `json:"customer" bson:"customer"`
	Pic                  *BusinessPic         `json:"pic" bson:"pic"`
	Address              []*BusinessAddress   `json:"address" bson:"address"`
	Viewer               int                  `json:"viewer" bson:"viewer"`
	CreditProposal       *BusinessCredit      `json:"creditProposal" bson:"creditProposal"`
	CreditActual         *BusinessCredit      `json:"creditActual" bson:"creditActual"`
	Tax                  *BusinessTax         `json:"tax" bson:"tax"`
	TransactionLastMonth int                  `json:"transactionLastMonth" bson:"transactionLastMonth"`
	TransactionPerMonth  int                  `json:"transactionPerMonth" bson:"transactionPerMonth"`
	UserApprover         []*ApplyUserApprover `json:"userApprover" bson:"userApprover"`
	Type                 int                  `json:"type" bson:"type"`
	Team                 int                  `json:"team" bson:"team"`
	Status               int                  `json:"status" bson:"status"`
	ExpiredAt            time.Time            `json:"expiredAt" bson:"expiredAt"`
}
type PageApply struct {
	Back   *int     `json:"back"`
	Next   *int     `json:"next"`
	Limit  int      `json:"limit"`
	UserId string   `json:"userId"`
	Type   int      `json:"type"`
	Items  []*Apply `json:"items"`
}
type ApplyNewLimit struct {
	Id                   string               `json:"id" binding:"required"`
	Location             *BusinessLocation    `json:"location" binding:"required"`
	PriceList            *BusinessPriceList   `json:"priceList" binding:"required"`
	Customer             *ApplyCustomer       `json:"customer" binding:"required"`
	Pic                  *BusinessPic         `json:"pic" binding:"required"`
	Address              []*BusinessAddress   `json:"address" binding:"required"`
	Viewer               int                  `json:"viewer" binding:"gte=0"`
	CreditProposal       *BusinessCredit      `json:"creditProposal" binding:"required"`
	CreditActual         *BusinessCredit      `json:"creditActual" binding:"required"`
	Tax                  *BusinessTax         `json:"tax"`
	TransactionLastMonth int                  `json:"transactionLastMonth" binding:"gte=0"`
	TransactionPerMonth  int                  `json:"transactionPerMonth" binding:"gte=0"`
	UserApprover         []*ApplyUserApprover `json:"userApprover" binding:"required"`
	Note                 string               `json:"note" binding:"required"`
	Team                 int                  `json:"team" binding:"gte=1,lte=2"`
}

func (a *ApplyNewLimit) CreateApplyNewLimit() (*Apply, error) {
	apply := &Apply{
		Id:                   a.Id,
		Location:             a.Location,
		PriceList:            a.PriceList,
		Customer:             a.Customer,
		Pic:                  a.Pic,
		Address:              a.Address,
		Viewer:               a.Viewer,
		CreditProposal:       a.CreditProposal,
		CreditActual:         a.CreditActual,
		Tax:                  a.Tax,
		TransactionLastMonth: a.TransactionLastMonth,
		TransactionPerMonth:  a.TransactionPerMonth,
		UserApprover:         a.UserApprover,
		Type:                 int(NEW_LIMIT),
		Status:               int(APPLY_WAITING_APPROVE),
		ExpiredAt:            time.Now().AddDate(0, 0, 1),
	}
	for i, u := range apply.UserApprover {
		if u.IsWaitingApprove() {
			u.Status = int(APPLY_APPROVE)
			u.Note = a.Note
			u.UpdatedAt = time.Now()
			apply.UserApprover[i] = u
			continue
		}
		switch {
		case a.Team == int(auth.FOOD) && (a.CreditProposal.Limit > toMilion(100) || a.CreditProposal.Term > 45):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER, auth.REGIONAL_MANAGER, auth.NASIONAL_SALES_MANAGER, auth.FINANCE_ADMIN, auth.GENERAL_MANAGER) {
				apply.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				apply.Status = int(APPLY_WAITING_APPROVE)
				return apply, nil
			} else {
				apply.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		case a.Team == int(auth.FOOD) && (a.CreditProposal.Limit > toMilion(50) || a.CreditProposal.Term == 45):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER, auth.REGIONAL_MANAGER, auth.NASIONAL_SALES_MANAGER) {
				apply.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				apply.Status = int(APPLY_WAITING_APPROVE)
				return apply, nil
			} else {
				apply.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		case a.Team == int(auth.FOOD) && (a.CreditProposal.Limit > toMilion(20) || (a.CreditProposal.Term >= 31 && a.CreditProposal.Term <= 44)):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER, auth.REGIONAL_MANAGER) {
				apply.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				apply.Status = int(APPLY_WAITING_APPROVE)
				return apply, nil
			} else {
				apply.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		case a.Team == int(auth.FOOD):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER) {
				apply.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				apply.Status = int(APPLY_WAITING_APPROVE)
				return apply, nil
			} else {
				apply.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		case a.Team == int(auth.RETAIL) && (a.CreditProposal.Limit > toMilion(100) || a.CreditProposal.Term > 30):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER, auth.REGIONAL_MANAGER, auth.GENERAL_MANAGER, auth.FINANCE_ADMIN, auth.DIREKTUR) {
				apply.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				apply.Status = int(APPLY_WAITING_APPROVE)
				return apply, nil
			} else {
				apply.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		case a.Team == int(auth.RETAIL) && (a.CreditProposal.Limit > toMilion(50) || a.CreditProposal.Term == 30):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER, auth.REGIONAL_MANAGER, auth.GENERAL_MANAGER) {
				apply.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				apply.Status = int(APPLY_WAITING_APPROVE)
				return apply, nil
			} else {
				apply.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		case a.Team == int(auth.RETAIL) && (a.CreditProposal.Limit >= toMilion(10) || (a.CreditProposal.Term >= 8 && a.CreditProposal.Term <= 29)):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER, auth.REGIONAL_MANAGER) {
				apply.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				apply.Status = int(APPLY_WAITING_APPROVE)
				return apply, nil
			} else {
				apply.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		case a.Team == int(auth.RETAIL):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER) {
				apply.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				apply.Status = int(APPLY_WAITING_APPROVE)
				return apply, nil
			} else {
				apply.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		default:
			return nil, fmt.Errorf("unknown next approver for team: %d, limit: %f, day: %d", a.Team, a.CreditProposal.Limit, a.CreditProposal.Term)
		}
	}
	apply.Status = int(APPLY_APPROVE)
	return apply, nil
}

type FindApply struct {
	Num    int    `form:"num" binding:"gte=1"`
	Limit  int    `form:"limit" binding:"gte=1,lte=100"`
	UserId string `form:"userId" binding:"required"`
	Type   int    `form:"type"`
}

func (f *FindApply) IsByWaitingLimit() bool {
	return f.Type == 1
}
func (f *FindApply) IsByWaitingApprove() bool {
	return f.Type == 2
}
func (f *FindApply) IsByWaitingCreate() bool {
	return f.Type == 3
}
func (f *FindApply) ToPage(items []*Apply, err error) (*PageApply, error) {
	if err != nil {
		return nil, err
	}
	result := &PageApply{Back: nil, Next: nil, Limit: f.Limit, UserId: f.UserId, Type: f.Type, Items: items}
	isAll := f.IsByWaitingLimit() || f.IsByWaitingApprove() || f.IsByWaitingCreate()
	if isAll {
		result.Limit = len(items)
	}
	if f.Num > 1 && !isAll {
		back := f.Num - 1
		result.Back = &back
	}
	if f.Limit == len(items) && !isAll {
		next := f.Num + 1
		result.Next = &next
	}
	return result, nil
}

type ApplyStatus int

const (
	APPLY_PENDING         ApplyStatus = iota
	APPLY_WAITING_APPROVE ApplyStatus = iota
	APPLY_APPROVE         ApplyStatus = iota
	APPLY_REJECT          ApplyStatus = iota
)

func toMilion(v float64) float64 {
	return v * 1000000
}

func (u *ApplyUserApprover) isNextApprover(authRoles ...auth.Roles) bool {
	for _, r := range authRoles {
		if u.Roles == int(r) && u.Status == int(APPLY_PENDING) {
			return true
		}
	}
	return false
}
func (u *ApplyUserApprover) IsWaitingApprove() bool {
	return u.Status == int(APPLY_WAITING_APPROVE)
}

func MakeApprove(data *Approve) (int, error) {
	for i, u := range data.UserApprover {
		if u.IsWaitingApprove() {
			u.Status = int(APPLY_APPROVE)
			u.Note = data.Note
			u.UpdatedAt = time.Now()
			data.UserApprover[i] = u
			continue
		}
		switch {
		case data.Team == int(auth.FOOD) && (data.CreditProposal.Limit > toMilion(100) || data.CreditProposal.Term > 45):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER, auth.REGIONAL_MANAGER, auth.NASIONAL_SALES_MANAGER, auth.FINANCE_ADMIN, auth.GENERAL_MANAGER) {
				data.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				return int(APPLY_WAITING_APPROVE), nil
			} else {
				data.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		case data.Team == int(auth.FOOD) && (data.CreditProposal.Limit > toMilion(50) || data.CreditProposal.Term == 45):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER, auth.REGIONAL_MANAGER, auth.NASIONAL_SALES_MANAGER) {
				data.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				return int(APPLY_WAITING_APPROVE), nil
			} else {
				data.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		case data.Team == int(auth.FOOD) && (data.CreditProposal.Limit > toMilion(20) || (data.CreditProposal.Term >= 31 && data.CreditProposal.Term <= 44)):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER, auth.REGIONAL_MANAGER) {
				data.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				return int(APPLY_WAITING_APPROVE), nil
			} else {
				data.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		case data.Team == int(auth.FOOD):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER) {
				data.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				return int(APPLY_WAITING_APPROVE), nil
			} else {
				data.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		case data.Team == int(auth.RETAIL) && (data.CreditProposal.Limit > toMilion(100) || data.CreditProposal.Term > 30):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER, auth.REGIONAL_MANAGER, auth.GENERAL_MANAGER, auth.FINANCE_ADMIN, auth.DIREKTUR) {
				data.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				return int(APPLY_WAITING_APPROVE), nil
			} else {
				data.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		case data.Team == int(auth.RETAIL) && (data.CreditProposal.Limit > toMilion(50) || data.CreditProposal.Term == 30):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER, auth.REGIONAL_MANAGER, auth.GENERAL_MANAGER) {
				data.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				return int(APPLY_WAITING_APPROVE), nil
			} else {
				data.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		case data.Team == int(auth.RETAIL) && (data.CreditProposal.Limit >= toMilion(10) || (data.CreditProposal.Term >= 8 && data.CreditProposal.Term <= 29)):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER, auth.REGIONAL_MANAGER) {
				data.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				return int(APPLY_WAITING_APPROVE), nil
			} else {
				data.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		case data.Team == int(auth.RETAIL):
			if u.isNextApprover(auth.SALES_ADMIN, auth.AREA_MANAGER) {
				data.UserApprover[i].Status = int(APPLY_WAITING_APPROVE)
				return int(APPLY_WAITING_APPROVE), nil
			} else {
				data.UserApprover[i].Status = int(APPLY_APPROVE)
			}
		default:
			return -1, fmt.Errorf("unknown next approver for team: %d, limit: %f, day: %d", data.Team, data.CreditProposal.Limit, data.CreditProposal.Term)
		}
	}
	return int(APPLY_APPROVE), nil
}

type Approve struct {
	Id             string               `json:"id" binding:"required"`
	Note           string               `json:"note" binding:"required"`
	Team           int                  `json:"team" binding:"gte=1,lte=2"`
	PriceList      *BusinessPriceList   `json:"priceList" binding:"required"`
	UserApprover   []*ApplyUserApprover `json:"userApprover" binding:"required"`
	CreditProposal *BusinessCredit      `json:"creditProposal" binding:"required"`
}

type CreateBusiness struct {
	ApplyId string `json:"applyId"`
	NewId   string `json:"newId"`
}

func NewCreateBusiness(data CreateBusiness, apply *Apply) *Customer {
	return &Customer{
		Id:       data.NewId,
		Phone:    apply.Customer.Phone,
		Email:    apply.Customer.Email,
		Name:     apply.Customer.Name,
		ImageUrl: apply.Customer.ImageUrl,
		Business: &Business{
			Location:  apply.Location,
			PriceList: apply.PriceList,
			Customer: &BusinessCustomer{
				Id:           data.ApplyId,
				IdCardPath:   apply.Customer.IdCardPath,
				IdCardNumber: apply.Customer.IdCardNumber,
				Address:      apply.Customer.Address,
			},
			Pic:     apply.Pic,
			Address: apply.Address,
			Viewer:  apply.Viewer,
			Credit:  apply.CreditProposal,
			Tax:     apply.Tax,
		},
		Query:     []string{strconv.Itoa(apply.Viewer), apply.Location.RegionId, apply.Location.BranchId},
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

type Reject struct {
	Id           string               `json:"id" binding:"required"`
	Note         string               `json:"note" binding:"required"`
	UserApprover []*ApplyUserApprover `json:"userApprover" binding:"required"`
}

func MakeReject(data *Reject) {
	for i, u := range data.UserApprover {
		if u.Status == int(APPLY_WAITING_APPROVE) {
			u.Status = int(APPLY_REJECT)
			u.Note = data.Note
			data.UserApprover[i] = u
		} else if u.Status == int(APPLY_PENDING) {
			u.Status = int(APPLY_REJECT)
			data.UserApprover[i] = u
		}
	}
}
