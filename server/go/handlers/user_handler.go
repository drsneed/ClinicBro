package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"gorm.io/gorm"
)

func CreateUser(c *gin.Context) {
	var newUser models.UserCreate
	if err := c.ShouldBindJSON(&newUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	var user models.User
	result := db.Raw(`
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
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	var user models.User
	result := db.First(&user, id)
	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}
	c.JSON(http.StatusOK, user)
}

func GetAllUsers(c *gin.Context) {
	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}
	var users []models.User
	result := db.Find(&users)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch users"})
		return
	}
	c.JSON(http.StatusOK, users)
}

func ChangePassword(c *gin.Context) {
	// Extract user ID from the JWT claims
	claims, exists := c.Get("claims")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Authentication required"})
		return
	}

	userID, ok := claims.(jwt.MapClaims)["user_id"].(float64)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
		return
	}

	var req models.PasswordChangeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var db = storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var user models.User
	result := db.Raw(`
		SELECT * FROM users
		WHERE id = ? AND active = true
		  AND (password = crypt(?, password))
	`, uint(userID), req.CurrentPassword).Scan(&user)

	if result.Error != nil || result.RowsAffected == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Current password is incorrect"})
		return
	}

	// Update the password
	result = db.Exec(`
		UPDATE users
		SET password = crypt(?, gen_salt('bf')), date_updated = NOW(), updated_user_id = ?
		WHERE id = ?
	`, req.NewPassword, uint(userID), uint(userID))

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not update password"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Password changed successfully"})
}

var jwtSecret string

func SetJWTSecret(secret string) {
	jwtSecret = secret
}

func AuthenticateUser(c *gin.Context) {
	var authRequest models.AuthRequest
	if err := c.ShouldBindJSON(&authRequest); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	db, err := storage.ConnectToTenantDB(authRequest.OrgID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to connect to tenant database"})
		return
	}

	var user models.User
	if err := db.Raw("SELECT * FROM users WHERE active=true AND name = ? AND password = crypt(?, password)",
		authRequest.Name, authRequest.Password).Scan(&user).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		}
		return
	}

	if user.ID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID,
		"org_id":  authRequest.OrgID,
		"exp":     time.Now().Add(time.Hour * 24).Unix(),
	})

	tokenString, err := token.SignedString([]byte(jwtSecret))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": tokenString, "user_id": user.ID})
}
