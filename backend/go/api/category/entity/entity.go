package entity

import (
	"time"
)

type Category struct {
	Id        string    `json:"id" bson:"_id"`
	Name      string    `json:"name" bson:"name"`
	Team      int       `json:"team" bson:"team"`
	Target    int       `json:"target" bson:"target"`
	CreatedAt time.Time `json:"createdAt" bson:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt" bson:"updatedAt"`
}
type Save struct {
	Name   string `json:"name" binding:"required"`
	Team   int    `json:"team" binding:"gte=1,lte=2"`
	Target int    `json:"target" binding:"gte=0"`
}
