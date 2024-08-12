package models

import "time"

type Appointment struct {
	ID                  uint      `gorm:"primaryKey" json:"id"`
	Title               *string   `gorm:"size:16" json:"title"` // Made Title a pointer to handle NULL values
	IsEvent             bool      `json:"is_event"`
	ApptDate            string    `json:"appt_date"`
	ApptFrom            string    `json:"appt_from"`
	ApptTo              string    `json:"appt_to"`
	Notes               string    `gorm:"size:2500;not null" json:"notes"`
	PatientID           *uint     `json:"patient_id"`            // Made PatientID a pointer to handle NULL values
	ProviderID          *uint     `json:"provider_id"`           // Made ProviderID a pointer to handle NULL values
	AppointmentTypeID   *uint     `json:"appointment_type_id"`   // Made AppointmentTypeID a pointer to handle NULL values
	AppointmentStatusID *uint     `json:"appointment_status_id"` // Made AppointmentStatusID a pointer to handle NULL values
	LocationID          *uint     `json:"location_id"`           // Made LocationID a pointer to handle NULL values
	DateCreated         time.Time `json:"date_created"`
	DateUpdated         time.Time `json:"date_updated"`
	CreatedUserID       uint      `json:"created_user_id"`
	UpdatedUserID       uint      `json:"updated_user_id"`

	// Define associations
	Patient           *Patient           `gorm:"foreignKey:PatientID"`
	Provider          *User              `gorm:"foreignKey:ProviderID"`
	AppointmentType   *AppointmentType   `gorm:"foreignKey:AppointmentTypeID"`
	AppointmentStatus *AppointmentStatus `gorm:"foreignKey:AppointmentStatusID"`
	Location          *Location          `gorm:"foreignKey:LocationID"`
}
