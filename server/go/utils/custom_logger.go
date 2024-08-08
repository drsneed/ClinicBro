package utils

import (
	"context"
	"log"
	"time"

	"gorm.io/gorm/logger"
)

// CustomLogger implements gorm/logger.Interface for SQL logging
type CustomLogger struct{}

func (cl CustomLogger) LogMode(logger.LogLevel) logger.Interface {
	return cl
}

func (cl CustomLogger) Info(ctx context.Context, msg string, args ...interface{}) {
	log.Printf("INFO: "+msg, args...)
}

func (cl CustomLogger) Warn(ctx context.Context, msg string, args ...interface{}) {
	log.Printf("WARN: "+msg, args...)
}

func (cl CustomLogger) Error(ctx context.Context, msg string, args ...interface{}) {
	log.Printf("ERROR: "+msg, args...)
}

func (cl CustomLogger) Trace(ctx context.Context, begin time.Time, fc func() (string, int64), err error) {
	sql, rows := fc()
	log.Printf("SQL: %s | RowsAffected: %d | Duration: %s | Error: %v", sql, rows, time.Since(begin), err)
}
