import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_expense/features/sms_import/domain/models/sms_record.dart';

class SmsStorageService {
  static const String _storageKey = 'wallety_imported_sms_records';
  static final SmsStorageService instance = SmsStorageService._();

  SmsStorageService._();

  final ValueNotifier<List<SmsRecord>> recordsNotifier =
      ValueNotifier<List<SmsRecord>>([]);
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await loadRecords();
    _isInitialized = true;
  }

  Future<List<SmsRecord>> loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        recordsNotifier.value = [];
        return [];
      }

      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      final list = decoded
          .map((item) => SmsRecord.fromJson(item as Map<String, dynamic>))
          .toList();
      recordsNotifier.value = list;
      return list;
    } catch (e) {
      debugPrint('SmsStorageService loadRecords error: $e');
      recordsNotifier.value = [];
      return [];
    }
  }

  Future<void> saveRecord(SmsRecord record) async {
    try {
      final current = List<SmsRecord>.from(recordsNotifier.value);
      // If already exists with same id, replace it; else prepend
      final index = current.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        current[index] = record;
      } else {
        current.insert(0, record);
      }

      recordsNotifier.value = current;
      await _persist(current);
    } catch (e) {
      debugPrint('SmsStorageService saveRecord error: $e');
    }
  }

  Future<void> updateRecord(SmsRecord record) async {
    await saveRecord(record);
  }

  Future<bool> isDuplicate({String? referenceNumber, required String fingerprint}) async {
    final current = recordsNotifier.value.isEmpty
        ? await loadRecords()
        : recordsNotifier.value;

    if (referenceNumber != null && referenceNumber.trim().isNotEmpty) {
      final hasRef = current.any((r) =>
          r.referenceNumber != null &&
          r.referenceNumber!.trim() == referenceNumber.trim());
      if (hasRef) return true;
    }

    return current.any((r) => r.id == fingerprint);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    recordsNotifier.value = [];
  }

  Future<void> _persist(List<SmsRecord> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((r) => r.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  static String generateFingerprint(
    String sender,
    String body,
    DateTime receivedAt,
  ) {
    final normalized = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    return 'fp_${sender.trim()}_${normalized.hashCode}_${receivedAt.millisecondsSinceEpoch}';
  }
}
