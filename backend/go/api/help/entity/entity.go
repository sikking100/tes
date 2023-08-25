package entity

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Help struct {
	Id        primitive.ObjectID `json:"id" bson:"_id"`
	Topic     string             `json:"topic" bson:"topic"`
	Question  string             `json:"question" bson:"question"`
	Answer    string             `json:"answer" bson:"answer"`
	Creator   Creator            `json:"creator" bson:"creator"`
	CreatedAt time.Time          `json:"createdAt" bson:"createdAt"`
	UpdatedAt time.Time          `json:"updatedAt" bson:"updatedAt"`
}

type Creator struct {
	Id          string `json:"id" bson:"id"`
	Name        string `json:"name" bson:"name"`
	Roles       int    `json:"roles" bson:"roles"`
	ImageUrl    string `json:"imageUrl" bson:"imageUrl"`
	Description string `json:"description" bson:"description"`
}

type SaveHelp struct {
	Topic    string   `json:"topic" bson:"topic" binding:"required"`
	Question string   `json:"question" bson:"question" binding:"required"`
	Answer   string   `json:"answer" bson:"answer" binding:"required"`
	Creator  *Creator `json:"creator" bson:"creator" binding:"required"`
}

type SaveQuestion struct {
	Question string   `json:"question" bson:"question" binding:"required"`
	Creator  *Creator `json:"creator" bson:"creator" binding:"required"`
}

type Answer struct {
	Answer string `json:"answer" bson:"answer" binding:"required"`
}

func CreateHelp(s SaveHelp) *Help {

	return &Help{
		Id:        primitive.NewObjectID(),
		Topic:     s.Topic,
		Question:  s.Question,
		Answer:    s.Answer,
		Creator:   *s.Creator,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

func CreateQuestion(s SaveQuestion) *Help {
	return &Help{
		Id:        primitive.NewObjectID(),
		Question:  s.Question,
		Answer:    "",
		Creator:   *s.Creator,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

func (h *Help) AnswerQuestion(answer string) error {
	h.Answer = answer
	h.UpdatedAt = time.Now()
	return nil
}

func (h *Help) UpdateHelp(data SaveHelp) error {
	h.Topic = data.Topic
	h.Question = data.Question
	h.Answer = data.Answer
	h.UpdatedAt = time.Now()
	return nil
}

type Find struct {
	Num        int    `form:"num" binding:"gte=1"`
	Limit      int    `form:"limit" binding:"gte=1,lte=100"`
	Search     string `form:"search"`
	IsHelp     bool   `form:"isHelp"`
	UserId     string `form:"userId"`
	IsAnswered bool   `form:"isAnswered"`
}

func (f *Find) IsBySearch() bool {
	return f.Search != ""
}

type Page struct {
	Back       *int    `json:"back"`
	Next       *int    `json:"next"`
	Limit      int     `json:"limit"`
	Search     string  `json:"search"`
	IsHelp     bool    `json:"isHelp"`
	UserId     string  `json:"userId"`
	IsAnswered bool    `json:"isAnswered"`
	Items      []*Help `json:"items"`
}

func (f *Find) ToPage(items []*Help) *Page {
	result := &Page{Back: nil, Next: nil, Search: f.Search, Limit: f.Limit, IsHelp: f.IsHelp, UserId: f.UserId, IsAnswered: f.IsAnswered, Items: items}
	if f.Num > 1 && !f.IsBySearch() {
		back := f.Num - 1
		result.Back = &back
	}
	if f.Limit == len(items) && !f.IsBySearch() {
		next := f.Num + 1
		result.Next = &next
	}
	return result
}
