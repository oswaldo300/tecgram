import 'package:flutter/material.dart';

// Colores y tema de TaroGram.
class AppTheme {
  AppTheme._();

  static const Color azulTelegram = Color.fromARGB(255, 142, 34, 209);
  static const Color azulClaro = Color(0xFFB56CE6);
  static const Color azulOscuro = Color(0xFF5A1187);
  static const Color azulTec = Color(0xFF003B71);

  // Fondo general de la app (lavanda muy suave que combina con el morado Taro)
  static const Color fondoApp = Color(0xFFF6F0FA);

  // Fondo de la sala de chat (tono lavanda grisáceo suave)
  static const Color fondoChat = Color(0xFFEDE4F5);

  // Burbujas: la mía en lila claro, la del otro en blanco
  static const Color burbujaMia = Color(0xFFE3CCF5);
  static const Color burbujaOtro = Color(0xFFFFFFFF);

  static const Color textoGris = Color(0xFF707579);

  static final ThemeData claro = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: azulTelegram,
      primary: azulTelegram,
      surface: fondoApp,
    ),
    scaffoldBackgroundColor: fondoApp,
    drawerTheme: const DrawerThemeData(
      backgroundColor: fondoApp,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: azulTelegram,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 2,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: azulTelegram,
      foregroundColor: Colors.white,
    ),
  );
}
