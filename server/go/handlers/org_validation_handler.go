package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"
	"net/http"

	"github.com/gin-gonic/gin"
)

func ValidateOrganization(c *gin.Context) {
	var orgValidationRequest models.OrgValidationRequest
	if err := c.ShouldBindJSON(&orgValidationRequest); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	tenant, err := storage.GetTenantInfo(orgValidationRequest.OrgID)

	var valid = err == nil && tenant != nil

	c.JSON(http.StatusOK, gin.H{"valid": valid})
}
