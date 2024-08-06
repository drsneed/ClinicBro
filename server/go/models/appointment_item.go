package models

type AppointmentItem struct {
	ApptID   uint   `json:"appt_id"`
	Title    string `json:"title"`
	Status   string `json:"status"`
	Patient  string `json:"patient"`
	Provider string `json:"provider"`
	Location string `json:"location"`
	Color    string `json:"color"`
	ApptDate string `json:"appt_date"`
	ApptFrom string `json:"appt_from"`
	ApptTo   string `json:"appt_to"`
}
