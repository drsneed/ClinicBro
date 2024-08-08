package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func WhoAreYou(c *gin.Context) {
	c.JSON(http.StatusOK, "ClinicBro-Server")
}
