package models

import "time"

type Location struct {
	ID            uint      `gorm:"primaryKey" json:"id"`
	Active        bool      `json:"active"`
	Name          string    `gorm:"uniqueIndex;size:50;not null" json:"name"`
	Phone         string    `gorm:"size:15" json:"phone"`
	Address1      string    `gorm:"size:128" json:"address_1"`
	Address2      string    `gorm:"size:32" json:"address_2"`
	City          string    `gorm:"size:35" json:"city"`
	State         string    `gorm:"size:2" json:"state"`
	ZipCode       string    `gorm:"size:15" json:"zip_code"`
	DateCreated   time.Time `json:"date_created"`
	DateUpdated   time.Time `json:"date_updated"`
	CreatedUserID uint      `json:"created_user_id"`
	UpdatedUserID uint      `json:"updated_user_id"`
}
