package main

import (
	"encoding/json"
	"fmt"
	"math"
	"os"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"time"
)

// ponytail: thread-safe JSON-backed store; eliminates external DB setup & overhead

type StoreData struct {
	Pockets             []Pocket      `json:"pockets"`
	Obligations         []Obligation  `json:"obligations"`
	Transactions        []Transaction `json:"transactions"`
	SelectedDailyTarget float64       `json:"selectedDailyTarget"`
	DaysRemaining       int           `json:"daysRemaining"`
	ProtectedFloorBRI   float64       `json:"protectedFloorBRI"`
}

type Store struct {
	mu       sync.RWMutex
	filePath string
	data     StoreData
}

var defaultScenarios = []DailyScenario{
	{
		Amount:      15000,
		Label:       "Rp15.000 / hari — Ultra Hemat",
		Description: "Prioritas menjaga runway stabil hingga akhir bulan.",
		BadgeText:   "Aman",
	},
	{
		Amount:      20000,
		Label:       "Rp20.000 / hari — Hemat",
		Description: "Ruang ekstra untuk jajan ringan sesekali.",
		BadgeText:   "Aman",
	},
	{
		Amount:      30000,
		Label:       "Rp30.000 / hari — Moderat",
		Description: "Pengeluaran standar tanpa penghematan ketat.",
		BadgeText:   "Waspada",
	},
	{
		Amount:      50000,
		Label:       "Rp50.000 / hari — Bebas Terkendali",
		Description: "Batas maksimum sebelum menyentuh cadangan darurat.",
		BadgeText:   "Batas Kritis",
	},
}

func NewStore(filePath string) *Store {
	s := &Store{
		filePath: filePath,
	}

	if err := s.load(); err != nil {
		s.seed()
		_ = s.save()
	}

	return s
}

func (s *Store) seed() {
	s.data = StoreData{
		SelectedDailyTarget: 15000,
		DaysRemaining:       22,
		ProtectedFloorBRI:   50000,
		Pockets: []Pocket{
			{
				ID:            "jago_makan",
				Name:          "Kantong Makan",
				Balance:       597500,
				IsSpendable:   true,
				ParentAccount: "Bank Jago",
				Subtitle:      "Tersedia harian",
			},
			{
				ID:            "jago_skincare",
				Name:          "Kantong Skincare",
				Balance:       325800,
				IsSpendable:   true,
				ParentAccount: "Bank Jago",
				Subtitle:      "Sisa Rp112.300 pasca komitmen",
			},
			{
				ID:            "jago_gym",
				Name:          "Kantong Gym",
				Balance:       150000,
				IsSpendable:   true,
				ParentAccount: "Bank Jago",
				Subtitle:      "Direservasi untuk Gym",
			},
			{
				ID:            "jago_keluarga",
				Name:          "Kantong Keluarga",
				Balance:       86500,
				IsSpendable:   true,
				ParentAccount: "Bank Jago",
				Subtitle:      "Direservasi untuk Keluarga",
			},
			{
				ID:            "cash",
				Name:          "Kas Tunai (Dompet Fisik)",
				Balance:       50000,
				IsSpendable:   true,
				ParentAccount: "Dompet Tunai",
				Subtitle:      "Uang fisik darurat",
			},
			{
				ID:            "bri",
				Name:          "Bank BRI",
				Balance:       552755,
				IsSpendable:   true,
				ParentAccount: "Bank BRI",
				Subtitle:      "Protected Floor Rp50.000",
			},
			{
				ID:            "stockbit",
				Name:          "Stockbit (Portofolio)",
				Balance:       28206,
				IsSpendable:   false,
				ParentAccount: "Stockbit",
				Subtitle:      "Portofolio Saham/Reksadana",
			},
		},
		Obligations: []Obligation{
			{
				ID:           "gym",
				Title:        "Biaya Gym Bulanan",
				DueDate:      "15 Okt",
				Amount:       150000,
				SourcePocket: "Jago Gym (Rp150.000)",
				IsPaid:       false,
			},
			{
				ID:           "keluarga",
				Title:        "Dukungan Keluarga",
				DueDate:      "20 Okt",
				Amount:       300000,
				SourcePocket: "Jago Keluarga (Rp86.500) + Skincare (Rp213.500)",
				IsPaid:       false,
			},
		},
		Transactions: []Transaction{
			{
				ID:            "tx_1",
				Title:         "Makan Siang Warteg",
				Category:      "Makanan",
				AccountPocket: "Bank Jago (Makan)",
				Amount:        15000,
				Type:          "Pengeluaran",
				DateTime:      time.Date(2026, 10, 10, 12, 45, 0, 0, time.Local),
				IsVerified:    true,
			},
			{
				ID:            "tx_2",
				Title:         "Kopi Hitam Pagi",
				Category:      "Jajan",
				AccountPocket: "Bank Jago (Makan)",
				Amount:        10000,
				Type:          "Pengeluaran",
				DateTime:      time.Date(2026, 10, 10, 8, 15, 0, 0, time.Local),
				IsVerified:    true,
			},
			{
				ID:            "tx_3",
				Title:         "Nasi Padang Bungkus",
				Category:      "Makanan",
				AccountPocket: "Kas Tunai",
				Amount:        14000,
				Type:          "Pengeluaran",
				DateTime:      time.Date(2026, 10, 9, 13, 0, 0, 0, time.Local),
				IsVerified:    true,
			},
			{
				ID:            "tx_4",
				Title:         "Gaji / Transfer Masuk",
				Category:      "Pendapatan",
				AccountPocket: "Bank BRI",
				Amount:        1500000,
				Type:          "Pemasukan",
				DateTime:      time.Date(2026, 10, 8, 9, 0, 0, 0, time.Local),
				IsVerified:    true,
			},
		},
	}
}

