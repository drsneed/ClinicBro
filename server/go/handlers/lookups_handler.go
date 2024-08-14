package handlers

import (
	"net/http"
	"strconv"

	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"

	"github.com/gin-gonic/gin"
)

func LookupAppointmentTypes(c *gin.Context) {
	db := storage.GetTenantDB(c)
	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
		return
	}

	// Parse the include_inactive query parameter
	includeInactive, _ := strconv.ParseBool(c.DefaultQuery("include_inactive", "false"))

	var appointmentTypes []models.AppointmentType
	query := db.Select("id", "active", "name")

	if !includeInactive {
		query = query.Where("active = ?", true)
	}

	if err := query.Find(&appointmentTypes).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch appointment types"})
		return
	}

	// Convert AppointmentType to LookupItem
	var lookupItems []models.LookupItem
	for _, apt := range appointmentTypes {
		lookupItems = append(lookupItems, models.LookupItem{
			ID:     apt.ID,
			Active: apt.Active,
			Name:   apt.Name,
		})
	}

	c.JSON(http.StatusOK, lookupItems)
}
