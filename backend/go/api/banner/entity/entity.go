package entity

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Type int

const (
	INTERNAL Type = iota + 1
	EXTERNAL
)

type Banner struct {
	Id        primitive.ObjectID `json:"id" bson:"_id"`
	Type      int                `json:"type" bson:"type"`
	ImageUrl  string             `json:"imageUrl" bson:"imageUrl"`
	CreatedAt time.Time          `json:"createdAt" bson:"createdAt"`
}
