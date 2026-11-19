import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tecgram/models/usuario.dart';
import 'package:tecgram/screens/pantalla_chats.dart';
import 'package:tecgram/screens/pantalla_verificacion.dart';
import 'package:tecgram/theme/app_theme.dart';
import 'package:tecgram/utils/validadores.dart';
import 'package:tecgram/widgets/logo_tecgram.dart';
import 'package:tecgram/widgets/oso_login.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _telefonoController = TextEditingController();
  final _nombreController = TextEditingController();

  final _focoTelefono = FocusNode();
  final _focoNombre = FocusNode();

  bool _isLoading = false;
  bool _navegando = false;
  double _mirada = 0;

  @override
  void initState() {
    super.initState();

    _focoTelefono.addListener(() {
      if (_focoTelefono.hasFocus) {
        setState(() => _mirada = -1);
      }
    });

    _focoNombre.addListener(() {
      if (_focoNombre.hasFocus) {
        setState(() => _mirada = 0);
      }
    });
  }

  @override
  void dispose() {
    _telefonoController.dispose();
    _nombreController.dispose();
    _focoTelefono.dispose();
    _focoNombre.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _navegando = false;
    });

    FocusScope.of(context).unfocus();

    final telefono = _telefonoController.text.replaceAll(
      RegExp(r'\D'),
      '',
    );

    final nombre = _nombreController.text.trim();
    final telefonoCompleto = '+52$telefono';

    try {
      await FirebaseAuth.instance.setLanguageCode('es');

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: telefonoCompleto,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          if (_navegando || !mounted) return;

          _navegando = true;

          try {
            final resultado = await FirebaseAuth.instance
                .signInWithCredential(credential);

            await resultado.user?.updateDisplayName(nombre);

            if (!mounted) return;

            final usuario = Usuario.desdeNombre(nombre, telefono);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PantallaChats(usuario: usuario),
              ),
            );
          } on FirebaseAuthException catch (e) {
            _mostrarError(e.message ?? 'No se pudo iniciar sesión.');
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() => _isLoading = false);

          String mensaje;

          switch (e.code) {
            case 'invalid-phone-number':
              mensaje = 'El número de teléfono no es válido.';
              break;
            case 'too-many-requests':
              mensaje = 'Demasiados intentos. Inténtalo más tarde.';
              break;
            case 'quota-exceeded':
              mensaje = 'Se alcanzÃ³ el lÃ­mite de SMS de Firebase.';
              break;
            default:
              mensaje = e.message ?? 'No se pudo enviar el código.';
          }

          _mostrarError(mensaje);
        },

        codeSent: (String verificationId, int? resendToken) {
          if (!mounted || _navegando) return;

          _navegando = true;
          setState(() => _isLoading = false);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PantallaVerificacion(
                verificationId: verificationId,
                telefono: telefono,
                nombre: nombre,
              ),
            ),
          );
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          // El usuario todavía puede introducir el código manualmente.
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _mostrarError(e.message ?? 'Ocurrió un error de autenticaciÃ³n.');
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _mostrarError('Ocurrió un error inesperado: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 8),
                const LogoTecGram(tamano: 64),
                const SizedBox(height: 4),
                const Text(
                  'TecGram',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.azulTelegram,
                  ),
                ),
                const Text(
                  'Mensajería del Instituto Tecnológico de Mérida',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textoGris,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),

                OsoLogin(
                  tapandoOjos: false,
                  mirada: _mirada,
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _telefonoController,
                  focusNode: _focoTelefono,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'NÃºmero de teléfono',
                    hintText: '9991234567',
                    prefixText: '+52 ',
                    prefixIcon: Icon(Icons.phone_android),
                    border: OutlineInputBorder(),
                  ),
                  validator: Validadores.telefono,
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _nombreController,
                  focusNode: _focoNombre,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Tu nombre',
                    hintText: 'Ana Pérez',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: Validadores.nombre,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.azulTelegram,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'ENVIAR CÓDIGO SMS',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Recibirás un SMS para verificar tu número. '
                  'Pueden aplicarse tarifas de mensajes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textoGris,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
