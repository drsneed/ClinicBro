package models

import "time"

type AppointmentStatus struct {
	ID            uint      `gorm:"primaryKey" json:"id"`
	Active        bool      `json:"active"`
	Name          string    `gorm:"uniqueIndex;size:32;not null" json:"name"`
	Description   string    `gorm:"size:256" json:"description"`
	Show          bool      `json:"show"`
	DateCreated   time.Time `json:"date_created"`
	DateUpdated   time.Time `json:"date_updated"`
	CreatedUserID uint      `json:"created_user_id"`
	UpdatedUserID uint      `json:"updated_user_id"`
}
