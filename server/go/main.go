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
	utils.Assert(len(jwtSecret) > 0, "Missing JWT_SECRET_KEY")
	middleware.SetJWTSecret(jwtSecret)
	handlers.SetJWTSecret(jwtSecret)
	clientApiKey := os.Getenv("CLIENT_API_KEY")
	utils.Assert(len(clientApiKey) > 0, "Missing CLIENT_API_KEY")

	app := gin.Default()

	//r.Use(middleware.LoggingMiddleware())

	// These routes require a valid client api key in the X-CLIENT-API-KEY header
	apiKeyUser := app.Group("/")
	apiKeyUser.Use(middleware.ClientApiKeyMiddleware(clientApiKey))
	{
		apiKeyUser.GET("/validate-server", handlers.ValidateServer)
		apiKeyUser.POST("/validate-organization", handlers.ValidateOrganization)
		apiKeyUser.POST("/authenticate-user", handlers.AuthenticateUser)
	}

	// These routes require a bearer token (jwt format)
	authenticatedUser := app.Group("/")
	authenticatedUser.Use(middleware.AuthMiddleware())
	{
		// User routes
		authenticatedUser.POST("/users", handlers.CreateUser)
		authenticatedUser.GET("/users/:id", handlers.GetUser)
		authenticatedUser.GET("/users", handlers.GetAllUsers)
		//authenticatedUser.PUT("/users/:id", handlers.UpdateUser)
		//authenticatedUser.DELETE("/users/:id", handlers.DeleteUser)

		// Avatar routes
		authenticatedUser.POST("/avatars/:type/:id", handlers.CreateOrUpdateAvatar)
		authenticatedUser.GET("/avatars/:type/:id", handlers.GetAvatar)
		authenticatedUser.PUT("/avatars/:type/:id", handlers.UpdateAvatar)
		authenticatedUser.DELETE("/avatars/:type/:id", handlers.DeleteAvatar)

		// Location routes
		authenticatedUser.POST("/locations", handlers.CreateLocation)
		authenticatedUser.GET("/locations/:id", handlers.GetLocation)
		authenticatedUser.GET("/locations", handlers.GetAllLocations)
		authenticatedUser.PUT("/locations/:id", handlers.UpdateLocation)
		authenticatedUser.DELETE("/locations/:id", handlers.DeleteLocation)

		// Patient routes
		authenticatedUser.POST("/patients", handlers.CreatePatient)
		authenticatedUser.GET("/patients/:id", handlers.GetPatient)
		authenticatedUser.GET("/patients", handlers.GetAllPatients)
		authenticatedUser.PUT("/patients/:id", handlers.UpdatePatient)
		authenticatedUser.DELETE("/patients/:id", handlers.DeletePatient)

		// Recent patients routes
		authenticatedUser.GET("/recent-patients", handlers.GetRecentPatients)
		authenticatedUser.POST("/recent-patients/:patient_id", handlers.AddRecentPatient)

		// Password change route
		authenticatedUser.POST("/change-password", handlers.ChangePassword)

		// Appointment Types routes
		authenticatedUser.POST("/appointment-types", handlers.CreateAppointmentType)
		authenticatedUser.GET("/appointment-types/:id", handlers.GetAppointmentType)
		authenticatedUser.GET("/appointment-types", handlers.GetAllAppointmentTypes)
		authenticatedUser.PUT("/appointment-types/:id", handlers.UpdateAppointmentType)
		authenticatedUser.DELETE("/appointment-types/:id", handlers.DeleteAppointmentType)

		// Appointment Statuses routes
		authenticatedUser.POST("/appointment-statuses", handlers.CreateAppointmentStatus)
		authenticatedUser.GET("/appointment-statuses/:id", handlers.GetAppointmentStatus)
		authenticatedUser.GET("/appointment-statuses", handlers.GetAllAppointmentStatuses)
		authenticatedUser.PUT("/appointment-statuses/:id", handlers.UpdateAppointmentStatus)
		authenticatedUser.DELETE("/appointment-statuses/:id", handlers.DeleteAppointmentStatus)

		// Appointments routes
		authenticatedUser.POST("/appointments", handlers.CreateAppointment)
		authenticatedUser.GET("/appointments/:id", handlers.GetAppointment)
		authenticatedUser.GET("/appointments", handlers.GetAllAppointments)
		authenticatedUser.PUT("/appointments/:id", handlers.UpdateAppointment)
		authenticatedUser.DELETE("/appointments/:id", handlers.DeleteAppointment)

		// Appointment Items route
		authenticatedUser.GET("/appointment-items", handlers.GetAppointmentItems)

		// Appointment Dates route
		authenticatedUser.GET("/appointment-dates", handlers.GetAppointmentDates)

		// Event Participants route
		authenticatedUser.GET("/event-participants", handlers.GetEventParticipants)

		// Operating Schedule routes
		authenticatedUser.POST("/operating-schedule", handlers.CreateOperatingSchedule)
		authenticatedUser.GET("/operating-schedule", handlers.GetOperatingSchedule)
		authenticatedUser.PUT("/operating-schedule", handlers.UpdateOperatingSchedule)
		authenticatedUser.DELETE("/operating-schedule", handlers.DeleteOperatingSchedule)
		authenticatedUser.GET("/operating-schedule/current-user", handlers.GetOperatingScheduleForCurrentUser)

		// RBAC routes
		authenticatedUser.POST("/roles", handlers.CreateRole)
		authenticatedUser.GET("/roles", handlers.GetAllRoles)
		authenticatedUser.GET("/roles/:id", handlers.GetRole)
		authenticatedUser.PUT("/roles/:id", handlers.UpdateRole)
		authenticatedUser.DELETE("/roles/:id", handlers.DeleteRole)

		authenticatedUser.POST("/permissions", handlers.CreatePermission)
		authenticatedUser.GET("/permissions", handlers.GetAllPermissions)
		authenticatedUser.GET("/permissions/:id", handlers.GetPermission)
		authenticatedUser.PUT("/permissions/:id", handlers.UpdatePermission)
		authenticatedUser.DELETE("/permissions/:id", handlers.DeletePermission)

		authenticatedUser.POST("/user-roles", handlers.AssignRoleToUser)
		authenticatedUser.GET("/user-roles/:user_id", handlers.GetUserRoles)
		authenticatedUser.DELETE("/user-roles/:user_id/:role_id", handlers.RemoveRoleFromUser)

		authenticatedUser.GET("/user-permissions/:user_id", handlers.GetUserPermissions)

		// User Preferences routes
		authenticatedUser.POST("/user-preferences", handlers.SetUserPreference)
		authenticatedUser.GET("/user-preferences/:user_id", handlers.GetUserPreferences)
		authenticatedUser.GET("/user-preferences/:user_id/:key", handlers.GetUserPreference)
		authenticatedUser.PUT("/user-preferences/:user_id/:key", handlers.UpdateUserPreference)
		authenticatedUser.DELETE("/user-preferences/:user_id/:key", handlers.DeleteUserPreference)

		// User permission check route
		authenticatedUser.GET("/check-permission", handlers.UserHasPermission)

		// System Information
		authenticatedUser.GET("/server-version", handlers.GetServerVersion)
	}

	host := os.Getenv("SERVER_HOST")
	utils.Assert(len(host) > 0, "Missing SERVER_HOST")
	app.Run(host)
}
