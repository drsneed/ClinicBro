package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"
	"net/http"

	"github.com/gin-gonic/gin"
)

func SetUserPreference(c *gin.Context) {
	var pref models.UserPreference
	if err := c.ShouldBindJSON(&pref); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	result := db.Create(&pref)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not set user preference"})
		return
	}

	c.JSON(http.StatusCreated, pref)
}

func GetUserPreference(c *gin.Context) {
	userID := c.Param("user_id")
	key := c.Param("key")

	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var preference models.UserPreference
	result := db.Where("user_id = ? AND preference_key = ?", userID, key).First(&preference)

	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User preference not found"})
		return
	}

	c.JSON(http.StatusOK, preference)
}

func GetUserPreferences(c *gin.Context) {
	userID := c.Param("user_id")

	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var preferences []models.UserPreference
	result := db.Where("user_id = ?", userID).Find(&preferences)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch user preferences"})
		return
	}

	c.JSON(http.StatusOK, preferences)
}

// User Preferences handlers

func UpdateUserPreference(c *gin.Context) {
	userID := c.Param("user_id")
	key := c.Param("key")
	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var preference models.UserPreference
	if err := db.Where("user_id = ? AND preference_key = ?", userID, key).First(&preference).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User preference not found"})
		return
	}

	if err := c.ShouldBindJSON(&preference); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := db.Save(&preference).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user preference"})
		return
	}

	c.JSON(http.StatusOK, preference)
}

func DeleteUserPreference(c *gin.Context) {
	userID := c.Param("user_id")
	key := c.Param("key")
	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	if err := db.Where("user_id = ? AND preference_key = ?", userID, key).Delete(&models.UserPreference{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete user preference"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User preference deleted successfully"})
}
