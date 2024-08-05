package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"
	"io"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// Create or Update Avatar
func CreateOrUpdateAvatar(c *gin.Context) {
	avatarType := c.Param("type")
	entityIDStr := c.Param("id")
	entityID, err := strconv.ParseUint(entityIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	file, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file uploaded"})
		return
	}

	fileContent, err := file.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not read file"})
		return
	}
	defer fileContent.Close()

	buffer, err := io.ReadAll(fileContent)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not read file contents"})
		return
	}

	avatar := models.Avatar{
		Type:     avatarType,
		EntityID: uint(entityID),
		Image:    buffer,
	}

	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}

	result := db.Save(&avatar)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not save avatar"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Avatar created/updated successfully"})
}

// Get Avatar
func GetAvatar(c *gin.Context) {
	avatarType := c.Param("type")
	entityIDStr := c.Param("id")
	entityID, err := strconv.ParseUint(entityIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var avatar models.Avatar
	result := db.Where("type = ? AND entity_id = ?", avatarType, entityID).First(&avatar)
	if result.Error != nil {
		c.Data(http.StatusNotFound, "image/png", nil) // Optionally serve a default avatar here
		return
	}

	c.Data(http.StatusOK, "image/png", avatar.Image)
}

// Update Avatar
func UpdateAvatar(c *gin.Context) {
	avatarType := c.Param("type")
	entityIDStr := c.Param("id")
	entityID, err := strconv.ParseUint(entityIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	file, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file uploaded"})
		return
	}

	fileContent, err := file.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not read file"})
		return
	}
	defer fileContent.Close()

	buffer, err := io.ReadAll(fileContent)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not read file contents"})
		return
	}

	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}

	result := db.Model(&models.Avatar{}).Where("type = ? AND entity_id = ?", avatarType, entityID).Update("image", buffer)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not update avatar"})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Avatar not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Avatar updated successfully"})
}

// Delete Avatar
func DeleteAvatar(c *gin.Context) {
	avatarType := c.Param("type")
	entityIDStr := c.Param("id")
	entityID, err := strconv.ParseUint(entityIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}

	result := db.Where("type = ? AND entity_id = ?", avatarType, entityID).Delete(&models.Avatar{})
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not delete avatar"})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Avatar not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Avatar deleted successfully"})
}
