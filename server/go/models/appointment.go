package models

import "time"

type Appointment struct {
	ID                  uint      `gorm:"primaryKey" json:"id"`
	Title               string    `gorm:"size:16;not null" json:"title"`
	ApptDate            time.Time `json:"appt_date"`
	ApptFrom            time.Time `json:"appt_from"`
	ApptTo              time.Time `json:"appt_to"`
	Notes               string    `gorm:"size:2500;not null" json:"notes"`
	PatientID           uint      `json:"patient_id"`
	ProviderID          uint      `json:"provider_id"`
	AppointmentTypeID   uint      `json:"appointment_type_id"`
	AppointmentStatusID uint      `json:"appointment_status_id"`
	LocationID          uint      `json:"location_id"`
	DateCreated         time.Time `json:"date_created"`
	DateUpdated         time.Time `json:"date_updated"`
	CreatedUserID       uint      `json:"created_user_id"`
	UpdatedUserID       uint      `json:"updated_user_id"`
}
