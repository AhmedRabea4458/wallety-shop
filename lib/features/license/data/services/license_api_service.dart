
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:smart_expense/features/license/data/models/license_token_model.dart';

/// Central configuration presets for the licensing system.
/// Central configuration for the licensing system.
class LicenseConfig {
  LicenseConfig._();

  // Presets for different environments:
  // - Android Emulator uses 10.0.2.2
  // - Desktop (Windows/macOS/Linux) and Web use localhost
  // - Physical devices use local machine LAN IP
  // - Production uses the deployed Render server

  static const String emulatorUrl = 'http://10.0.2.2:3000';
  static const String desktopUrl = 'http://localhost:3000';
  static const String lanUrl = 'http://192.168.1.100:3000';

  static const String productionUrl =
      'https://license-server-ph4w.onrender.com';

 
  static const String baseUrl = productionUrl;

  /// Expected product identifier.
  static const String productId = 'wallety_shop';

  /// Interval in days before re-validating the license with the server.
  static const int revalidationIntervalDays = 7;
}

/// Status of license online activation.
enum LicenseActivationStatus {
  success,
  invalidLicense,
  wrongProduct,
  revokedLicense,
  expiredLicense,
  deviceLimitReached,
  networkError,
  serverError,
  verificationFailed,
  unknownError,
}

/// Result of online license activation.
class LicenseActivationResult {
  final LicenseActivationStatus status;
  final String message;
  final String? licenseKey;
  final String? tokenPayload;
  final String? tokenSignature;
  final LicenseTokenModel? parsedPayload;

  const LicenseActivationResult({
    required this.status,
    required this.message,
    this.licenseKey,
    this.tokenPayload,
    this.tokenSignature,
    this.parsedPayload,
  });

  bool get isSuccess => status == LicenseActivationStatus.success;

  @override
  String toString() =>
      'LicenseActivationResult(status: $status, message: $message)';
}

class LicenseApiService {
  static const String defaultServerUrl = LicenseConfig.baseUrl;
  static const String expectedProductId = LicenseConfig.productId;

  final http.Client _httpClient;
  final String serverUrl;

  LicenseApiService({
    http.Client? httpClient,
    this.serverUrl = defaultServerUrl,
  }) : _httpClient = httpClient ?? http.Client();

  Future<LicenseActivationResult> activate({
    required String licenseKey,
    required String deviceId,
  }) async {
    final trimmedKey = licenseKey.trim();
    if (trimmedKey.isEmpty) {
      return const LicenseActivationResult(
        status: LicenseActivationStatus.invalidLicense,
        message: 'License key cannot be empty.',
      );
    }

    try {
      final cleanBaseUrl =
          serverUrl.endsWith('/')
              ? serverUrl.substring(0, serverUrl.length - 1)
              : serverUrl;
      final uri = Uri.parse('$cleanBaseUrl/activate');

      final response = await _httpClient
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'licenseKey': trimmedKey,
              'productId': expectedProductId,
              'deviceId': deviceId,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 500) {
        return const LicenseActivationResult(
          status: LicenseActivationStatus.serverError,
          message: 'Server error encountered. Please try again later.',
        );
      }

      final dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        return const LicenseActivationResult(
          status: LicenseActivationStatus.serverError,
          message: 'Invalid response format received from server.',
        );
      }

      if (decoded is! Map<String, dynamic>) {
        return const LicenseActivationResult(
          status: LicenseActivationStatus.serverError,
          message: 'Invalid response structure received from server.',
        );
      }

      final success = decoded['success'] == true;
      final serverMessage = decoded['message']?.toString() ?? '';

      if (!success) {
        return _mapServerErrorToResult(serverMessage);
      }

      final tokenData = decoded['token'];
      if (tokenData is! Map<String, dynamic>) {
        return const LicenseActivationResult(
          status: LicenseActivationStatus.serverError,
          message: 'Response is missing token information.',
        );
      }

      final payloadString = tokenData['payload']?.toString();
      final signatureBase64 = tokenData['signature']?.toString();

      if (payloadString == null || signatureBase64 == null) {
        return const LicenseActivationResult(
          status: LicenseActivationStatus.serverError,
          message: 'Malformed token received in server response.',
        );
      }

      return LicenseActivationResult(
        status: LicenseActivationStatus.success,
        message:
            serverMessage.isNotEmpty
                ? serverMessage
                : 'License activated successfully.',
        licenseKey: trimmedKey,
        tokenPayload: payloadString,
        tokenSignature: signatureBase64,
      );
    } on SocketException {
      return const LicenseActivationResult(
        status: LicenseActivationStatus.networkError,
        message:
            'Could not connect to license server. Please check your internet connection.',
      );
    } on HandshakeException {
      return const LicenseActivationResult(
        status: LicenseActivationStatus.networkError,
        message:
            'Could not establish a secure connection to the license server.',
      );
    } on http.ClientException {
      return const LicenseActivationResult(
        status: LicenseActivationStatus.networkError,
        message: 'Network communication error. Please check your connection.',
      );
    } on TimeoutException {
      return const LicenseActivationResult(
        status: LicenseActivationStatus.networkError,
        message: 'Connection timed out. Please try again.',
      );
    } catch (_) {
      return const LicenseActivationResult(
        status: LicenseActivationStatus.unknownError,
        message: 'An unexpected error occurred during activation.',
      );
    }
  }

  LicenseActivationResult _mapServerErrorToResult(String serverMessage) {
    final lower = serverMessage.toLowerCase();
    if (lower.contains('not found') || lower.contains('required')) {
      return LicenseActivationResult(
        status: LicenseActivationStatus.invalidLicense,
        message:
            serverMessage.isNotEmpty ? serverMessage : 'License not found.',
      );
    }
    if (lower.contains('product')) {
      return LicenseActivationResult(
        status: LicenseActivationStatus.wrongProduct,
        message:
            serverMessage.isNotEmpty
                ? serverMessage
                : 'License does not belong to this product.',
      );
    }
    if (lower.contains('not active') || lower.contains('revoked')) {
      return LicenseActivationResult(
        status: LicenseActivationStatus.revokedLicense,
        message:
            serverMessage.isNotEmpty
                ? serverMessage
                : 'License is not active or has been revoked.',
      );
    }
    if (lower.contains('expired')) {
      return LicenseActivationResult(
        status: LicenseActivationStatus.expiredLicense,
        message:
            serverMessage.isNotEmpty ? serverMessage : 'License has expired.',
      );
    }
    if (lower.contains('maximum') || lower.contains('device')) {
      return LicenseActivationResult(
        status: LicenseActivationStatus.deviceLimitReached,
        message:
            serverMessage.isNotEmpty
                ? serverMessage
                : 'Maximum number of devices reached for this license.',
      );
    }
    return LicenseActivationResult(
      status: LicenseActivationStatus.unknownError,
      message: serverMessage.isNotEmpty ? serverMessage : 'Activation failed.',
    );
  }
}
