package utils

import (
	"log"
	"os"

	"ClinicBro-Server/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func InitDB() {
	dsn := os.Getenv("DATABASE_URL")
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	DB = db

	// Migrate the schema
	DB.AutoMigrate(&models.User{}, &models.Avatar{}, &models.Location{}, &models.Patient{}, &models.RecentPatient{})
}
