package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
)

// ponytail: straightforward tests using httptest standard library

func setupTestStore(t *testing.T) (*Store, func()) {
	tmpFile, err := os.CreateTemp("", "test_jaga_uang_*.json")
	if err != nil {
		t.Fatalf("failed to create temp file: %v", err)
	}
	tmpPath := tmpFile.Name()
	tmpFile.Close()
	os.Remove(tmpPath)

	store := NewStore(tmpPath)
	cleanup := func() {
		os.Remove(tmpPath)
	}
	return store, cleanup
}

func TestHealthCheck(t *testing.T) {
	store, cleanup := setupTestStore(t)
	defer cleanup()

	srv := NewServer(store)
	req := httptest.NewRequest("GET", "/api/health", nil)
	w := httptest.NewRecorder()

	srv.handleHealth(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", w.Code)
	}
}

func TestRunwayCalculation(t *testing.T) {
	store, cleanup := setupTestStore(t)
	defer cleanup()

	summary := store.GetRunwaySummary()

	if summary.TotalAssets <= 0 {
		t.Errorf("expected total assets > 0, got %f", summary.TotalAssets)
	}
	if summary.SpendableCash <= 0 {
		t.Errorf("expected spendable cash > 0, got %f", summary.SpendableCash)
	}
	if summary.UsableMoney != summary.SpendableCash-summary.ProtectedFloorBRI-summary.UnpaidObligations {
		t.Errorf("usable money calculation incorrect")
	}
}

func TestAddTransactionAndBalanceDeduction(t *testing.T) {
	store, cleanup := setupTestStore(t)
	defer cleanup()

	initialPockets := store.GetPockets()
	var initialMakan float64
	for _, p := range initialPockets {
		if p.ID == "jago_makan" {
			initialMakan = p.Balance
		}
	}

	tx, err := store.AddTransaction(CreateTransactionRequest{
		Title:    "Nasi Goreng Malam",
		Category: "Makanan",
		PocketID: "jago_makan",
		Amount:   20000,
		Type:     "Pengeluaran",
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if tx.Amount != 20000 {
		t.Errorf("expected 20000, got %f", tx.Amount)
	}

	updatedPockets := store.GetPockets()
	for _, p := range updatedPockets {
		if p.ID == "jago_makan" {
			if p.Balance != initialMakan-20000 {
				t.Errorf("expected balance %f, got %f", initialMakan-20000, p.Balance)
			}
		}
	}
}

func TestParseNaturalLanguage(t *testing.T) {
	res := ParseNaturalLanguage("Beli ketoprak 16 ribu pakai Jago kantong makan")

	if res.Amount != 16000 {
		t.Errorf("expected 16000, got %f", res.Amount)
	}
	if res.Category != "Makanan" {
		t.Errorf("expected Makanan, got %s", res.Category)
	}
}

func TestReconcile(t *testing.T) {
	store, cleanup := setupTestStore(t)
	defer cleanup()

	srv := NewServer(store)
	payload := ReconcileRequest{
		AccountName:   "Bank BRI",
		ActualBalance: 600000,
		Reason:        "Koreksi saldo fisik",
	}
	body, _ := json.Marshal(payload)
	req := httptest.NewRequest("POST", "/api/reconciliation", bytes.NewReader(body))
	w := httptest.NewRecorder()

	srv.handleReconcile(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", w.Code)
	}

	summary := store.GetRunwaySummary()
	for _, p := range store.GetPockets() {
		if p.ParentAccount == "Bank BRI" {
			if p.Balance != 600000 {
				t.Errorf("expected 600000, got %f", p.Balance)
			}
		}
	}
	_ = summary
}
