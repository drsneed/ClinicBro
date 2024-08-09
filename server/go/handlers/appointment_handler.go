package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"
	"net/http"
	"time"

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

func CreateAppointment(c *gin.Context) {
	var appointment models.Appointment
	if err := c.ShouldBindJSON(&appointment); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	appointment.DateCreated = time.Now()
	appointment.DateUpdated = time.Now()
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	if err := db.Create(&appointment).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create appointment"})
		return
	}
	c.JSON(http.StatusCreated, appointment)
}

func GetAppointment(c *gin.Context) {
	id := c.Param("id")
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	var appointment models.Appointment
	if err := db.First(&appointment, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Appointment not found"})
		return
	}
	c.JSON(http.StatusOK, appointment)
}

func GetAllAppointments(c *gin.Context) {
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	var appointments []models.Appointment
	if err := db.Find(&appointments).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch appointments"})
		return
	}
	c.JSON(http.StatusOK, appointments)
}

func UpdateAppointment(c *gin.Context) {
	id := c.Param("id")
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	var appointment models.Appointment
	if err := db.First(&appointment, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Appointment not found"})
		return
	}
	if err := c.ShouldBindJSON(&appointment); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	appointment.DateUpdated = time.Now()
	if err := db.Save(&appointment).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not update appointment"})
		return
	}
	c.JSON(http.StatusOK, appointment)
}

func DeleteAppointment(c *gin.Context) {
	id := c.Param("id")
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	if err := db.Delete(&models.Appointment{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not delete appointment"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Appointment deleted successfully"})
}

func GetEventParticipants(c *gin.Context) {
	appointmentID := c.Query("appointment_id")

	if appointmentID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "appointment_id query parameter is required"})
		return
	}

	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var participants []models.EventParticipant
	query := `
        SELECT u.id, u.name
        FROM users u
        JOIN event_user_links eul ON u.id = eul.user_id
        WHERE eul.appointment_id = ?
    `
	if err := db.Raw(query, appointmentID).Scan(&participants).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch event participants"})
		return
	}

	c.JSON(http.StatusOK, participants)
}
