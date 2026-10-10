import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/app_state.dart';

class ApiService {
  // Production Google Cloud Run backend URL
  static const String cloudRunBaseUrl = 'https://app-jaga-uang-git-95763364095.asia-southeast2.run.app/api';
  
  static String? customBaseUrl;
  static const Duration _timeout = Duration(seconds: 15);

  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    return cloudRunBaseUrl;
  }

  static Future<Map<String, dynamic>?> fetchRunway() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/runway')).timeout(_timeout);
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('ApiService fetchRunway error: $e');
    }
    return null;
  }

  static Future<List<Pocket>?> fetchPockets() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/pockets')).timeout(_timeout);
      if (res.statusCode == 200) {
        final List list = json.decode(res.body);
        return list.map((item) => Pocket(
          id: item['id'],
          name: item['name'],
          balance: (item['balance'] as num).toDouble(),
          isSpendable: item['isSpendable'] ?? true,
          parentAccount: item['parentAccount'] ?? '',
          subtitle: item['subtitle'] ?? '',
        )).toList();
      }
    } catch (e) {
      debugPrint('ApiService fetchPockets error: $e');
    }
    return null;
  }

  static Future<List<Obligation>?> fetchObligations() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/obligations')).timeout(_timeout);
      if (res.statusCode == 200) {
        final List list = json.decode(res.body);
        return list.map((item) => Obligation(
          id: item['id'],
          title: item['title'],
          dueDate: item['dueDate'],
          amount: (item['amount'] as num).toDouble(),
          sourcePocket: item['sourcePocket'] ?? '',
          isPaid: item['isPaid'] ?? false,
        )).toList();
      }
    } catch (e) {
      debugPrint('ApiService fetchObligations error: $e');
    }
    return null;
  }

  static Future<bool> toggleObligation(String id) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/obligations/$id/toggle')).timeout(_timeout);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService toggleObligation error: $e');
      return false;
    }
  }

  static Future<List<TransactionItem>?> fetchTransactions({String? type, String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (type != null && type.isNotEmpty && type != 'Semua') queryParams['type'] = type;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/transactions').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final res = await http.get(uri).timeout(_timeout);
      if (res.statusCode == 200) {
        final List list = json.decode(res.body);
        return list.map((item) => TransactionItem(
          id: item['id'],
          title: item['title'],
          category: item['category'],
          accountPocket: item['accountPocket'],
          amount: (item['amount'] as num).toDouble(),
          type: item['type'],
          dateTime: DateTime.tryParse(item['dateTime'] ?? '') ?? DateTime.now(),
          isVerified: item['isVerified'] ?? true,
        )).toList();
      }
    } catch (e) {
      debugPrint('ApiService fetchTransactions error: $e');
    }
    return null;
  }

  static Future<TransactionItem?> createTransaction({
    required String title,
    required String category,
    required String pocketId,
    required double amount,
    required String type,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'category': category,
          'pocketId': pocketId,
          'amount': amount,
          'type': type,
        }),
      ).timeout(_timeout);

      if (res.statusCode == 201) {
        final item = json.decode(res.body);
        return TransactionItem(
          id: item['id'],
          title: item['title'],
          category: item['category'],
          accountPocket: item['accountPocket'],
          amount: (item['amount'] as num).toDouble(),
          type: item['type'],
          dateTime: DateTime.tryParse(item['dateTime'] ?? '') ?? DateTime.now(),
          isVerified: item['isVerified'] ?? true,
        );
      }
    } catch (e) {
      debugPrint('ApiService createTransaction error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> parseAi(String text) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/transactions/parse-ai'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': text}),
      ).timeout(_timeout);

      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('ApiService parseAi error: $e');
    }
    return null;
  }

  static Future<bool> setDailyTarget(double target) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/runway/scenario'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'targetAmount': target}),
      ).timeout(_timeout);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService setDailyTarget error: $e');
      return false;
    }
  }

  static Future<bool> reconcile({
    required String accountName,
    required double actualBalance,
    required String reason,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/reconciliation'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'accountName': accountName,
          'actualBalance': actualBalance,
          'reason': reason,
        }),
      ).timeout(_timeout);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService reconcile error: $e');
      return false;
    }
  }

  static Future<AiModelsFetchResult> fetchAiModels({
    required String endpoint,
    required String apiKey,
  }) async {
    final cleanEndpoint = endpoint.trim().replaceAll(RegExp(r'/+$'), '');
    try {
      // First try directly calling the router
      final uri = Uri.parse('$cleanEndpoint/models');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${apiKey.trim()}',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeout);

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          final List list = decoded['data'];
          final modelIds = list
              .map((item) => item['id']?.toString() ?? '')
              .where((id) => id.isNotEmpty)
              .toList();
          if (modelIds.isNotEmpty) {
            return AiModelsFetchResult(models: modelIds, isSuccess: true);
          }
        }
      }

      // If direct call returned non-200, try via Go backend proxy
      final proxyRes = await http.post(
        Uri.parse('$baseUrl/ai/models'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'endpoint': cleanEndpoint, 'apiKey': apiKey.trim()}),
      ).timeout(_timeout);

      if (proxyRes.statusCode == 200) {
        final decoded = json.decode(proxyRes.body);
        if (decoded['models'] != null && (decoded['models'] as List).isNotEmpty) {
          final List list = decoded['models'];
          return AiModelsFetchResult(
            models: list.map((e) => e.toString()).toList(),
            isSuccess: true,
          );
        }
        if (decoded['error'] != null && decoded['error'].toString().isNotEmpty) {
          return AiModelsFetchResult(
            models: [],
            isSuccess: false,
            errorMessage: decoded['error'].toString(),
          );
        }
      }

      if (res.statusCode != 200) {
        try {
          final errBody = json.decode(res.body);
          final msg = errBody['error']?.toString() ?? 'HTTP ${res.statusCode}';
          return AiModelsFetchResult(models: [], isSuccess: false, errorMessage: msg);
        } catch (_) {
          return AiModelsFetchResult(models: [], isSuccess: false, errorMessage: 'HTTP ${res.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('ApiService fetchAiModels error: $e');
      return AiModelsFetchResult(models: [], isSuccess: false, errorMessage: e.toString());
    }
    return AiModelsFetchResult(models: [], isSuccess: false, errorMessage: 'Tidak ada model ditemukan');
  }

  static Future<Map<String, dynamic>?> parseWithRouter({
    required String endpoint,
    required String apiKey,
    required String model,
    required String text,
  }) async {
    final cleanEndpoint = endpoint.trim().replaceAll(RegExp(r'/+$'), '');

    // First try direct router call
    try {
      final uri = Uri.parse('$cleanEndpoint/chat/completions');
      final res = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${apiKey.trim()}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': 'Kamu adalah parser transaksi keuangan aplikasi JagaUang Indonesia. '
                  'Kembalikan HANYA JSON murni tanpa markdown, tanpa backtick, persis format berikut:\n'
                  '{"amount": 16000, "description": "Ketoprak siang", "category": "Makanan", "pocketId": "jago_makan", "type": "Pengeluaran"}\n'
                  'Pilihan category: Makanan, Jajan, Kebutuhan, Transportasi, Keluarga, Gym, Skincare, Lain-lain.\n'
                  'Pilihan pocketId: jago_makan, jago_skincare, jago_gym, jago_keluarga, cash, bri, stockbit.\n'
                  'Pilihan type: Pengeluaran, Pemasukan.',
            },
            {
              'role': 'user',
              'content': text,
            }
          ],
          'temperature': 0.1,
        }),
      ).timeout(_timeout);

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final content = decoded['choices']?[0]?['message']?['content']?.toString() ?? '';
        final cleanContent = content
            .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
            .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
            .replaceAll('```', '')
            .trim();
        final jsonResult = json.decode(cleanContent);
        if (jsonResult is Map<String, dynamic> && (jsonResult['amount'] as num?) != null) {
          return jsonResult;
        }
      }
    } catch (e) {
      debugPrint('ApiService parseWithRouter direct error: $e');
    }

    // Try Go backend with router payload
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/transactions/parse-ai'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': text,
          'endpoint': cleanEndpoint,
          'apiKey': apiKey.trim(),
          'model': model,
        }),
      ).timeout(_timeout);

      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('ApiService parseWithRouter proxy error: $e');
    }

    // Final fallback: standard Go parseAi
    return parseAi(text);
  }
}

class AiModelsFetchResult {
  final List<String> models;
  final bool isSuccess;
  final String? errorMessage;

  AiModelsFetchResult({
    required this.models,
    required this.isSuccess,
    this.errorMessage,
  });
}
