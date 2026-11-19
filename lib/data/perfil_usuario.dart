import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tecgram/models/usuario.dart';

// Perfil del usuario en Firestore (código de Diego): al entrar por teléfono,
// si el usuario no tiene documento en usuarios/{uid} se crea con sus datos;
// si ya existe, se recuperan los guardados. Se usa tanto cuando el código
// se verifica a mano como cuando el celular lo lee solo.
class PerfilUsuario {
  PerfilUsuario._();

  static Future<Usuario> guardarOCargar({
    required User usuarioFirebase,
    required String nombre,
    required String telefono,
  }) async {
    final referencia = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuarioFirebase.uid);

    final documento = await referencia.get();

    if (!documento.exists) {
      // Usuario nuevo: registrar sus datos.
      final nuevoUsuario = Usuario.desdeNombre(
        nombre,
        usuarioFirebase.phoneNumber ?? telefono,
        correo: usuarioFirebase.email ?? '',
      );

      await referencia.set({
        'uid': usuarioFirebase.uid,
        'nombre': nuevoUsuario.nombre,
        'telefono': nuevoUsuario.telefono,
        'correo': nuevoUsuario.correo,
        'iniciales': nuevoUsuario.iniciales,
        'fechaRegistro': FieldValue.serverTimestamp(),
        'activo': true,
      });

      await usuarioFirebase.updateDisplayName(nuevoUsuario.nombre);

      return nuevoUsuario;
    }

    // Usuario existente: recuperar sus datos.
    final datos = documento.data()!;
    final nombreGuardado = datos['nombre'] as String? ?? nombre;

    return Usuario(
      nombre: nombreGuardado,
      telefono:
          datos['telefono'] as String? ??
          usuarioFirebase.phoneNumber ??
          telefono,
      iniciales:
          datos['iniciales'] as String? ??
          Usuario.desdeNombre(
            nombreGuardado,
            usuarioFirebase.phoneNumber ?? telefono,
          ).iniciales,
      correo: datos['correo'] as String? ?? usuarioFirebase.email ?? '',
    );
  }
}
