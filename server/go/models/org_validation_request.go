// models/auth.go
package models

type OrgValidationRequest struct {
	OrgID string `json:"org_id" binding:"required"`
}
