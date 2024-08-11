package models

type ValueResponse struct {
	value string `json:"vaue" binding:"required"`
}
