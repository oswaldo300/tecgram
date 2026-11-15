import 'package:flutter/material.dart';
import 'package:tecgram/screens/pantalla_login.dart';
import 'package:tecgram/theme/app_theme.dart';

void main() {
  runApp(const TecGramApp());
}

// Raíz de la app. Aquí solo se configura el tema y la pantalla inicial,
// toda la lógica vive en sus propias carpetas (screens, models, data).
class TecGramApp extends StatelessWidget {
  const TecGramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TecGram',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      home: const PantallaLogin(),
    );
  }
}
