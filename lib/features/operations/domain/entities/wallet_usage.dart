class WalletUsage {
  final double dailyUsed;
  final double dailyLimit;
  final double weeklyUsed;
  final double weeklyLimit;
  final double monthlyUsed;
  final double monthlyLimit;

  const WalletUsage({
    required this.dailyUsed,
    required this.dailyLimit,
    required this.weeklyUsed,
    required this.weeklyLimit,
    required this.monthlyUsed,
    required this.monthlyLimit,
  });

  double get dailyRemaining => (dailyLimit - dailyUsed).clamp(0, double.infinity);
  double get weeklyRemaining => (weeklyLimit - weeklyUsed).clamp(0, double.infinity);
  double get monthlyRemaining => (monthlyLimit - monthlyUsed).clamp(0, double.infinity);

  double get dailyProgress => dailyLimit > 0 ? (dailyUsed / dailyLimit).clamp(0, 1) : 0;
  double get weeklyProgress => weeklyLimit > 0 ? (weeklyUsed / weeklyLimit).clamp(0, 1) : 0;
  double get monthlyProgress => monthlyLimit > 0 ? (monthlyUsed / monthlyLimit).clamp(0, 1) : 0;
}
