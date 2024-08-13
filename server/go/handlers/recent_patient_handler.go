package handlers

import (
	"net/http"
	"strconv"
	"time"

	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"gorm.io/gorm"
)

// AddRecentPatient handles the addition of a recent patient and performs cleanup
func AddRecentPatient(c *gin.Context) {
	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Authentication required"})
		return
	}

	userID, ok := claims.(jwt.MapClaims)["user_id"].(float64)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
		return
	}

	// Extract the patientID from the URL parameter
	patientIDStr := c.Param("patient_id")
	patientID, err := strconv.Atoi(patientIDStr) // Convert patientID to an integer
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid patient ID"})
		return
	}

	var db = storage.GetTenantDB(c)
	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection failed"})
		return
	}

	// Add or update recent patient entry
	now := time.Now()
	recentPatient := models.RecentPatient{
		UserID:      uint(userID),
		PatientID:   uint(patientID),
		DateCreated: now,
	}

	// Check if the recent patient entry exists
	var existingRecentPatient models.RecentPatient
	if err := db.Where("user_id = ? AND patient_id = ?", recentPatient.UserID, recentPatient.PatientID).First(&existingRecentPatient).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			// Create a new record if it does not exist
			if err := db.Create(&recentPatient).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not add recent patient"})
				return
			}
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
			return
		}
	} else {
		// Update the existing record
		if err := db.Model(&existingRecentPatient).Updates(recentPatient).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not update recent patient"})
			return
		}
	}

	// Cleanup old entries to keep only the 20 most recent
	if err := cleanupRecentPatients(db, uint(userID)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not clean up recent patients"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "Recent patient added successfully"})
}

// cleanupRecentPatients removes old recent patients to keep only the 20 most recent ones
func cleanupRecentPatients(db *gorm.DB, userID uint) error {
	// Raw SQL to delete entries that are not among the 20 most recent ones
	query := `
	DELETE FROM recent_patients
	WHERE user_id = ? AND date_created NOT IN (
		SELECT date_created
		FROM recent_patients
		WHERE user_id = ?
		ORDER BY date_created DESC
		LIMIT 20
	)
	`

	if err := db.Exec(query, userID, userID).Error; err != nil {
		return err
	}

	return nil
}

func GetRecentPatients(c *gin.Context) {
	// Retrieve the claims from the context
	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Authentication required"})
		return
	}

	// Extract the user ID from the claims
	userID, ok := claims.(jwt.MapClaims)["user_id"].(float64)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
		return
	}

	// Get the database instance for the tenant
	var db = storage.GetTenantDB(c)
	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection error"})
		return
	}

	// Fetch recent patients based on the user ID (limit to 20)
	var recentPatients []models.RecentPatient
	if err := db.Where("user_id = ?", uint(userID)).Order("date_created DESC").Limit(20).Find(&recentPatients).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch recent patients"})
		return
	}

	// Extract patient IDs from recent patients
	var patientIDs []uint
	for _, rp := range recentPatients {
		patientIDs = append(patientIDs, rp.PatientID)
	}

	// Fetch patient details based on the extracted patient IDs
	var patients []models.Patient
	if err := db.Where("id IN ?", patientIDs).Find(&patients).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch patient details"})
		return
	}

	// Convert Patient models to PatientItem models
	var patientItems []models.PatientItem
	for _, patient := range patients {
		// Format the full name as "LastName, FirstName MiddleInitial"
		var fullName string
		if patient.MiddleName != "" {
			fullName = patient.LastName + ", " + patient.FirstName + " " + string(patient.MiddleName[0]) + "."
		} else {
			fullName = patient.LastName + ", " + patient.FirstName
		}

		patientItem := models.PatientItem{
			ID:          patient.ID,
			Active:      patient.Active,
			FirstName:   patient.FirstName,
			FullName:    fullName,
			DateOfBirth: patient.DateOfBirth,
		}
		patientItems = append(patientItems, patientItem)
	}

	// Send the response with PatientItem objects
	c.JSON(http.StatusOK, patientItems)
}
