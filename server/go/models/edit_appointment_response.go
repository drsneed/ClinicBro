package models

type EditAppointmentResponse struct {
	Appointment         Appointment         `json:"appointment"`
	Patient             *Patient            `json:"patient,omitempty"`
	Provider            *User               `json:"provider,omitempty"`
	AppointmentTypes    []AppointmentType   `json:"appointment_types"`
	AppointmentStatuses []AppointmentStatus `json:"appointment_statuses"`
	Locations           []Location          `json:"locations"`
	Providers           []User              `json:"providers"`
}
