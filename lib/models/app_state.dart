import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class Pocket {
  final String id;
  final String name;
  double balance;
  final bool isSpendable;
  final String parentAccount;
  final String subtitle;

  Pocket({
    required this.id,
    required this.name,
    required this.balance,
    this.isSpendable = true,
    required this.parentAccount,
    this.subtitle = '',
  });
}

class Obligation {
  final String id;
  final String title;
  final String dueDate;
  final double amount;
  final String sourcePocket;
  bool isPaid;

  Obligation({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.amount,
    required this.sourcePocket,
    this.isPaid = false,
  });
}

class TransactionItem {
  final String id;
  final String title;
  final String category;
  final String accountPocket;
  final double amount;
  final String type; // 'Pengeluaran', 'Pemasukan', 'Transfer', 'Penyesuaian', 'Reimburse'
  final DateTime dateTime;
  final bool isVerified;

  TransactionItem({
    required this.id,
    required this.title,
    required this.category,
    required this.accountPocket,
    required this.amount,
    required this.type,
    required this.dateTime,
    this.isVerified = true,
  });
}

class DailyScenario {
  final double amount;
  final String label;
  final String description;
  final String badgeText;

  const DailyScenario({
    required this.amount,
    required this.label,
    required this.description,
    required this.badgeText,
  });
}

class AppState extends ChangeNotifier {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static String formatRupiah(double amount) {
    return _currencyFormat.format(amount).replaceAll(' ', '');
  }

  // Pockets & Accounts
  final List<Pocket> pockets = [
    Pocket(
      id: 'jago_makan',
      name: 'Kantong Makan',
      balance: 597500,
      parentAccount: 'Bank Jago',
      subtitle: 'Tersedia harian',
    ),
    Pocket(
      id: 'jago_skincare',
      name: 'Kantong Skincare',
      balance: 325800,
      parentAccount: 'Bank Jago',
      subtitle: 'Sisa Rp112.300 pasca komitmen',
    ),
    Pocket(
      id: 'jago_gym',
      name: 'Kantong Gym',
      balance: 150000,
      parentAccount: 'Bank Jago',
      subtitle: 'Direservasi untuk Gym',
    ),
    Pocket(
      id: 'jago_keluarga',
      name: 'Kantong Keluarga',
      balance: 86500,
      parentAccount: 'Bank Jago',
      subtitle: 'Direservasi untuk Keluarga',
    ),
    Pocket(
      id: 'cash',
      name: 'Kas Tunai (Dompet Fisik)',
      balance: 50000,
      parentAccount: 'Dompet Tunai',
      subtitle: 'Uang fisik darurat',
    ),
    Pocket(
      id: 'bri',
      name: 'Bank BRI',
      balance: 552755,
      parentAccount: 'Bank BRI',
      subtitle: 'Protected Floor Rp50.000',
    ),
    Pocket(
      id: 'stockbit',
      name: 'Stockbit (Portofolio)',
      balance: 28206,
      isSpendable: false,
      parentAccount: 'Stockbit',
      subtitle: 'Portofolio Saham/Reksadana',
    ),
  ];

  // Obligations
  final List<Obligation> obligations = [
    Obligation(
      id: 'gym',
      title: 'Biaya Gym Bulanan',
      dueDate: '15 Okt',
      amount: 150000,
      sourcePocket: 'Jago Gym (Rp150.000)',
      isPaid: false,
    ),
    Obligation(
      id: 'keluarga',
      title: 'Dukungan Keluarga',
      dueDate: '20 Okt',
      amount: 300000,
      sourcePocket: 'Jago Keluarga (Rp86.500) + Skincare (Rp213.500)',
      isPaid: false,
    ),
  ];

  // Daily Scenarios
  final List<DailyScenario> scenarios = const [
    DailyScenario(
      amount: 15000,
      label: 'Rp15.000 / hari — Ultra Hemat',
      description: 'Prioritas menjaga runway stabil hingga akhir bulan.',
      badgeText: 'Aman',
    ),
    DailyScenario(
      amount: 20000,
      label: 'Rp20.000 / hari — Hemat',
      description: 'Ruang ekstra untuk jajan ringan sesekali.',
      badgeText: 'Aman',
    ),
    DailyScenario(
      amount: 30000,
      label: 'Rp30.000 / hari — Moderat',
      description: 'Pengeluaran standar tanpa penghematan ketat.',
      badgeText: 'Waspada',
    ),
    DailyScenario(
      amount: 50000,
      label: 'Rp50.000 / hari — Bebas Terkendali',
      description: 'Batas maksimum sebelum menyentuh cadangan darurat.',
      badgeText: 'Batas Kritis',
    ),
  ];

