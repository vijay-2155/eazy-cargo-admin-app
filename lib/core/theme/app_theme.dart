import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// EazeMyCargo — Design System v3
class AppColors {
  // ── Primary: Deep Port Blue (Matching EazeMy Box) ───────────────────
  static const Color brandBlue      = Color(0xFF0C4A9E); // Logo Royal Deep Blue
  static const Color brandBlueDark  = Color(0xFF093775); // Darker maritime blue
  static const Color brandBlueMid   = Color(0xFF0D5BC3); // Middle ocean blue
  static const Color brandBlueLight = Color(0xFFEFF6FF); // Soft blue tint

  // ── Accent: Shipping Crimson Red (Matching Cargo Red) ───────────────
  static const Color brandRed       = Color(0xFFDE1D35); // Logo Cargo Crimson Red
  static const Color brandRedDark   = Color(0xFFB51227); // Dark crimson red
  static const Color brandRedLight  = Color(0xFFFEF2F2); // Soft red tint

  // ── Secondary: Greener Port Green (Matching Greener Theme) ──────────
  static const Color teal           = Color(0xFF107C41); // Deep maritime green
  static const Color tealLight      = Color(0xFFE6F4EA); // Soft green tint

  // ── Legacy aliases ───────────────────────────────────────────
  static const Color brandLight = Color(0xFFF8FAFC);
  static const Color brandDark  = Color(0xFF0F172A);

  // ── Surface / background ─────────────────────────────────────
  static const Color darkBg      = Color(0xFFF8FAFC); // Clean slate-50 light background
  static const Color darkCard    = Color(0xFFFFFFFF); // Pure white cards
  static const Color darkSurface = Color(0xFFF8FAFC); // Slate-50 surface
  static const Color darkBorder  = Color(0xFFE2E8F0); // Slate-200 borders

  // ── Navbar specific ──────────────────────────────────────────
  static const Color navBg            = Color(0xFFFFFFFF); // Clean white bar
  static const Color navInactiveIcon  = Color(0xFF64748B); // Slate-500
  static const Color navActiveStart   = Color(0xFF0C4A9E); // Deep Port Blue
  static const Color navActiveEnd     = Color(0xFF0C4A9E); // Deep Port Blue (Solid)

  // ── Neutrals (slate scale, dark = text) ─────────────────────
  static const Color neutral50  = Color(0xFF0F172A); // Slate-950 primary text
  static const Color neutral100 = Color(0xFF1E293B);
  static const Color neutral200 = Color(0xFF334155);
  static const Color neutral300 = Color(0xFF475569);
  static const Color neutral400 = Color(0xFF64748B); // Slate-500
  static const Color neutral500 = Color(0xFF94A3B8); // Slate-400
  static const Color neutral600 = Color(0xFFCBD5E1);
  static const Color neutral700 = Color(0xFFE2E8F0);
  static const Color neutral800 = Color(0xFFF1F5F9);
  static const Color neutral900 = Color(0xFFF8FAFC);
  static const Color neutral950 = Color(0xFFFFFFFF);

  // ── Semantic ─────────────────────────────────────────────────
  static const Color success = Color(0xFF107C41); // Deep Port Green
  static const Color warning = Color(0xFFD97706); // Amber-500
  static const Color error   = Color(0xFFDE1D35); // Crimson Port Red
  static const Color info    = Color(0xFF0C4A9E); // Deep Port Blue

  // ── Status ───────────────────────────────────────────────────
  static const Color statusActive    = Color(0xFF107C41);
  static const Color statusInTransit = Color(0xFF0C4A9E);
  static const Color statusDelayed   = Color(0xFFDE1D35);
  static const Color statusPending   = Color(0xFFD97706);
  static const Color statusCompleted = Color(0xFF94A3B8);

  // ── Glows (Muted solid opacity instead of glowing neon) ──────
  static const Color glowBlue  = Color(0x140C4A9E);
  static const Color glowRed   = Color(0x14DE1D35);
  static const Color glowGreen = Color(0x14107C41);
  static const Color glowAmber = Color(0x14D97706);

  // ── Text tokens (named "white" for backwards compat) ─────────
  static const Color white   = Color(0xFF0F172A); // Primary text slate-950
  static const Color white70 = Color(0xFF334155); // Body text slate-800
  static const Color white50 = Color(0xFF64748B); // Muted text slate-500
  static const Color white20 = Color(0xFFCBD5E1); // Divider
  static const Color white10 = Color(0xFFE2E8F0); // Subtle bg

  // ── Blue shade scale ─────────────────────────────────────────
  static const Color blue50  = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF0D5BC3);
  static const Color blue600 = Color(0xFF0C4A9E);
  static const Color blue700 = Color(0xFF093775);
  static const Color blue800 = Color(0xFF06254F);
  static const Color blue900 = Color(0xFF041834);
  static const Color blue950 = Color(0xFF020C1A);

  // ── Red shades ───────────────────────────────────────────────
  static const Color red50  = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red500 = Color(0xFFDE1D35);
  static const Color red600 = Color(0xFFB51227);
  static const Color red700 = Color(0xFF8F0B1C);
}

