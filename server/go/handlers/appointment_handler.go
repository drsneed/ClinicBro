package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"
	"net/http"
	"strconv"
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
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection error"})
		return
	}

	// Get optional query parameters
	patientID := c.Query("patient_id")
	providerID := c.Query("provider_id")
	locationID := c.Query("location_id")
	appointmentTypeID := c.Query("appointment_type_id")
	appointmentStatusID := c.Query("appointment_status_id")
	fromDate := c.Query("from_date")
	toDate := c.Query("to_date")

	// Create the base query
	query := db.Model(&models.Appointment{}).Where("1 = 1")

	// Add conditions based on query parameters
	if patientID != "" {
		pID, err := strconv.ParseUint(patientID, 10, 32)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid Patient ID"})
			return
		}
		query = query.Where("patient_id = ?", uint(pID))
	}

	if providerID != "" {
		pID, err := strconv.ParseUint(providerID, 10, 32)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid Provider ID"})
			return
		}
		query = query.Where("provider_id = ?", uint(pID))
	}

	if locationID != "" {
		lID, err := strconv.ParseUint(locationID, 10, 32)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid Location ID"})
			return
		}
		query = query.Where("location_id = ?", uint(lID))
	}

	if appointmentTypeID != "" {
		atID, err := strconv.ParseUint(appointmentTypeID, 10, 32)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid Appointment Type ID"})
			return
		}
		query = query.Where("appointment_type_id = ?", uint(atID))
	}

	if appointmentStatusID != "" {
		asID, err := strconv.ParseUint(appointmentStatusID, 10, 32)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid Appointment Status ID"})
			return
		}
		query = query.Where("appointment_status_id = ?", uint(asID))
	}

	if fromDate != "" {
		_, err := time.Parse("2006-01-02", fromDate)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid From Date format"})
			return
		}
		query = query.Where("appt_date >= ?", fromDate)
	}

	if toDate != "" {
		_, err := time.Parse("2006-01-02", toDate)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid To Date format"})
			return
		}
		query = query.Where("appt_date <= ?", toDate)
	}

	// Execute the query
	var appointments []models.Appointment
	if err := query.Find(&appointments).Error; err != nil {
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
func GetEditAppointmentData(c *gin.Context) {
	appointmentID := c.Query("appointment_id")

	if appointmentID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Appointment ID is required"})
		return
	}

	var db = storage.GetTenantDB(c)
	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection error"})
		return
	}

	var response models.EditAppointmentResponse

	// Fetch appointment details
	if err := db.Preload("Patient").
		Preload("Provider").
		Preload("AppointmentType").
		Preload("AppointmentStatus").
		Preload("Location").
		First(&response.Appointment, appointmentID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Appointment not found"})
		return
	}

	// Collect IDs for filtering
	var locationID uint
	var appointmentTypeID uint
	var appointmentStatusID uint
	var providerID uint

	if response.Appointment.LocationID != nil {
		locationID = *response.Appointment.LocationID
	}
	if response.Appointment.AppointmentTypeID != nil {
		appointmentTypeID = *response.Appointment.AppointmentTypeID
	}
	if response.Appointment.AppointmentStatusID != nil {
		appointmentStatusID = *response.Appointment.AppointmentStatusID
	}

	if response.Appointment.ProviderID != nil {
		providerID = *response.Appointment.ProviderID
	}

	// Fetch locations, providers, appointment statuses, and types
	if err := db.Where("active = true OR id = ?", locationID).Find(&response.Locations).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch locations"})
		return
	}
	if err := db.Where("active = true OR id = ?", appointmentStatusID).Find(&response.AppointmentStatuses).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch appointment statuses"})
		return
	}
	if err := db.Where("active = true OR id = ?", appointmentTypeID).Find(&response.AppointmentTypes).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch appointment types"})
		return
	}
	if err := db.Where("(is_provider = true and active = true) or id = ?", providerID).Find(&response.Providers).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch providers"})
		return
	}

	c.JSON(http.StatusOK, response)
}

func GetCreateAppointmentData(c *gin.Context) {
	patientIDParam := c.Query("patient_id") // Use query parameter for patient ID

	if patientIDParam == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Patient ID is required"})
		return
	}

	patientID, err := strconv.ParseUint(patientIDParam, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid Patient ID"})
		return
	}

	var db = storage.GetTenantDB(c)
	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection error"})
		return
	}

	var response models.CreateAppointmentResponse

	// Fetch all active locations
	if err := db.Where("active = true").Find(&response.Locations).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch locations"})
		return
	}

	// Fetch all active appointment types
	if err := db.Where("active = true").Find(&response.AppointmentTypes).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch appointment types"})
		return
	}

	// Fetch all active appointment statuses
	if err := db.Where("active = true").Find(&response.AppointmentStatuses).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch appointment statuses"})
		return
	}

	// Fetch all active providers
	if err := db.Where("is_provider = true and active = true").Find(&response.Providers).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch providers"})
		return
	}

	// Fetch patient details if patient ID is provided
	var patient models.Patient
	if err := db.First(&patient, patientID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Patient not found"})
		return
	}
	response.Patient = &patient

	c.JSON(http.StatusOK, response)
}
