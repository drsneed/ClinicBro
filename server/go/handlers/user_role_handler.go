package handlers

import (
	"ClinicBro-Server/models"
	"ClinicBro-Server/storage"
	"net/http"

	"github.com/gin-gonic/gin"
)

func CreateRole(c *gin.Context) {
	var newRole models.Role
	if err := c.ShouldBindJSON(&newRole); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	result := db.Create(&newRole)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create role"})
		return
	}

	c.JSON(http.StatusCreated, newRole)
}

func AssignRoleToUser(c *gin.Context) {
	var userRole models.UserRole
	if err := c.ShouldBindJSON(&userRole); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	result := db.Create(&userRole)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not assign role to user"})
		return
	}

	c.JSON(http.StatusCreated, userRole)
}

func GetUserRoles(c *gin.Context) {
	userID := c.Param("id")

	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var roles []models.Role
	result := db.Joins("JOIN user_roles ON roles.id = user_roles.role_id").
		Where("user_roles.user_id = ?", userID).
		Find(&roles)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch user roles"})
		return
	}

	c.JSON(http.StatusOK, roles)
}

// Roles handlers

func GetAllRoles(c *gin.Context) {
	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var roles []models.Role
	if err := db.Find(&roles).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch roles"})
		return
	}

	c.JSON(http.StatusOK, roles)
}

func GetRole(c *gin.Context) {
	id := c.Param("id")
	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var role models.Role
	if err := db.First(&role, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Role not found"})
		return
	}

	c.JSON(http.StatusOK, role)
}

func UpdateRole(c *gin.Context) {
	id := c.Param("id")
	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var role models.Role
	if err := db.First(&role, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Role not found"})
		return
	}

	if err := c.ShouldBindJSON(&role); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := db.Save(&role).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update role"})
		return
	}

	c.JSON(http.StatusOK, role)
}

func DeleteRole(c *gin.Context) {
	id := c.Param("id")
	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	if err := db.Delete(&models.Role{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete role"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Role deleted successfully"})
}

// Permissions handlers

func CreatePermission(c *gin.Context) {
	var permission models.Permission
	if err := c.ShouldBindJSON(&permission); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	if err := db.Create(&permission).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create permission"})
		return
	}

	c.JSON(http.StatusCreated, permission)
}

func GetAllPermissions(c *gin.Context) {
	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var permissions []models.Permission
	if err := db.Find(&permissions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch permissions"})
		return
	}

	c.JSON(http.StatusOK, permissions)
}

func GetPermission(c *gin.Context) {
	id := c.Param("id")
	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var permission models.Permission
	if err := db.First(&permission, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Permission not found"})
		return
	}

	c.JSON(http.StatusOK, permission)
}

func UpdatePermission(c *gin.Context) {
	id := c.Param("id")
	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var permission models.Permission
	if err := db.First(&permission, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Permission not found"})
		return
	}

	if err := c.ShouldBindJSON(&permission); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := db.Save(&permission).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update permission"})
		return
	}

	c.JSON(http.StatusOK, permission)
}

func DeletePermission(c *gin.Context) {
	id := c.Param("id")
	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	if err := db.Delete(&models.Permission{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete permission"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Permission deleted successfully"})
}

// User Roles handlers

func RemoveRoleFromUser(c *gin.Context) {
	userID := c.Param("user_id")
	roleID := c.Param("role_id")
	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	if err := db.Where("user_id = ? AND role_id = ?", userID, roleID).Delete(&models.UserRole{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to remove role from user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Role removed from user successfully"})
}

// User Permissions handlers

func GetUserPermissions(c *gin.Context) {
	userID := c.Param("user_id")
	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var permissions []models.Permission
	if err := db.Joins("JOIN role_permissions ON permissions.id = role_permissions.permission_id").
		Joins("JOIN user_roles ON role_permissions.role_id = user_roles.role_id").
		Where("user_roles.user_id = ?", userID).
		Distinct().
		Find(&permissions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user permissions"})
		return
	}

	c.JSON(http.StatusOK, permissions)
}

func UserHasPermission(c *gin.Context) {
	userID := c.Param("id")
	permissionName := c.Query("permission")

	db := storage.GetTenantDB(c)
	if db == nil {
		return
	}

	var hasPermission bool
	result := db.Raw("SELECT user_has_permission(?, ?)", userID, permissionName).Scan(&hasPermission)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not check user permission"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"has_permission": hasPermission})
}
