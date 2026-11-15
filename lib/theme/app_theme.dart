import 'package:flutter/material.dart';

// Colores y tema de TecGram.
// La paleta toma el azul clásico de Telegram (#0088cc) y lo combina
// con el azul institucional del Tecnológico de Mérida.
class AppTheme {
  AppTheme._();

  static const Color azulTelegram = Color(0xFF0088CC);
  static const Color azulClaro = Color(0xFF54A9EB);
  static const Color azulOscuro = Color(0xFF0B4F71);
  static const Color azulTec = Color(0xFF003B71);

  // Fondo de la sala de chat (tono gris azulado, como el de Telegram)
  static const Color fondoChat = Color(0xFFE7EBF0);

  // Burbujas: la mía en azul claro, la del otro en blanco
  static const Color burbujaMia = Color(0xFFD6ECFA);
  static const Color burbujaOtro = Color(0xFFFFFFFF);

  static const Color textoGris = Color(0xFF707579);

  static final ThemeData claro = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: azulTelegram,
      primary: azulTelegram,
    ),
    scaffoldBackgroundColor: Colors.white,
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
