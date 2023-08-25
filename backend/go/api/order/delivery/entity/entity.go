package entity

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Status int

const (
	APPLY Status = iota
	PENDING
	WAITING_CREATE_PACKING_LIST
	WAITING_ADD_COURIER
	PICKED_UP
	LOADED
	WAITING_DELIVER
	DELIVER
	RESTOCK
	COMPLETE
	CANCEL
)

type CourierType int

const (
	INTERNAL CourierType = iota
	EXTERNAL
)

type Warehouse struct {
	Id            string    `json:"id" bson:"_id"`
	Name          string    `json:"name" bson:"name"`
	AddressName   string    `json:"addressName" bson:"addressName"`
	AddressLngLat []float64 `json:"addressLngLat" bson:"addressLngLat"`
}
type Product struct {
	Id          string     `json:"id" bson:"_id"`
	Warehouse   *Warehouse `json:"warehouse" bson:"warehouse"`
	Category    string     `json:"category" bson:"category"`
	Brand       string     `json:"brand" bson:"brand"`
	Name        string     `json:"name" bson:"name"`
	Size        string     `json:"size" bson:"size"`
	ImageUrl    string     `json:"imageUrl" bson:"imageUrl"`
	PurcaseQty  int        `json:"purcaseQty" bson:"purcaseQty"`
	DeliveryQty int        `json:"deliveryQty" bson:"deliveryQty"`
	ReciveQty   int        `json:"reciveQty" bson:"reciveQty"`
	BrokenQty   int        `json:"brokenQty" bson:"brokenQty"`
	Status      int        `json:"status" bson:"status"`
}
type Customer struct {
	Id            string    `json:"id" bson:"_id" binding:"required"`
	Name          string    `json:"name" bson:"name" binding:"required"`
	Phone         string    `json:"phone" bson:"phone" binding:"required"`
	AddressName   string    `json:"addressName" bson:"addressName" binding:"required"`
	AddressLngLat []float64 `json:"addressLngLat" bson:"addressLngLat" binding:"required"`
}
type Courier struct {
	Id       string `json:"id" bson:"_id" binding:"required"`
	Name     string `json:"name" bson:"name" binding:"required"`
	Phone    string `json:"phone" bson:"phone" binding:"required"`
	ImageUrl string `json:"imageUrl" bson:"imageUrl" binding:"required"`
}
type Delivery struct {
	Id            primitive.ObjectID `json:"id" bson:"_id"`
	OrderId       primitive.ObjectID `json:"orderId" bson:"orderId"`
	TransactionId string             `json:"transactionId" bson:"transactionId"`
	RegionId      string             `json:"regionId" bson:"regionId"`
	RegionName    string             `json:"regionName" bson:"regionName"`
	BranchId      string             `json:"branchId" bson:"branchId"`
	BranchName    string             `json:"branchName" bson:"branchName"`
	Customer      *Customer          `json:"customer" bson:"customer"`
	Courier       *Courier           `json:"courier" bson:"courier"`
	CourierType   int                `json:"courierType" bson:"courierType"`
	Url           string             `json:"url" bson:"url"`
	Product       []*Product         `json:"product" bson:"product"`
	Note          string             `json:"note" bson:"note"`
	IsBeenLoaded  bool               `json:"-" bson:"isBeenLoaded"`
	Price         float64            `json:"price" bson:"price"`
	Status        int                `json:"status" bson:"status"`
	DeliveryAt    time.Time          `json:"deliveryAt" bson:"deliveryAt"`
	CreatedAt     time.Time          `json:"createdAt" bson:"createdAt"`
}
type Page struct {
	Back      *int        `json:"back"`
	Next      *int        `json:"next"`
	Limit     int         `json:"limit"`
	BranchId  string      `json:"branchId"`
	CourierId string      `json:"courier"`
	Status    int         `json:"status"`
	Items     []*Delivery `json:"items"`
}
type Create struct {
	OrderId     primitive.ObjectID
	RegionId    string
	RegionName  string
	BranchId    string
	BranchName  string
	Customer    *Customer
	CourierType int
	Product     []*Product
	Note        string
	Price       float64
	DeliveryAt  time.Time
}

func (c Create) NewDelivery(status Status) *Delivery {
	return &Delivery{
		Id:            primitive.NewObjectID(),
		OrderId:       c.OrderId,
		TransactionId: "",
		RegionId:      c.RegionId,
		RegionName:    c.RegionName,
		BranchId:      c.BranchId,
		BranchName:    c.BranchName,
		Customer:      c.Customer,
		Courier:       nil,
		CourierType:   c.CourierType,
		Url:           "",
		Product:       c.Product,
		Note:          c.Note,
		IsBeenLoaded:  false,
		Price:         c.Price,
		Status:        int(status),
		DeliveryAt:    c.DeliveryAt,
		CreatedAt:     time.Now(),
	}

}

