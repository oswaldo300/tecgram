import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tecgram/models/usuario.dart';
import 'package:tecgram/screens/pantalla_chats.dart';
import 'package:tecgram/theme/app_theme.dart';

class PantallaVerificacion extends StatefulWidget {
  final String verificationId;
  final String telefono;
  final String nombre;

  const PantallaVerificacion({
    super.key,
    required this.verificationId,
    required this.telefono,
    required this.nombre,
  });

  @override
  State<PantallaVerificacion> createState() => _PantallaVerificacionState();
}

class _PantallaVerificacionState extends State<PantallaVerificacion> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _verificarCodigo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credencial = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _codigoController.text.trim(),
      );

      final resultado =
          await FirebaseAuth.instance.signInWithCredential(credencial);

      final usuarioFirebase = resultado.user;

      if (usuarioFirebase == null) {
        throw Exception('No se pudo obtener el usuario autenticado.');
      }

      // Referencia al documento del usuario mediante su UID.
      final referencia = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioFirebase.uid);

      // Consultar si el usuario ya está registrado.
      final documento = await referencia.get();

      late Usuario usuario;

      if (!documento.exists) {
        // Usuario nuevo: registrar sus datos.
        final nuevoUsuario = Usuario.desdeNombre(
          widget.nombre,
          usuarioFirebase.phoneNumber ?? '+52${widget.telefono}',
        );

        await referencia.set({
          'uid': usuarioFirebase.uid,
          'nombre': nuevoUsuario.nombre,
          'telefono': nuevoUsuario.telefono,
          'iniciales': nuevoUsuario.iniciales,
          'fechaRegistro': FieldValue.serverTimestamp(),
          'activo': true,
        });

        await usuarioFirebase.updateDisplayName(nuevoUsuario.nombre);

        usuario = nuevoUsuario;
      } else {
        // Usuario existente: recuperar sus datos.
        final datos = documento.data()!;

        final nombreGuardado = datos['nombre'] ?? widget.nombre;

        usuario = Usuario(
          nombre: nombreGuardado,
          telefono: datos['telefono'] ??
              usuarioFirebase.phoneNumber ??
              '+52${widget.telefono}',
          iniciales: datos['iniciales'] ??
              Usuario.desdeNombre(
                nombreGuardado,
                usuarioFirebase.phoneNumber ?? widget.telefono,
              ).iniciales,
        );
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => PantallaChats(usuario: usuario),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensaje;

      switch (e.code) {
        case 'invalid-verification-code':
          mensaje = 'El código introducido es incorrecto.';
          break;
        case 'session-expired':
          mensaje = 'El código expiró. Solicita uno nuevo.';
          break;
        case 'invalid-verification-id':
          mensaje = 'La sesión de verificación no es válida.';
          break;
        default:
          mensaje = e.message ?? 'No se pudo verificar el código.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar teléfono'),
        backgroundColor: AppTheme.azulTelegram,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sms_outlined,
                    size: 75,
                    color: AppTheme.azulTelegram,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Verifica tu número',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Introduce el código de seis dígitos enviado a '
                    '+52 ${widget.telefono}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textoGris,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _codigoController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Código de verificación',
                      hintText: '123456',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    validator: (valor) {
                      if (valor == null || valor.length != 6) {
                        return 'Introduce los seis dígitos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verificarCodigo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.azulTelegram,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'VERIFICAR CÓDIGO',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
