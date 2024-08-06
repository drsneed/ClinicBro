package models

import (
	"time"
)

// OperatingSchedule represents the operating_schedules table in the database
type OperatingSchedule struct {
	LocationID    int       `gorm:"column:location_id;not null" json:"location_id"`
	UserID        *int      `gorm:"column:user_id" json:"user_id"`
	HoursSunFrom  *string   `gorm:"column:hours_sun_from" json:"hours_sun_from"`
	HoursSunTo    *string   `gorm:"column:hours_sun_to" json:"hours_sun_to"`
	HoursMonFrom  *string   `gorm:"column:hours_mon_from" json:"hours_mon_from"`
	HoursMonTo    *string   `gorm:"column:hours_mon_to" json:"hours_mon_to"`
	HoursTueFrom  *string   `gorm:"column:hours_tue_from" json:"hours_tue_from"`
	HoursTueTo    *string   `gorm:"column:hours_tue_to" json:"hours_tue_to"`
	HoursWedFrom  *string   `gorm:"column:hours_wed_from" json:"hours_wed_from"`
	HoursWedTo    *string   `gorm:"column:hours_wed_to" json:"hours_wed_to"`
	HoursThuFrom  *string   `gorm:"column:hours_thu_from" json:"hours_thu_from"`
	HoursThuTo    *string   `gorm:"column:hours_thu_to" json:"hours_thu_to"`
	HoursFriFrom  *string   `gorm:"column:hours_fri_from" json:"hours_fri_from"`
	HoursFriTo    *string   `gorm:"column:hours_fri_to" json:"hours_fri_to"`
	HoursSatFrom  *string   `gorm:"column:hours_sat_from" json:"hours_sat_from"`
	HoursSatTo    *string   `gorm:"column:hours_sat_to" json:"hours_sat_to"`
	DateCreated   time.Time `gorm:"column:date_created;not null" json:"date_created"`
	DateUpdated   time.Time `gorm:"column:date_updated;not null" json:"date_updated"`
	CreatedUserID *int      `gorm:"column:created_user_id" json:"created_user_id"`
	UpdatedUserID *int      `gorm:"column:updated_user_id" json:"updated_user_id"`
}
