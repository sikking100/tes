package entity

import (
	"time"
)

type Code struct {
	Id          string    `json:"id" bson:"_id"`
	Description string    `json:"description" bson:"description"`
	CreatedAt   time.Time `json:"createdAt" bson:"createdAt"`
	UpdatedAt   time.Time `json:"updatedAt" bson:"updatedAt"`
}
type Save struct {
	Description string `json:"description" bson:"description"`
}

type Find struct {
	Num   int `form:"num" binding:"gte=1"`
	Limit int `form:"limit" binding:"gte=1,lte=100"`
}

type Page struct {
	Back  *int    `json:"back"`
	Next  *int    `json:"next"`
	Limit int     `json:"limit"`
	Items []*Code `json:"items"`
}

func (f *Find) ToPage(items []*Code) *Page {
	result := &Page{Back: nil, Next: nil, Limit: f.Limit, Items: items}
	if f.Num > 1 {
		back := f.Num - 1
		result.Back = &back
	}
	if f.Limit == len(items) {
		next := f.Num + 1
		result.Next = &next
	}
	return result
}
