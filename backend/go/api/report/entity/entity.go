package entity

import (
	"os"
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Report struct {
	Id          primitive.ObjectID `json:"id" bson:"_id"`
	To          *User              `json:"to" bson:"to"`
	From        *User              `json:"from" bson:"from"`
	Title       string             `json:"title" bson:"title"`
	Description string             `json:"description" bson:"description"`
	ImageUrl    string             `json:"imageUrl" bson:"imageUrl"`
	FilePath    string             `json:"filePath" bson:"filePath"`
	SendDate    time.Time          `json:"sendDate" bson:"sendDate"`
}
type User struct {
	Id          string `json:"id" bson:"id"`
	Name        string `json:"name" bson:"name"`
	Roles       int    `json:"roles" bson:"roles"`
	ImageUrl    string `json:"imageUrl" bson:"imageUrl"`
	Description string `json:"description" bson:"description"`
}

type Save struct {
	To          *User  `json:"to" bson:"to" binding:"required"`
	From        *User  `json:"from" bson:"from" binding:"required"`
	Title       string `json:"title" bson:"title" binding:"required"`
	Description string `json:"description" bson:"description" binding:"required"`
}

func Create(s Save) *Report {
	return &Report{
		Id:          primitive.NewObjectID(),
		From:        s.From,
		To:          s.To,
		Title:       s.Title,
		Description: s.Description,
		ImageUrl:    os.Getenv("IMAGE_URL"),
		FilePath:    "",
		SendDate:    time.Now(),
	}
}
func (r *Report) NewFile(file string, isImage bool) error {
	if isImage {
		r.ImageUrl = file
		return nil
	}
	r.FilePath = file
	return nil
}

type Find struct {
	Num   int    `form:"num" binding:"gte=1"`
	Limit int    `form:"limit" binding:"gte=1,lte=100"`
	To    string `form:"to"`
	From  string `form:"from"`
}

type Page struct {
	Back  *int      `json:"back"`
	Next  *int      `json:"next"`
	Limit int       `json:"limit"`
	Items []*Report `json:"items"`
}

func (f *Find) ToPage(items []*Report) *Page {
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
