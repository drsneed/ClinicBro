package models

import "time"

type AppointmentType struct {
	ID            uint      `gorm:"primaryKey" json:"id"`
	Active        bool      `json:"active"`
	Name          string    `gorm:"size:32;not null" json:"name"`
	Description   string    `gorm:"size:256" json:"description"`
	Color         string    `gorm:"size:9;not null" json:"color"`
	DateCreated   time.Time `json:"date_created"`
	DateUpdated   time.Time `json:"date_updated"`
	CreatedUserID uint      `json:"created_user_id"`
	UpdatedUserID uint      `json:"updated_user_id"`
}
