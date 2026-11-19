import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tecgram/data/perfil_usuario.dart';
import 'package:tecgram/screens/pantalla_chats.dart';
import 'package:tecgram/theme/app_theme.dart';
import 'package:tecgram/widgets/oso_login.dart';

// Pantalla donde se escribe el código de 6 dígitos que llegó por SMS.
// Si el número es nuevo, aquí se crea la cuenta y su perfil en Firestore;
// si ya existe, se recuperan sus datos guardados.
class PantallaVerificacion extends StatefulWidget {
  final String verificationId;
  final String telefono;
  final String nombre;
  final int? resendToken;

  const PantallaVerificacion({
    super.key,
    required this.verificationId,
    required this.telefono,
    required this.nombre,
    this.resendToken,
  });

  @override
  State<PantallaVerificacion> createState() => _PantallaVerificacionState();
}

class _PantallaVerificacionState extends State<PantallaVerificacion> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _focoCodigo = FocusNode();

  late String _verificationId;
  int? _resendToken;
  bool _isLoading = false;
  bool _tapandoOjos = false;
  int _exitos = 0;
  int _fallos = 0;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;
    _focoCodigo.addListener(() {
      if (!mounted) return;
      setState(() => _tapandoOjos = _focoCodigo.hasFocus);
    });
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _focoCodigo.dispose();
    super.dispose();
  }

  // Entrar con la credencial ya verificada (código escrito o leído solo):
  // guarda o carga el perfil en Firestore y abre la lista de chats.
  Future<void> _entrarConCredencial(PhoneAuthCredential credencial) async {
    final resultado = await FirebaseAuth.instance.signInWithCredential(
      credencial,
    );
    final usuarioFirebase = resultado.user;

    if (usuarioFirebase == null) {
      throw Exception('No se pudo obtener el usuario autenticado.');
    }

    final usuario = await PerfilUsuario.guardarOCargar(
      usuarioFirebase: usuarioFirebase,
      nombre: widget.nombre,
      telefono: '+52${widget.telefono}',
    );

    if (!mounted) return;

    // El oso celebra antes de entrar a los chats.
    setState(() => _exitos++);
    _mostrarMensaje('¡Bienvenido, ${usuario.nombre}!', esError: false);
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => PantallaChats(usuario: usuario)),
      (route) => false,
    );
  }

  Future<void> _verificarCodigo() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credencial = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _codigoController.text.trim(),
      );
      await _entrarConCredencial(credencial);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _fallos++);

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
      _mostrarMensaje(mensaje, esError: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _fallos++);
      _mostrarMensaje('Error inesperado: $e', esError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Pedir otro código al mismo número, sin volver al login.
  Future<void> _reenviarCodigo() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+52${widget.telefono}',
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _entrarConCredencial(credential);
          } catch (e) {
            if (!mounted) return;
            _mostrarMensaje('No se pudo iniciar sesión.', esError: true);
          } finally {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _fallos++;
          });
          _mostrarMensaje(
            e.message ?? 'No se pudo reenviar el código.',
            esError: true,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isLoading = false;
          });
          _codigoController.clear();
          _mostrarMensaje('Código reenviado.', esError: false);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // El usuario todavía puede introducir el código manualmente.
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _mostrarMensaje('No se pudo reenviar el código.', esError: true);
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
                  OsoLogin(
                    tapandoOjos: _tapandoOjos,
                    mirada: 0,
                    exitos: _exitos,
                    fallos: _fallos,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Verifica tu número',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
                    focusNode: _focoCodigo,
                    enabled: !_isLoading,
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
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'VERIFICAR CÓDIGO',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isLoading ? null : _reenviarCodigo,
                    child: const Text('Reenviar código'),
                  ),
                  const Text(
                    '¿No te llegó? Revisa tu señal o reenvía el código.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppTheme.textoGris),
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
