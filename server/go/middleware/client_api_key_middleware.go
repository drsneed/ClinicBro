package middleware

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

var orgValidationApiKey string

func SetOrgValidationKey(key string) {
	orgValidationApiKey = key
}

func ClientApiKeyMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		path := c.Request.URL.Path
		if path == "/validate-org" || path == "/server-version" {
			apiKey := c.GetHeader("X-Client-Api-Key")
			if apiKey != orgValidationApiKey {
				c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
				c.Abort() // Stop further processing
				return
			}
		}
		c.Next() // Proceed to the next handler
	}
}
