package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// Used by clients to make sure they are talking to a ClinicBro server
func ValidateServer(c *gin.Context) {
	c.JSON(http.StatusOK, "ClinicBro-Server")
}
