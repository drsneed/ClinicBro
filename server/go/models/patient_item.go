package models

import "time"

type PatientItem struct {
	ID          uint       `gorm:"primaryKey" json:"id"`
	Active      bool       `json:"active"`
	FirstName   string     `gorm:"size:50" json:"first_name"`
	FullName    string     `gorm:"size:50" json:"full_name"`
	DateOfBirth *time.Time `json:"date_of_birth"`
}
