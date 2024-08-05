package handlers

import (
	"net/http"
	"time"

	"ClinicBro-Server/models"
	"ClinicBro-Server/utils"

	"github.com/gin-gonic/gin"
)

func CreateLocation(c *gin.Context) {
	var location models.Location
	if err := c.ShouldBindJSON(&location); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	location.DateCreated = time.Now()
	location.DateUpdated = time.Now()

	if err := utils.DB.Create(&location).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create location"})
		return
	}

	c.JSON(http.StatusCreated, location)
}

func GetLocation(c *gin.Context) {
	id := c.Param("id")
	var location models.Location
	if err := utils.DB.First(&location, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Location not found"})
		return
	}
	c.JSON(http.StatusOK, location)
}

func GetAllLocations(c *gin.Context) {
	var locations []models.Location
	if err := utils.DB.Find(&locations).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch locations"})
		return
	}
	c.JSON(http.StatusOK, locations)
}

func UpdateLocation(c *gin.Context) {
	id := c.Param("id")
	var location models.Location
	if err := utils.DB.First(&location, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Location not found"})
		return
	}

	if err := c.ShouldBindJSON(&location); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	location.DateUpdated = time.Now()

	if err := utils.DB.Save(&location).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not update location"})
		return
	}

	c.JSON(http.StatusOK, location)
}

func DeleteLocation(c *gin.Context) {
	id := c.Param("id")
	if err := utils.DB.Delete(&models.Location{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not delete location"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Location deleted successfully"})
}
