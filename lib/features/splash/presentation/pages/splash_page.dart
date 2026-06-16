import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_expense/core/constants/app_routes.dart';
import 'package:smart_expense/core/di/injection_container.dart';
import 'package:smart_expense/core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkOnboarding();
  });
}

 Future<void> _checkOnboarding() async {
  final prefs = sl<SharedPreferences>();

  final hasSeenOnboarding =
      prefs.getBool(_hasSeenOnboardingKey) ?? false;

  if (!mounted) return;

  context.go(
    hasSeenOnboarding
        ? AppRoutes.main
        : AppRoutes.onboarding,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
