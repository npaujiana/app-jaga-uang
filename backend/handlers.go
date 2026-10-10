package main

import (
	"encoding/json"
	"net/http"
)

// ponytail: thin standard library HTTP handlers returning JSON directly

type Server struct {
	store *Store
}

func NewServer(store *Store) *Server {
	return &Server{store: store}
}

func (s *Server) writeJSON(w http.ResponseWriter, status int, data any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(data)
}

func (s *Server) writeError(w http.ResponseWriter, status int, message string) {
	s.writeJSON(w, status, map[string]string{"error": message})
}

func (s *Server) handleHealth(w http.ResponseWriter, r *http.Request) {
	s.writeJSON(w, http.StatusOK, map[string]any{
		"status":    "healthy",
		"service":   "JagaUang Core API",
		"version":   "1.0.0",
		"timestamp": timeNowStr(),
	})
}

func (s *Server) handleGetPockets(w http.ResponseWriter, r *http.Request) {
	pockets := s.store.GetPockets()
	s.writeJSON(w, http.StatusOK, pockets)
}

func (s *Server) handleGetObligations(w http.ResponseWriter, r *http.Request) {
	obligations := s.store.GetObligations()
	s.writeJSON(w, http.StatusOK, obligations)
}

func (s *Server) handleToggleObligation(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if id == "" {
		s.writeError(w, http.StatusBadRequest, "obligation id required")
		return
	}

	ob, err := s.store.ToggleObligation(id)
	if err != nil {
		s.writeError(w, http.StatusNotFound, err.Error())
		return
	}

	s.writeJSON(w, http.StatusOK, ob)
}

func (s *Server) handleGetRunway(w http.ResponseWriter, r *http.Request) {
	summary := s.store.GetRunwaySummary()
	s.writeJSON(w, http.StatusOK, summary)
}

func (s *Server) handleSetScenario(w http.ResponseWriter, r *http.Request) {
	var req SetTargetRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		s.writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	s.store.SetDailyTarget(req.TargetAmount)
	summary := s.store.GetRunwaySummary()
	s.writeJSON(w, http.StatusOK, summary)
}

func (s *Server) handleGetTransactions(w http.ResponseWriter, r *http.Request) {
	filterType := r.URL.Query().Get("type")
	search := r.URL.Query().Get("search")

	transactions := s.store.GetTransactions(filterType, search)
	s.writeJSON(w, http.StatusOK, transactions)
}

func (s *Server) handleCreateTransaction(w http.ResponseWriter, r *http.Request) {
	var req CreateTransactionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		s.writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if req.Amount <= 0 {
		s.writeError(w, http.StatusBadRequest, "amount must be greater than 0")
		return
	}
	if req.Title == "" {
		req.Title = "Transaksi Baru"
	}
	if req.Type == "" {
		req.Type = "Pengeluaran"
	}

	tx, err := s.store.AddTransaction(req)
	if err != nil {
		s.writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	s.writeJSON(w, http.StatusCreated, tx)
}

func (s *Server) handleParseAI(w http.ResponseWriter, r *http.Request) {
	var req ParseAiRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		s.writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	parsed := ParseNaturalLanguage(req.Text)
	s.writeJSON(w, http.StatusOK, parsed)
}

func (s *Server) handleReconcile(w http.ResponseWriter, r *http.Request) {
	var req ReconcileRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		s.writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if req.AccountName == "" {
		req.AccountName = "Bank BRI"
	}

	tx, err := s.store.Reconcile(req)
	if err != nil {
		s.writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	s.writeJSON(w, http.StatusOK, tx)
}
