import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:smart_expense/features/license/data/models/license_token_model.dart';
import 'package:smart_expense/features/license/data/services/license_api_service.dart';
import 'package:smart_expense/features/license/data/services/license_storage.dart';
import 'package:smart_expense/features/license/data/services/license_verifier.dart';

enum LicenseState {
  valid,
  unlicensed,
  expired,
  invalidSignature,
  wrongDevice,
  wrongProduct,
}

class LicenseValidationResult {
  final LicenseState state;
  final String message;
  final LicenseTokenModel? payload;
  final bool isOfflineAllowed;

  const LicenseValidationResult({
    required this.state,
    required this.message,
    this.payload,
    this.isOfflineAllowed = false,
  });

  bool get isValid => state == LicenseState.valid;

  @override
  String toString() =>
      'LicenseValidationResult(state: $state, message: $message, isOfflineAllowed: $isOfflineAllowed)';
}

class LicenseManager {
  final LicenseStorage _storage;
  final LicenseApiService _apiService;
  final LicenseVerifier _verifier;
  final DeviceInfoPlugin _deviceInfoPlugin;
  final int revalidationIntervalDays;

  LicenseManager({
    required LicenseStorage storage,
    required LicenseApiService apiService,
    required LicenseVerifier verifier,
    DeviceInfoPlugin? deviceInfoPlugin,
    this.revalidationIntervalDays = LicenseConfig.revalidationIntervalDays,
  }) : _storage = storage,
       _apiService = apiService,
       _verifier = verifier,
       _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        final parts = [
          androidInfo.brand,
          androidInfo.model,
          androidInfo.id,
        ].where((s) => s.isNotEmpty).join('_');
        return parts.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfoPlugin.windowsInfo;
        return windowsInfo.deviceId
            .replaceAll(RegExp(r'[{}]'), '')
            .toLowerCase();
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor ?? 'ios_unknown';
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfoPlugin.linuxInfo;
        return linuxInfo.machineId ?? 'linux_unknown';
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfoPlugin.macOsInfo;
        return macInfo.systemGUID ?? 'macos_unknown';
      }
    } catch (_) {
      // Fallback in case platform querying is unsupported
    }
    return 'unknown_device';
  }

  /// Validates the local license with offline support and periodic server revalidation.
  ///
  /// Flow:
  /// 1. Check if licenseKey, payload, and signature exist locally in secure storage.
  /// 2. If missing -> returns [LicenseState.unlicensed].
  /// 3. Locally verify the cryptographic Ed25519 signature, product ID, device ID, and expiry.
  /// 4. If invalid -> clear local storage and return specific failure state.
  /// 5. Check if periodic server revalidation is due (7 days).
  /// 6. If not due -> allow instant startup.
  /// 7. If due -> attempt online revalidation:
  ///    - On success: updates local token & lastValidatedAt.
  ///    - On explicit server rejection (revoked, expired, limit, not found): clears local storage & denies access.
  ///    - On network/server failure: fallback to allow offline use since local token is still valid.
  Future<LicenseValidationResult> validateLicense({
    bool forceServerCheck = false,
    String? customDeviceId,
  }) async {
    final licenseKey = await _storage.getLicenseKey();
    final tokenPayload = await _storage.getTokenPayload();
    final tokenSignature = await _storage.getTokenSignature();

    if (licenseKey == null ||
        licenseKey.isEmpty ||
        tokenPayload == null ||
        tokenPayload.isEmpty ||
        tokenSignature == null ||
        tokenSignature.isEmpty) {
      return const LicenseValidationResult(
        state: LicenseState.unlicensed,
        message: 'يرجى إدخال مفتاح الترخيص لتفعيل التطبيق',
      );
    }

    final currentDeviceId = customDeviceId ?? await getDeviceId();

    // Local cryptographic & structural verification
    final localResult = await _verifier.verifyToken(
      payloadString: tokenPayload,
      signatureBase64: tokenSignature,
      currentDeviceId: currentDeviceId,
    );

    if (!localResult.isValid) {
      final state = _mapVerificationStatus(localResult.status);
      // If tampered or invalid, clear local license
      if (state == LicenseState.invalidSignature ||
          state == LicenseState.wrongProduct) {
        await _storage.clear();
      }
      return LicenseValidationResult(
        state: state,
        message: getArabicMessage(state),
        payload: localResult.payload,
      );
    }

    // Check periodic revalidation & maximum offline grace period (7 days)
    // The 7-day counter is strictly measured from the last successful server check.
    final lastValidatedAt = await _storage.getLastValidatedAt();
    final now = DateTime.now();

    final bool isGracePeriodExpired;
    if (lastValidatedAt == null) {
      isGracePeriodExpired = true;
    } else if (now.isBefore(lastValidatedAt)) {
      // Clock was moved backwards into the past
      isGracePeriodExpired = true;
    } else {
      final dateNow = DateTime(now.year, now.month, now.day);
      final dateValidated = DateTime(
        lastValidatedAt.year,
        lastValidatedAt.month,
        lastValidatedAt.day,
      );
      final calendarDaysPassed = dateNow.difference(dateValidated).inDays;
      final durationPassed = now.difference(lastValidatedAt);
      isGracePeriodExpired =
          calendarDaysPassed >= revalidationIntervalDays ||
          durationPassed >= Duration(days: revalidationIntervalDays);
    }
    final isRevalidationDue = forceServerCheck || isGracePeriodExpired;

    if (!isRevalidationDue) {
      return LicenseValidationResult(
        state: LicenseState.valid,
        message: 'الترخيص سارٍ وتم التحقق منه محلياً',
        payload: localResult.payload,
        isOfflineAllowed: true,
      );
    }

    // Revalidation is due -> attempt server validation
    try {
      final activationResult = await activateLicense(
        licenseKey,
        customDeviceId: currentDeviceId,
      );

      if (activationResult.isSuccess) {
        return LicenseValidationResult(
          state: LicenseState.valid,
          message: 'تم التحقق من الترخيص وتحديثه بنجاح',
          payload: activationResult.parsedPayload ?? localResult.payload,
        );
      }

      // If server or network issue:
      // If grace period has expired (> 7 days), offline usage is no longer allowed.
      if (activationResult.status == LicenseActivationStatus.networkError ||
          activationResult.status == LicenseActivationStatus.serverError ||
          activationResult.status == LicenseActivationStatus.unknownError) {
        if (isGracePeriodExpired) {
          return LicenseValidationResult(
            state: LicenseState.expired,
            message:
                'انتهت مهلة الاستخدام بدون إنترنت (7 أيام)، يرجى الاتصال بالإنترنت لتأكيد الترخيص',
            payload: localResult.payload,
            isOfflineAllowed: false,
          );
        }
        return LicenseValidationResult(
          state: LicenseState.valid,
          message: 'تعذر الاتصال بالخادم، تم السماح بالاستخدام بدون إنترنت',
          payload: localResult.payload,
          isOfflineAllowed: true,
        );
      }

      // Server explicitly rejected the license (revoked, expired, limit, not found)
      await _storage.clear();
      final rejectedState = _mapActivationStatusToState(
        activationResult.status,
      );
      return LicenseValidationResult(
        state: rejectedState,
        message: getArabicMessage(activationResult.status),
        payload: localResult.payload,
      );
    } catch (_) {
      if (isGracePeriodExpired) {
        return LicenseValidationResult(
          state: LicenseState.expired,
          message:
              'انتهت مهلة الاستخدام بدون إنترنت (7 أيام)، يرجى الاتصال بالإنترنت لتأكيد الترخيص',
          payload: localResult.payload,
          isOfflineAllowed: false,
        );
      }
      // In case of unexpected connection failure within grace period, allow offline use
      return LicenseValidationResult(
        state: LicenseState.valid,
        message: 'تم السماح بالاستخدام بدون إنترنت',
        payload: localResult.payload,
        isOfflineAllowed: true,
      );
    }
  }

  /// Activates a license with the remote server, verifies its cryptographic signature,
  /// and persists it locally upon success.
  Future<LicenseActivationResult> activateLicense(
    String licenseKey, {
    String? customDeviceId,
  }) async {
    final trimmedKey = licenseKey.trim();
    if (trimmedKey.isEmpty) {
      return const LicenseActivationResult(
        status: LicenseActivationStatus.invalidLicense,
        message: 'مفتاح الترخيص غير صحيح',
      );
    }

    final deviceId = customDeviceId ?? await getDeviceId();

    final response = await _apiService.activate(
      licenseKey: trimmedKey,
      deviceId: deviceId,
    );

    if (!response.isSuccess) {
      return response;
    }

    final payloadString = response.tokenPayload;
    final signatureBase64 = response.tokenSignature;

    if (payloadString == null || signatureBase64 == null) {
      return const LicenseActivationResult(
        status: LicenseActivationStatus.serverError,
        message: 'Malformed token received in server response.',
      );
    }

    // Security check: Verify cryptographic signature and payload authenticity
    final verifyResult = await _verifier.verifyToken(
      payloadString: payloadString,
      signatureBase64: signatureBase64,
      currentDeviceId: deviceId,
    );

    if (!verifyResult.isValid) {
      return LicenseActivationResult(
        status: LicenseActivationStatus.verificationFailed,
        message: verifyResult.message ?? 'Token signature verification failed.',
      );
    }

    // Save valid license securely
    await _storage.saveLicense(
      licenseKey: trimmedKey,
      tokenPayload: payloadString,
      tokenSignature: signatureBase64,
      lastValidatedAt: DateTime.now(),
    );

    return LicenseActivationResult(
      status: LicenseActivationStatus.success,
      message: response.message,
      licenseKey: trimmedKey,
      tokenPayload: payloadString,
      tokenSignature: signatureBase64,
      parsedPayload: verifyResult.payload,
    );
  }

  /// Returns the stored license key, or null if none is saved.
  Future<String?> getStoredLicenseKey() => _storage.getLicenseKey();

  /// Clears stored license data.
  Future<void> clearLicense() async {
    await _storage.clear();
  }

  /// Helper to map local verification status to LicenseState.
  LicenseState _mapVerificationStatus(LicenseVerificationStatus status) {
    switch (status) {
      case LicenseVerificationStatus.valid:
        return LicenseState.valid;
      case LicenseVerificationStatus.expired:
        return LicenseState.expired;
      case LicenseVerificationStatus.invalidSignature:
      case LicenseVerificationStatus.invalidPayload:
        return LicenseState.invalidSignature;
      case LicenseVerificationStatus.wrongDevice:
        return LicenseState.wrongDevice;
      case LicenseVerificationStatus.wrongProduct:
        return LicenseState.wrongProduct;
    }
  }

  /// Helper to map activation status to LicenseState.
  LicenseState _mapActivationStatusToState(LicenseActivationStatus status) {
    switch (status) {
      case LicenseActivationStatus.success:
        return LicenseState.valid;
      case LicenseActivationStatus.expiredLicense:
        return LicenseState.expired;
      case LicenseActivationStatus.wrongProduct:
        return LicenseState.wrongProduct;
      case LicenseActivationStatus.deviceLimitReached:
        return LicenseState.wrongDevice;
      case LicenseActivationStatus.invalidLicense:
      case LicenseActivationStatus.revokedLicense:
      case LicenseActivationStatus.networkError:
      case LicenseActivationStatus.serverError:
      case LicenseActivationStatus.verificationFailed:
      case LicenseActivationStatus.unknownError:
        return LicenseState.unlicensed;
    }
  }

  /// Maps any license status or state to standard, user-friendly Arabic text.
  static String getArabicMessage(dynamic status) {
    if (status == LicenseState.unlicensed) {
      return 'يرجى إدخال مفتاح الترخيص لتفعيل التطبيق';
    } else if (status == LicenseState.invalidSignature ||
        status == LicenseActivationStatus.invalidLicense) {
      return 'مفتاح الترخيص غير صحيح';
    } else if (status == LicenseActivationStatus.revokedLicense) {
      return 'هذا الترخيص موقوف';
    } else if (status == LicenseState.expired ||
        status == LicenseActivationStatus.expiredLicense) {
      return 'انتهت صلاحية الترخيص';
    } else if (status == LicenseActivationStatus.deviceLimitReached) {
      return 'تم الوصول للحد الأقصى من الأجهزة';
    } else if (status == LicenseState.wrongProduct ||
        status == LicenseActivationStatus.wrongProduct) {
      return 'هذا الترخيص غير مخصص لهذا البرنامج';
    } else if (status == LicenseActivationStatus.networkError) {
      return 'تعذر الاتصال بالخادم، حاول مرة أخرى';
    } else if (status == LicenseActivationStatus.serverError) {
      return 'حدث خطأ في خادم الترخيص، يرجى المحاولة لاحقاً';
    } else if (status == LicenseState.wrongDevice) {
      return 'هذا الترخيص غير مخصص لهذا الجهاز';
    }
    return 'حدث خطأ أثناء التحقق من الترخيص';
  }
}
