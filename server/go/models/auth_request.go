package models

type AuthRequest struct {
	OrgID    string `json:"org_id" binding:"required"`
	Name     string `json:"name" binding:"required"`
	Password string `json:"password" binding:"required"`
}
