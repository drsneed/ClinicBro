package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func CreateAppointmentType(c *gin.Context) {
	var appointmentType models.AppointmentType
	if err := c.ShouldBindJSON(&appointmentType); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	appointmentType.DateCreated = time.Now()
	appointmentType.DateUpdated = time.Now()
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	if err := db.Create(&appointmentType).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create appointment type"})
		return
	}
	c.JSON(http.StatusCreated, appointmentType)
}

func GetAppointmentType(c *gin.Context) {
	log.Printf("Got here :CONFETTI:")
	id := c.Param("id")
	log.Printf("GetAppointmentType: id = %s", id)
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	var appointmentType models.AppointmentType
	if err := db.First(&appointmentType, id).Error; err != nil {
		log.Printf("GetAppointmentType: err = %s", err.Error())
		c.JSON(http.StatusNotFound, gin.H{"error": "Appointment type not found"})
		return
	}
	c.JSON(http.StatusOK, appointmentType)
}

func GetAllAppointmentTypes(c *gin.Context) {
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	var appointmentTypes []models.AppointmentType
	if err := db.Find(&appointmentTypes).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch appointment types"})
		return
	}
	c.JSON(http.StatusOK, appointmentTypes)
}

func UpdateAppointmentType(c *gin.Context) {
	id := c.Param("id")
	log.Printf("UpdateAppointmentType: id = %s", string(id))
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	var appointmentType models.AppointmentType
	if err := db.First(&appointmentType, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Appointment type not found"})
		return
	}
	if err := c.ShouldBindJSON(&appointmentType); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	appointmentType.DateUpdated = time.Now()
	if err := db.Save(&appointmentType).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not update appointment type"})
		return
	}
	c.JSON(http.StatusOK, appointmentType)
}

func DeleteAppointmentType(c *gin.Context) {
	id := c.Param("id")
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	if err := db.Delete(&models.AppointmentType{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not delete appointment type"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Appointment type deleted successfully"})
}
