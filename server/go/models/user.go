package models

import (
	"time"
)

type User struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	Name        string    `gorm:"uniqueIndex" json:"name"`
	Color       string    `json:"color"`
	IsProvider  bool      `json:"is_provider"`
	Active      bool      `json:"active"`
	DateCreated time.Time `json:"date_created"`
	DateUpdated time.Time `json:"date_updated"`
	CreatedByID uint      `json:"-"`
	UpdatedByID uint      `json:"-"`
}

type UserCreate struct {
	Name       string `json:"name" binding:"required"`
	Password   string `json:"password" binding:"required"`
	Color      string `json:"color" binding:"required"`
	IsProvider bool   `json:"is_provider"`
	Active     bool   `json:"active"`
}
