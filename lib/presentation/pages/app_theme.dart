import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme — GudangPro Light Blue Theme
// Gunakan AppTheme.buildTheme() di MaterialApp, dan AppTheme.<color> di widget.
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  // ── Palet Biru ──────────────────────────────────────────────────────────────
  static const Color primaryDark    = Color(0xFF0277BD); // biru tua
  static const Color primary        = Color(0xFF0288D1); // biru utama
  static const Color primaryMid     = Color(0xFF029BE5); // biru tengah
  static const Color primaryLight   = Color(0xFF29B6F6); // biru muda
  static const Color primaryLighter = Color(0xFF4FC3F7); // biru lebih muda
  static const Color primaryPale    = Color(0xFFB3E5FC); // biru pucat
  static const Color primarySurface = Color(0xFFE1F5FE); // biru surface
  static const Color background     = Color(0xFFF0F9FF); // biru sangat muda

  // ── Warna Teks ──────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF01579B); // teks utama biru gelap
  static const Color textDark    = Color(0xFF1A237E); // teks sangat gelap

  // ── Status ──────────────────────────────────────────────────────────────────
  static const Color statusApproved  = Color(0xFF00BFA5);
  static const Color statusPending   = Color(0xFFFFB300);
  static const Color statusRejected  = Color(0xFFFF5252);
  static const Color statusCompleted = Color(0xFF00897B);
  static const Color statusInfo      = Color(0xFF0288D1);

  // ── Background Status ────────────────────────────────────────────────────────
  static const Color bgApproved  = Color(0xFFE0F7FA);
  static const Color bgPending   = Color(0xFFFFF8E1);
  static const Color bgRejected  = Color(0xFFFFEBEE);
  static const Color bgCompleted = Color(0xFFE0F2F1);
  static const Color bgInfo      = Color(0xFFE1F5FE);

  // ── Gradien Utama ───────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryLight],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryMid, primaryLighter],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  // ── SystemUiOverlayStyle ─────────────────────────────────────────────────────
  static const SystemUiOverlayStyle lightOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  // ── ThemeData ────────────────────────────────────────────────────────────────
  static ThemeData buildTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primarySurface,
        onPrimaryContainer: textPrimary,
        secondary: primaryLight,
        onSecondary: Colors.white,
        secondaryContainer: primaryPale,
        onSecondaryContainer: textPrimary,
        surface: Colors.white,
        onSurface: textPrimary,
        background: background,
        onBackground: textPrimary,
        error: statusRejected,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: lightOverlay,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Color(0x990288D1),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          minimumSize: Size(double.infinity, 54),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0x3329B6F6), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: statusRejected, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: statusRejected, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        iconColor: primary,
        prefixIconColor: primary,
        hintStyle: TextStyle(fontSize: 14),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primaryDark,
          letterSpacing: 0.3,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primary : null,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: Colors.grey, width: 1.5),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primarySurface,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade100,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
