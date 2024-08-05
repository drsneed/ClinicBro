package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/utils"
	"net/http"

	"github.com/gin-gonic/gin"
)

func CreateUser(c *gin.Context) {
	var newUser models.UserCreate
	if err := c.ShouldBindJSON(&newUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	result := utils.DB.Raw(`
		INSERT INTO users (name, password, color, is_provider, active, date_created, date_updated)
		VALUES (?, crypt(?, gen_salt('bf')), ?, ?, ?, NOW(), NOW())
		RETURNING id, name, color, is_provider, active, date_created, date_updated
	`, newUser.Name, newUser.Password, newUser.Color, newUser.IsProvider, newUser.Active).Scan(&user)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create user"})
		return
	}

	c.JSON(http.StatusCreated, user)
}

func GetUser(c *gin.Context) {
	id := c.Param("id")
	var user models.User
	result := utils.DB.First(&user, id)
	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}
	c.JSON(http.StatusOK, user)
}

func GetAllUsers(c *gin.Context) {
	var users []models.User
	result := utils.DB.Find(&users)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch users"})
		return
	}
	c.JSON(http.StatusOK, users)
}
