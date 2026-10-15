import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_radius.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/operations/domain/entities/daily_closing_entity.dart';

/// Daily Closing Card (كارت تقفيل اليومية)
///
/// Displays the current net financial position of the shop:
/// تقفيل اليومية = رصيد الدرج النقدي + مجموع أرصدة المحافظ النشطة + مجموع أرصدة حسابات InstaPay النشطة + إجمالي الآجل المتبقي للمحل عند العملاء - إجمالي المستحقات المتبقية على المحل.
class DailyClosingCard extends StatefulWidget {
  final double cashDrawerBalance;
  final double totalWalletBalance;
  final double totalInstaPayBalance;
  final double customerReceivables;
  final double payables;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onEditCashDrawer;

  const DailyClosingCard({
    super.key,
    required this.cashDrawerBalance,
    required this.totalWalletBalance,
    required this.totalInstaPayBalance,
    required this.customerReceivables,
    required this.payables,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onEditCashDrawer,
  });

  @override
  State<DailyClosingCard> createState() => _DailyClosingCardState();
}

class _DailyClosingCardState extends State<DailyClosingCard> {
  bool _isVisible = true;

  String _formatAmount(double amount) {
    return NumberFormat('#,##0.##', 'ar').format(amount);
  }

  DailyClosingEntity get _closingEntity => DailyClosingEntity(
        cashDrawerBalance: widget.cashDrawerBalance,
        activeWalletsBalance: widget.totalWalletBalance,
        activeInstaPayBalance: widget.totalInstaPayBalance,
        customerReceivables: widget.customerReceivables,
        outstandingPayables: widget.payables,
      );

