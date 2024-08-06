package models

import "time"

type OperatingSchedule struct {
	LocationID    int       `gorm:"not null" json:"location_id"`
	UserID        *int      `json:"user_id"`
	HoursSunFrom  time.Time `gorm:"not null" json:"hours_sun_from"`
	HoursSunTo    time.Time `gorm:"not null" json:"hours_sun_to"`
	HoursMonFrom  time.Time `gorm:"not null" json:"hours_mon_from"`
	HoursMonTo    time.Time `gorm:"not null" json:"hours_mon_to"`
	HoursTueFrom  time.Time `gorm:"not null" json:"hours_tue_from"`
	HoursTueTo    time.Time `gorm:"not null" json:"hours_tue_to"`
	HoursWedFrom  time.Time `gorm:"not null" json:"hours_wed_from"`
	HoursWedTo    time.Time `gorm:"not null" json:"hours_wed_to"`
	HoursThuFrom  time.Time `gorm:"not null" json:"hours_thu_from"`
	HoursThuTo    time.Time `gorm:"not null" json:"hours_thu_to"`
	HoursFriFrom  time.Time `gorm:"not null" json:"hours_fri_from"`
	HoursFriTo    time.Time `gorm:"not null" json:"hours_fri_to"`
	HoursSatFrom  time.Time `gorm:"not null" json:"hours_sat_from"`
	HoursSatTo    time.Time `gorm:"not null" json:"hours_sat_to"`
	DateCreated   time.Time `gorm:"not null" json:"date_created"`
	DateUpdated   time.Time `gorm:"not null" json:"date_updated"`
	CreatedUserID *int      `json:"created_user_id"`
	UpdatedUserID *int      `json:"updated_user_id"`
}