// ─────────────────────────────────────────────────────────────
// Text Styles
// ─────────────────────────────────────────────────────────────
class AppTextStyles {
  static const String _fontFamily = 'Inter';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 36, fontWeight: FontWeight.w800,
    letterSpacing: -1.0, height: 1.1,
  );
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily, fontSize: 28, fontWeight: FontWeight.w800,
    letterSpacing: -0.5, height: 1.15,
  );
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 24, fontWeight: FontWeight.w700,
    letterSpacing: -0.3, height: 1.2,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily, fontSize: 20, fontWeight: FontWeight.w700,
    letterSpacing: -0.2, height: 1.25,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily, fontSize: 17, fontWeight: FontWeight.w600,
    letterSpacing: -0.1, height: 1.3,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w400,
    letterSpacing: 0.0, height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w400,
    letterSpacing: 0.0, height: 1.5,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w400,
    letterSpacing: 0.0, height: 1.5,
  );
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600,
    letterSpacing: 0.5, height: 1.3,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w600,
    letterSpacing: 0.5, height: 1.3,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily, fontSize: 10, fontWeight: FontWeight.w600,
    letterSpacing: 0.8, height: 1.3,
  );
  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w500,
    letterSpacing: 0.5, height: 1.3,
  );
}

// ─────────────────────────────────────────────────────────────
// App Theme
// ─────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get dark => light;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandBlue,
        secondary: AppColors.brandRed,
        tertiary: AppColors.teal,
        surface: AppColors.darkCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: AppColors.white,
        error: AppColors.error,
        outline: AppColors.darkBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkCard,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Color(0x08000000),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brandBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Inter', color: AppColors.neutral500, fontSize: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter', color: AppColors.neutral400, fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter', fontSize: 15,
            fontWeight: FontWeight.w700, letterSpacing: 0.2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brandBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandBlue,
          side: const BorderSide(color: AppColors.darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandBlue,
          textStyle: const TextStyle(
            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder, thickness: 1, space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.brandBlueLight,
        selectedColor: AppColors.brandBlue,
        labelStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkCard,
        selectedItemColor: AppColors.brandBlue,
        unselectedItemColor: AppColors.neutral500,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkCard,
        indicatorColor: AppColors.brandBlueLight,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.brandBlue, size: 24);
          }
          return const IconThemeData(color: AppColors.neutral500, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: 'Inter', fontSize: 11,
              fontWeight: FontWeight.w700, color: AppColors.brandBlue,
            );
          }
          return const TextStyle(
            fontFamily: 'Inter', fontSize: 11,
            fontWeight: FontWeight.w500, color: AppColors.neutral500,
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Decorations & Gradients (Solid Uniform Color Sweeps — No Gradients)
// ─────────────────────────────────────────────────────────────
class AppDecorations {
  static BoxDecoration get darkCardDecoration => BoxDecoration(
    color: AppColors.darkCard,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.darkBorder),
  );

  static BoxDecoration blueGlowCard({double radius = 16}) => BoxDecoration(
    color: AppColors.darkCard,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.brandBlue.withValues(alpha: 0.22)),
    boxShadow: [
      BoxShadow(color: AppColors.glowBlue, blurRadius: 20, offset: const Offset(0, 4)),
    ],
  );

  static BoxDecoration redGlowCard({double radius = 16}) => BoxDecoration(
    color: AppColors.darkCard,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.error.withValues(alpha: 0.22)),
    boxShadow: [
      BoxShadow(color: AppColors.glowRed, blurRadius: 20, offset: const Offset(0, 4)),
    ],
  );

  static BoxDecoration tealGlowCard({double radius = 16}) => BoxDecoration(
    color: AppColors.darkCard,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.teal.withValues(alpha: 0.22)),
    boxShadow: [
      BoxShadow(color: AppColors.glowGreen, blurRadius: 20, offset: const Offset(0, 4)),
    ],
  );

  /// Primary brand background: Solid Deep Port Blue
  static LinearGradient get blueBrandGradient => const LinearGradient(
    colors: [AppColors.brandBlue, AppColors.brandBlue],
  );

  /// Navbar active pill: Solid light slate blue tint
  static LinearGradient get navActivePillGradient => const LinearGradient(
    colors: [AppColors.brandBlueLight, AppColors.brandBlueLight],
  );

  /// Solid crimson red fill
  static LinearGradient get amberGradient => const LinearGradient(
    colors: [AppColors.brandRed, AppColors.brandRed],
  );

  /// Login screen background: Solid Deep Port Blue
  static LinearGradient get loginGradient => const LinearGradient(
    colors: [AppColors.brandBlue, AppColors.brandBlue],
  );

  /// Hero banner: Solid Ocean Blue
  static LinearGradient get heroBannerGradient => const LinearGradient(
    colors: [AppColors.brandBlue, AppColors.brandBlue],
  );

  /// Page background: Solid Slate-50 Light background
  static LinearGradient get darkBgGradient => const LinearGradient(
    colors: [AppColors.darkBg, AppColors.darkBg],
  );

  /// Solid Port Blue
  static LinearGradient get violetGradient => const LinearGradient(
    colors: [AppColors.brandBlue, AppColors.brandBlue],
  );
}
