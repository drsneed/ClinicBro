package models

import (
	"time"
)

type UserRole struct {
	UserID      uint      `gorm:"primaryKey" json:"user_id"`
	RoleID      uint      `gorm:"primaryKey" json:"role_id"`
	DateCreated time.Time `json:"date_created"`
	DateUpdated time.Time `json:"date_updated"`
	CreatedByID uint      `json:"-"`
	UpdatedByID uint      `json:"-"`
}
