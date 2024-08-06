package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func CreateAppointmentStatus(c *gin.Context) {
	var appointmentStatus models.AppointmentStatus
	if err := c.ShouldBindJSON(&appointmentStatus); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	appointmentStatus.DateCreated = time.Now()
	appointmentStatus.DateUpdated = time.Now()
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	if err := db.Create(&appointmentStatus).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create appointment status"})
		return
	}
	c.JSON(http.StatusCreated, appointmentStatus)
}

func GetAppointmentStatus(c *gin.Context) {
	id := c.Param("id")
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	var appointmentStatus models.AppointmentStatus
	if err := db.First(&appointmentStatus, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Appointment status not found"})
		return
	}
	c.JSON(http.StatusOK, appointmentStatus)
}

func GetAllAppointmentStatuses(c *gin.Context) {
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	var appointmentStatuses []models.AppointmentStatus
	if err := db.Find(&appointmentStatuses).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch appointment statuses"})
		return
	}
	c.JSON(http.StatusOK, appointmentStatuses)
}

func UpdateAppointmentStatus(c *gin.Context) {
	id := c.Param("id")
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	var appointmentStatus models.AppointmentStatus
	if err := db.First(&appointmentStatus, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Appointment status not found"})
		return
	}
	if err := c.ShouldBindJSON(&appointmentStatus); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	appointmentStatus.DateUpdated = time.Now()
	if err := db.Save(&appointmentStatus).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not update appointment status"})
		return
	}
	c.JSON(http.StatusOK, appointmentStatus)
}

func DeleteAppointmentStatus(c *gin.Context) {
	id := c.Param("id")
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	if err := db.Delete(&models.AppointmentStatus{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not delete appointment status"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Appointment status deleted successfully"})
}
