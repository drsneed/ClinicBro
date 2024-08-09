package models

import "fmt"

type Tenant struct {
	OrgID        string
	Active       bool
	DBName       string
	DBHost       string
	DBUser       string
	DBPassword   string
	LicenseCount int
}

func (t *Tenant) GetDSN() string {
	return fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=disable",
		t.DBHost, t.DBUser, t.DBPassword, t.DBName)
}
