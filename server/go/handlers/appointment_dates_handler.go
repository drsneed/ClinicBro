package handlers

import (
	"ClinicBro-Server/storage"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func GetAppointmentDates(c *gin.Context) {
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

	var appointmentDates []time.Time
	query := `SELECT DISTINCT(appt_date) From appointments WHERE appt_date BETWEEN ? AND ?`
	if err := db.Raw(query, startDate, endDate).Scan(&appointmentDates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch appointment dates"})
		return
	}

	c.JSON(http.StatusOK, appointmentDates)
}
