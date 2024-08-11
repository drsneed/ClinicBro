package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

const (
	defaultThemeKey   = "theme_mode"
	defaultThemeValue = "system"
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
	userIDStr := c.Param("user_id")

	// Convert userID from string to uint
	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	// Cast uint64 to uint
	userIDUint := uint(userID)

	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	// Step 1: Fetch existing preferences for the user
	var preferences []models.UserPreference
	result := db.Where("user_id = ?", userIDUint).Find(&preferences)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch user preferences"})
		return
	}

	// Step 2: Check if default preferences are missing and insert them if necessary
	existingPreferences := make(map[string]struct{})
	for _, p := range preferences {
		existingPreferences[p.PreferenceKey] = struct{}{}
	}

	// Check if default theme preference is missing
	if _, exists := existingPreferences[defaultThemeKey]; !exists {
		defaultPreference := models.UserPreference{
			UserID:          userIDUint,
			PreferenceKey:   defaultThemeKey,
			PreferenceValue: defaultThemeValue,
		}
		if err := db.Create(&defaultPreference).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create default preference"})
			return
		}
		preferences = append(preferences, defaultPreference)
	}

	// Step 3: Return the preferences
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
