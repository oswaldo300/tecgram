import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tecgram/main.dart';

void main() {
  testWidgets('La app arranca en el login por teléfono', (tester) async {
    await tester.pumpWidget(const TecGramApp());

    // Título y campos del login
    expect(find.text('TecGram'), findsWidgets);
    expect(find.text('Número de teléfono'), findsOneWidget);
    expect(find.text('Tu nombre'), findsOneWidget);
    expect(find.text('ENVIAR CÓDIGO SMS'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('El botón de enviar código está habilitado al inicio', (
    tester,
  ) async {
    await tester.pumpWidget(const TecGramApp());

    final boton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(boton.onPressed, isNotNull);
  });
}
