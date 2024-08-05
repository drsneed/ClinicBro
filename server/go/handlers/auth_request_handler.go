package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/utils"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

func Authenticate(c *gin.Context) {
	var req models.AuthRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	result := utils.DB.Raw(`
		SELECT * FROM users
		WHERE name = ? AND active = true
		  AND (password = crypt(?, password))
	`, req.Name, req.Password).Scan(&user)

	if result.Error != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid user or password"})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid user or password"})
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub":     user.Name,
		"user_id": user.ID,
		"exp":     time.Now().Add(time.Minute * 30).Unix(),
	})

	tokenString, err := token.SignedString([]byte(os.Getenv("JWT_SECRET_KEY")))
	if err != nil {
		fmt.Println("Token signing error:", err) // Add this line
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": tokenString, "user_id": user.ID})
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

	var user models.User
	result := utils.DB.Raw(`
		SELECT * FROM users
		WHERE id = ? AND active = true
		  AND (password = crypt(?, password))
	`, uint(userID), req.CurrentPassword).Scan(&user)

	if result.Error != nil || result.RowsAffected == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Current password is incorrect"})
		return
	}

	// Update the password
	result = utils.DB.Exec(`
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