  double selectedDailyTarget = 15000;
  int daysRemaining = 22;
  double protectedFloorBRI = 50000;

  // 9Router & AI Configuration
  String aiEndpoint = 'https://9router.npaujiana.tech/v1';
  String aiApiKey = 'sk-00ffe5fd244dbeca-jl72jn-4327b226';
  String aiSelectedModel = 'ag/gemini-3.8-flash';
  List<String> aiAvailableModels = [
    'ag/gemini-3.8-flash',
    'ag/gemini-3.7-flash',
    'ag/gemini-3-flash',
    'ag/claude-sonnet-4-6',
    'cbai/deepseek-v4.1-flash',
    'kr/claude-sonnet-4.5',
    'kr/deepseek-3.2',
  ];
  bool isAiLoadingModels = false;
  String? aiLastRefreshStatus;

  // Transactions History
  final List<TransactionItem> transactions = [
    TransactionItem(
      id: 'tx_1',
      title: 'Makan Siang Warteg',
      category: 'Makanan',
      accountPocket: 'Bank Jago (Makan)',
      amount: 15000,
      type: 'Pengeluaran',
      dateTime: DateTime(2026, 10, 10, 12, 45),
      isVerified: true,
    ),
    TransactionItem(
      id: 'tx_2',
      title: 'Kopi Hitam Pagi',
      category: 'Jajan',
      accountPocket: 'Bank Jago (Makan)',
      amount: 10000,
      type: 'Pengeluaran',
      dateTime: DateTime(2026, 10, 10, 8, 15),
      isVerified: true,
    ),
    TransactionItem(
      id: 'tx_3',
      title: 'Nasi Padang Bungkus',
      category: 'Makanan',
      accountPocket: 'Kas Tunai',
      amount: 14000,
      type: 'Pengeluaran',
      dateTime: DateTime(2026, 10, 9, 13, 0),
      isVerified: true,
    ),
    TransactionItem(
      id: 'tx_4',
      title: 'Gaji / Transfer Masuk',
      category: 'Pendapatan',
      accountPocket: 'Bank BRI',
      amount: 1500000,
      type: 'Pemasukan',
      dateTime: DateTime(2026, 10, 8, 9, 0),
      isVerified: true,
    ),
  ];

  // Calculated Getters
  double get totalAssets {
    return pockets.fold(0.0, (sum, p) => sum + p.balance);
  }

  double get spendableCash {
    return pockets
        .where((p) => p.isSpendable)
        .fold(0.0, (sum, p) => sum + p.balance);
  }

  double get lockedFunds {
    return pockets
        .where((p) => !p.isSpendable)
        .fold(0.0, (sum, p) => sum + p.balance);
  }

  double get unpaidObligations {
    return obligations
        .where((o) => !o.isPaid)
        .fold(0.0, (sum, o) => sum + o.amount);
  }

  double get usableMoney {
    return spendableCash - protectedFloorBRI - unpaidObligations;
  }

  double get breakEvenDailyRate {
    if (daysRemaining <= 0) return 0;
    return usableMoney / daysRemaining;
  }

  double get projectedExpensePeriod {
    return daysRemaining * selectedDailyTarget;
  }

  double get projectedEndBalance {
    return spendableCash - projectedExpensePeriod - unpaidObligations;
  }

