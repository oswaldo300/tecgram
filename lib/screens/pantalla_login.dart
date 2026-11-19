import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tecgram/main.dart';
import 'package:tecgram/screens/pantalla_registro.dart';
import 'package:tecgram/theme/app_theme.dart';
import 'package:tecgram/utils/validadores.dart';
import 'package:tecgram/widgets/logo_tecgram.dart';
import 'package:tecgram/widgets/oso_login.dart';

// Login con correo y contraseña, como en login_osito_rive.
// El oso mira el campo activo, sigue lo que se escribe en el correo,
// se tapa los ojos al escribir la contraseña y reacciona al resultado.
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();

  final _focoCorreo = FocusNode();
  final _focoClave = FocusNode();

  bool _isLoading = false;
  bool _ocultarClave = true;
  bool _tapandoOjos = false;
  bool _mirandoCampo = false;
  double _mirada = -1;
  int _exitos = 0;
  int _fallos = 0;

  @override
  void initState() {
    super.initState();

    _focoCorreo.addListener(() {
      if (!mounted) return;
      setState(() {
        _mirandoCampo = _focoCorreo.hasFocus;
        if (_focoCorreo.hasFocus) _tapandoOjos = false;
      });
    });

    _focoClave.addListener(() {
      if (!mounted) return;
      setState(() {
        _mirandoCampo = false;
        _tapandoOjos = _focoClave.hasFocus && _ocultarClave;
      });
    });
  }

  @override
  void dispose() {
    _correoController.dispose();
    _claveController.dispose();
    _focoCorreo.dispose();
    _focoClave.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _mirandoCampo = false;
      _tapandoOjos = false;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() => _fallos++);
      return;
    }

    setState(() => _isLoading = true);
    reproduciendoExitoLogin.value = true;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _correoController.text.trim(),
        password: _claveController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _exitos++);
      _mostrarMensaje('¡Bienvenido! Iniciando sesión...', esError: false);

      await Future.delayed(const Duration(milliseconds: 1600));
      reproduciendoExitoLogin.value = false;
    } on FirebaseAuthException catch (e) {
      reproduciendoExitoLogin.value = false;
      if (!mounted) return;
      setState(() => _fallos++);
      _mostrarMensaje(_mensajeError(e.code), esError: true);
    } catch (_) {
      reproduciendoExitoLogin.value = false;
      if (!mounted) return;
      setState(() => _fallos++);
      _mostrarMensaje('Ocurrió un error inesperado al conectar', esError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _recuperarClave() async {
    final correoController = TextEditingController(
      text: _correoController.text.trim(),
    );

    FocusScope.of(context).unfocus();
    setState(() {
      _mirandoCampo = false;
      _tapandoOjos = false;
    });

    final correo = await showDialog<String>(
      context: context,
      builder: (contextDialogo) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Recuperar contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Escribe tu correo y te enviaremos un enlace para restablecer tu contraseña.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: correoController,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(contextDialogo).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.azulTelegram,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(contextDialogo).pop(correoController.text.trim());
              },
              child: const Text('Enviar enlace'),
            ),
          ],
        );
      },
    );

    correoController.dispose();

    if (correo == null || !mounted) return;

    final error = Validadores.correo(correo);
    if (error != null) {
      setState(() => _fallos++);
      _mostrarMensaje(error, esError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: correo);
      if (!mounted) return;
      setState(() => _exitos++);
      _mostrarMensaje(
        'Correo de recuperación enviado a $correo. Revisa tu bandeja o spam.',
        esError: false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _fallos++);
      _mostrarMensaje(_mensajeError(e.code), esError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _fallos++);
      _mostrarMensaje(
        'No se pudo enviar el correo de recuperación',
        esError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mensajeError(String codigo) {
    switch (codigo) {
      case 'invalid-email':
        return 'El formato del correo no es válido';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento';
      case 'user-disabled':
        return 'Esta cuenta está deshabilitada';
      case 'network-request-failed':
        return 'Sin conexión. Revisa tu internet e inténtalo de nuevo';
      default:
        return 'Error de autenticación ($codigo)';
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
                  style: TextStyle(color: AppTheme.textoGris, fontSize: 13),
                ),
                const SizedBox(height: 12),

                OsoLogin(
                  tapandoOjos: _tapandoOjos,
                  mirada: _mirada,
                  mirandoCampo: _mirandoCampo,
                  exitos: _exitos,
                  fallos: _fallos,
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _correoController,
                  focusNode: _focoCorreo,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (texto) {
                    final vista = (texto.length * 2.0).clamp(0, 100);
                    setState(() => _mirada = vista / 50 - 1);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'ana@ejemplo.com',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: Validadores.correo,
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _claveController,
                  focusNode: _focoClave,
                  enabled: !_isLoading,
                  obscureText: _ocultarClave,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarClave ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _ocultarClave = !_ocultarClave;
                          if (_focoClave.hasFocus) {
                            _tapandoOjos = _ocultarClave;
                          }
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: Validadores.clave,
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _recuperarClave,
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),

                const SizedBox(height: 8),

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
                        : const Text('ENTRAR', style: TextStyle(fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes cuenta?'),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PantallaRegistro(),
                                ),
                              );
                            },
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
