package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"
	"encoding/json"
	"log"
	"net/http"
	"strings"
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

func SearchPatients(c *gin.Context) {
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}

	// Get search parameters from query string
	searchTerm := c.Query("search")
	email := c.Query("email")
	phone := c.Query("phone")
	dateOfBirth := c.Query("date_of_birth")

	// Start building the query
	query := db.Model(&models.Patient{})

	// Add conditions based on provided search parameters
	if searchTerm != "" {
		searchTerm = "%" + strings.ToLower(searchTerm) + "%"
		query = query.Where("LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(CONCAT(first_name, ' ', last_name)) LIKE ?",
			searchTerm, searchTerm, searchTerm)
	}
	if email != "" {
		query = query.Where("LOWER(email) LIKE ?", "%"+strings.ToLower(email)+"%")
	}
	if phone != "" {
		query = query.Where("phone LIKE ?", "%"+phone+"%")
	}
	if dateOfBirth != "" {
		query = query.Where("date_of_birth = ?", dateOfBirth)
	}

	// Execute the query
	var patients []models.Patient
	if err := query.Find(&patients).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not search patients"})
		return
	}

	// Convert Patient models to PatientItem models
	var patientItems []models.PatientItem
	for _, patient := range patients {
		// Format the full name as "LastName, FirstName MiddleInitial"
		var fullName string
		if patient.MiddleName != "" {
			fullName = patient.LastName + ", " + patient.FirstName + " " + string(patient.MiddleName[0]) + "."
		} else {
			fullName = patient.LastName + ", " + patient.FirstName
		}
		patientItem := models.PatientItem{
			ID:          patient.ID,
			Active:      patient.Active,
			FullName:    fullName,
			DateOfBirth: patient.DateOfBirth,
		}
		patientItems = append(patientItems, patientItem)
	}

	c.JSON(http.StatusOK, patientItems)
}

func GetPatientsWithAppointmentToday(c *gin.Context) {
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}

	// Get today's date
	today := time.Now().Format("2006-01-02")

	// Find appointments scheduled for today
	var appointments []models.Appointment
	if err := db.Where("appt_date = ?", today).Find(&appointments).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch appointments"})
		return
	}

	// Extract patient IDs from the appointments
	var patientIDs []uint
	for _, appointment := range appointments {
		if appointment.PatientID != nil {
			patientIDs = append(patientIDs, *appointment.PatientID)
		}
	}

	// Fetch patients with these IDs
	var patients []models.Patient
	if len(patientIDs) > 0 {
		if err := db.Where("id IN ?", patientIDs).Find(&patients).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch patients"})
			return
		}
	}

	// Convert Patient models to PatientItem models
	var patientItems []models.PatientItem
	for _, patient := range patients {
		// Format the full name as "LastName, FirstName MiddleInitial"
		var fullName string
		if patient.MiddleName != "" {
			fullName = patient.LastName + ", " + patient.FirstName + " " + string(patient.MiddleName[0]) + "."
		} else {
			fullName = patient.LastName + ", " + patient.FirstName
		}
		patientItem := models.PatientItem{
			ID:          patient.ID,
			Active:      patient.Active,
			FullName:    fullName,
			DateOfBirth: patient.DateOfBirth,
		}
		patientItems = append(patientItems, patientItem)
	}

	c.JSON(http.StatusOK, patientItems)
}
