package entity

import (
	"fmt"
	"strconv"
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type PriceList struct {
	Id        string    `json:"id" bson:"_id"`
	Name      string    `json:"name" bson:"name"`
	CreatedAt time.Time `json:"createdAt" bson:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt" bson:"updatedAt"`
}
type SavePriceList struct {
	Name string `json:"name" binding:"required"`
}
type Category struct {
	Id   string `json:"id" bson:"_id" binding:"required"`
	Name string `json:"name" bson:"name" binding:"required"`
	Team int    `json:"team" bson:"team" binding:"gte=1,lte=2"`
}
type Brand struct {
	Id       string `json:"id" bson:"_id" binding:"required"`
	Name     string `json:"name" bson:"name" binding:"required"`
	ImageUrl string `json:"imageUrl" bson:"imageUrl" binding:"required,url"`
}
type Discount struct {
	Min       int       `json:"min" bson:"min"`
	Max       *int      `json:"max" bson:"max"`
	Discount  float64   `json:"discount" bson:"discount"`
	StartAt   time.Time `json:"startAt" bson:"startAt"`
	ExpiredAt time.Time `json:"expiredAt" bson:"expiredAt" binding:"gtfield=StartAt"`
}
type Price struct {
	Id       string      `json:"id" bson:"_id" binding:"required"`
	Name     string      `json:"name" bson:"name" binding:"required"`
	Price    float64     `json:"price" bson:"price" binding:"gt=0"`
	Discount []*Discount `json:"discount" bson:"discount"`
}

type Warehouse struct {
	Id   string `json:"id" bson:"_id" binding:"required"`
	Name string `json:"name" bson:"name" binding:"required"`
	Qty  int    `json:"qty" bson:"qty" binding:"gte=0"`
}

type Product struct {
	Id          string       `json:"id" bson:"_id"`
	BranchId    string       `json:"branchId" bson:"branchId"`
	ProductId   string       `json:"productId" bson:"productId"`
	SalesId     string       `json:"salesId" bson:"salesId"`
	SalesName   string       `json:"salesName" bson:"salesName"`
	Category    *Category    `json:"category" bson:"category"`
	Brand       *Brand       `json:"brand" bson:"brand"`
	Name        string       `json:"name" bson:"name"`
	Description string       `json:"description" bson:"description"`
	Size        string       `json:"size" bson:"size"`
	ImageUrl    string       `json:"imageUrl" bson:"imageUrl"`
	Point       float32      `json:"point" bson:"point"`
	Price       []*Price     `json:"price" bson:"price"`
	Warehouse   []*Warehouse `json:"warehouse" bson:"warehouse"`
	OrderCount  int          `json:"orderCount" bson:"orderCount"`
	IsVisible   bool         `json:"isVisible" bson:"isVisible"`
	Query       []string     `json:"-" bson:"query"`
	CreatedAt   time.Time    `json:"createdAt" bson:"createdAt"`
	UpdatedAt   time.Time    `json:"updatedAt" bson:"updatedAt"`
}
type PageProduct struct {
	Back   *int       `json:"back"`
	Next   *int       `json:"next"`
	Limit  int        `json:"limit"`
	Query  string     `json:"query"`
	Sort   int        `json:"sort"`
	Search string     `json:"search"`
	Items  []*Product `json:"items"`
}
type SaveCatalog struct {
	Category    *Category `json:"category" binding:"required"`
	Brand       *Brand    `json:"brand" binding:"required"`
	Name        string    `json:"name" binding:"required"`
	Description string    `json:"description" binding:"required"`
	Size        string    `json:"size" binding:"required"`
	Point       float32   `json:"point" binding:"gte=0,lte=1"`
}

func (s *SaveCatalog) Query() []string {
	query := []string{s.Brand.Id, s.Category.Id, strconv.Itoa(s.Category.Team)}
	return query
}

func ProductId(branchId string, productId string) string {
	return fmt.Sprintf("%s-%s", branchId, productId)
}

type SaveProduct struct {
	BranchId    string    `json:"branchId" binding:"required"`
	ProductId   string    `json:"productId" binding:"required"`
	SalesId     string    `json:"salesId"`
	SalesName   string    `json:"salesName"`
	Category    *Category `json:"category" binding:"required"`
	Brand       *Brand    `json:"brand" binding:"required"`
	Name        string    `json:"name" binding:"required"`
	Description string    `json:"description" binding:"required"`
	Size        string    `json:"size" binding:"required"`
	ImageUrl    string    `json:"imageUrl" binding:"required,url"`
	Point       float32   `json:"point" binding:"gte=0,lte=1"`
	Price       []*Price  `json:"price" binding:"required,min=1"`
}

func (s *SaveProduct) Query() []string {
	query := []string{s.BranchId, s.Brand.Id, s.Category.Id, strconv.Itoa(s.Category.Team)}
	if s.SalesId != "" {
		query = append(query, s.SalesId)
	}
	return query
}

type Creator struct {
	Id       string `json:"id" bson:"_id" binding:"required"`
	Name     string `json:"name" bson:"name" binding:"required"`
	ImageUrl string `json:"imageUrl" bson:"imageUrl" binding:"required,url"`
	Roles    int    `json:"roles" bson:"roles" binding:"gte=1"`
}
type AddQty struct {
	WarehouseId   string   `json:"warehouseId" binding:"required"`
	WarehouseName string   `json:"warehouseName" binding:"required"`
	Qty           int      `json:"qty" binding:"gte=1"`
	Creator       *Creator `json:"creator" binding:"required"`
}

func (a *AddQty) Create(p *Product) *HistoryQty {
	var to *Warehouse = nil
	for i := 0; i < len(p.Warehouse); i++ {
		if p.Warehouse[i].Id == a.WarehouseId {
			p.Warehouse[i].Qty += a.Qty
			to = p.Warehouse[i]
			break
		}
	}
	if to == nil {
		to = &Warehouse{Id: a.WarehouseId, Name: a.WarehouseName, Qty: a.Qty}
		p.Warehouse = append(p.Warehouse, to)
	}
	return &HistoryQty{
		Id:          primitive.NewObjectID(),
		Type:        int(QTY_ADD),
		BranchId:    p.BranchId,
		ProductId:   p.Id,
		Category:    p.Category,
		Brand:       p.Brand,
		Name:        p.Name,
		Description: p.Description,
		Size:        p.Size,
		ImageUrl:    p.ImageUrl,
		Warehouse:   []*HistoryQtyWarehouse{nil, {Id: to.Id, Name: to.Name, LastQty: to.Qty - a.Qty, NewQty: to.Qty}},
		Qty:         a.Qty,
		Creator:     a.Creator,
		CreatedAt:   time.Now(),
	}
}

type TransferQty struct {
	FromWarehouseId   string   `json:"fromWarehouseId" binding:"required"`
	FromWarehouseName string   `json:"fromWarehouseName" binding:"required"`
	ToWarehouseId     string   `json:"toWarehouseId" binding:"required"`
	ToWarehouseName   string   `json:"toWarehouseName" binding:"required"`
	Qty               int      `json:"qty" binding:"gte=1"`
	Creator           *Creator `json:"creator" binding:"required"`
}

func (a *TransferQty) Create(p *Product) *HistoryQty {
	var from, to *Warehouse = nil, nil
	for i := 0; i < len(p.Warehouse); i++ {
		if p.Warehouse[i].Id == a.FromWarehouseId {
			p.Warehouse[i].Qty -= a.Qty
			from = p.Warehouse[i]
			if from != nil && to != nil {
				break
			}
			continue
		}
		if p.Warehouse[i].Id == a.ToWarehouseId {
			p.Warehouse[i].Qty += a.Qty
			to = p.Warehouse[i]
			if from != nil && to != nil {
				break
			}
			continue
		}
	}
	if to == nil {
		to = &Warehouse{Id: a.ToWarehouseId, Name: a.ToWarehouseName, Qty: a.Qty}
		p.Warehouse = append(p.Warehouse, to)
	}
	return &HistoryQty{
		Id:          primitive.NewObjectID(),
		Type:        int(QTY_ADD),
		BranchId:    p.BranchId,
		ProductId:   p.Id,
		Category:    p.Category,
		Brand:       p.Brand,
		Name:        p.Name,
		Description: p.Description,
		Size:        p.Size,
		ImageUrl:    p.ImageUrl,
		Warehouse: []*HistoryQtyWarehouse{
			{Id: from.Id, Name: from.Name, LastQty: from.Qty + a.Qty, NewQty: from.Qty},
			{Id: to.Id, Name: to.Name, LastQty: to.Qty - a.Qty, NewQty: to.Qty},
		},
		Qty:       a.Qty,
		Creator:   a.Creator,
		CreatedAt: time.Now(),
	}
}

type HistoryQtyWarehouse struct {
	Id      string `json:"id" bson:"_id"`
	Name    string `json:"name" bson:"name"`
	LastQty int    `json:"lastQty" bson:"lastQty"`
	NewQty  int    `json:"newQty" bson:"newQty"`
}
type HistoryQtyType int

const (
	QTY_ADD HistoryQtyType = iota + 1
	QTY_TRF
)

type HistoryQty struct {
	Id          primitive.ObjectID     `json:"id" bson:"_id"`
	Type        int                    `json:"type" bson:"type"`
	BranchId    string                 `json:"branchId" bson:"branchId"`
	ProductId   string                 `json:"productId" bson:"productId"`
	Category    *Category              `json:"category" bson:"category"`
	Brand       *Brand                 `json:"brand" bson:"brand"`
	Name        string                 `json:"name" bson:"name"`
	Description string                 `json:"description" bson:"description"`
	Size        string                 `json:"size" bson:"size"`
	ImageUrl    string                 `json:"imageUrl" bson:"imageUrl"`
	Warehouse   []*HistoryQtyWarehouse `json:"warehouse" bson:"warehouse"`
	Qty         int                    `json:"qty" bson:"qty"`
	Creator     *Creator               `json:"creator" bson:"creator"`
	CreatedAt   time.Time              `json:"createdAt" bson:"createdAt"`
}
type PageHistoryQty struct {
	Back     *int          `json:"back"`
	Next     *int          `json:"next"`
	Limit    int           `json:"limit"`
	BranchId string        `json:"branchId"`
	Items    []*HistoryQty `json:"items"`
}
type SalesProduct struct {
	Id           string `json:"id" bson:"_id"`
	Name         string `json:"name" bson:"name"`
	TotalProduct int    `json:"totalProduct" bson:"totalProduct"`
}
type SaveSalesProduct struct {
	Id         string `json:"id" binding:"required"`
	BranchId   string `json:"branchId" binding:"required"`
	BrandId    string `json:"brandId" binding:"required"`
	CategoryId string `json:"categoryId" binding:"required"`
	Team       int    `json:"team" binding:"required,gte=1,lte=2"`
	SalesId    string `json:"salesId" binding:"required"`
	SalesName  string `json:"salesName" binding:"required"`
}

func (s *SaveSalesProduct) Query() []string {
	query := []string{s.BranchId, s.BrandId, s.CategoryId, strconv.Itoa(s.Team), s.SalesId}
	return query
}

type FindCatalog struct {
	Num    int    `form:"num" binding:"gte=1"`
	Limit  int    `form:"limit" binding:"gte=1,lte=100"`
	Query  string `form:"query"`
	Search string `form:"search"`
}

func (f *FindCatalog) IsBySearch() bool {
	return f.Search != ""
}
func (f *FindCatalog) ToPage(items []*Product, err error) (*PageProduct, error) {
	if err != nil {
		return nil, err
	}
	result := &PageProduct{Back: nil, Next: nil, Limit: f.Limit, Query: f.Query, Sort: 0, Search: f.Search, Items: items}
	if f.Num > 1 && !f.IsBySearch() {
		back := f.Num - 1
		result.Back = &back
	}
	if len(items) == f.Limit && !f.IsBySearch() {
		next := f.Num + 1
		result.Next = &next
	}
	return result, nil
}

type FindProduct struct {
	Num    int    `form:"num" binding:"gte=1"`
	Limit  int    `form:"limit" binding:"gte=1,lte=100"`
	Query  string `form:"query" binding:"required"`
	Sort   int    `form:"sort"`
	Search string `form:"search"`
}

func (f *FindProduct) IsSortOrder() bool {
	return f.Sort == 1
}
func (f *FindProduct) IsSortDiscount() bool {
	return f.Sort == 2
}
func (f *FindProduct) IsBySearch() bool {
	return f.Search != ""
}
func (f *FindProduct) ToPage(items []*Product, err error) (*PageProduct, error) {
	if err != nil {
		return nil, err
	}
	result := &PageProduct{Back: nil, Next: nil, Limit: f.Limit, Query: f.Query, Sort: f.Sort, Search: f.Search, Items: items}
	if f.Num > 1 && !f.IsBySearch() {
		back := f.Num - 1
		result.Back = &back
	}
	if len(items) == f.Limit && !f.IsBySearch() {
		next := f.Num + 1
		result.Next = &next
	}
	return result, nil
}

type WarehouseNewHistory struct {
	Id   string
	Name string
}
type TNewHistory struct {
	From    *WarehouseNewHistory
	To      *WarehouseNewHistory
	Type    HistoryQtyType
	Product *Product
	Qty     int
	Creator *Creator
}

type FindHistory struct {
	Num      int    `form:"num" binding:"gte=1"`
	Limit    int    `form:"limit" binding:"gte=1,lte=100"`
	BranchId string `form:"branchId"`
}

func (f *FindHistory) IsByBranch() bool {
	return f.BranchId != ""
}

func (f *FindHistory) ToPage(items []*HistoryQty, err error) (*PageHistoryQty, error) {
	if err != nil {
		return nil, err
	}
	result := &PageHistoryQty{Back: nil, Next: nil, Limit: f.Limit, BranchId: f.BranchId, Items: items}
	if f.Num > 1 {
		back := f.Num - 1
		result.Back = &back
	}
	if len(items) == f.Limit {
		next := f.Num + 1
		result.Next = &next
	}
	return result, nil
}
