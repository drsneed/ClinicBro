package models

import "time"

type RecentPatient struct {
	UserID      uint      `gorm:"primaryKey" json:"user_id"`
	PatientID   uint      `gorm:"primaryKey" json:"patient_id"`
	DateCreated time.Time `json:"date_created"`
}