func (s *Store) load() error {
	bytes, err := os.ReadFile(s.filePath)
	if err != nil {
		return err
	}
	return json.Unmarshal(bytes, &s.data)
}

func (s *Store) save() error {
	bytes, err := json.MarshalIndent(s.data, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(s.filePath, bytes, 0644)
}

func (s *Store) GetPockets() []Pocket {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return append([]Pocket(nil), s.data.Pockets...)
}

func (s *Store) GetObligations() []Obligation {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return append([]Obligation(nil), s.data.Obligations...)
}

func (s *Store) ToggleObligation(id string) (*Obligation, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	for i := range s.data.Obligations {
		if s.data.Obligations[i].ID == id {
			s.data.Obligations[i].IsPaid = !s.data.Obligations[i].IsPaid
			_ = s.save()
			res := s.data.Obligations[i]
			return &res, nil
		}
	}
	return nil, fmt.Errorf("obligation not found: %s", id)
}

func (s *Store) GetTransactions(filterType, search string) []Transaction {
	s.mu.RLock()
	defer s.mu.RUnlock()

	var result []Transaction
	searchLower := strings.ToLower(search)

	for _, tx := range s.data.Transactions {
		if filterType != "" && filterType != "Semua" && tx.Type != filterType {
			continue
		}
		if searchLower != "" {
			if !strings.Contains(strings.ToLower(tx.Title), searchLower) &&
				!strings.Contains(strings.ToLower(tx.Category), searchLower) &&
				!strings.Contains(strings.ToLower(tx.AccountPocket), searchLower) {
				continue
			}
		}
		result = append(result, tx)
	}
	return result
}

func (s *Store) AddTransaction(req CreateTransactionRequest) (*Transaction, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	var targetPocketName string
	pocketIndex := -1
	for i, p := range s.data.Pockets {
		if p.ID == req.PocketID {
			pocketIndex = i
			targetPocketName = fmt.Sprintf("%s (%s)", p.ParentAccount, p.Name)
			break
		}
	}

	if pocketIndex != -1 {
		if req.Type == "Pengeluaran" {
			s.data.Pockets[pocketIndex].Balance -= req.Amount
		} else if req.Type == "Pemasukan" {
			s.data.Pockets[pocketIndex].Balance += req.Amount
		}
	} else {
		targetPocketName = "Bank Jago (Makan)"
	}

	newTx := Transaction{
		ID:            fmt.Sprintf("tx_%d", time.Now().UnixMilli()),
		Title:         req.Title,
		Category:      req.Category,
		AccountPocket: targetPocketName,
		Amount:        req.Amount,
		Type:          req.Type,
		DateTime:      time.Now(),
		IsVerified:    true,
	}

	s.data.Transactions = append([]Transaction{newTx}, s.data.Transactions...)
	_ = s.save()
	return &newTx, nil
}

func (s *Store) SetDailyTarget(target float64) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.data.SelectedDailyTarget = target
	_ = s.save()
}

