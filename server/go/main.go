package main

import (
	"ClinicBro-Server/handlers"
	"ClinicBro-Server/middleware"
	"ClinicBro-Server/storage"
	"ClinicBro-Server/utils"
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
	clientApiKey := os.Getenv("CLIENT_API_KEY")
	host := os.Getenv("SERVER_HOST")
	// these environment variables are required to start the server
	utils.Assert(len(jwtSecret) > 0, "Missing JWT_SECRET_KEY")
	utils.Assert(len(clientApiKey) > 0, "Missing CLIENT_API_KEY")
	utils.Assert(len(host) > 0, "Missing SERVER_HOST")

	// required by user authentication handler to issue token
	handlers.SetJWTSecret(jwtSecret)

	app := gin.Default()

	app.Use(middleware.LoggingMiddleware())

	// These routes require a valid client api key in the X-CLIENT-API-KEY header
	apiKeyEndpoints := app.Group("/")
	apiKeyEndpoints.Use(middleware.ClientApiKeyMiddleware(clientApiKey))
	{
		apiKeyEndpoints.GET("/validate-server", handlers.ValidateServer)
		apiKeyEndpoints.POST("/validate-organization", handlers.ValidateOrganization)
		apiKeyEndpoints.POST("/authenticate-user", handlers.AuthenticateUser)
	}

	// These routes require a bearer token (jwt format)
	bearerTokenEndpoints := app.Group("/")
	bearerTokenEndpoints.Use(middleware.AuthMiddleware(jwtSecret))
	{
		// User routes
		bearerTokenEndpoints.POST("/users", handlers.CreateUser)
		bearerTokenEndpoints.GET("/users/:id", handlers.GetUser)
		bearerTokenEndpoints.GET("/users", handlers.GetAllUsers)
		//bearerTokenEndpoints.PUT("/users/:id", handlers.UpdateUser)
		//bearerTokenEndpoints.DELETE("/users/:id", handlers.DeleteUser)

		// Avatar routes
		bearerTokenEndpoints.POST("/avatars/:type/:id", handlers.CreateOrUpdateAvatar)
		bearerTokenEndpoints.GET("/avatars/:type/:id", handlers.GetAvatar)
		bearerTokenEndpoints.PUT("/avatars/:type/:id", handlers.UpdateAvatar)
		bearerTokenEndpoints.DELETE("/avatars/:type/:id", handlers.DeleteAvatar)

		// Location routes
		bearerTokenEndpoints.POST("/locations", handlers.CreateLocation)
		bearerTokenEndpoints.GET("/locations/:id", handlers.GetLocation)
		bearerTokenEndpoints.GET("/locations", handlers.GetAllLocations)
		bearerTokenEndpoints.PUT("/locations/:id", handlers.UpdateLocation)
		bearerTokenEndpoints.DELETE("/locations/:id", handlers.DeleteLocation)

		// Patient routes
		bearerTokenEndpoints.POST("/patients", handlers.CreatePatient)
		bearerTokenEndpoints.GET("/patients/:id", handlers.GetPatient)
		bearerTokenEndpoints.GET("/patients", handlers.GetAllPatients)
		bearerTokenEndpoints.PUT("/patients/:id", handlers.UpdatePatient)
		bearerTokenEndpoints.DELETE("/patients/:id", handlers.DeletePatient)

		// Recent patients routes
		bearerTokenEndpoints.GET("/recent-patients", handlers.GetRecentPatients)
		bearerTokenEndpoints.POST("/recent-patients/:patient_id", handlers.AddRecentPatient)

		// Password change route
		bearerTokenEndpoints.POST("/change-password", handlers.ChangePassword)

		// Appointment Types routes
		bearerTokenEndpoints.POST("/appointment-types", handlers.CreateAppointmentType)
		bearerTokenEndpoints.GET("/appointment-types/:id", handlers.GetAppointmentType)
		bearerTokenEndpoints.GET("/appointment-types", handlers.GetAllAppointmentTypes)
		bearerTokenEndpoints.PUT("/appointment-types/:id", handlers.UpdateAppointmentType)
		bearerTokenEndpoints.DELETE("/appointment-types/:id", handlers.DeleteAppointmentType)

		// Appointment Statuses routes
		bearerTokenEndpoints.POST("/appointment-statuses", handlers.CreateAppointmentStatus)
		bearerTokenEndpoints.GET("/appointment-statuses/:id", handlers.GetAppointmentStatus)
		bearerTokenEndpoints.GET("/appointment-statuses", handlers.GetAllAppointmentStatuses)
		bearerTokenEndpoints.PUT("/appointment-statuses/:id", handlers.UpdateAppointmentStatus)
		bearerTokenEndpoints.DELETE("/appointment-statuses/:id", handlers.DeleteAppointmentStatus)

		// Appointments routes
		bearerTokenEndpoints.POST("/appointments", handlers.CreateAppointment)
		bearerTokenEndpoints.GET("/appointments/:id", handlers.GetAppointment)
		bearerTokenEndpoints.GET("/appointments", handlers.GetAllAppointments)
		bearerTokenEndpoints.PUT("/appointments/:id", handlers.UpdateAppointment)
		bearerTokenEndpoints.DELETE("/appointments/:id", handlers.DeleteAppointment)

		// Appointment Items route
		bearerTokenEndpoints.GET("/appointment-items", handlers.GetAppointmentItems)

		// Appointment Dates route
		bearerTokenEndpoints.GET("/appointment-dates", handlers.GetAppointmentDates)

		// Event Participants route
		bearerTokenEndpoints.GET("/event-participants", handlers.GetEventParticipants)

		// Operating Schedule routes
		bearerTokenEndpoints.POST("/operating-schedule", handlers.CreateOperatingSchedule)
		bearerTokenEndpoints.GET("/operating-schedule", handlers.GetOperatingSchedule)
		bearerTokenEndpoints.PUT("/operating-schedule", handlers.UpdateOperatingSchedule)
		bearerTokenEndpoints.DELETE("/operating-schedule", handlers.DeleteOperatingSchedule)
		bearerTokenEndpoints.GET("/operating-schedule/current-user", handlers.GetOperatingScheduleForCurrentUser)

		// RBAC routes
		bearerTokenEndpoints.POST("/roles", handlers.CreateRole)
		bearerTokenEndpoints.GET("/roles", handlers.GetAllRoles)
		bearerTokenEndpoints.GET("/roles/:id", handlers.GetRole)
		bearerTokenEndpoints.PUT("/roles/:id", handlers.UpdateRole)
		bearerTokenEndpoints.DELETE("/roles/:id", handlers.DeleteRole)

		bearerTokenEndpoints.POST("/permissions", handlers.CreatePermission)
		bearerTokenEndpoints.GET("/permissions", handlers.GetAllPermissions)
		bearerTokenEndpoints.GET("/permissions/:id", handlers.GetPermission)
		bearerTokenEndpoints.PUT("/permissions/:id", handlers.UpdatePermission)
		bearerTokenEndpoints.DELETE("/permissions/:id", handlers.DeletePermission)

		bearerTokenEndpoints.POST("/user-roles", handlers.AssignRoleToUser)
		bearerTokenEndpoints.GET("/user-roles/:user_id", handlers.GetUserRoles)
		bearerTokenEndpoints.DELETE("/user-roles/:user_id/:role_id", handlers.RemoveRoleFromUser)

		bearerTokenEndpoints.GET("/user-permissions/:user_id", handlers.GetUserPermissions)

		// User Preferences routes
		bearerTokenEndpoints.POST("/user-preferences", handlers.SetUserPreference)
		bearerTokenEndpoints.GET("/user-preferences/:user_id", handlers.GetUserPreferences)
		bearerTokenEndpoints.GET("/user-preferences/:user_id/:key", handlers.GetUserPreference)
		bearerTokenEndpoints.PUT("/user-preferences/:user_id/:key", handlers.UpdateUserPreference)
		bearerTokenEndpoints.DELETE("/user-preferences/:user_id/:key", handlers.DeleteUserPreference)

		// User permission check route
		bearerTokenEndpoints.GET("/check-permission", handlers.UserHasPermission)

		// System Information
		bearerTokenEndpoints.GET("/server-version", handlers.GetServerVersion)
	}

	app.Run(host)
}
