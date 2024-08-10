package models

import (
	"time"
)

type UserPreference struct {
	ID              uint      `gorm:"primaryKey" json:"id"`
	UserID          uint      `json:"user_id"`
	PreferenceKey   string    `json:"preference_key"`
	PreferenceValue string    `json:"preference_value"`
	DateCreated     time.Time `json:"date_created"`
	DateUpdated     time.Time `json:"date_updated"`
	CreatedByID     uint      `json:"-"`
	UpdatedByID     uint      `json:"-"`
}
