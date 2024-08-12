package models

type CreateAppointmentResponse struct {
	AppointmentTypes    []AppointmentType   `json:"appointment_types"`
	AppointmentStatuses []AppointmentStatus `json:"appointment_statuses"`
	Locations           []Location          `json:"locations"`
	Providers           []User              `json:"providers"`
	Patient             *Patient            `json:"patient,omitempty"` // Use pointer to handle absence
}
