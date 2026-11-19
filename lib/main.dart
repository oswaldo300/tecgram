import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'package:tecgram/firebase_options.dart';
import 'package:tecgram/models/usuario.dart';
import 'package:tecgram/screens/pantalla_chats.dart';
import 'package:tecgram/screens/pantalla_login.dart';
import 'package:tecgram/theme/app_theme.dart';

// Mientras vale true, la pantalla no cambia aunque ya haya sesión:
// así se alcanza a ver la animación de éxito del oso.
final ValueNotifier<bool> reproduciendoExitoLogin = ValueNotifier(false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase con el proyecto real (sin emulador)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Correos de Firebase (recuperar contraseña) en español
  await FirebaseAuth.instance.setLanguageCode('es');

  // Necesario para cargar archivos .riv con Rive
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

// Si hay sesión activa, entra directo a los chats; si no, al login.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // En pruebas no hay Firebase inicializado: se muestra el login directo.
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

  // El usuario de Firebase a Usuario de TecGram: el nombre es el nombre
  // para mostrar, y si no tiene, la parte del correo antes de la @.
  Usuario _usuarioDe(User user) {
    final correo = user.email ?? '';
    var nombre = user.displayName?.trim() ?? '';
    if (nombre.isEmpty) {
      nombre = correo.split('@').first;
    }
    return Usuario.desdeNombre(nombre, user.phoneNumber ?? '', correo: correo);
  }
}
