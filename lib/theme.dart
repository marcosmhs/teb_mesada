import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Definição das cores principais baseadas na imagem do monstrinho.
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _secondaryBlue = Color(0xFF2196F3);
const Color _tertiaryGold = Color(0xFFFFC107);
const Color _lightSurface = Color(0xFFFAFAFA);
const Color _darkText = Color(0xFF212121);

/// Nosso tema customizado para o aplicativo.
/// É vibrante, amigável e moderno, ideal para crianças e adultos.
final ThemeData appTheme = ThemeData(
  // Ativa o Material Design 3 para um visual mais moderno.
  useMaterial3: true,
  brightness: Brightness.light,

  // Esquema de cores principal do aplicativo.
  colorScheme: const ColorScheme.light(
    primary: _primaryGreen,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFC8E6C9),
    onPrimaryContainer: Color(0xFF1B5E20),

    secondary: _secondaryBlue,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFBBDEFB),
    onSecondaryContainer: Color(0xFF0D47A1),

    tertiary: _tertiaryGold,
    onTertiary: _darkText,
    tertiaryContainer: Color(0xFFFFECB3),
    onTertiaryContainer: _darkText,

    error: Color(0xFFB00020),
    onError: Colors.white,

    surface: _lightSurface,
    onSurface: _darkText,

    // Outras cores de superfície para variantes de containers.
    surfaceDim: Color(0xFFEDEDED),
    surfaceBright: Colors.white,
  ),

  // Tema para a AppBar (barra de título).
  appBarTheme: const AppBarTheme(
    backgroundColor: _primaryGreen,
    foregroundColor: Colors.white, // Cor do título e ícones
    elevation: 2.0,
    centerTitle: true,
  ),

  // Tema para Botões Flutuantes (FAB).
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _tertiaryGold,
    foregroundColor: _darkText,
    elevation: 4.0,
    splashColor: Colors.white54,
  ),

  // Tema para botões elevados.
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _secondaryBlue, // Cor de fundo do botão
      foregroundColor: Colors.white, // Cor do texto e ícone do botão
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),

  // Tema para cartões (Cards).
  cardTheme: CardThemeData(
    elevation: 1.0,
    color: Colors.white,
    surfaceTintColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
  ),

  // Tema para campos de texto.
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: _primaryGreen, width: 2.0),
    ),
    filled: true,
    fillColor: Colors.white,
  ),

  // Estilos de texto. Usamos a fonte "Nunito" do Google Fonts.
  textTheme: GoogleFonts.nunitoTextTheme(
    const TextTheme(
      displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 45.0, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),

      headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700, color: _primaryGreen),

      titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),

      bodyLarge: TextStyle(fontSize: 16.0, color: _darkText),
      bodyMedium: TextStyle(fontSize: 14.0, color: _darkText),
      bodySmall: TextStyle(fontSize: 12.0, color: Colors.black54),

      labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      labelMedium: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
      labelSmall: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500),
    ),
  ),
);
