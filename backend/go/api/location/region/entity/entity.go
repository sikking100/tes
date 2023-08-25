package entity

import (
	"time"
)

type Region struct {
	Id        string    `json:"id" bson:"_id"`
	Name      string    `json:"name" bson:"name"`
	CreatedAt time.Time `json:"createdAt" bson:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt" bson:"updatedAt"`
}
type Find struct {
	Num    int    `form:"num" binding:"gte=1"`
	Limit  int    `form:"limit" binding:"gte=1,lte=100"`
	Search string `form:"search"`
}

func (f *Find) IsBySearch() bool {
	return f.Search != ""
}

type Page struct {
	Back   *int      `json:"back"`
	Next   *int      `json:"next"`
	Limit  int       `json:"limit"`
	Search string    `json:"search"`
	Items  []*Region `json:"items"`
}

func (f *Find) ToPage(items []*Region, err error) (*Page, error) {
	if err != nil {
		return nil, err
	}
	result := &Page{Back: nil, Next: nil, Limit: f.Limit, Search: f.Search, Items: items}
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
