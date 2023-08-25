package auth

import (
	"encoding/base64"
	"encoding/json"
	"fmt"

	"github.com/gin-gonic/gin"
)

type Team int

const (
	NO_TEAM Team = iota
	FOOD
	RETAIL
)

type Roles int

const (
	CUSTOMER               Roles = iota
	SYSTEM_ADMIN           Roles = iota
	FINANCE_ADMIN          Roles = iota
	SALES_ADMIN            Roles = iota
	WAREHOUSE_ADMIN        Roles = iota
	BRANCH_ADMIN           Roles = iota
	BRANCH_FINANCE_ADMIN   Roles = iota
	BRANCH_SALES_ADMIN     Roles = iota
	BRANCH_WAREHOUSE_ADMIN Roles = iota
	DIREKTUR               Roles = iota
	GENERAL_MANAGER        Roles = iota
	NASIONAL_SALES_MANAGER Roles = iota
	REGIONAL_MANAGER       Roles = iota
	AREA_MANAGER           Roles = iota
	SALES                  Roles = iota
	COURIER                Roles = iota
)

type User struct {
	Id         string `json:"id"`
	Roles      int    `json:"roles"`
	Phone      string `json:"phone"`
	LocationId string `json:"locationId"`
	Team       int    `json:"team"`
}

func RolesEmployee() []Roles {
	return []Roles{
		SYSTEM_ADMIN,
		FINANCE_ADMIN,
		SALES_ADMIN,
		WAREHOUSE_ADMIN,
		BRANCH_ADMIN,
		BRANCH_FINANCE_ADMIN,
		BRANCH_SALES_ADMIN,
		BRANCH_WAREHOUSE_ADMIN,
		DIREKTUR,
		GENERAL_MANAGER,
		NASIONAL_SALES_MANAGER,
		REGIONAL_MANAGER,
		AREA_MANAGER,
		SALES,
		COURIER,
	}
}

func RolesAdmin() []Roles {
	return []Roles{
		SYSTEM_ADMIN,
		FINANCE_ADMIN,
		SALES_ADMIN,
		WAREHOUSE_ADMIN,
		BRANCH_ADMIN,
		BRANCH_FINANCE_ADMIN,
		BRANCH_SALES_ADMIN,
		BRANCH_WAREHOUSE_ADMIN,
	}
}

func RolesLeader() []Roles {
	return []Roles{
		DIREKTUR,
		GENERAL_MANAGER,
		NASIONAL_SALES_MANAGER,
		REGIONAL_MANAGER,
		AREA_MANAGER,
	}
}

func (u *User) isRoles(roles []Roles) bool {
	if len(roles) == 0 {
		return true
	}
	for _, r := range roles {
		if u.Roles == int(r) {
			return true
		}
	}
	return false
}
func Validate(roles ...Roles) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		b, err := base64.StdEncoding.DecodeString(ctx.GetHeader("Auth-User"))
		if err != nil {
			ctx.Error(err)
			ctx.AbortWithStatusJSON(401, gin.H{"code": 401, "data": nil, "errors": err.Error()})
			return
		}
		var u User
		if err := json.Unmarshal(b, &u); err != nil {
			ctx.Error(err)
			ctx.AbortWithStatusJSON(401, gin.H{"code": 401, "data": nil, "errors": err.Error()})
			return
		}
		if !u.isRoles(roles) {
			err := fmt.Errorf("permission denied")
			ctx.Error(err)
			ctx.AbortWithStatusJSON(401, gin.H{"code": 401, "data": nil, "errors": err.Error()})
			return
		}
		ctx.Set("user", &u)
		ctx.Next()
	}
}
func GetUser(ctx *gin.Context) *User {
	if v, ok := ctx.Get("user"); v != nil && ok {
		if u, ok := v.(*User); u != nil && ok {
			return u
		}
	}
	return nil
}