func NewDelivery(c Create, status Status) *Delivery {
	return &Delivery{
		Id:            primitive.NewObjectID(),
		OrderId:       c.OrderId,
		TransactionId: "",
		RegionId:      c.RegionId,
		RegionName:    c.RegionName,
		BranchId:      c.BranchId,
		BranchName:    c.BranchName,
		Customer:      c.Customer,
		Courier:       nil,
		CourierType:   c.CourierType,
		Url:           "",
		Product:       c.Product,
		Note:          c.Note,
		IsBeenLoaded:  false,
		Price:         c.Price,
		Status:        int(status),
		DeliveryAt:    c.DeliveryAt,
		CreatedAt:     time.Now(),
	}
}

type CreatePackingList struct {
	CourierType int        `json:"courierType" binding:"gte=0,lte=1"`
	Product     []*Product `json:"product" binding:"required"`
}

type BookingCourierExternal struct {
	CustomerPicName      string  `json:"customerPicName" binding:"required"`
	CustomerPicPhone     string  `json:"customerPicPhone" binding:"required,e164"`
	CustomerAddressName  string  `json:"customerAddressName" binding:"required"`
	CustomerAddressLng   float64 `json:"customerAddressLng" binding:"required,longitude"`
	CustomerAddressLat   float64 `json:"customerAddressLat" binding:"required,latitude"`
	WarehousePicName     string  `json:"warehousePicName" binding:"required"`
	WarehousePicPhone    string  `json:"warehousePicPhone" binding:"required"`
	WarehouseAddressName string  `json:"warehouseAddressName" binding:"required"`
	WarehouseAddressLng  float64 `json:"warehouseAddressLng" binding:"required,longitude"`
	WarehouseAddressLat  float64 `json:"warehouseAddressLat" binding:"required,latitude"`
	Item                 string  `json:"item" binding:"required"`
}

type UpdateQty struct {
	ProductId   string `json:"productId" binding:"required"`
	DeliveryQty int    `json:"deliveryQty" binding:"gte=0"`
}
type FindPackingListWarehouse struct {
	BranchId    string `form:"branchId" binding:"required"`
	WarehouseId string `form:"warehouseId" binding:"required"`
	Status      int    `form:"status" binding:"gte=0"`
}
type PackingListWarehouse struct {
	Courier *Courier   `json:"courier" bson:"courier"`
	Product []*Product `json:"product" bson:"product"`
}
type FindPackingListCourier struct {
	CourierId string `form:"courierId" binding:"required"`
	Status    int    `form:"status" binding:"gte=0"`
}
type PackingListCourier struct {
	Warehouse *Warehouse `json:"warehouse" bson:"warehouse"`
	Product   []*Product `json:"product" bson:"product"`
}
type FindPackingListDestination struct {
	CourierId string `form:"courierId" binding:"required"`
}
type PackingListDestination struct {
	DeliveryId primitive.ObjectID `json:"deliveryId" bson:"_id"`
	OrderId    primitive.ObjectID `json:"orderId" bson:"orderId"`
	Customer   *Customer          `json:"customer" bson:"customer"`
}

type PackingListLoaded struct {
	BranchId    string         `json:"branchId" binding:"required"`
	CourierId   string         `json:"courierId" binding:"required"`
	WarehouseId string         `json:"warehouseId" binding:"required"`
	Product     map[string]int `json:"product"`
}
type Restock struct {
	BranchId    string `json:"branchId" binding:"required"`
	WarehouseId string `json:"warehouseId" binding:"required"`
}
type Complete struct {
	CourierId string     `json:"courierId" binding:"required"`
	Product   []*Product `json:"product" binding:"required"`
	Status    int        `json:"status" binding:"gte=8,lte=9"`
	Note      string     `json:"note" binding:"required"`
}

type FindProduct struct {
	CourierId   string `form:"courierId"`
	WarehouseId string `form:"warehouseId"`
	BranchId    string `form:"branchId"`
	Status      int    `form:"status" binding:"gte=0"`
}

type GetGoSendPrice struct {
	OriginLat      float64 `form:"originLat" binding:"required,latitude"`
	OriginLng      float64 `form:"originLng" binding:"required,longitude"`
	DestinationLat float64 `form:"destinationLat" binding:"required,latitude"`
	DestinationLng float64 `form:"destinationLng" binding:"required,longitude"`
}
type GoSendCallback struct {
	StoreOrderId    primitive.ObjectID `json:"store_order_id"`
	EntityId        string             `json:"entity_id"`
	Status          string             `json:"status"`
	DriverName      string             `json:"driver_name"`
	DriverPhone     string             `json:"driver_phone"`
	DriverPhotoUrl  string             `json:"driver_photo_url"`
	LiveTrackingUrl string             `json:"liveTrackingUrl"`
	Price           float64            `json:"price"`
}
type Find struct {
	Num       int    `form:"num" binding:"gte=1"`
	Limit     int    `form:"limit" binding:"gte=1,lte=100"`
	BranchId  string `form:"branchId"`
	CourierId string `form:"courierId"`
	Status    int    `form:"status"`
}

func (f *Find) ToPage(items []*Delivery) *Page {
	page := &Page{Back: nil, Next: nil, Limit: f.Limit, BranchId: f.BranchId, CourierId: f.CourierId, Status: f.Status, Items: items}
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
