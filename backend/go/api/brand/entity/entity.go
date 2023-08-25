package entity

import (
	"time"
)

type Brand struct {
	Id        string    `json:"id" bson:"_id"`
	Name      string    `json:"name" bson:"name"`
	ImageUrl  string    `json:"imageUrl" bson:"imageUrl"`
	CreatedAt time.Time `json:"createdAt" bson:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt" bson:"updatedAt"`
}
