package entity

import (
	"sort"
	"time"
)

type Region struct {
	Id   string `json:"id" bson:"_id"`
	Name string `json:"name" bson:"name"`
}
type Address struct {
	Name   string    `json:"name" bson:"name"`
	LngLat []float64 `json:"lngLat" bson:"lngLat"`
}
type Warehouse struct {
	Id        string   `json:"id" bson:"_id"`
	Name      string   `json:"name" bson:"name"`
	Phone     string   `json:"phone" bson:"phone"`
	Address   *Address `json:"address" bson:"address"`
	IsDefault bool     `json:"isDefault" bson:"isDefault"`
}
type Branch struct {
	Id        string       `json:"id" bson:"_id"`
	Region    *Region      `json:"region" bson:"region"`
	Name      string       `json:"name" bson:"name"`
	Address   *Address     `json:"address" bson:"address"`
	Warehouse []*Warehouse `json:"warehouse" bson:"warehouse"`
	CreatedAt time.Time    `json:"createdAt" bson:"createdAt"`
	UpdatedAt time.Time    `json:"updatedAt" bson:"updatedAt"`
}
type SaveBranch struct {
	RegionId   string  `json:"regionId" binding:"required"`
	RegionName string  `json:"regionName" binding:"required"`
	Name       string  `json:"name" binding:"required"`
	Address    string  `json:"address" binding:"required"`
	AddressLat float64 `json:"addressLat" binding:"required,latitude"`
	AddressLng float64 `json:"addressLng" binding:"required,longitude"`
}
type SaveWarehouse struct {
	Id         string  `json:"id" binding:"required"`
	Name       string  `json:"name" binding:"required"`
	Phone      string  `json:"phone" binding:"required"`
	Address    string  `json:"address" binding:"required"`
	AddressLat float64 `json:"addressLat" binding:"required,latitude"`
	AddressLng float64 `json:"addressLng" binding:"required,longitude"`
	IsDefault  bool    `json:"isDefault"`
}

func NewWarehouse(saveWarehouse []*SaveWarehouse) []*Warehouse {
	mWarehouse := make(map[string]*Warehouse)
	for _, w := range saveWarehouse {
		mWarehouse[w.Id] = &Warehouse{Id: w.Id, Name: w.Name, Phone: w.Phone, Address: &Address{Name: w.Address, LngLat: []float64{w.AddressLng, w.AddressLat}}, IsDefault: w.IsDefault}
	}
	warehouse := make([]*Warehouse, 0)
	for _, w := range mWarehouse {
		warehouse = append(warehouse, w)
	}
	sort.Slice(warehouse, func(i, j int) bool {
		return warehouse[i].Name < warehouse[j].Name
	})
	return warehouse
}

type Find struct {
	Num      int    `form:"num" binding:"gte=1"`
	Limit    int    `form:"limit" binding:"gte=1,lte=100"`
	RegionId string `form:"regionId"`
	Search   string `form:"search"`
}

func (f *Find) IsBySearch() bool {
	return f.Search != ""
}
func (f *Find) IsByRegion() bool {
	return f.RegionId != ""
}

type Page struct {
	Back     *int      `json:"back"`
	Next     *int      `json:"next"`
	Limit    int       `json:"limit"`
	RegionId string    `json:"regionId"`
	Search   string    `json:"search"`
	Items    []*Branch `json:"items"`
}

func (f *Find) ToPage(items []*Branch, err error) (*Page, error) {
	if err != nil {
		return nil, err
	}
	result := &Page{Back: nil, Next: nil, Limit: f.Limit, RegionId: f.RegionId, Search: f.Search, Items: items}
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
