import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tecgram/main.dart';
import 'package:tecgram/theme/app_theme.dart';
import 'package:tecgram/utils/validadores.dart';
import 'package:tecgram/widgets/oso_login.dart';

// Crear cuenta con correo y contraseña, como en login_osito_rive.
// El nombre se guarda como nombre para mostrar en Firebase.
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();
  final _confirmarController = TextEditingController();

  final _focoNombre = FocusNode();
  final _focoCorreo = FocusNode();
  final _focoClave = FocusNode();
  final _focoConfirmar = FocusNode();

  bool _isLoading = false;
  bool _ocultarClave = true;
  bool _ocultarConfirmar = true;
  bool _tapandoOjos = false;
  bool _mirandoCampo = false;
  double _mirada = -1;
  int _exitos = 0;
  int _fallos = 0;

  @override
  void initState() {
    super.initState();

    _focoNombre.addListener(() {
      if (!mounted) return;
      setState(() {
        _mirandoCampo = _focoNombre.hasFocus;
        if (_focoNombre.hasFocus) _tapandoOjos = false;
      });
    });

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

    _focoConfirmar.addListener(() {
      if (!mounted) return;
      setState(() {
        _mirandoCampo = false;
        _tapandoOjos = _focoConfirmar.hasFocus && _ocultarConfirmar;
      });
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _claveController.dispose();
    _confirmarController.dispose();
    _focoNombre.dispose();
    _focoCorreo.dispose();
    _focoClave.dispose();
    _focoConfirmar.dispose();
    super.dispose();
  }

  Future<void> _crearCuenta() async {
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
      final credencial = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _correoController.text.trim(),
            password: _claveController.text.trim(),
          );

      await credencial.user?.updateDisplayName(_nombreController.text.trim());

      if (!mounted) return;
      setState(() => _exitos++);
      _mostrarMensaje('¡Cuenta creada! Entrando...', esError: false);

      await Future.delayed(const Duration(milliseconds: 1600));
      reproduciendoExitoLogin.value = false;

      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      reproduciendoExitoLogin.value = false;
      if (!mounted) return;
      setState(() => _fallos++);
      _mostrarMensaje(_mensajeError(e.code), esError: true);
    } catch (_) {
      reproduciendoExitoLogin.value = false;
      if (!mounted) return;
      setState(() => _fallos++);
      _mostrarMensaje('Error inesperado al crear la cuenta', esError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mensajeError(String codigo) {
    switch (codigo) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'invalid-email':
        return 'El formato del correo no es válido';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'operation-not-allowed':
        return 'El registro con correo está deshabilitado en Firebase';
      default:
        return 'Error al registrar ($codigo)';
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
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                OsoLogin(
                  tapandoOjos: _tapandoOjos,
                  mirada: _mirada,
                  mirandoCampo: _mirandoCampo,
                  exitos: _exitos,
                  fallos: _fallos,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _nombreController,
                  focusNode: _focoNombre,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Tu nombre',
                    hintText: 'Ana Pérez',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: Validadores.nombre,
                ),

                const SizedBox(height: 14),

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
                    hintText: 'Mínimo 6 caracteres',
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

                const SizedBox(height: 14),

                TextFormField(
                  controller: _confirmarController,
                  focusNode: _focoConfirmar,
                  enabled: !_isLoading,
                  obscureText: _ocultarConfirmar,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarConfirmar
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _ocultarConfirmar = !_ocultarConfirmar;
                          if (_focoConfirmar.hasFocus) {
                            _tapandoOjos = _ocultarConfirmar;
                          }
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Confirma tu contraseña';
                    }
                    if (valor != _claveController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _crearCuenta,
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
                            'CREAR CUENTA',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes cuenta?'),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text(
                        'Entrar',
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
