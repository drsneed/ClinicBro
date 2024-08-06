package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetAppointmentItems(c *gin.Context) {
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	if startDate == "" || endDate == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "start_date and end_date are required"})
		return
	}

	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var appointmentItems []models.AppointmentItem
	query := `SELECT * FROM appointment_items WHERE appt_date BETWEEN ? AND ?`
	if err := db.Raw(query, startDate, endDate).Scan(&appointmentItems).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch appointment items"})
		return
	}

	c.JSON(http.StatusOK, appointmentItems)
}
