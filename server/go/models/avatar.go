package models

type Avatar struct {
	Type     string `gorm:"primaryKey;size:20" json:"type"` // 'user' or 'patient'
	EntityID uint   `gorm:"primaryKey" json:"entity_id"`
	Image    []byte `json:"-"`
}
