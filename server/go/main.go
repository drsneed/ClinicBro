package main

import (
	"io"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// User model
type User struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	Name        string    `gorm:"uniqueIndex" json:"name"`
	Color       string    `json:"color"`
	IsProvider  bool      `json:"is_provider"`
	Active      bool      `json:"active"`
	DateCreated time.Time `json:"date_created"`
	DateUpdated time.Time `json:"date_updated"`
	CreatedByID uint      `json:"-"`
	UpdatedByID uint      `json:"-"`
}

// Avatar model
type Avatar struct {
	UserID uint   `gorm:"primaryKey" json:"user_id"`
	Image  []byte `json:"-"`
}

// AuthRequest model
type AuthRequest struct {
	Name     string `json:"name" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// PasswordChangeRequest model
type PasswordChangeRequest struct {
	CurrentPassword string `json:"current_password" binding:"required"`
	NewPassword     string `json:"new_password" binding:"required"`
}

// UserCreate model
type UserCreate struct {
	Name       string `json:"name" binding:"required"`
	Password   string `json:"password" binding:"required"`
	Color      string `json:"color" binding:"required"`
	IsProvider bool   `json:"is_provider"`
	Active     bool   `json:"active"`
}

var db *gorm.DB
var jwtKey []byte

func init() {
	// Load .env file
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	// Set up database connection
	dsn := os.Getenv("DATABASE_URL")
	db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Migrate the schema
	db.AutoMigrate(&User{}, &Avatar{})

	// Set JWT key
	jwtKey = []byte(os.Getenv("JWT_SECRET_KEY"))
	if len(jwtKey) == 0 {
		log.Fatal("JWT_SECRET_KEY not set in environment variables")
	}
}

func main() {
	r := gin.Default()

	// Public routes
	r.POST("/authenticate", authenticate)

	// Protected routes
	authorized := r.Group("/")
	authorized.Use(authMiddleware())
	{
		authorized.POST("/users", createUser)
		authorized.GET("/users/:id", getUser)
		authorized.GET("/users", getAllUsers)
		authorized.POST("/avatar", createAvatar)
		authorized.GET("/avatar/:id", getAvatar)
		authorized.PUT("/avatar/:id", updateAvatar)
		authorized.DELETE("/avatar/:id", deleteAvatar)
		authorized.POST("/change-password", changePassword)
	}

	// Start server
	host := os.Getenv("ClinicBroHost")
	if host == "" {
		host = "[::]:8080"
	}
	r.Run(host)
}

func authMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header is required"})
			c.Abort()
			return
		}

		bearerToken := strings.Split(authHeader, " ")
		if len(bearerToken) != 2 || strings.ToLower(bearerToken[0]) != "bearer" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid authorization header format"})
			c.Abort()
			return
		}

		tokenString := bearerToken[1]
		claims := jwt.MapClaims{}

		token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
			return jwtKey, nil
		})

		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
			c.Abort()
			return
		}

		if !token.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
			c.Abort()
			return
		}

		// Add claims to the context
		c.Set("claims", claims)
		c.Next()
	}
}

func authenticate(c *gin.Context) {
	var req AuthRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user User
	result := db.Raw(`
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

	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": tokenString, "user_id": user.ID})
}

func changePassword(c *gin.Context) {
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

	var req PasswordChangeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user User
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

func createUser(c *gin.Context) {
	var newUser UserCreate
	if err := c.ShouldBindJSON(&newUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user User
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

func getUser(c *gin.Context) {
	id := c.Param("id")
	var user User
	result := db.First(&user, id)
	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}
	c.JSON(http.StatusOK, user)
}

func getAllUsers(c *gin.Context) {
	var users []User
	result := db.Find(&users)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch users"})
		return
	}
	c.JSON(http.StatusOK, users)
}
func createAvatar(c *gin.Context) {
	userIDStr := c.PostForm("user_id")
	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	file, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file uploaded"})
		return
	}

	// Read file contents
	fileContent, err := file.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not read file"})
		return
	}
	defer fileContent.Close()

	buffer, err := io.ReadAll(fileContent)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not read file contents"})
		return
	}

	avatar := Avatar{
		UserID: uint(userID),
		Image:  buffer,
	}

	result := db.Save(&avatar)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not save avatar"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Avatar created/updated successfully"})
}

func getAvatar(c *gin.Context) {
	userID := c.Param("id")
	var avatar Avatar
	result := db.Where("user_id = ?", userID).First(&avatar)
	if result.Error != nil {
		//c.File("img/avatar.png") // Default avatar
		c.Data(http.StatusNotFound, "image/png", nil)
		return
	}

	c.Data(http.StatusOK, "image/png", avatar.Image)
}

func updateAvatar(c *gin.Context) {
	userID := c.Param("id")
	file, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file uploaded"})
		return
	}

	// Read file contents
	fileContent, err := file.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not read file"})
		return
	}
	defer fileContent.Close()

	var buffer []byte
	_, err = fileContent.Read(buffer)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not read file contents"})
		return
	}

	result := db.Model(&Avatar{}).Where("user_id = ?", userID).Update("image", buffer)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not update avatar"})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Avatar not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Avatar updated successfully"})
}

func deleteAvatar(c *gin.Context) {
	userID := c.Param("id")
	result := db.Where("user_id = ?", userID).Delete(&Avatar{})
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not delete avatar"})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Avatar not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Avatar deleted successfully"})
}
