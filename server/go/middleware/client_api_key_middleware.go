package middleware

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

var actualClientApiKey string

func ClientApiKeyMiddleware(clientApiKey string) gin.HandlerFunc {
	actualClientApiKey = clientApiKey
	return func(c *gin.Context) {
		providedClientApiKey := c.GetHeader("X-Client-Api-Key")
		if providedClientApiKey == actualClientApiKey {
			c.Next()
			return
		}
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		c.Abort() // Prevent further processing
	}
}
