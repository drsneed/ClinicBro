package main

import (
	"ClinicBro-Server/handlers"
	"ClinicBro-Server/middleware"
	"ClinicBro-Server/storage"
	"ClinicBro-Server/utils"
	"flag"
	"fmt"
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Fatal("Error loading .env file")
	}
	storage.InitAll()

	// Parse command-line arguments
	enableLogging := flag.Bool("enable-logging", false, "Enable logging middleware")
	flag.Parse()

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

	// Conditionally apply logging middleware based on the command-line argument
	if *enableLogging {
		app.Use(middleware.LoggingMiddleware())
		fmt.Println("logging enabled")
	} else {
		fmt.Println("logging disabled")
	}

	// Routes that require API Key Authentication
	apiKeyRouter := app.Group("/")
	apiKeyRouter.Use(middleware.ClientApiKeyMiddleware(clientApiKey))
	{
		apiKeyRouter.GET("/validate-server", handlers.ValidateServer)
		apiKeyRouter.POST("/validate-organization", handlers.ValidateOrganization)
		apiKeyRouter.POST("/authenticate-user", handlers.AuthenticateUser)
	}

	// Routes that require JWT Authentication
	authTokenRouter := app.Group("/")
	authTokenRouter.Use(middleware.AuthMiddleware(jwtSecret))
	{
		// User routes
		authTokenRouter.POST("/users", handlers.CreateUser)
		authTokenRouter.GET("/users/:id", handlers.GetUser)
		authTokenRouter.GET("/users", handlers.GetAllUsers)
		//authTokenRouter.PUT("/users/:id", handlers.UpdateUser)
		//authTokenRouter.DELETE("/users/:id", handlers.DeleteUser)

		// Avatar routes
		authTokenRouter.POST("/avatars/:type/:id", handlers.CreateOrUpdateAvatar)
		authTokenRouter.GET("/avatars/:type/:id", handlers.GetAvatar)
		authTokenRouter.PUT("/avatars/:type/:id", handlers.UpdateAvatar)
		authTokenRouter.DELETE("/avatars/:type/:id", handlers.DeleteAvatar)

		// Location routes
		authTokenRouter.POST("/locations", handlers.CreateLocation)
		authTokenRouter.GET("/locations/:id", handlers.GetLocation)
		authTokenRouter.GET("/locations", handlers.GetAllLocations)
		authTokenRouter.PUT("/locations/:id", handlers.UpdateLocation)
		authTokenRouter.DELETE("/locations/:id", handlers.DeleteLocation)

		// Patient routes
		authTokenRouter.POST("/patients", handlers.CreatePatient)
		authTokenRouter.GET("/patients/:id", handlers.GetPatient)
		authTokenRouter.GET("/patients", handlers.GetAllPatients)
		authTokenRouter.PUT("/patients/:id", handlers.UpdatePatient)
		authTokenRouter.DELETE("/patients/:id", handlers.DeletePatient)

		// Recent patients routes
		authTokenRouter.GET("/recent-patients", handlers.GetRecentPatients)
		authTokenRouter.POST("/recent-patients/:patient_id", handlers.AddRecentPatient)

		// Search patients route
		authTokenRouter.GET("/patients/search", handlers.SearchPatients)

		// Patients with appt today route
		authTokenRouter.GET("/patients/appt-today", handlers.GetPatientsWithAppointmentToday)

		// Password change route
		authTokenRouter.POST("/change-password", handlers.ChangePassword)

		// Appointment Types routes
		authTokenRouter.POST("/appointment-types", handlers.CreateAppointmentType)
		authTokenRouter.GET("/appointment-types/:id", handlers.GetAppointmentType)
		authTokenRouter.GET("/appointment-types", handlers.GetAllAppointmentTypes)
		authTokenRouter.PUT("/appointment-types/:id", handlers.UpdateAppointmentType)
		authTokenRouter.DELETE("/appointment-types/:id", handlers.DeleteAppointmentType)

		// Appointment Statuses routes
		authTokenRouter.POST("/appointment-statuses", handlers.CreateAppointmentStatus)
		authTokenRouter.GET("/appointment-statuses/:id", handlers.GetAppointmentStatus)
		authTokenRouter.GET("/appointment-statuses", handlers.GetAllAppointmentStatuses)
		authTokenRouter.PUT("/appointment-statuses/:id", handlers.UpdateAppointmentStatus)
		authTokenRouter.DELETE("/appointment-statuses/:id", handlers.DeleteAppointmentStatus)

		// Appointments routes
		authTokenRouter.POST("/appointments", handlers.CreateAppointment)
		authTokenRouter.GET("/appointments/:id", handlers.GetAppointment)
		authTokenRouter.GET("/appointments", handlers.GetAllAppointments)
		authTokenRouter.PUT("/appointments/:id", handlers.UpdateAppointment)
		authTokenRouter.DELETE("/appointments/:id", handlers.DeleteAppointment)

		// Routes for fetching create/edit appointment data
		authTokenRouter.GET("/edit-appointment-data", handlers.GetEditAppointmentData)
		authTokenRouter.GET("/create-appointment-data", handlers.GetCreateAppointmentData)

		// Appointment Items route
		authTokenRouter.GET("/appointment-items", handlers.GetAppointmentItems)

		// Appointment Dates route
		authTokenRouter.GET("/appointment-dates", handlers.GetAppointmentDates)

		// Event Participants route
		authTokenRouter.GET("/event-participants", handlers.GetEventParticipants)

		// Operating Schedule routes
		authTokenRouter.POST("/operating-schedule", handlers.CreateOperatingSchedule)
		authTokenRouter.GET("/operating-schedule", handlers.GetOperatingSchedule)
		authTokenRouter.PUT("/operating-schedule", handlers.UpdateOperatingSchedule)
		authTokenRouter.DELETE("/operating-schedule", handlers.DeleteOperatingSchedule)
		authTokenRouter.GET("/operating-schedule/current-user", handlers.GetOperatingScheduleForCurrentUser)

		// RBAC routes
		authTokenRouter.POST("/roles", handlers.CreateRole)
		authTokenRouter.GET("/roles", handlers.GetAllRoles)
		authTokenRouter.GET("/roles/:id", handlers.GetRole)
		authTokenRouter.PUT("/roles/:id", handlers.UpdateRole)
		authTokenRouter.DELETE("/roles/:id", handlers.DeleteRole)

		authTokenRouter.POST("/permissions", handlers.CreatePermission)
		authTokenRouter.GET("/permissions", handlers.GetAllPermissions)
		authTokenRouter.GET("/permissions/:id", handlers.GetPermission)
		authTokenRouter.PUT("/permissions/:id", handlers.UpdatePermission)
		authTokenRouter.DELETE("/permissions/:id", handlers.DeletePermission)

		authTokenRouter.POST("/user-roles", handlers.AssignRoleToUser)
		authTokenRouter.GET("/user-roles/:user_id", handlers.GetUserRoles)
		authTokenRouter.DELETE("/user-roles/:user_id/:role_id", handlers.RemoveRoleFromUser)

		authTokenRouter.GET("/user-permissions/:user_id", handlers.GetUserPermissions)

		// User Preferences routes
		authTokenRouter.POST("/user-preferences", handlers.SetUserPreference)
		authTokenRouter.GET("/user-preferences/:user_id", handlers.GetUserPreferences)
		authTokenRouter.GET("/user-preferences/:user_id/:key", handlers.GetUserPreference)
		authTokenRouter.PUT("/user-preferences/:user_id/:key", handlers.UpdateUserPreference)
		authTokenRouter.DELETE("/user-preferences/:user_id/:key", handlers.DeleteUserPreference)

		// User permission check route
		authTokenRouter.GET("/check-permission", handlers.UserHasPermission)

		// System Information
		authTokenRouter.GET("/server-version", handlers.GetServerVersion)
	}

	// Start the server
	app.Run(host)
}
