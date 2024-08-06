package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// Example function that logs JSON deserialization
func unmarshalPatient(jsonData []byte) {
	var patient models.Patient
	err := json.Unmarshal(jsonData, &patient)
	if err != nil {
		log.Printf("Error unmarshaling patient: %v", err)
		return
	}
	log.Printf("Deserialized Patient: %+v", patient)
}

// Example function that logs JSON serialization
func logPatient(patient models.Patient) {
	jsonData, err := json.Marshal(patient)
	if err != nil {
		log.Printf("Error marshaling patient: %v", err)
		return
	}
	log.Printf("Serialized Patient JSON: %s", jsonData)
}

func CreatePatient(c *gin.Context) {
	var patient models.Patient
	if err := c.ShouldBindJSON(&patient); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	patient.DateCreated = time.Now()
	patient.DateUpdated = time.Now()

	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}

	if err := db.Create(&patient).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create patient"})
		return
	}

	c.JSON(http.StatusCreated, patient)
}

func GetPatient(c *gin.Context) {
	id := c.Param("id")
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	// var patient models.Patient
	// result := db.Raw("SELECT address_1, address_2 FROM patients WHERE id = ?", id).Scan(&patient)
	// if result.Error != nil {
	// 	log.Fatalf("Query error: %v", result.Error)
	// }

	var patient models.Patient
	if err := db.First(&patient, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Patient not found"})
		return
	}
	c.JSON(http.StatusOK, patient)
}

func GetAllPatients(c *gin.Context) {
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	var patients []models.Patient
	if err := db.Find(&patients).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch patients"})
		return
	}
	c.JSON(http.StatusOK, patients)
}

func UpdatePatient(c *gin.Context) {
	id := c.Param("id")
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	var patient models.Patient
	if err := db.First(&patient, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Patient not found"})
		return
	}

	if err := c.ShouldBindJSON(&patient); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	patient.DateUpdated = time.Now()

	if err := db.Save(&patient).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not update patient"})
		return
	}

	c.JSON(http.StatusOK, patient)
}

func DeletePatient(c *gin.Context) {
	id := c.Param("id")
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	if err := db.Delete(&models.Patient{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not delete patient"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Patient deleted successfully"})
}
