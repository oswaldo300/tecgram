import 'package:flutter/material.dart';
import 'package:tecgram/models/usuario.dart';
import 'package:tecgram/screens/pantalla_chats.dart';
import 'package:tecgram/theme/app_theme.dart';
import 'package:tecgram/utils/validadores.dart';
import 'package:tecgram/widgets/logo_tecgram.dart';
import 'package:tecgram/widgets/oso_login.dart';

// Pantalla de inicio de sesión.
// Validación básica (teléfono, nombre y clave) + bloqueo anti-spam:
// mientras _isLoading es true el botón queda deshabilitado (onPressed: null)
// y no se puede mandar el formulario dos veces.
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _telefonoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _claveController = TextEditingController();

  // Nodos de foco: sirven para que el oso mire al campo que se está llenando
  final _focoTelefono = FocusNode();
  final _focoNombre = FocusNode();
  final _focoClave = FocusNode();

  bool _isLoading = false;
  bool _claveOculta = true;
  bool _tapandoOjos = false;
  double _mirada = 0;

  @override
  void initState() {
    super.initState();
    // El oso reacciona según el campo activo
    _focoTelefono.addListener(() {
      if (_focoTelefono.hasFocus) setState(() => _mirada = -1);
    });
    _focoNombre.addListener(() {
      if (_focoNombre.hasFocus) setState(() => _mirada = 0);
    });
    _focoClave.addListener(() {
      setState(() => _tapandoOjos = _focoClave.hasFocus);
    });
  }

  @override
  void dispose() {
    // Siempre liberar controladores y focos, si no hay fugas de memoria
    _telefonoController.dispose();
    _nombreController.dispose();
    _claveController.dispose();
    _focoTelefono.dispose();
    _focoNombre.dispose();
    _focoClave.dispose();
    super.dispose();
  }

  // Simula el inicio de sesión (no hay servidor, es local)
  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    // Quita el teclado mientras "carga"
    FocusScope.of(context).unfocus();

    // Espera simulada, como si validara con un servidor
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    final usuario = Usuario.desdeNombre(
      _nombreController.text,
      _telefonoController.text,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PantallaChats(usuario: usuario)),
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
                OsoLogin(tapandoOjos: _tapandoOjos, mirada: _mirada),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _telefonoController,
                  focusNode: _focoTelefono,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Número de teléfono',
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
                const SizedBox(height: 14),
                TextFormField(
                  controller: _claveController,
                  focusNode: _focoClave,
                  obscureText: _claveOculta,
                  decoration: InputDecoration(
                    labelText: 'Clave',
                    hintText: 'Mínimo 4 caracteres',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _claveOculta ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _claveOculta = !_claveOculta);
                      },
                    ),
                  ),
                  validator: Validadores.clave,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    // Anti-spam: mientras carga, onPressed es null y
                    // el botón no responde a más toques
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
                            'ENTRAR',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Proyecto escolar — no se envían datos a ningún servidor.',
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
