package middleware

import (
	"bytes"
	"io/ioutil"
	"log"

	"github.com/gin-gonic/gin"
)

// LoggingMiddleware logs the details of incoming requests and responses
func LoggingMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Log the request body
		var requestBody []byte
		if c.Request.Body != nil {
			requestBody, _ = ioutil.ReadAll(c.Request.Body)
			c.Request.Body = ioutil.NopCloser(bytes.NewBuffer(requestBody))
		}

		log.Printf("Request Body: %s", string(requestBody))

		// Capture the response
		writer := &responseWriter{ResponseWriter: c.Writer}
		c.Writer = writer

		c.Next()

		log.Printf("Response Status: %d", writer.statusCode)
		log.Printf("Response Body: %s", writer.body.String())
	}
}

// responseWriter is a wrapper around gin.ResponseWriter to capture the response body
type responseWriter struct {
	gin.ResponseWriter
	body       bytes.Buffer
	statusCode int
}

func (rw *responseWriter) Write(b []byte) (int, error) {
	rw.body.Write(b)
	return rw.ResponseWriter.Write(b)
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}
