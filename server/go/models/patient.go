package models

import "time"

type Patient struct {
	ID            uint       `gorm:"primaryKey" json:"id"`
	Active        bool       `json:"active"`
	FirstName     string     `gorm:"size:50" json:"first_name"`
	MiddleName    string     `gorm:"size:50" json:"middle_name"`
	LastName      string     `gorm:"size:50" json:"last_name"`
	DateOfBirth   *time.Time `json:"date_of_birth"`
	DateOfDeath   *time.Time `json:"date_of_death"`
	Email         string     `gorm:"size:99" json:"email"`
	Phone         string     `gorm:"size:15" json:"phone"`
	Password      string     `gorm:"size:60" json:"-"`
	Address1      string     `gorm:"size:128" json:"address_1"`
	Address2      string     `gorm:"size:32" json:"address_2"`
	City          string     `gorm:"size:35" json:"city"`
	State         string     `gorm:"size:2" json:"state"`
	ZipCode       string     `gorm:"size:15" json:"zip_code"`
	Notes         string     `gorm:"size:2500" json:"notes"`
	CanCall       bool       `json:"can_call"`
	CanText       bool       `json:"can_text"`
	CanEmail      bool       `json:"can_email"`
	LocationID    uint       `json:"location_id"`
	ProviderID    uint       `json:"provider_id"`
	DateCreated   time.Time  `json:"date_created"`
	DateUpdated   time.Time  `json:"date_updated"`
	CreatedUserID uint       `json:"created_user_id"`
	UpdatedUserID uint       `json:"updated_user_id"`
}
