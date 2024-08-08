package utils

import (
	"log"
)

// Assert checks if the condition is true; if not, it logs an error and panics.
func Assert(condition bool, message string) {
	if !condition {
		log.Fatalf("Assertion failed: %s", message)
	}
}
