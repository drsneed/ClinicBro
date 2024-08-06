package middleware

import (
	"ClinicBro-Server/storage"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

var jwtSecret string

func SetJWTSecret(secret string) {
	jwtSecret = secret
}

func AuthMiddleware() gin.HandlerFunc {
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
			return []byte(jwtSecret), nil
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

		orgID, ok := claims["org_id"].(string)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "org_id not found in token"})
			c.Abort()
			return
		}

		// userID, ok := claims["user_id"].(string)
		// if !ok {
		// 	c.JSON(http.StatusUnauthorized, gin.H{"error": "user_id not found in token"})
		// 	c.Abort()
		// 	return
		// }

		db, err := storage.ConnectToTenantDB(orgID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to connect to tenant database"})
			c.Abort()
			return
		}

		// Add claims and db to the context
		c.Set("claims", claims)
		c.Set("db", db)
		c.Set("org_id", orgID)
		//c.Set("user_id", userID)
		c.Next()
	}
}
