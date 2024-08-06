package main

import (
	"ClinicBro-Server/handlers"
	"ClinicBro-Server/middleware"
	"ClinicBro-Server/storage"
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Fatal("Error loading .env file")
	}
	storage.InitAll()
	jwtSecret := os.Getenv("JWT_SECRET_KEY")
	middleware.SetJWTSecret(jwtSecret)
	handlers.SetJWTSecret(jwtSecret)

	r := gin.Default()

	// Apply the logging middleware globally
	r.Use(middleware.LoggingMiddleware())

	// Public routes
	r.POST("/authenticate", handlers.Authenticate)

	// Protected routes
	authorized := r.Group("/")
	authorized.Use(middleware.AuthMiddleware())
	{
		// User routes
		authorized.POST("/users", handlers.CreateUser)
		authorized.GET("/users/:id", handlers.GetUser)
		authorized.GET("/users", handlers.GetAllUsers)
		//authorized.PUT("/users/:id", handlers.UpdateUser)
		//authorized.DELETE("/users/:id", handlers.DeleteUser)

		// Avatar routes
		authorized.POST("/avatars/:type/:id", handlers.CreateOrUpdateAvatar)
		authorized.GET("/avatars/:type/:id", handlers.GetAvatar)
		authorized.PUT("/avatars/:type/:id", handlers.UpdateAvatar)
		authorized.DELETE("/avatars/:type/:id", handlers.DeleteAvatar)

		// Location routes
		authorized.POST("/locations", handlers.CreateLocation)
		authorized.GET("/locations/:id", handlers.GetLocation)
		authorized.GET("/locations", handlers.GetAllLocations)
		authorized.PUT("/locations/:id", handlers.UpdateLocation)
		authorized.DELETE("/locations/:id", handlers.DeleteLocation)

		// Patient routes
		authorized.POST("/patients", handlers.CreatePatient)
		authorized.GET("/patients/:id", handlers.GetPatient)
		authorized.GET("/patients", handlers.GetAllPatients)
		authorized.PUT("/patients/:id", handlers.UpdatePatient)
		authorized.DELETE("/patients/:id", handlers.DeletePatient)

		// Recent patients route
		authorized.GET("/recent-patients", handlers.GetRecentPatients)

		// Password change route
		authorized.POST("/change-password", handlers.ChangePassword)

		// Appointment Types routes
		authorized.POST("/appointment-types", handlers.CreateAppointmentType)
		authorized.GET("/appointment-types/:id", handlers.GetAppointmentType)
		authorized.GET("/appointment-types", handlers.GetAllAppointmentTypes)
		authorized.PUT("/appointment-types/:id", handlers.UpdateAppointmentType)
		authorized.DELETE("/appointment-types/:id", handlers.DeleteAppointmentType)

		// Appointment Statuses routes
		authorized.POST("/appointment-statuses", handlers.CreateAppointmentStatus)
		authorized.GET("/appointment-statuses/:id", handlers.GetAppointmentStatus)
		authorized.GET("/appointment-statuses", handlers.GetAllAppointmentStatuses)
		authorized.PUT("/appointment-statuses/:id", handlers.UpdateAppointmentStatus)
		authorized.DELETE("/appointment-statuses/:id", handlers.DeleteAppointmentStatus)

		// Appointments routes
		authorized.POST("/appointments", handlers.CreateAppointment)
		authorized.GET("/appointments/:id", handlers.GetAppointment)
		authorized.GET("/appointments", handlers.GetAllAppointments)
		authorized.PUT("/appointments/:id", handlers.UpdateAppointment)
		authorized.DELETE("/appointments/:id", handlers.DeleteAppointment)

		// Appointment Items routes
		authorized.GET("/appointment-items", handlers.GetAppointmentItems)

		// Operating Schedule routes
		authorized.POST("/operating-schedule", handlers.CreateOperatingSchedule)
		authorized.GET("/operating-schedule", handlers.GetOperatingSchedule)
		authorized.PUT("/operating-schedule", handlers.UpdateOperatingSchedule)
		authorized.DELETE("/operating-schedule", handlers.DeleteOperatingSchedule)
	}

	// Start server
	host := os.Getenv("ClinicBroHost")
	if host == "" {
		host = "[::]:8080"
	}
	r.Run(host)
}
