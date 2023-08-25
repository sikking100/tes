package entity

import (
	"os"
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Recipe struct {
	Id          primitive.ObjectID `json:"id" bson:"_id"`
	Category    string             `json:"category" bson:"category"`
	Title       string             `json:"title" bson:"title"`
	ImageUrl    string             `json:"imageUrl" bson:"imageUrl"`
	Description string             `json:"description" bson:"description"`
	CreatedAt   time.Time          `json:"createdAt" bson:"createdAt"`
	UpdatedAt   time.Time          `json:"updatedAt" bson:"updatedAt"`
}

type Save struct {
	Category    string `json:"category" bson:"category" binding:"required"`
	Title       string `json:"title" bson:"title" binding:"required"`
	Description string `json:"description" bson:"description" binding:"required"`
}
type Categories struct {
	Category string `json:"category" bson:"category"`
}

func Create(s Save) *Recipe {
	return &Recipe{
		Id:          primitive.NewObjectID(),
		Category:    s.Category,
		Title:       s.Title,
		Description: s.Description,
		ImageUrl:    os.Getenv("IMAGE_URL"),
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
}

func (r *Recipe) Update(data Save) error {
	r.Category = data.Category
	r.Title = data.Title
	r.Description = data.Description
	r.UpdatedAt = time.Now()
	return nil
}

func (r *Recipe) NewFile(imageUrl string) error {
	r.ImageUrl = imageUrl
	r.UpdatedAt = time.Now()
	return nil
}

type Find struct {
	Num        int    `form:"num" binding:"gte=1"`
	Limit      int    `form:"limit" binding:"gte=1,lte=100"`
	Search     string `form:"search"`
	Category   string `form:"category"`
	Categories bool   `form:"categories"`
}

type Page struct {
	Back     *int      `json:"back"`
	Next     *int      `json:"next"`
	Limit    int       `json:"limit"`
	Search   string    `json:"search"`
	Category string    `json:"category"`
	Items    []*Recipe `json:"items"`
}

func (f *Find) ToPage(items []*Recipe) *Page {
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
