package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

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
