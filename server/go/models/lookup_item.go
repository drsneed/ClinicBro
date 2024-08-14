package models

type LookupItem struct {
	ID     uint   `json:"id"`
	Active bool   `json:"active"`
	Name   string `json:"name"`
}
