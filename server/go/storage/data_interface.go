package storage

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Tenant struct {
	OrgID      string
	DBName     string
	DBHost     string
	DBUser     string
	DBPassword string
}

func (t *Tenant) GetDSN() string {
	return fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=disable",
		t.DBHost, t.DBUser, t.DBPassword, t.DBName)
}

var (
	masterDB      *gorm.DB
	redisClient   *redis.Client
	tenantDBs     = make(map[string]*gorm.DB)
	tenantDBMutex sync.RWMutex
)

// var DB *gorm.DB
// var RDS *redis.Client

func InitRedis() {
	redisClient = redis.NewClient(&redis.Options{
		Addr:     "localhost:6379", // Redis server address
		Password: "",               // No password set
		DB:       0,                // Use default DB
	})
}

func InitMasterDB() {
	dsn := os.Getenv("MASTER_DATABASE_URL")
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	masterDB = db

	//TODO: Migrate the master db schema
	//This would be how to migrate a tenant db
	//masterDB.AutoMigrate(&models.User{}, &models.Avatar{}, &models.Location{}, &models.Patient{}, &models.RecentPatient{})
}

func InitAll() {
	InitMasterDB()
	InitRedis()
}

func getTenantInfo(orgID string) (*Tenant, error) {
	ctx := context.Background()

	// Check Redis cache first
	cacheKey := fmt.Sprintf("tenant:%s", orgID)
	cachedInfo, err := redisClient.Get(ctx, cacheKey).Result()
	if err == nil {
		var tenantInfo Tenant
		err = json.Unmarshal([]byte(cachedInfo), &tenantInfo)
		if err == nil {
			return &tenantInfo, nil
		}
	}

	// If not in cache, query master database
	var tenantInfo Tenant
	result := masterDB.Where("org_id = ?", orgID).First(&tenantInfo)
	if result.Error != nil {
		return nil, result.Error
	}

	// Cache the result in Redis
	tenantInfoJSON, err := json.Marshal(tenantInfo)
	if err == nil {
		redisClient.Set(ctx, cacheKey, tenantInfoJSON, 1*time.Hour) // Cache for 1 hour
	}

	return &tenantInfo, nil
}

func ConnectToTenantDB(orgID string) (*gorm.DB, error) {
	tenantDBMutex.RLock()
	if db, exists := tenantDBs[orgID]; exists {
		tenantDBMutex.RUnlock()
		return db, nil
	}
	tenantDBMutex.RUnlock()

	tenantInfo, err := getTenantInfo(orgID)
	if err != nil {
		return nil, err
	}

	// Create new database connection with logging
	db, err := gorm.Open(postgres.Open(tenantInfo.GetDSN()), &gorm.Config{
		Logger: CustomLogger{}, // Use the custom logger for SQL logging
	})
	if err != nil {
		return nil, err
	}

	tenantDBMutex.Lock()
	tenantDBs[orgID] = db
	tenantDBMutex.Unlock()

	return db, nil
}

func GetTenantDB(c *gin.Context) *gorm.DB {
	db, exists := c.Get("db")
	if !exists {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database not found in context"})
		return nil
	}
	tenantDB := db.(*gorm.DB)
	return tenantDB
}
