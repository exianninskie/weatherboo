import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pastel sakura-sky palette — cute anime vibes for Weatherboo.
class AppColors {
  static const Color backgroundTop = Color(0xFFFFF0F8);
  static const Color backgroundMid = Color(0xFFF3ECFF);
  static const Color backgroundBottom = Color(0xFFE5F4FF);
  static const Color surface = Color(0xFFFFFBFE);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color sakura = Color(0xFFFF8FC7);
  static const Color sakuraDeep = Color(0xFFFF6BB5);
  static const Color sky = Color(0xFF8EC5FF);
  static const Color lavender = Color(0xFFB8A9FF);
  static const Color mint = Color(0xFF9EECD9);
  static const Color peach = Color(0xFFFFC4A8);
  static const Color text = Color(0xFF6B5B7A);
  static const Color textMuted = Color(0xFF9D8FB0);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Legacy aliases for profile & older code
  static const Color primaryBlue = sakura;
  static const Color textDark = text;
  static const Color textLight = textMuted;
  static const Color gold = sakura;
  static const Color goldLight = sakura;
  static const Color goldMuted = Color(0xFFFFB8DD);
  static const Color ivory = text;
  static const Color muted = textMuted;
  static const Color onSurface = text;
  static const Color roseGold = Color(0xFFFF8A9A);
}

class AppTypography {
  static TextStyle brandTitle(double size, {Color? color}) {
    return GoogleFonts.baloo2(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.sakuraDeep,
      letterSpacing: 0.5,
      height: 1.1,
    );
  }

  static TextStyle brandSubtitle(double size, {Color? color}) {
    return GoogleFonts.mPlusRounded1c(
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.textMuted,
      letterSpacing: 0.3,
    );
  }

  static TextStyle headline(double size, {Color? color, FontWeight? weight}) {
    return GoogleFonts.baloo2(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w700,
      color: color ?? AppColors.text,
      height: 1.15,
    );
  }

  static TextStyle body(double size, {Color? color, FontWeight? weight}) {
    return GoogleFonts.mPlusRounded1c(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w500,
      color: color ?? AppColors.text,
      height: 1.4,
    );
  }

  static TextStyle label(double size, {Color? color}) {
    return GoogleFonts.mPlusRounded1c(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.textMuted,
    );
  }

  static TextStyle button({Color? color}) {
    return GoogleFonts.baloo2(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.onPrimary,
      letterSpacing: 0.5,
    );
  }
}

class AppTheme {
  static ThemeData get kawaii {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundTop,
      colorScheme: const ColorScheme.light(
        primary: AppColors.sakura,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.sky,
        onSecondary: AppColors.text,
        tertiary: AppColors.lavender,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: Color(0xFFFF8A9A),
        onError: AppColors.onPrimary,
      ),
    );

    final textTheme = TextTheme(
      displayLarge: AppTypography.headline(40),
      displayMedium: AppTypography.headline(32),
      displaySmall: AppTypography.headline(28),
      headlineLarge: AppTypography.headline(26),
      headlineMedium: AppTypography.headline(22),
      headlineSmall: AppTypography.headline(20),
      titleLarge: AppTypography.body(20, weight: FontWeight.w700),
      titleMedium: AppTypography.body(18, weight: FontWeight.w700),
      titleSmall: AppTypography.body(16, weight: FontWeight.w700),
      bodyLarge: AppTypography.body(17),
      bodyMedium: AppTypography.body(15),
      bodySmall: AppTypography.body(13, color: AppColors.textMuted),
      labelLarge: AppTypography.label(14),
      labelMedium: AppTypography.label(12),
      labelSmall: AppTypography.label(11),
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        titleTextStyle: AppTypography.brandTitle(22),
        iconTheme: const IconThemeData(color: AppColors.sakuraDeep),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceElevated,
        elevation: 0,
        shadowColor: AppColors.sakura.withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.sakura.withValues(alpha: 0.2)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sakura,
          foregroundColor: AppColors.onPrimary,
          elevation: 4,
          shadowColor: AppColors.sakura.withValues(alpha: 0.45),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: AppTypography.button(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.sakuraDeep,
          side: const BorderSide(color: AppColors.sakura, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: AppTypography.button(color: AppColors.sakuraDeep),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.sakuraDeep,
          textStyle: AppTypography.body(14, color: AppColors.sakuraDeep, weight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        labelStyle: AppTypography.label(14),
        hintStyle: AppTypography.body(14, color: AppColors.textMuted),
        prefixIconColor: AppColors.sakura,
        suffixIconColor: AppColors.lavender,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.lavender.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.sky.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.sakura, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.lavender.withValues(alpha: 0.35),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.text,
        contentTextStyle: AppTypography.body(14, color: AppColors.onPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.sakura,
      ),
      iconTheme: const IconThemeData(color: AppColors.sakuraDeep),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.sakura,
        foregroundColor: AppColors.onPrimary,
      ),
    );
  }

  static BoxDecoration get backgroundGradient => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundTop,
            AppColors.backgroundMid,
            AppColors.backgroundBottom,
          ],
        ),
      );

  static BoxDecoration get logoGradient => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.sakura,
            AppColors.lavender,
            AppColors.sky,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.sakura.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration get appBarGradient => const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xE6FFF0F8),
            Color(0xE6F3ECFF),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: Color(0x40FF8FC7)),
        ),
      );
}

/// Pastel gradient backdrop with soft cloud blobs.
class KawaiiBackground extends StatelessWidget {
  final Widget child;

  const KawaiiBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DecoratedBox(
          decoration: AppTheme.backgroundGradient,
          child: SizedBox.expand(),
        ),
        Positioned(
          top: -40,
          right: -20,
          child: _CloudBlob(size: 120, color: AppColors.sakura.withValues(alpha: 0.15)),
        ),
        Positioned(
          top: 80,
          left: -30,
          child: _CloudBlob(size: 90, color: AppColors.sky.withValues(alpha: 0.2)),
        ),
        Positioned(
          bottom: 100,
          right: 40,
          child: _CloudBlob(size: 70, color: AppColors.lavender.withValues(alpha: 0.18)),
        ),
        child,
      ],
    );
  }
}

class _CloudBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _CloudBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.65,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}

/// @deprecated Use [KawaiiBackground] instead.
typedef LuxuryBackground = KawaiiBackground;
