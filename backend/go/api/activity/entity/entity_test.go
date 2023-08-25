package entity

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestNew(t *testing.T) {
	assert.NotEqual(t, NewActivity(SaveActivity{}), &Activity{}, "FAIL")
}

func TestNewComment(t *testing.T) {
	assert.NotEqual(t, NewComment(SaveComment{}), &Comment{}, "FAIL")
}

func TestToPage(t *testing.T) {
	a := Find{
		Num:   1,
		Limit: 1,
	}
	assert.NotEqual(t, a.ToPage([]*Activity{}), &Page{}, "FAIL")
	a.Num++
	assert.NotEqual(t, a.ToPage([]*Activity{}), &Page{}, "FAIL")
	a.Limit--
	assert.NotEqual(t, a.ToPage([]*Activity{}), &Page{}, "FAIL")
}
