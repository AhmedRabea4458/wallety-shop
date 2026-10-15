/// Represents the Daily Closing (تقفيل اليومية) financial position snapshot.
///
/// Formula:
/// تقفيل اليومية = رصيد الدرج النقدي + مجموع أرصدة المحافظ النشطة + مجموع أرصدة حسابات InstaPay النشطة + إجمالي الآجل المتبقي للمحل عند العملاء - إجمالي المستحقات المتبقية على المحل.
class DailyClosingEntity {
  /// رصيد الدرج النقدي الحالي
  final double cashDrawerBalance;

  /// مجموع أرصدة المحافظ النشطة (غير المؤرشفة)
  final double activeWalletsBalance;

  /// مجموع أرصدة حسابات InstaPay النشطة
  final double activeInstaPayBalance;

  /// إجمالي الآجل المتبقي للمحل عند العملاء (لنا)
  final double customerReceivables;

  /// إجمالي المستحقات المتبقية على المحل (علينا)
  final double outstandingPayables;

  const DailyClosingEntity({
    required this.cashDrawerBalance,
    required this.activeWalletsBalance,
    required this.activeInstaPayBalance,
    required this.customerReceivables,
    required this.outstandingPayables,
  });

  /// مجموع الأرصدة الرقمية (المحافظ + InstaPay)
  double get digitalBalance => activeWalletsBalance + activeInstaPayBalance;

  /// إجمالي الأصول والسيولة والآجل لنا (+)
  double get totalAssets =>
      cashDrawerBalance + digitalBalance + customerReceivables;

  /// صافي تقفيل اليومية (صافي الموقف المالي الحالي)
  double get netClosingBalance => totalAssets - outstandingPayables;

  /// Returns true if all components are zero.
  bool get isEmpty =>
      cashDrawerBalance == 0.0 &&
      activeWalletsBalance == 0.0 &&
      activeInstaPayBalance == 0.0 &&
      customerReceivables == 0.0 &&
      outstandingPayables == 0.0;
}
