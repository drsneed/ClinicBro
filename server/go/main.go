package main

import (
	"log"
	"os"

	"ClinicBro-Server/handlers"
	"ClinicBro-Server/middleware"
	"ClinicBro-Server/utils"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func init() {
	if err := godotenv.Load(); err != nil {
		log.Fatal("Error loading .env file")
	}

	utils.InitDB()
}

func main() {
	r := gin.Default()

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
	}

	// Start server
	host := os.Getenv("ClinicBroHost")
	if host == "" {
		host = "[::]:8080"
	}
	r.Run(host)
}
