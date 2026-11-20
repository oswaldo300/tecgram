import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tecgram/data/perfil_usuario.dart';
import 'package:tecgram/screens/pantalla_chats.dart';
import 'package:tecgram/screens/pantalla_verificacion.dart';
import 'package:tecgram/theme/app_theme.dart';
import 'package:tecgram/utils/validadores.dart';
import 'package:tecgram/widgets/logo_tecgram.dart';
import 'package:tecgram/widgets/oso_login.dart';

// Entrar con número de celular, como Telegram: se escribe el número y el
// nombre, Firebase manda un SMS con un código y se verifica en la siguiente
// pantalla. Si es la primera vez, la verificación crea la cuenta.
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
  bool _mirandoCampo = false;
  double _mirada = 0;
  int _fallos = 0;

  @override
  void initState() {
    super.initState();

    _focoTelefono.addListener(() {
      if (!mounted) return;
      setState(() => _mirandoCampo = _focoTelefono.hasFocus);
    });

    _focoNombre.addListener(() {
      if (!mounted) return;
      setState(() {
        _mirandoCampo = _focoNombre.hasFocus;
        if (_focoNombre.hasFocus) _mirada = 0;
      });
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
    FocusScope.of(context).unfocus();
    setState(() => _mirandoCampo = false);

    if (!_formKey.currentState!.validate()) {
      setState(() => _fallos++);
      return;
    }

    setState(() {
      _isLoading = true;
      _navegando = false;
    });

    final telefono = _telefonoController.text.replaceAll(RegExp(r'\D'), '');
    final nombre = _nombreController.text.trim();
    final telefonoCompleto = '+52$telefono';

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: telefonoCompleto,
        timeout: const Duration(seconds: 60),

        // En algunos celulares el código se lee solo y entra directo.
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (_navegando || !mounted) return;
          _navegando = true;

          try {
            final resultado = await FirebaseAuth.instance.signInWithCredential(
              credential,
            );
            final usuarioFirebase = resultado.user;
            if (usuarioFirebase == null) {
              throw Exception('No se pudo obtener el usuario autenticado.');
            }

            final usuario = await PerfilUsuario.guardarOCargar(
              usuarioFirebase: usuarioFirebase,
              nombre: nombre,
              telefono: telefonoCompleto,
            );

            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => PantallaChats(usuario: usuario),
              ),
              (route) => false,
            );
          } catch (e) {
            _navegando = false;
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _fallos++;
            });
            _mostrarMensaje('No se pudo iniciar sesión.', esError: true);
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          _navegando = false;
          setState(() {
            _isLoading = false;
            _fallos++;
          });

          String mensaje;
          switch (e.code) {
            case 'invalid-phone-number':
              mensaje = 'El número de teléfono no es válido.';
              break;
            case 'too-many-requests':
              mensaje = 'Demasiados intentos. Inténtalo más tarde.';
              break;
            case 'quota-exceeded':
              mensaje = 'Se alcanzó el límite de SMS de Firebase.';
              break;
            default:
              mensaje = e.message ?? 'No se pudo enviar el código.';
          }
          _mostrarMensaje(mensaje, esError: true);
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
                resendToken: resendToken,
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
      _navegando = false;
      setState(() {
        _isLoading = false;
        _fallos++;
      });
      _mostrarMensaje(
        e.message ?? 'Ocurrió un error de autenticación.',
        esError: true,
      );
    } catch (e) {
      if (!mounted) return;
      _navegando = false;
      setState(() {
        _isLoading = false;
        _fallos++;
      });
      _mostrarMensaje('Ocurrió un error inesperado: $e', esError: true);
    }
  }

  void _mostrarMensaje(String texto, {required bool esError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 8),
                const LogoTecGram(tamano: 64),
                const SizedBox(height: 4),
                const Text(
                  'TaroGram',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 142, 34, 209),
                  ),
                ),
                const SizedBox(height: 12),

                OsoLogin(
                  tapandoOjos: false,
                  mirada: _mirada,
                  mirandoCampo: _mirandoCampo,
                  fallos: _fallos,
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _telefonoController,
                  focusNode: _focoTelefono,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.phone,
                  onChanged: (texto) {
                    final vista = (texto.length * 2.0).clamp(0, 100);
                    setState(() => _mirada = vista / 50 - 1);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Número de teléfono',
                    hintText: 'Ej. 9991234567',
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
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Tu nombre',
                    hintText: 'Ej. Ana Pérez',
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
                      backgroundColor: Color.fromARGB(255, 142, 34, 209),
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
                  style: TextStyle(fontSize: 12, color: AppTheme.textoGris),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
