package entity

import (
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/grocee-project/dairyfood/backend/go/pkg/auth"
)

type Location struct {
	Id   string `json:"id" bson:"_id" binding:"required"`
	Name string `json:"name" bson:"name" binding:"required"`
	Type int    `json:"type" bson:"type" binding:"required"`
}
type Employee struct {
	Id        string    `json:"id" bson:"_id"`
	Phone     string    `json:"phone" bson:"phone"`
	Email     string    `json:"email" bson:"email"`
	Name      string    `json:"name" bson:"name"`
	ImageUrl  string    `json:"imageUrl" bson:"imageUrl"`
	Roles     int       `json:"roles" bson:"roles"`
	Location  *Location `json:"location" bson:"location"`
	Team      int       `json:"team" bson:"team"`
	FcmToken  string    `json:"fcmToken" bson:"fcmToken"`
	CreatedAt time.Time `json:"createdAt" bson:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt" bson:"updatedAt"`
}
type Save struct {
	Phone    string    `json:"phone" binding:"required,e164"`
	Email    string    `json:"email" binding:"required,email"`
	Name     string    `json:"name" binding:"required"`
	Roles    int       `json:"roles" binding:"gte=1,lte=15"`
	Location *Location `json:"location"`
	Team     int       `json:"team" binding:"gte=0,lte=2"`
	Query    []string  `json:"-"`
}

type UpdateAccount struct {
	Phone string `json:"phone" binding:"required,e164"`
	Email string `json:"email" binding:"required,email"`
	Name  string `json:"name" binding:"required"`
}

func isContain(i int, roles ...auth.Roles) bool {
	for _, r := range roles {
		if i == int(r) {
			return true
		}
	}
	return false

}
func (s *Save) Save() error {
	switch {
	case isContain(s.Roles, auth.SYSTEM_ADMIN, auth.FINANCE_ADMIN, auth.SALES_ADMIN, auth.WAREHOUSE_ADMIN):
		s.Location = nil
		s.Team = 0
		s.Query = []string{strconv.Itoa(s.Roles)}
		return nil
	case isContain(s.Roles, auth.DIREKTUR, auth.GENERAL_MANAGER, auth.NASIONAL_SALES_MANAGER):
		s.Location = nil
		if s.Team == 0 {
			return fmt.Errorf("team required")
		}
		s.Query = []string{strconv.Itoa(s.Roles), strconv.Itoa(s.Team)}
		return nil
	case isContain(s.Roles, auth.REGIONAL_MANAGER, auth.AREA_MANAGER):
		switch {
		case s.Location == nil:
			return fmt.Errorf("location required")
		case s.Team == 0:
			return fmt.Errorf("team required")
		}
		s.Query = []string{strconv.Itoa(s.Roles), strconv.Itoa(s.Team), s.Location.Id}
		return nil
	case isContain(s.Roles, auth.BRANCH_ADMIN, auth.BRANCH_FINANCE_ADMIN, auth.BRANCH_SALES_ADMIN, auth.BRANCH_WAREHOUSE_ADMIN, auth.COURIER):
		if s.Location == nil {
			return fmt.Errorf("location required")
		}
		s.Team = 0
		s.Query = []string{strconv.Itoa(s.Roles), s.Location.Id}
		return nil
	case isContain(s.Roles, auth.SALES):
		switch {
		case s.Location == nil:
			return fmt.Errorf("location required")
		case s.Team == 0:
			return fmt.Errorf("team required")
		}
		s.Query = []string{strconv.Itoa(s.Roles), strconv.Itoa(s.Team), s.Location.Id}
		return nil
	}
	return fmt.Errorf("invalid roles")
}

type Find struct {
	Num    int    `form:"num" binding:"gte=1"`
	Limit  int    `form:"limit" binding:"gte=1,lte=100"`
	Query  string `form:"query"`
	Search string `form:"search"`
}

func (f *Find) GetQuery() []string {
	return strings.Split(f.Query, ",")
}
func (f *Find) IsBySearch() bool {
	return f.Search != ""
}
func (f *Find) IsByQuery() bool {
	return f.Query != ""
}

type Page struct {
	Back   *int        `json:"back"`
	Next   *int        `json:"next"`
	Limit  int         `json:"limit"`
	Query  string      `json:"query"`
	Search string      `json:"search"`
	Items  []*Employee `json:"items"`
}

func (f *Find) ToPage(items []*Employee, err error) (*Page, error) {
	if err != nil {
		return nil, err
	}
	result := &Page{Back: nil, Next: nil, Limit: f.Limit, Query: f.Query, Search: f.Search, Items: items}
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

type FindApprover struct {
	RegionId string `form:"regionId" binding:"required"`
	BranchId string `form:"branchId" binding:"required"`
	Team     int    `form:"team" binding:"gte=1,lte=2"`
}
type UserApprover struct {
	Id        string    `json:"id"`
	Phone     string    `json:"phone"`
	Email     string    `json:"email"`
	Name      string    `json:"name"`
	ImageUrl  string    `json:"imageUrl"`
	Roles     int       `json:"roles"`
	FcmToken  string    `json:"fcmToken"`
	Note      string    `json:"note"`
	Status    int       `json:"status"`
	UpdatedAt time.Time `json:"updatedAt"`
}

func ToUserApprover(items []*Employee) []*UserApprover {
	result := make([]*UserApprover, 0)
	for _, it := range items {
		if it != nil {
			result = append(result, &UserApprover{Id: it.Id, Phone: it.Phone, Email: it.Email, Name: it.Name, ImageUrl: it.ImageUrl, Roles: it.Roles, FcmToken: it.FcmToken, Note: "", Status: 0})
		}
	}
	result[0].Status = 1
	return result
}
