package handlers

import (
	"net/http"

	"ClinicBro-Server/models"
	"ClinicBro-Server/utils"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

func GetRecentPatients(c *gin.Context) {
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

	var recentPatients []models.RecentPatient
	if err := utils.DB.Where("user_id = ?", uint(userID)).Order("date_created DESC").Limit(10).Find(&recentPatients).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch recent patients"})
		return
	}

	var patientIDs []uint
	for _, rp := range recentPatients {
		patientIDs = append(patientIDs, rp.PatientID)
	}

	var patients []models.Patient
	if err := utils.DB.Where("id IN ?", patientIDs).Find(&patients).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch patient details"})
		return
	}

	c.JSON(http.StatusOK, patients)
}
