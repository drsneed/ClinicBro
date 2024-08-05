package handlers

import (
	"net/http"
	"time"

	"ClinicBro-Server/models"
	"ClinicBro-Server/utils"

	"github.com/gin-gonic/gin"
)

func CreatePatient(c *gin.Context) {
	var patient models.Patient
	if err := c.ShouldBindJSON(&patient); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	patient.DateCreated = time.Now()
	patient.DateUpdated = time.Now()

	if err := utils.DB.Create(&patient).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create patient"})
		return
	}

	c.JSON(http.StatusCreated, patient)
}

func GetPatient(c *gin.Context) {
	id := c.Param("id")
	var patient models.Patient
	if err := utils.DB.First(&patient, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Patient not found"})
		return
	}
	c.JSON(http.StatusOK, patient)
}

func GetAllPatients(c *gin.Context) {
	var patients []models.Patient
	if err := utils.DB.Find(&patients).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch patients"})
		return
	}
	c.JSON(http.StatusOK, patients)
}

func UpdatePatient(c *gin.Context) {
	id := c.Param("id")
	var patient models.Patient
	if err := utils.DB.First(&patient, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Patient not found"})
		return
	}

	if err := c.ShouldBindJSON(&patient); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	patient.DateUpdated = time.Now()

	if err := utils.DB.Save(&patient).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not update patient"})
		return
	}

	c.JSON(http.StatusOK, patient)
}

func DeletePatient(c *gin.Context) {
	id := c.Param("id")
	if err := utils.DB.Delete(&models.Patient{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not delete patient"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Patient deleted successfully"})
}
