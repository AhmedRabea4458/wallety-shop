import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_expense/core/di/injection_container.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/core/theme/app_spacing.dart';
import 'package:smart_expense/core/theme/app_text_styles.dart';
import 'package:smart_expense/features/license/domain/license_manager.dart';

import '../../../../core/constants/app_routes.dart';

class LicensePage extends StatefulWidget {
  const LicensePage({super.key});

  @override
  State<LicensePage> createState() => _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {
  final TextEditingController _licenseController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _deviceId;

  /// Non-null when a license key is already stored locally.
  /// In that case we show the revalidation UI instead of the input field.
  String? _storedKey;

  /// True while we are loading the device ID and stored key on first render.
  bool _initialising = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final manager = sl<LicenseManager>();
      final deviceId = await manager.getDeviceId();
      final storedKey = await manager.getStoredLicenseKey();
      if (!mounted) return;
      setState(() {
        _deviceId = deviceId;
        _storedKey = storedKey;
      });
    } catch (e) {
      debugPrint('LicensePage init error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _initialising = false;
        });
      }
    }
  }

  // ── Revalidation (stored key exists) ────────────────────────────────────

  Future<void> _handleRevalidation() async {
    if (_isLoading || _storedKey == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final licenseManager = sl<LicenseManager>();
      final result = await licenseManager.activateLicense(_storedKey!);

      if (!mounted) return;

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم التحقق من الترخيص بنجاح',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.main);
      } else {
        setState(() {
          _errorMessage = LicenseManager.getArabicMessage(result.status);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'تعذر الاتصال بالخادم، حاول مرة أخرى';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleActivation() async {
    if (_isLoading) return;

    final key = _licenseController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _errorMessage = 'يرجى إدخال مفتاح الترخيص';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final licenseManager = sl<LicenseManager>();
      final result = await licenseManager.activateLicense(key);

      if (!mounted) return;

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم تفعيل الترخيص بنجاح',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.main);
      } else {
        setState(() {
          _errorMessage = LicenseManager.getArabicMessage(result.status);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'تعذر الاتصال بالخادم، حاول مرة أخرى';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.space6,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.space6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child:
                      _initialising
                          ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                          : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Brand Icon
                              Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary10,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.verified_user_rounded,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space5),

                              // Title
                              Text(
                                'تفعيل التطبيق',
                                style: AppTextStyles.title.copyWith(
                                  color: AppColors.foreground,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.space2),

                              // Subtitle
                              Text(
                                'نظام ادارة مبيعات الكاش والانستا باي',
                                style: AppTextStyles.headline.copyWith(
                                  color: AppColors.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.space3),
                              // Description: differs per mode
                              Text(
                                _storedKey != null
                                    ? 'اتصل بالإنترنت للتحقق من الترخيص'
                                    : 'يرجى إدخال مفتاح الترخيص المعتمد للمتابعة والبدء باستخدام النظام.',
                                style: AppTextStyles.body.copyWith(
                                  color:
                                      _storedKey != null
                                          ? AppColors.foreground
                                          : AppColors.mutedForeground,
                                  fontWeight:
                                      _storedKey != null
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.space6),

                              // Error message container if present
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.space4,
                                    vertical: AppSpacing.space3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.destructive.withValues(
                                      alpha: 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.destructive.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        color: AppColors.destructive,
                                        size: 20,
                                      ),
                                      const SizedBox(width: AppSpacing.space3),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: AppTextStyles.body.copyWith(
                                            color: AppColors.destructive,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.space4),
                              ],

                              // ── MODE A: stored key → revalidation button only ──
                              if (_storedKey != null) ...[
                                ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _handleRevalidation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor:
                                        AppColors.primaryForeground,
                                    elevation: 0,
                                    minimumSize: const Size(
                                      double.infinity,
                                      52,
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    disabledBackgroundColor: AppColors.primary
                                        .withValues(alpha: 0.5),
                                  ),
                                  child:
                                      _isLoading
                                          ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : const Text(
                                            'إعادة التحقق',
                                            style: TextStyle(
                                              fontFamily:
                                                  AppTextStyles.fontFamily,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              height: 1.2,
                                            ),
                                          ),
                                ),
                              ],

                              // ── MODE B: no stored key → full activation form ──
                              if (_storedKey == null) ...[
                                Text(
                                  'مفتاح الترخيص',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.foregroundSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.space2),
                                TextField(
                                  controller: _licenseController,
                                  enabled: !_isLoading,
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'XXXX-XXXX-XXXX-XXXX',
                                    hintTextDirection: TextDirection.ltr,
                                    hintStyle: TextStyle(
                                      color: AppColors.mutedForeground
                                          .withValues(alpha: 0.5),
                                      fontFamily: 'monospace',
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.key_rounded,
                                      color: AppColors.mutedForeground,
                                    ),
                                    suffixIcon:
                                        _licenseController.text.isNotEmpty
                                            ? IconButton(
                                              icon: const Icon(
                                                Icons.clear_rounded,
                                                size: 18,
                                                color:
                                                    AppColors.mutedForeground,
                                              ),
                                              onPressed:
                                                  _isLoading
                                                      ? null
                                                      : () {
                                                        _licenseController
                                                            .clear();
                                                        setState(() {});
                                                      },
                                            )
                                            : null,
                                    filled: true,
                                    fillColor: AppColors.cardSecondary,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.space4,
                                      vertical: AppSpacing.space3,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  onChanged: (_) {
                                    if (_errorMessage != null) {
                                      setState(() {
                                        _errorMessage = null;
                                      });
                                    } else {
                                      setState(() {});
                                    }
                                  },
                                ),
                                const SizedBox(height: AppSpacing.space6),
                                // Activation Button
                                ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _handleActivation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor:
                                        AppColors.primaryForeground,
                                    elevation: 0,
                                    minimumSize: const Size(
                                      double.infinity,
                                      52,
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    disabledBackgroundColor: AppColors.primary
                                        .withValues(alpha: 0.5),
                                  ),
                                  child:
                                      _isLoading
                                          ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : const Text(
                                            'تفعيل الترخيص',
                                            style: TextStyle(
                                              fontFamily:
                                                  AppTextStyles.fontFamily,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              height: 1.2,
                                            ),
                                          ),
                                ),
                              ],

                              // Device ID footer
                              if (_deviceId != null) ...[
                                const SizedBox(height: AppSpacing.space6),
                                const Divider(color: AppColors.border),
                                const SizedBox(height: AppSpacing.space3),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.devices_rounded,
                                      size: 16,
                                      color: AppColors.mutedForeground,
                                    ),
                                    const SizedBox(width: AppSpacing.space2),
                                    Text(
                                      'معرّف هذا الجهاز:',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.space2),
                                    Expanded(
                                      child: Text(
                                        _deviceId!,
                                        textDirection: TextDirection.ltr,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                          color: AppColors.mutedForeground,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.copy_rounded,
                                        size: 16,
                                        color: AppColors.mutedForeground,
                                      ),
                                      tooltip: 'نسخ معرّف الجهاز',
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(text: _deviceId!),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'تم نسخ معرّف الجهاز للحافظة',
                                              textDirection: TextDirection.rtl,
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
