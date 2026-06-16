import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      surface: AppColors.surface,
      onSurface: AppColors.foreground,
      surfaceContainer: AppColors.card,
      surfaceContainerHighest: AppColors.cardSecondary,
      error: AppColors.destructive,
      onError: AppColors.destructiveForeground,
      outline: AppColors.border,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: GoogleFonts.cairo().fontFamily,
    textTheme: TextTheme(
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.caption,
      labelMedium: AppTextStyles.caption,
      titleMedium: AppTextStyles.bodyLarge,
      titleSmall: AppTextStyles.caption,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.foreground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.headline.copyWith(
        color: AppColors.foreground,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      margin: const EdgeInsets.all(0),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.mutedForeground,
      textColor: AppColors.foreground,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4, horizontal: AppSpacing.space6),
        textStyle: AppTextStyles.bodyLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.bodyLarge,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3, horizontal: AppSpacing.space4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.foreground,
        side: const BorderSide(color: AppColors.border),
        textStyle: AppTextStyles.body,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4, horizontal: AppSpacing.space6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.all(AppSpacing.space4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        borderSide: const BorderSide(color: AppColors.destructive),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        borderSide: const BorderSide(color: AppColors.destructive, width: 2),
      ),
      labelStyle: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground),
      hintStyle: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground),
      helperStyle: AppTextStyles.caption.copyWith(color: AppColors.mutedForeground),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.destructive),
      prefixIconColor: AppColors.mutedForeground,
      suffixIconColor: AppColors.mutedForeground,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.muted,
      selectedColor: AppColors.primary10,
      labelStyle: AppTextStyles.caption.copyWith(color: AppColors.foreground),
      secondaryLabelStyle: AppTextStyles.caption.copyWith(color: AppColors.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      side: const BorderSide(color: AppColors.border),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.mutedForeground,
      selectedLabelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: AppTextStyles.caption,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.primaryForeground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.foreground,
      contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.background),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.card,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
    iconTheme: IconThemeData(
      color: AppColors.foreground,
      size: 24,
    ),
    primaryIconTheme: IconThemeData(
      color: AppColors.primary,
      size: 24,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.foreground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      textStyle: AppTextStyles.caption.copyWith(color: AppColors.background),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.mutedForeground,
      labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: AppTextStyles.body,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.border,
      circularTrackColor: AppColors.border,
    ),
  );
}
