import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Cairo';

  // ── Scale ──

  /// Hero Amount — 52 px · Black 900
  ///
  /// Balance-card main number. letter-spacing: -1 for tight,
  /// scannable rendering in under 200 ms.
  static const TextStyle hero = TextStyle(
    fontFamily: fontFamily,
    fontSize: 52,
    fontWeight: FontWeight.w900,
    letterSpacing: -1,
    height: 1.1,
  );

  /// Display — 28 px · ExtraBold 800
  ///
  /// Screen titles (الإعدادات, التحليلات).
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  /// Title — 24 px · Bold 700
  ///
  /// Card headers, section heads.
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  /// Headline — 20 px · Bold 700
  ///
  /// Sub-section headers, dialog titles.
  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  /// Body Large — 16 px · SemiBold 600
  ///
  /// Row labels, primary content.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.6,
  );

  /// Body — 14 px · Medium 500
  ///
  /// Secondary content, descriptions.
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.7,
  );

  /// Caption — 12 px · SemiBold 600
  ///
  /// Tags, timestamps, secondary labels.
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  /// Micro — 10 px · Bold 700
  ///
  /// Nav labels, legal text, badges.
  static const TextStyle micro = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );

  // ── Specialised ──

  /// Transaction amount — 16 px · ExtraBold 800
  ///
  /// Used on transaction rows. Placed at the leading (right) edge in RTL.
  static const TextStyle transactionAmount = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    height: 1.5,
  );

  /// Nav label — 11 px · SemiBold 600
  ///
  /// Bottom-navigation-bar labels.
  static const TextStyle navLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Section label — 13 px · SemiBold 600
  ///
  /// Uppercase or emphasized section labels.
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.5,
  );

  // ── Material 3 TextTheme ──

  /// Pre-built [TextTheme] that maps every style to a M3 slot.
  static const TextTheme textTheme = TextTheme(
    displayLarge: hero,
    displayMedium: display,
    headlineLarge: headline,
    headlineSmall: title,
    titleLarge: title,
    titleMedium: bodyLarge,
    titleSmall: sectionLabel,
    bodyLarge: bodyLarge,
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: caption,
    labelMedium: caption,
    labelSmall: micro,
  );
}
