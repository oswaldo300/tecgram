import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tecgram/firebase_options.dart';
import 'package:tecgram/models/usuario.dart';
import 'package:tecgram/screens/pantalla_chats.dart';
import 'package:tecgram/screens/pantalla_login.dart';
import 'package:tecgram/theme/app_theme.dart';

// Controla la animación de éxito del oso.
final ValueNotifier<bool> reproduciendoExitoLogin = ValueNotifier(false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Cerrar cualquier sesión anterior al iniciar la aplicación.
  await FirebaseAuth.instance.signOut();

  await FirebaseAuth.instance.useAuthEmulator(
    '127.0.0.1',
    9099,
    automaticHostMapping: false,
  );

  // Solo para pruebas locales con Firebase Emulator.
  await FirebaseAuth.instance.setSettings(
    appVerificationDisabledForTesting: true,
  );

  // Conectar Firestore al emulador.
  FirebaseFirestore.instance.useFirestoreEmulator(
    '127.0.0.1',
    8080,
    automaticHostMapping: false,
  );

  // Configurar idioma español.
  await FirebaseAuth.instance.setLanguageCode('es');

  // Inicializar Rive.
  await RiveFile.initialize();

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
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return const PantallaLogin();
    }

    return ValueListenableBuilder<bool>(
      valueListenable: reproduciendoExitoLogin,
      builder: (context, reproduciendo, _) {
        return StreamBuilder<User?>(
          initialData: FirebaseAuth.instance.currentUser,
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            final usuarioFirebase = snapshot.data;

            if (usuarioFirebase != null && !reproduciendo) {
              return PantallaChats(usuario: _usuarioDe(usuarioFirebase));
            }

            return const PantallaLogin();
          },
        );
      },
    );
  }

  Usuario _usuarioDe(User user) {
    final correo = user.email ?? '';
    var nombre = user.displayName?.trim() ?? '';

    if (nombre.isEmpty) {
      nombre = correo.split('@').first;
    }

    return Usuario.desdeNombre(nombre, user.phoneNumber ?? '', correo: correo);
  }
}
