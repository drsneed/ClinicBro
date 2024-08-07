package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

func GetOperatingScheduleForCurrentUser(c *gin.Context) {
	// Extract location ID from query parameters
	locationID := c.Query("location_id")
	if locationID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Location ID is required"})
		return
	}

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

	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var schedule models.OperatingSchedule
	query := db.Where("location_id = ? AND user_id = ?", locationID, userID)

	if err := query.First(&schedule).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Operating schedule not found"})
		return
	}

	c.JSON(http.StatusOK, schedule)
}

func CreateOperatingSchedule(c *gin.Context) {
	var schedule models.OperatingSchedule
	if err := c.ShouldBindJSON(&schedule); err != nil {
		fmt.Print("Errored out: ", err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	schedule.DateCreated = time.Now()
	schedule.DateUpdated = time.Now()

	claims, exists := c.Get("claims")
	if !exists {
		fmt.Print("no claims")
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Authentication required"})
		return
	}

	// Extract the user ID from the claims
	userIDFloat, ok := claims.(jwt.MapClaims)["user_id"].(float64)
	if !ok {
		fmt.Print("couldn't get user_id from claim")
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
		return
	}
	userID := int(userIDFloat)
	schedule.CreatedUserID = &userID
	schedule.UpdatedUserID = &userID

	var db = storage.GetTenantDB(c)
	if db == nil {
		fmt.Print("couldn't get db connection")
		return
	}
	if err := db.Create(&schedule).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create operating schedule"})
		return
	}
	c.JSON(http.StatusCreated, schedule)
}

func GetOperatingSchedule(c *gin.Context) {
	locationID := c.Query("location_id")
	userID := c.Query("user_id")
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	var schedule models.OperatingSchedule
	query := db.Where("location_id = ?", locationID)
	if userID != "" {
		query = query.Where("user_id = ?", userID)
	} else {
		query = query.Where("user_id IS NULL")
	}
	if err := query.First(&schedule).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Operating schedule not found"})
		return
	}
	c.JSON(http.StatusOK, schedule)
}

func UpdateOperatingSchedule(c *gin.Context) {
	var schedule models.OperatingSchedule
	// Bind JSON body to the schedule model
	if err := c.ShouldBindJSON(&schedule); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}

	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Authentication required"})
		return
	}
	updatedUserIDFloat, ok := claims.(jwt.MapClaims)["user_id"].(float64)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
		return
	}
	updatedUserID := int(updatedUserIDFloat)

	// Fetch existing schedule from the database
	var existingSchedule models.OperatingSchedule
	query := db.Where("location_id = ?", schedule.LocationID)
	if schedule.UserID != nil {
		query = query.Where("user_id = ?", schedule.UserID)
	} else {
		query = query.Where("user_id IS NULL")
	}

	if err := query.First(&existingSchedule).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Operating schedule not found"})
		return
	}

	// Perform the update with a specific WHERE clause
	if err := db.Model(&models.OperatingSchedule{}).Where("location_id = ? AND user_id = ?", schedule.LocationID, schedule.UserID).
		Updates(map[string]interface{}{
			"HoursSunFrom":  schedule.HoursSunFrom,
			"HoursSunTo":    schedule.HoursSunTo,
			"HoursMonFrom":  schedule.HoursMonFrom,
			"HoursMonTo":    schedule.HoursMonTo,
			"HoursTueFrom":  schedule.HoursTueFrom,
			"HoursTueTo":    schedule.HoursTueTo,
			"HoursWedFrom":  schedule.HoursWedFrom,
			"HoursWedTo":    schedule.HoursWedTo,
			"HoursThuFrom":  schedule.HoursThuFrom,
			"HoursThuTo":    schedule.HoursThuTo,
			"HoursFriFrom":  schedule.HoursFriFrom,
			"HoursFriTo":    schedule.HoursFriTo,
			"HoursSatFrom":  schedule.HoursSatFrom,
			"HoursSatTo":    schedule.HoursSatTo,
			"DateUpdated":   time.Now(),
			"UpdatedUserID": &updatedUserID,
		}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not update operating schedule"})
		return
	}

	// Fetch the updated schedule to return it
	var updatedSchedule models.OperatingSchedule
	if err := db.Where("location_id = ? AND user_id = ?", schedule.LocationID, schedule.UserID).First(&updatedSchedule).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not retrieve updated operating schedule"})
		return
	}

	c.JSON(http.StatusOK, updatedSchedule)
}

func DeleteOperatingSchedule(c *gin.Context) {
	locationID := c.Query("location_id")
	userID := c.Query("user_id")
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	query := db.Where("location_id = ?", locationID)
	if userID != "" {
		query = query.Where("user_id = ?", userID)
	} else {
		query = query.Where("user_id IS NULL")
	}
	if err := query.Delete(&models.OperatingSchedule{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not delete operating schedule"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Operating schedule deleted successfully"})
}
