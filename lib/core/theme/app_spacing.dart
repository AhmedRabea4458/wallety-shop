import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  /// Base grid unit — every spacing value is a multiple of this.
  static const double unit = 4.0;

  // ── Scale ──

  ///   4px — icon internal padding, micro gaps
  static const double space1 = 4.0;

  ///   8px — tight internal row gaps
  static const double space2 = 8.0;

  ///  12px — icon-to-label gaps, badge padding
  static const double space3 = 12.0;

  ///  16px — standard internal card padding
  static const double space4 = 16.0;

  ///  20px — card-to-card gaps
  static const double space5 = 20.0;

  ///  24px — section padding, card padding
  static const double space6 = 24.0;

  ///  28px — between major sections
  static const double space7 = 28.0;

  ///  32px — screen-level vertical rhythm
  static const double space8 = 32.0;

  ///  40px — hero card internal spacing
  static const double space10 = 40.0;

  // ── Screen-Level ──

  /// Horizontal screen padding (minimum).
  static const double screenHorizontal = 20.0;

  /// Horizontal screen padding (maximum / relaxed).
  static const double screenHorizontalMax = 24.0;

  /// Gap between distinct content sections.
  static const double sectionGap = 24.0;

  /// Large gap between major sections.
  static const double sectionGapLarge = 32.0;

  /// Bottom safe area reserved for the nav bar (h-28 = 112 px).
  static const double bottomSafeArea = 112.0;

  /// Typical content width (390 - 2 × 20).
  static const double contentWidth = 350.0;

  // ── Common EdgeInsets ──

  /// 20 px horizontal — full-screen horizontal inset.
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
  );

  /// 24 px all sides — standard card interior.
  static const EdgeInsets cardPadding = EdgeInsets.all(space6);

  /// 20 px all sides — compact card interior.
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(space5);

  /// 20 px horizontal × 16 px vertical — settings / list row.
  static const EdgeInsets rowPadding = EdgeInsets.symmetric(
    horizontal: space5,
    vertical: space4,
  );

  /// 24 px bottom — standard section separator.
  static const EdgeInsets sectionMargin = EdgeInsets.only(bottom: sectionGap);

  /// 24 px horizontal — content inset for scrollable areas.
  static const EdgeInsets contentInset = EdgeInsets.symmetric(
    horizontal: space6,
  );
}
