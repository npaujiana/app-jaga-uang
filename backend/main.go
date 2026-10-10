package main

import (
	"log"
	"net/http"
	"os"
	"strings"
	"time"
)

// ponytail: single binary, zero framework overhead using Go 1.22+ standard mux

func timeNowStr() string {
	return time.Now().Format(time.RFC3339)
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func main() {
	store := NewStore("data.json")
	srv := NewServer(store)

	mux := http.NewServeMux()

	// Health
	mux.HandleFunc("GET /api/health", srv.handleHealth)

	// Pockets / Accounts
	mux.HandleFunc("GET /api/pockets", srv.handleGetPockets)

	// Obligations
	mux.HandleFunc("GET /api/obligations", srv.handleGetObligations)
	mux.HandleFunc("POST /api/obligations/{id}/toggle", srv.handleToggleObligation)

	// Runway Engine & Scenarios
	mux.HandleFunc("GET /api/runway", srv.handleGetRunway)
	mux.HandleFunc("POST /api/runway/scenario", srv.handleSetScenario)

	// Transactions
	mux.HandleFunc("GET /api/transactions", srv.handleGetTransactions)
	mux.HandleFunc("POST /api/transactions", srv.handleCreateTransaction)

	// AI Natural Language Parser
	mux.HandleFunc("POST /api/transactions/parse-ai", srv.handleParseAI)

	// Reconciliation
	mux.HandleFunc("POST /api/reconciliation", srv.handleReconcile)

	handler := corsMiddleware(mux)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	if !strings.HasPrefix(port, ":") {
		port = ":" + port
	}

	log.Printf("🚀 JagaUang Golang Backend running on %s\n", port)
	log.Printf("Endpoints available at /api/*")
	if err := http.ListenAndServe(port, handler); err != nil {
		log.Fatalf("Server stopped: %v", err)
	}
}
