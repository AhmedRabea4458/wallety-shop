import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_expense/features/sms_import/data/sms_import_processor.dart';

/// Service to handle incoming SMS listening and automatic import via Native MethodChannel.
class SmsListenerService {
  SmsListenerService._() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  static final SmsListenerService instance = SmsListenerService._();

  static const MethodChannel _channel = MethodChannel('com.example.smart_expense/sms');
  static const String _prefsKey = 'sms_listener_enabled';

  final ValueNotifier<bool> isListening = ValueNotifier<bool>(false);
  final SmsImportProcessor _processor = SmsImportProcessor();

  /// Restore saved state on app startup. Call this from init().
  Future<void> restoreState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wasEnabled = prefs.getBool(_prefsKey) ?? false;
      if (wasEnabled) {
        // Re-request permissions and resume listening silently
        final hasPermission = await requestPermissions();
        if (hasPermission) {
          isListening.value = true;
          debugPrint('SmsListenerService: Restored listening state — active');
        } else {
          // Permissions revoked — clear saved state
          await prefs.setBool(_prefsKey, false);
          debugPrint('SmsListenerService: Could not restore — permissions denied');
        }
      }
    } catch (e) {
      debugPrint('SmsListenerService: Error restoring state: $e');
    }
  }

  /// Persist current listening state to SharedPreferences.
  Future<void> _saveState(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, enabled);
    } catch (e) {
      debugPrint('SmsListenerService: Error saving state: $e');
    }
  }

  /// Handle native calls from Android
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onSmsReceived') {
      final arguments = call.arguments;
      if (arguments is Map) {
        final sender = arguments['sender']?.toString() ?? 'Unknown';
        final body = arguments['body']?.toString() ?? '';
        final timestamp = arguments['timestamp'];
        final date = timestamp is int
            ? DateTime.fromMillisecondsSinceEpoch(timestamp)
            : DateTime.now();

        _onSmsReceived(sender, body, date);
      }
    }
  }

  /// Request SMS permissions at runtime via Native Android
  Future<bool> requestPermissions() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('requestPermissions');
      return result ?? false;
    } catch (e) {
      debugPrint('SmsListenerService error requesting permissions: $e');
      return false;
    }
  }

  /// Start listening for incoming SMS messages
  Future<bool> startListening() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        debugPrint('SmsListenerService: SMS permissions not granted');
        return false;
      }

      isListening.value = true;
      await _saveState(true);
      debugPrint('SmsListenerService: SMS listener started successfully');
      return true;
    } catch (e) {
      debugPrint('SmsListenerService error starting listener: $e');
      return false;
    }
  }

  /// Stop/pause processing incoming SMS messages
  Future<void> stopListening() async {
    isListening.value = false;
    await _saveState(false);
    debugPrint('SmsListenerService: SMS listener paused');
  }

  /// Toggle listener status
  Future<bool> toggleListening() async {
    if (isListening.value) {
      await stopListening();
      return false;
    } else {
      return await startListening();
    }
  }

  /// Handle incoming SMS message
  void _onSmsReceived(String sender, String body, DateTime date) async {
    if (!isListening.value) return;

    debugPrint('================= [SMS RECEIVED] =================');
    debugPrint('Sender: $sender');
    debugPrint('Body: $body');
    debugPrint('Date/Time: $date');
    debugPrint('==================================================');

    try {
      // Process incoming SMS for financial transaction
      await _processor.processIncomingSms(
        sender: sender,
        body: body,
        receivedAt: date,
      );
    } catch (e) {
      debugPrint('SmsListenerService: Error processing incoming SMS: $e');
    }
  }

  /// Method to manually import recent SMS from the phone's inbox via Native MethodChannel
  Future<int> importRecentSms({int count = 10}) async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) return 0;

      final dynamic rawMessages = await _channel.invokeMethod('getInboxSms', {'count': count});
      if (rawMessages is! List) return 0;

      int importedCount = 0;
      for (final raw in rawMessages) {
        if (raw is Map) {
          final sender = raw['sender']?.toString() ?? '';
          final body = raw['body']?.toString() ?? '';
          final timestamp = raw['timestamp'];
          final date = timestamp is int
              ? DateTime.fromMillisecondsSinceEpoch(timestamp)
              : DateTime.now();

          if (body.isNotEmpty) {
            final res = await _processor.processIncomingSms(
              sender: sender,
              body: body,
              receivedAt: date,
            );
            if (res != null) {
              importedCount++;
            }
          }
        }
      }
      return importedCount;
    } catch (e) {
      debugPrint('SmsListenerService importRecentSms error: $e');
      return 0;
    }
  }
}