func (s *Store) Reconcile(req ReconcileRequest) (*Transaction, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	targetIdx := -1
	for i, p := range s.data.Pockets {
		if strings.Contains(strings.ToLower(p.ParentAccount), strings.ToLower(req.AccountName)) ||
			strings.Contains(strings.ToLower(p.Name), strings.ToLower(req.AccountName)) {
			targetIdx = i
			break
		}
	}

	if targetIdx == -1 {
		for i, p := range s.data.Pockets {
			if p.ParentAccount == "Bank BRI" {
				targetIdx = i
				break
			}
		}
	}

	diff := req.ActualBalance - s.data.Pockets[targetIdx].Balance
	s.data.Pockets[targetIdx].Balance = req.ActualBalance

	adjTx := Transaction{
		ID:            fmt.Sprintf("adj_%d", time.Now().UnixMilli()),
		Title:         fmt.Sprintf("Penyesuaian Saldo: %s", req.Reason),
		Category:      "Audit",
		AccountPocket: s.data.Pockets[targetIdx].Name,
		Amount:        math.Abs(diff),
		Type:          "Penyesuaian",
		DateTime:      time.Now(),
		IsVerified:    true,
	}

	s.data.Transactions = append([]Transaction{adjTx}, s.data.Transactions...)
	_ = s.save()
	return &adjTx, nil
}

func (s *Store) GetRunwaySummary() RunwaySummary {
	s.mu.RLock()
	defer s.mu.RUnlock()

	var totalAssets, spendableCash, lockedFunds, unpaidObligations float64

	for _, p := range s.data.Pockets {
		totalAssets += p.Balance
		if p.IsSpendable {
			spendableCash += p.Balance
		} else {
			lockedFunds += p.Balance
		}
	}

	for _, o := range s.data.Obligations {
		if !o.IsPaid {
			unpaidObligations += o.Amount
		}
	}

	usableMoney := spendableCash - s.data.ProtectedFloorBRI - unpaidObligations

	var breakEven float64
	if s.data.DaysRemaining > 0 {
		breakEven = usableMoney / float64(s.data.DaysRemaining)
	}

	today := time.Now().Format("2006-01-02")
	var todaySpent float64
	for _, tx := range s.data.Transactions {
		if tx.Type == "Pengeluaran" && tx.DateTime.Format("2006-01-02") == today {
			todaySpent += tx.Amount
		}
	}

	projectedExpensePeriod := float64(s.data.DaysRemaining) * s.data.SelectedDailyTarget
	projectedEndBalance := spendableCash - projectedExpensePeriod - unpaidObligations

	return RunwaySummary{
		TotalAssets:            totalAssets,
		SpendableCash:          spendableCash,
		LockedFunds:            lockedFunds,
		UnpaidObligations:      unpaidObligations,
		ProtectedFloorBRI:      s.data.ProtectedFloorBRI,
		UsableMoney:            usableMoney,
		SelectedDailyTarget:    s.data.SelectedDailyTarget,
		DaysRemaining:          s.data.DaysRemaining,
		BreakEvenDailyRate:     breakEven,
		TodaySpent:             todaySpent,
		TodayQuotaRemaining:    s.data.SelectedDailyTarget - todaySpent,
		ProjectedExpensePeriod: projectedExpensePeriod,
		ProjectedEndBalance:    projectedEndBalance,
		Scenarios:              defaultScenarios,
	}
}

// ParseNaturalLanguage simulates an NLP parser for quick transaction drafting
func ParseNaturalLanguage(text string) ParseAiResponse {
	textLower := strings.ToLower(text)
	amount := 16000.0
	category := "Makanan"
	pocketID := "jago_makan"

	// Match numbers like "16 ribu", "20rb", "50k", or digits
	reRibu := regexp.MustCompile(`(\d+)\s*(ribu|rb|k)`)
	if match := reRibu.FindStringSubmatch(textLower); len(match) > 1 {
		if val, err := strconv.ParseFloat(match[1], 64); err == nil {
			amount = val * 1000
		}
	}

	if strings.Contains(textLower, "kopi") || strings.Contains(textLower, "jajan") || strings.Contains(textLower, "boba") {
		category = "Jajan"
	} else if strings.Contains(textLower, "bensin") || strings.Contains(textLower, "gojek") || strings.Contains(textLower, "grab") {
		category = "Transportasi"
	} else if strings.Contains(textLower, "gym") {
		category = "Gym"
	} else if strings.Contains(textLower, "skincare") {
		category = "Skincare"
	}

	if strings.Contains(textLower, "tunai") || strings.Contains(textLower, "cash") || strings.Contains(textLower, "dompet") {
		pocketID = "cash"
	} else if strings.Contains(textLower, "bri") {
		pocketID = "bri"
	}

	return ParseAiResponse{
		Amount:      amount,
		Description: text,
		Category:    category,
		PocketID:    pocketID,
		Type:        "Pengeluaran",
	}
}
