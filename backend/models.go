package main

import "time"

// ponytail: straightforward domain structs without bloated DTO layers

type Pocket struct {
	ID            string  `json:"id"`
	Name          string  `json:"name"`
	Balance       float64 `json:"balance"`
	IsSpendable   bool    `json:"isSpendable"`
	ParentAccount string  `json:"parentAccount"`
	Subtitle      string  `json:"subtitle"`
}

type Obligation struct {
	ID           string  `json:"id"`
	Title        string  `json:"title"`
	DueDate      string  `json:"dueDate"`
	Amount       float64 `json:"amount"`
	SourcePocket string  `json:"sourcePocket"`
	IsPaid       bool    `json:"isPaid"`
}

type Transaction struct {
	ID            string    `json:"id"`
	Title         string    `json:"title"`
	Category      string    `json:"category"`
	AccountPocket string    `json:"accountPocket"`
	Amount        float64   `json:"amount"`
	Type          string    `json:"type"` // Pengeluaran, Pemasukan, Transfer, Penyesuaian, Reimburse
	DateTime      time.Time `json:"dateTime"`
	IsVerified    bool      `json:"isVerified"`
}

type DailyScenario struct {
	Amount      float64 `json:"amount"`
	Label       string  `json:"label"`
	Description string  `json:"description"`
	BadgeText   string  `json:"badgeText"`
}

type RunwaySummary struct {
	TotalAssets            float64         `json:"totalAssets"`
	SpendableCash          float64         `json:"spendableCash"`
	LockedFunds            float64         `json:"lockedFunds"`
	UnpaidObligations      float64         `json:"unpaidObligations"`
	ProtectedFloorBRI      float64         `json:"protectedFloorBRI"`
	UsableMoney            float64         `json:"usableMoney"`
	SelectedDailyTarget    float64         `json:"selectedDailyTarget"`
	DaysRemaining          int             `json:"daysRemaining"`
	BreakEvenDailyRate     float64         `json:"breakEvenDailyRate"`
	TodaySpent             float64         `json:"todaySpent"`
	TodayQuotaRemaining    float64         `json:"todayQuotaRemaining"`
	ProjectedExpensePeriod float64         `json:"projectedExpensePeriod"`
	ProjectedEndBalance    float64         `json:"projectedEndBalance"`
	Scenarios              []DailyScenario `json:"scenarios"`
}

type ParseAiRequest struct {
	Text string `json:"text"`
}

type ParseAiResponse struct {
	Amount      float64 `json:"amount"`
	Description string  `json:"description"`
	Category    string  `json:"category"`
	PocketID    string  `json:"pocketId"`
	Type        string  `json:"type"`
}

type CreateTransactionRequest struct {
	Title    string  `json:"title"`
	Category string  `json:"category"`
	PocketID string  `json:"pocketId"`
	Amount   float64 `json:"amount"`
	Type     string  `json:"type"`
}

type ReconcileRequest struct {
	AccountName   string  `json:"accountName"`
	ActualBalance float64 `json:"actualBalance"`
	Reason        string  `json:"reason"`
}

type SetTargetRequest struct {
	TargetAmount float64 `json:"targetAmount"`
}
