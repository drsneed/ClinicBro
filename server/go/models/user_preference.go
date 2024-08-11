package models

type UserPreference struct {
	ID              uint   `gorm:"primaryKey" json:"id"`
	UserID          uint   `json:"user_id"`
	PreferenceKey   string `json:"preference_key"`
	PreferenceValue string `json:"preference_value"`
}