  void _showFormulaInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.space6),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mutedForeground.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.calculate_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Text(
                  'معادلة تقفيل اليومية',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.foreground,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),
            Text(
              'يعرض هذا الكارت صافي الموقف المالي الإجمالي للمحل في اللحظة الحالية (وليس الأرباح)، ويُحسب وفق المعادلة التالية:',
              style: AppTextStyles.body.copyWith(
                color: AppColors.mutedForeground,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: AppColors.cardSecondary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _FormulaRow(
                    sign: '+',
                    signColor: AppColors.success,
                    title: 'رصيد الدرج النقدي',
                    amount: _formatAmount(widget.cashDrawerBalance),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  _FormulaRow(
                    sign: '+',
                    signColor: AppColors.success,
                    title: 'أرصدة المحافظ النشطة',
                    amount: _formatAmount(widget.totalWalletBalance),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  _FormulaRow(
                    sign: '+',
                    signColor: AppColors.success,
                    title: 'أرصدة حسابات InstaPay',
                    amount: _formatAmount(widget.totalInstaPayBalance),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  _FormulaRow(
                    sign: '+',
                    signColor: AppColors.success,
                    title: 'إجمالي الآجل المتبقي للمحل (لنا)',
                    amount: _formatAmount(widget.customerReceivables),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  _FormulaRow(
                    sign: '-',
                    signColor: AppColors.destructive,
                    title: 'إجمالي المستحقات على المحل (علينا)',
                    amount: _formatAmount(widget.payables),
                  ),
                  const Divider(height: AppSpacing.space4),
                  _FormulaRow(
                    sign: '=',
                    signColor: AppColors.primary,
                    title: 'صافي تقفيل اليومية',
                    amount: _formatAmount(_closingEntity.netClosingBalance),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: widget.isLoading
          ? _buildLoadingCard()
          : widget.errorMessage != null
              ? _buildErrorCard(widget.errorMessage!)
              : _buildMainCard(),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border50),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(height: AppSpacing.space3),
          Text(
            'جاري احتساب تقفيل اليومية...',
            style: TextStyle(
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.destructive.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.destructive,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فشل تحميل تقفيل اليومية',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.destructive,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          if (widget.onRetry != null)
            TextButton.icon(
              onPressed: widget.onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('إعادة المحاولة'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    final closing = _closingEntity;
    final netAmount = closing.netClosingBalance;
    final isNegative = netAmount < 0;
    final digitalTotal = closing.digitalBalance;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A), // Dark slate
            Color(0xFF1E293B), // Slate 800
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Title, Sub-badge, Actions (Visibility, Formula Info)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            Color(0xFF38BDF8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.fact_check_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تقفيل اليومية',
                          style: AppTextStyles.title.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            'صافي الموقف المالي',
                            style: AppTextStyles.micro.copyWith(
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _isVisible = !_isVisible),
                      icon: Icon(
                        _isVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white.withValues(alpha: 0.75),
                        size: 20,
                      ),
                      tooltip: _isVisible ? 'إخفاء الأرقام' : 'إظهار الأرقام',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    const SizedBox(width: AppSpacing.space1),
                    IconButton(
                      onPressed: () => _showFormulaInfo(context),
                      icon: Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white.withValues(alpha: 0.75),
                        size: 20,
                      ),
                      tooltip: 'معادلة التقفيل',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.space4),

            // Hero Net Total Amount Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
                vertical: AppSpacing.space3,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isNegative
                      ? AppColors.destructive.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي صافي التقفيل',
                        style: AppTextStyles.caption.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _isVisible
                                  ? (isNegative
                                      ? '- ${_formatAmount(netAmount.abs())}'
                                      : _formatAmount(netAmount))
                                  : '••••••',
                              style: AppTextStyles.headline.copyWith(
                                color: isNegative
                                    ? const Color(0xFFFCA5A5) // Soft red
                                    : const Color(0xFF38BDF8), // Cyan glow
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ج.م',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isNegative)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.destructive.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: AppColors.destructive.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'المستحقات تفوق الأصول',
                        style: AppTextStyles.caption.copyWith(
                          color: const Color(0xFFFCA5A5),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.space4),

            // 4 Core Component Breakdown Grid (2x2)
            Row(
              children: [
                // 1. Cash Drawer (الدرج النقدي) (+)
                Expanded(
                  child: _ComponentTile(
                    title: 'الدرج النقدي',
                    amount: _isVisible ? _formatAmount(widget.cashDrawerBalance) : '••••',
                    sign: '+',
                    signColor: const Color(0xFFF59E0B),
                    icon: Icons.point_of_sale_rounded,
                    accentColor: const Color(0xFFF59E0B),
                    onTap: widget.onEditCashDrawer,
                    actionTooltip: 'تعديل الدرج',
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                // 2. Digital Balances (المحافظ و InstaPay) (+)
                Expanded(
                  child: _ComponentTile(
                    title: 'المحافظ و InstaPay',
                    amount: _isVisible ? _formatAmount(digitalTotal) : '••••',
                    sign: '+',
                    signColor: const Color(0xFF06B6D4),
                    icon: Icons.account_balance_wallet_rounded,
                    accentColor: const Color(0xFF06B6D4),
                    subtitle: widget.totalInstaPayBalance > 0
                        ? 'محافظ: ${_formatAmount(widget.totalWalletBalance)} | إنستا: ${_formatAmount(widget.totalInstaPayBalance)}'
                        : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.space2),

            Row(
              children: [
                // 3. Customer Receivables (الآجل لنا) (+)
                Expanded(
                  child: _ComponentTile(
                    title: 'آجل العملاء (لنا)',
                    amount: _isVisible ? _formatAmount(widget.customerReceivables) : '••••',
                    sign: '+',
                    signColor: const Color(0xFF10B981),
                    icon: Icons.arrow_downward_rounded,
                    accentColor: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                // 4. Payables (المستحقات علينا) (-)
                Expanded(
                  child: _ComponentTile(
                    title: 'مستحقات (علينا)',
                    amount: _isVisible ? _formatAmount(widget.payables) : '••••',
                    sign: '-',
                    signColor: const Color(0xFFF97316),
                    icon: Icons.arrow_upward_rounded,
                    accentColor: const Color(0xFFF97316),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.space3),

            // Subtle Formula Indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space3,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'الدرج (+) + المحافظ (+) + الآجل (+) - المستحقات (-)',
                    style: AppTextStyles.micro.copyWith(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComponentTile extends StatelessWidget {
  final String title;
  final String amount;
  final String sign;
  final Color signColor;
  final IconData icon;
  final Color accentColor;
  final String? subtitle;
  final VoidCallback? onTap;
  final String? actionTooltip;

  const _ComponentTile({
    required this.title,
    required this.amount,
    required this.sign,
    required this.signColor,
    required this.icon,
    required this.accentColor,
    this.subtitle,
    this.onTap,
    this.actionTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        icon,
                        color: accentColor,
                        size: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: AppTextStyles.micro.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: signColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    sign,
                    style: TextStyle(
                      color: signColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  Text(
                    amount,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'ج.م',
                    style: AppTextStyles.micro.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: AppTextStyles.micro.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 9,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FormulaRow extends StatelessWidget {
  final String sign;
  final Color signColor;
  final String title;
  final String amount;
  final bool isTotal;

  const _FormulaRow({
    required this.sign,
    required this.signColor,
    required this.title,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              alignment: Alignment.center,
              child: Text(
                sign,
                style: TextStyle(
                  color: signColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                color: isTotal ? AppColors.foreground : AppColors.foregroundSecondary,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              amount,
              style: AppTextStyles.body.copyWith(
                color: isTotal ? AppColors.primary : AppColors.foreground,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'ج.م',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
