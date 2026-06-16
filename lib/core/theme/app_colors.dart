import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Core Light Base ──
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardSecondary = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color muted = Color(0xFFF1F5F9);
  static const Color mutedForeground = Color(0xFF64748B);
  static const Color foreground = Color(0xFF0F172A);
  static const Color foregroundSecondary = Color(0xFF334155);

  // ── Primary (Brand Cyan 500) ──
  static const Color primary = Color(0xFF06B6D4);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFF0FDFA);
  static const Color secondaryForeground = Color(0xFF0891B2);

  // ── Semantic ──
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  // ── Gradient Stops ──
  static const Color gradientHeroStart = Color(0xFF0891B2);
  static const Color gradientHeroMid = Color(0xFF06B6D4);
  static const Color gradientHeroEnd = Color(0xFF22D3EE);

  static const Color gradientCtaStart = Color(0xFF06B6D4);
  static const Color gradientCtaEnd = Color(0xFF8B5CF6);

  // ── Gradient Lists ──
  static const List<Color> heroGradient = [
    gradientHeroStart,
    gradientHeroMid,
    gradientHeroEnd,
  ];

  static const List<Color> ctaGradient = [
    gradientCtaStart,
    gradientCtaEnd,
  ];

  // ── Pre-computed Alpha Variants ──

  /// primary at 10% — icon wrappers, tinted surfaces
  static const Color primary10 = Color(0x1A06B6D4);

  /// primary at 25% — tap highlights, active borders
  static const Color primary25 = Color(0x4006B6D4);

  /// border at 50% — card borders, structural separation
  static const Color border50 = Color(0x80E2E8F0);

  /// border at 45% — inset section dividers
  static const Color border45 = Color(0x73E2E8F0);

  /// white at 20% — budget progress-bar track
  static const Color white20 = Color(0x33FFFFFF);

  /// white at 90% — budget progress-bar fill
  static const Color white90 = Color(0xE6FFFFFF);

  /// card at 95% — nav-bar background with blur
  static const Color card95 = Color(0xF2FFFFFF);

  // ── Fab Glow ──
  static const Color fabGlow = Color(0x80CFFAFE);

  // ── Helpers ──

  /// Returns [color] with the given [opacity] (0.0 → 1.0).
  static Color withAlpha(Color color, double opacity) {
    final a = (opacity * 255).round().clamp(0, 255);
    return Color.fromARGB(a, color.red, color.green, color.blue);
  }

  /// Returns [primary] at [opacity] (0.0 → 1.0).
  static Color primaryAlpha(double opacity) => withAlpha(primary, opacity);

  /// LinearGradient for hero surfaces (135°).
  static const LinearGradient heroGradientLinear = LinearGradient(
    colors: heroGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// LinearGradient for primary CTA buttons (135°).
  static const LinearGradient ctaGradientLinear = LinearGradient(
    colors: ctaGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
