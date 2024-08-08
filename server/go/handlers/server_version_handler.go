package handlers

import (
	"ClinicBro-Server/utils"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetServerVersion(c *gin.Context) {
	filename := "ClinicBro-Server.exe"

	data, err := utils.GetFileVersionInfo(filename)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	// productName, err := utils.GetVersionValue(data, `\StringFileInfo\040904b0\ProductName`)
	// if err != nil {
	// 	fmt.Println("Error:", err)
	// 	return
	// }

	productVersion, err := utils.GetVersionValue(data, `\StringFileInfo\040904b0\ProductVersion`)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	c.JSON(http.StatusOK, productVersion)
}
