import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  // ── Scale ──

  ///   8px — tags, chips, badges, toggles
  static const double sm = 8.0;

  ///  12px — buttons, inputs, icon wrappers
  static const double md = 12.0;

  ///  16px — compact cards, transaction rows
  static const double lg = 16.0;

  ///  20px — action buttons (CTA)
  static const double xl = 20.0;

  ///  24px — primary cards, settings sections
  static const double xxl = 24.0;

  ///  28–32px — hero cards, identity card
  static const double xxxl = 28.0;
    ///  32px — pie chart center space
  static const double pieCenter = 32.0;


  /// 9999 — fully circular (avatars, FAB)
  static const double full = 9999.0;

  // ── Semantic Aliases ──

  /// Tag / chip / badge radius.
  static const double tag = sm;

  /// Button radius (global --radius anchor).
  static const double button = xl;

  /// Text-field / input radius.
  static const double input = md;

  /// Standard card radius.
  static const double card = xxl;

  /// Hero / identity card radius.
  static const double heroCard = xxxl;

  /// Icon wrapper (32 px container) radius.
  static const double iconWrapper = md;

  /// Bottom-sheet top corners.
  static const double sheet = xxl;

  // ── BorderRadius Constants ──

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlAll = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius xxxlAll = BorderRadius.all(Radius.circular(xxxl));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));

  // ── RoundedRectangleBorder Constants ──

  static const RoundedRectangleBorder smBorder = RoundedRectangleBorder(
    borderRadius: smAll,
  );

  static const RoundedRectangleBorder mdBorder = RoundedRectangleBorder(
    borderRadius: mdAll,
  );

  static const RoundedRectangleBorder lgBorder = RoundedRectangleBorder(
    borderRadius: lgAll,
  );

  static const RoundedRectangleBorder xlBorder = RoundedRectangleBorder(
    borderRadius: xlAll,
  );

  static const RoundedRectangleBorder xxlBorder = RoundedRectangleBorder(
    borderRadius: xxlAll,
  );

  static const RoundedRectangleBorder xxxlBorder = RoundedRectangleBorder(
    borderRadius: xxxlAll,
  );

  static const RoundedRectangleBorder fullBorder = RoundedRectangleBorder(
    borderRadius: fullAll,
  );

  // ── Sheet Shape (top-only rounding) ──

  static const RoundedRectangleBorder sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(sheet)),
  );
}
