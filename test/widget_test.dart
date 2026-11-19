import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tecgram/main.dart';

void main() {
  testWidgets('La app arranca en el login', (tester) async {
    await tester.pumpWidget(const TecGramApp());

    // Título y campos del login
    expect(find.text('TecGram'), findsWidgets);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('El botón de entrar está habilitado al inicio', (tester) async {
    await tester.pumpWidget(const TecGramApp());

    final boton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(boton.onPressed, isNotNull);
  });
}
