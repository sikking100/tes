package entity

import (
	"os"
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Creator struct {
	Id          string `json:"id" bson:"_id" binding:"required"`
	Name        string `json:"name" bson:"name" binding:"required"`
	Roles       int    `json:"roles" bson:"roles" binding:"gte=1"`
	ImageUrl    string `json:"imageUrl" bson:"imageUrl" binding:"required"`
	Description string `json:"description" bson:"description" binding:"required"`
}
type Comment struct {
	Id         primitive.ObjectID `json:"id" bson:"_id"`
	ActivityId primitive.ObjectID `json:"activityId" bson:"activityId"`
	Comment    string             `json:"comment" bson:"comment"`
	Creator    *Creator           `json:"creator" bson:"creator"`
	CreatedAt  time.Time          `json:"createdAt" bson:"createdAt"`
}

type Activity struct {
	Id           primitive.ObjectID `json:"id" bson:"_id"`
	Title        string             `json:"title" bson:"title"`
	Description  string             `json:"description" bson:"description"`
	VideoUrl     string             `json:"videoUrl" bson:"videoUrl"`
	ImageUrl     string             `json:"imageUrl" bson:"imageUrl"`
	ImagePath    string             `json:"imagePath" bson:"imagePath,omitempty"`
	Comment      []*Comment         `json:"comment" bson:"comment"`
	CommentCount int                `json:"commentCount" bson:"commentCount"`
	Creator      *Creator           `json:"creator" bson:"creator"`
	CreatedAt    time.Time          `json:"createdAt" bson:"createdAt"`
	UpdatedAt    time.Time          `json:"updatedAt" bson:"updatedAt"`
}

type SaveActivity struct {
	Title       string   `json:"title" binding:"required"`
	Description string   `json:"description" binding:"required"`
	VideoUrl    string   `json:"videoUrl" binding:"required"`
	Creator     *Creator `json:"creator" binding:"required"`
}

func NewActivity(s SaveActivity) *Activity {
	return &Activity{
		Id:           primitive.NewObjectID(),
		Title:        s.Title,
		Description:  s.Description,
		VideoUrl:     s.VideoUrl,
		ImageUrl:     os.Getenv("IMAGE_URL"),
		Creator:      s.Creator,
		Comment:      make([]*Comment, 0),
		CommentCount: 0,
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}
}

type SaveComment struct {
	ActivityId primitive.ObjectID `json:"activityId" binding:"required"`
	Comment    string             `json:"comment" binding:"required"`
	Creator    *Creator           `json:"creator" binding:"required"`
}

func NewComment(s SaveComment) *Comment {
	return &Comment{
		Id:         primitive.NewObjectID(),
		ActivityId: s.ActivityId,
		Creator:    s.Creator,
		Comment:    s.Comment,
		CreatedAt:  time.Now(),
	}
}

type Find struct {
	Num   int `form:"num" binding:"gte=1"`
	Limit int `form:"limit" binding:"gte=1,lte=100"`
}

type Page struct {
	Back  *int        `json:"back"`
	Next  *int        `json:"next"`
	Limit int         `json:"limit"`
	Items []*Activity `json:"items"`
}

func (f *Find) ToPage(items []*Activity) *Page {
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
