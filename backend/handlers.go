package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"
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

func (s *Server) handleGetAiModels(w http.ResponseWriter, r *http.Request) {
	var req AiModelsRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		s.writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	endpoint := strings.TrimRight(strings.TrimSpace(req.Endpoint), "/")
	if endpoint == "" {
		endpoint = "https://9router.npaujiana.tech/v1"
	}

	client := &http.Client{Timeout: 10 * time.Second}
	modelsReq, err := http.NewRequest(http.MethodGet, endpoint+"/models", nil)
	if err != nil {
		s.writeJSON(w, http.StatusOK, AiModelsResponse{Error: err.Error()})
		return
	}

	if req.ApiKey != "" {
		modelsReq.Header.Set("Authorization", "Bearer "+req.ApiKey)
	}
	modelsReq.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(modelsReq)
	if err != nil {
		s.writeJSON(w, http.StatusOK, AiModelsResponse{Error: err.Error()})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		var errResp map[string]any
		_ = json.NewDecoder(resp.Body).Decode(&errResp)
		msg := fmt.Sprintf("HTTP %d", resp.StatusCode)
		if e, ok := errResp["error"]; ok {
			msg = fmt.Sprintf("HTTP %d: %v", resp.StatusCode, e)
		}
		s.writeJSON(w, http.StatusOK, AiModelsResponse{Error: msg})
		return
	}

	var data struct {
		Data []struct {
			ID string `json:"id"`
		} `json:"data"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		s.writeJSON(w, http.StatusOK, AiModelsResponse{Error: err.Error()})
		return
	}

	var modelList []string
	for _, m := range data.Data {
		if m.ID != "" {
			modelList = append(modelList, m.ID)
		}
	}

	s.writeJSON(w, http.StatusOK, AiModelsResponse{Models: modelList})
}

func (s *Server) handleParseAI(w http.ResponseWriter, r *http.Request) {
	var req ParseAiRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		s.writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	// Try remote LLM if endpoint, apiKey, and model are provided
	if req.Endpoint != "" && req.ApiKey != "" && req.Model != "" {
		endpoint := strings.TrimRight(strings.TrimSpace(req.Endpoint), "/")
		client := &http.Client{Timeout: 12 * time.Second}

		systemPrompt := `Kamu adalah parser transaksi keuangan aplikasi JagaUang Indonesia. ` +
			`Kembalikan HANYA JSON murni tanpa markdown, tanpa backtick, persis format berikut: ` +
			`{"amount": 16000, "description": "Ketoprak siang", "category": "Makanan", "pocketId": "jago_makan", "type": "Pengeluaran"}` +
			`Kategori valid: Makanan, Jajan, Kebutuhan, Transportasi, Keluarga, Gym, Skincare, Lain-lain.` +
			`PocketID valid: jago_makan, jago_skincare, jago_gym, jago_keluarga, cash, bri, stockbit.` +
			`Type valid: Pengeluaran, Pemasukan.`

		payload := map[string]any{
			"model":  req.Model,
			"stream": false,
			"messages": []map[string]string{
				{"role": "system", "content": systemPrompt},
				{"role": "user", "content": req.Text},
			},
			"temperature": 0.1,
		}

		payloadBytes, _ := json.Marshal(payload)
		chatReq, err := http.NewRequest(http.MethodPost, endpoint+"/chat/completions", bytes.NewReader(payloadBytes))
		if err == nil {
			chatReq.Header.Set("Authorization", "Bearer "+req.ApiKey)
			chatReq.Header.Set("Content-Type", "application/json")

			resp, err := client.Do(chatReq)
			if err == nil && resp.StatusCode == http.StatusOK {
				defer resp.Body.Close()
				var chatResp struct {
					Choices []struct {
						Message struct {
							Content string `json:"content"`
						} `json:"message"`
					} `json:"choices"`
				}
				if json.NewDecoder(resp.Body).Decode(&chatResp) == nil && len(chatResp.Choices) > 0 {
					rawContent := strings.TrimSpace(chatResp.Choices[0].Message.Content)
					rawContent = strings.TrimPrefix(rawContent, "```json")
					rawContent = strings.TrimPrefix(rawContent, "```")
					rawContent = strings.TrimSuffix(rawContent, "```")
					rawContent = strings.TrimSpace(rawContent)

					var aiResult ParseAiResponse
					if json.Unmarshal([]byte(rawContent), &aiResult) == nil && aiResult.Amount > 0 {
						if aiResult.Description == "" {
							aiResult.Description = req.Text
						}
						s.writeJSON(w, http.StatusOK, aiResult)
						return
					}
				}
			}
		}
	}

	// Graceful fallback to built-in rule-based NLP parser
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
