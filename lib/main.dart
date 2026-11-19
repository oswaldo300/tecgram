import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tecgram/firebase_options.dart';
import 'package:tecgram/screens/pantalla_login.dart';
import 'package:tecgram/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Conectar Firebase Authentication al emulador local
  await FirebaseAuth.instance.useAuthEmulator(
    '10.0.2.2',
    9099,
  );

  FirebaseFirestore.instance.useFirestoreEmulator(
    '10.0.2.2',
    8080,
  );

  runApp(const TecGramApp());
}

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
