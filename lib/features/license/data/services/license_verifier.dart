import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:smart_expense/features/license/data/models/license_token_model.dart';

/// Status of license token verification.
enum LicenseVerificationStatus {
  valid,
  invalidSignature,
  expired,
  wrongDevice,
  wrongProduct,
  invalidPayload,
}

/// Result of license token verification.
class LicenseVerificationResult {
  final LicenseVerificationStatus status;
  final String? message;
  final LicenseTokenModel? payload;

  const LicenseVerificationResult({
    required this.status,
    this.message,
    this.payload,
  });

  bool get isValid => status == LicenseVerificationStatus.valid;

  @override
  String toString() =>
      'LicenseVerificationResult(status: $status, message: $message, payload: $payload)';
}

class LicenseVerifier {
  static const String defaultPublicKeyBase64 =
      'HmxcBQo2AksxLXskX4QKueohAL0wqMognErP0oKjc48=';

  /// Expected product identifier for this application.
  static const String defaultProductId = 'wallety_shop';

  final String publicKeyBase64;
  final String expectedProductId;

  LicenseVerifier({
    this.publicKeyBase64 = defaultPublicKeyBase64,
    this.expectedProductId = defaultProductId,
  });

  /// Verifies an Ed25519 signature over [payloadString] using the embedded public key.
  Future<bool> verifySignature({
    required String payloadString,
    required String signatureBase64,
  }) async {
    try {
      final signatureBytes = base64Decode(signatureBase64);
      var keyBytes = base64Decode(publicKeyBase64);

      // If SPKI-wrapped key is provided (44 bytes), extract the raw 32-byte key
      if (keyBytes.length == 44) {
        keyBytes = keyBytes.sublist(12);
      }

      if (keyBytes.length != 32 || signatureBytes.length != 64) {
        return false;
      }

      final algorithm = Ed25519();
      final signature = Signature(
        signatureBytes,
        publicKey: SimplePublicKey(keyBytes, type: KeyPairType.ed25519),
      );

      return await algorithm.verify(
        utf8.encode(payloadString),
        signature: signature,
      );
    } catch (_) {
      return false;
    }
  }

  /// Verifies token from a map containing "payload" and "signature" fields.
  Future<LicenseVerificationResult> verifyTokenMap(
    Map<String, dynamic> tokenMap, {
    String? currentDeviceId,
  }) async {
    final payloadString = tokenMap['payload'] as String?;
    final signatureBase64 = tokenMap['signature'] as String?;

    if (payloadString == null || signatureBase64 == null) {
      return const LicenseVerificationResult(
        status: LicenseVerificationStatus.invalidPayload,
        message: 'Token map must contain "payload" and "signature" strings',
      );
    }

    return verifyToken(
      payloadString: payloadString,
      signatureBase64: signatureBase64,
      currentDeviceId: currentDeviceId,
    );
  }

  /// Verifies the token signature and inspects its payload fields.
  Future<LicenseVerificationResult> verifyToken({
    required String payloadString,
    required String signatureBase64,
    String? currentDeviceId,
  }) async {
    // 1. Verify Ed25519 signature
    final isValidSig = await verifySignature(
      payloadString: payloadString,
      signatureBase64: signatureBase64,
    );

    if (!isValidSig) {
      return const LicenseVerificationResult(
        status: LicenseVerificationStatus.invalidSignature,
        message: 'Invalid signature',
      );
    }

    // 2. Parse and validate JSON payload
    final LicenseTokenModel payload;
    try {
      final decoded = jsonDecode(payloadString);
      if (decoded is! Map<String, dynamic>) {
        return const LicenseVerificationResult(
          status: LicenseVerificationStatus.invalidPayload,
          message: 'Payload is not a JSON object',
        );
      }

      if (!decoded.containsKey('licenseId') ||
          !decoded.containsKey('productId') ||
          !decoded.containsKey('deviceId') ||
          !decoded.containsKey('issuedAt') ||
          !decoded.containsKey('expiresAt')) {
        return const LicenseVerificationResult(
          status: LicenseVerificationStatus.invalidPayload,
          message: 'Missing required payload fields',
        );
      }

      final issuedAt = DateTime.tryParse(decoded['issuedAt']?.toString() ?? '');
      final expiresAt = DateTime.tryParse(
        decoded['expiresAt']?.toString() ?? '',
      );

      if (issuedAt == null || expiresAt == null) {
        return const LicenseVerificationResult(
          status: LicenseVerificationStatus.invalidPayload,
          message: 'Invalid date format in payload',
        );
      }

      payload = LicenseTokenModel(
        licenseId: decoded['licenseId'],
        productId: decoded['productId'].toString(),
        deviceId: decoded['deviceId'].toString(),
        issuedAt: issuedAt,
        expiresAt: expiresAt,
      );
    } catch (e) {
      return LicenseVerificationResult(
        status: LicenseVerificationStatus.invalidPayload,
        message: 'Failed to parse payload: $e',
      );
    }

    // 3. Verify productId
    if (payload.productId != expectedProductId) {
      return LicenseVerificationResult(
        status: LicenseVerificationStatus.wrongProduct,
        message:
            'Product ID mismatch: expected $expectedProductId, got ${payload.productId}',
        payload: payload,
      );
    }

    // 4. Verify deviceId
    if (currentDeviceId != null && payload.deviceId != currentDeviceId) {
      return LicenseVerificationResult(
        status: LicenseVerificationStatus.wrongDevice,
        message:
            'Device ID mismatch: expected $currentDeviceId, got ${payload.deviceId}',
        payload: payload,
      );
    }

    // 5. Verify expiresAt is in the future
    if (!payload.expiresAt.isAfter(DateTime.now())) {
      return LicenseVerificationResult(
        status: LicenseVerificationStatus.expired,
        message: 'License expired at ${payload.expiresAt.toIso8601String()}',
        payload: payload,
      );
    }

    return LicenseVerificationResult(
      status: LicenseVerificationStatus.valid,
      message: 'Token is valid',
      payload: payload,
    );
  }
}
