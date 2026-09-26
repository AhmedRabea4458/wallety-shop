/// Parsed data payload from license token.
class LicenseTokenModel {
  final dynamic licenseId;
  final String productId;
  final String deviceId;
  final DateTime issuedAt;
  final DateTime expiresAt;

  LicenseTokenModel({
    required this.licenseId,
    required this.productId,
    required this.deviceId,
    required this.issuedAt,
    required this.expiresAt,
  });

  factory LicenseTokenModel.fromJson(Map<String, dynamic> json) {
    final licenseId = json['licenseId'];
    final productId = json['productId'] as String? ?? '';
    final deviceId = json['deviceId'] as String? ?? '';
    final issuedAtStr = json['issuedAt'] as String? ?? '';
    final expiresAtStr = json['expiresAt'] as String? ?? '';

    final issuedAt =
        DateTime.tryParse(issuedAtStr) ?? DateTime.fromMillisecondsSinceEpoch(0);
    final expiresAt =
        DateTime.tryParse(expiresAtStr) ?? DateTime.fromMillisecondsSinceEpoch(0);

    return LicenseTokenModel(
      licenseId: licenseId,
      productId: productId,
      deviceId: deviceId,
      issuedAt: issuedAt,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'licenseId': licenseId,
        'productId': productId,
        'deviceId': deviceId,
        'issuedAt': issuedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };
}

/// Backwards compatibility alias
typedef LicenseTokenPayload = LicenseTokenModel;