  double get todaySpent {
    final now = DateTime(2026, 10, 10);
    return transactions
        .where((tx) =>
            tx.type == 'Pengeluaran' &&
            tx.dateTime.year == now.year &&
            tx.dateTime.month == now.month &&
            tx.dateTime.day == now.day)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get todayQuotaRemaining {
    return selectedDailyTarget - todaySpent;
  }

  // Actions & Backend Sync
  Future<void> syncFromBackend() async {
    final runway = await ApiService.fetchRunway();
    if (runway != null) {
      if (runway['selectedDailyTarget'] != null) {
        selectedDailyTarget = (runway['selectedDailyTarget'] as num).toDouble();
      }
      if (runway['daysRemaining'] != null) {
        daysRemaining = runway['daysRemaining'] as int;
      }
      if (runway['protectedFloorBRI'] != null) {
        protectedFloorBRI = (runway['protectedFloorBRI'] as num).toDouble();
      }
    }

    final serverPockets = await ApiService.fetchPockets();
    if (serverPockets != null && serverPockets.isNotEmpty) {
      pockets.clear();
      pockets.addAll(serverPockets);
    }

    final serverObligations = await ApiService.fetchObligations();
    if (serverObligations != null && serverObligations.isNotEmpty) {
      obligations.clear();
      obligations.addAll(serverObligations);
    }

    final serverTxs = await ApiService.fetchTransactions();
    if (serverTxs != null && serverTxs.isNotEmpty) {
      transactions.clear();
      transactions.addAll(serverTxs);
    }

    notifyListeners();
  }

  void setDailyTarget(double newTarget) {
    selectedDailyTarget = newTarget;
    notifyListeners();
    ApiService.setDailyTarget(newTarget);
  }

  void toggleObligationPaid(String id) {
    final index = obligations.indexWhere((o) => o.id == id);
    if (index != -1) {
      obligations[index].isPaid = !obligations[index].isPaid;
      notifyListeners();
      ApiService.toggleObligation(id);
    }
  }

  void addTransaction({
    required String title,
    required String category,
    required String pocketId,
    required double amount,
    required String type,
    DateTime? customDateTime,
  }) {
    // Deduct or add to pocket balance locally
    final pocketIndex = pockets.indexWhere((p) => p.id == pocketId);
    if (pocketIndex != -1) {
      if (type == 'Pengeluaran') {
        pockets[pocketIndex].balance -= amount;
      } else if (type == 'Pemasukan') {
        pockets[pocketIndex].balance += amount;
      }
    }

    final pocketName = pocketIndex != -1
        ? '${pockets[pocketIndex].parentAccount} (${pockets[pocketIndex].name})'
        : 'Bank Jago (Makan)';

    transactions.insert(
      0,
      TransactionItem(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        category: category,
        accountPocket: pocketName,
        amount: amount,
        type: type,
        dateTime: customDateTime ?? DateTime.now(),
        isVerified: true,
      ),
    );

    notifyListeners();

    // Async sync with Golang backend
    ApiService.createTransaction(
      title: title,
      category: category,
      pocketId: pocketId,
      amount: amount,
      type: type,
    );
  }

  void reconcileAccount({
    required String accountName,
    required double actualBalance,
    required String reason,
  }) {
    final target = pockets.firstWhere(
      (p) => p.name.contains(accountName) || p.parentAccount.contains(accountName),
      orElse: () => pockets.firstWhere((p) => p.parentAccount == 'Bank BRI'),
    );

    final diff = actualBalance - target.balance;
    target.balance = actualBalance;

    transactions.insert(
      0,
      TransactionItem(
        id: 'adj_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Penyesuaian Saldo: $reason',
        category: 'Audit',
        accountPocket: target.name,
        amount: diff.abs(),
        type: 'Penyesuaian',
        dateTime: DateTime.now(),
        isVerified: true,
      ),
    );

    notifyListeners();

    // Async sync with Golang backend
    ApiService.reconcile(
      accountName: accountName,
      actualBalance: actualBalance,
      reason: reason,
    );
  }

  void updateAiConfig({
    String? endpoint,
    String? apiKey,
    String? selectedModel,
  }) {
    if (endpoint != null) aiEndpoint = endpoint.trim();
    if (apiKey != null) aiApiKey = apiKey.trim();
    if (selectedModel != null) aiSelectedModel = selectedModel.trim();
    notifyListeners();
  }

  Future<AiModelsFetchResult> refreshAiModels() async {
    isAiLoadingModels = true;
    aiLastRefreshStatus = null;
    notifyListeners();

    final result = await ApiService.fetchAiModels(
      endpoint: aiEndpoint,
      apiKey: aiApiKey,
    );

    isAiLoadingModels = false;
    if (result.isSuccess && result.models.isNotEmpty) {
      aiAvailableModels = result.models;
      if (!aiAvailableModels.contains(aiSelectedModel)) {
        aiSelectedModel = aiAvailableModels.first;
      }
      aiLastRefreshStatus = 'Berhasil memuat ${result.models.length} model!';
    } else {
      aiLastRefreshStatus = result.errorMessage ?? 'Gagal memuat model';
    }
    notifyListeners();
    return result;
  }
}
