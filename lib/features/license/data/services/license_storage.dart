import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LicenseStorage {
  final FlutterSecureStorage _storage;

  LicenseStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyLicenseKey = 'license_key';
  static const String _keyTokenPayload = 'token_payload';
  static const String _keyTokenSignature = 'token_signature';
  static const String _keyLastValidatedAt = 'last_validated_at';

  Future<void> saveLicense({
    required String licenseKey,
    required String tokenPayload,
    required String tokenSignature,
    DateTime? lastValidatedAt,
  }) async {
    await _storage.write(key: _keyLicenseKey, value: licenseKey);
    await _storage.write(key: _keyTokenPayload, value: tokenPayload);
    await _storage.write(key: _keyTokenSignature, value: tokenSignature);
    final validatedTime = lastValidatedAt ?? DateTime.now();
    await _storage.write(
      key: _keyLastValidatedAt,
      value: validatedTime.toIso8601String(),
    );
  }

  /// Retrieves the stored license key.
  Future<String?> getLicenseKey() async {
    return _storage.read(key: _keyLicenseKey);
  }

  /// Retrieves the stored token payload.
  Future<String?> getTokenPayload() async {
    return _storage.read(key: _keyTokenPayload);
  }

  /// Retrieves the stored token signature.
  Future<String?> getTokenSignature() async {
    return _storage.read(key: _keyTokenSignature);
  }

  /// Retrieves the date and time when the license was last validated.
  Future<DateTime?> getLastValidatedAt() async {
    final value = await _storage.read(key: _keyLastValidatedAt);
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  /// Updates the last validated date and time.
  Future<void> setLastValidatedAt(DateTime dateTime) async {
    await _storage.write(
      key: _keyLastValidatedAt,
      value: dateTime.toIso8601String(),
    );
  }

  /// Clears all stored license data.
  Future<void> clear() async {
    await _storage.delete(key: _keyLicenseKey);
    await _storage.delete(key: _keyTokenPayload);
    await _storage.delete(key: _keyTokenSignature);
    await _storage.delete(key: _keyLastValidatedAt);
  }
}
