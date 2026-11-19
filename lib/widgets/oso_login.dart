import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

// Oso animado del login, estilo Telegram.
// Carga el archivo Rive (assets/rive/oso_login.riv) y maneja su state
// machine: mira al campo activo, se tapa los ojos al escribir algo
// secreto y reacciona cuando el login sale bien o mal.
// Si el archivo no está, muestra el oso dibujado con widgets.
class OsoLogin extends StatefulWidget {
  // true = el usuario está escribiendo algo secreto (el oso se tapa los ojos)
  final bool tapandoOjos;
  // -1 = mira a la izquierda, 0 = al centro, 1 = a la derecha
  final double mirada;
  // true = algún campo tiene el foco (el oso está atento)
  final bool mirandoCampo;
  // Cada vez que sube este número, el oso celebra (login correcto)
  final int exitos;
  // Cada vez que sube este número, el oso se lamenta (login fallido)
  final int fallos;

  const OsoLogin({
    super.key,
    this.tapandoOjos = false,
    this.mirada = 0,
    this.mirandoCampo = false,
    this.exitos = 0,
    this.fallos = 0,
  });

  @override
  State<OsoLogin> createState() => _OsoLoginState();
}

class _OsoLoginState extends State<OsoLogin> {
  bool _tieneRive = false;

  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMINumber? _numLook;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  @override
  void initState() {
    super.initState();
    _buscarArchivoRive();
  }

  // Checa si el .riv está en assets; si no, se usa el oso dibujado.
  Future<void> _buscarArchivoRive() async {
    try {
      await rootBundle.load('assets/rive/oso_login.riv');
      if (mounted) setState(() => _tieneRive = true);
    } catch (_) {
      // No hay archivo Rive, no pasa nada: se dibuja el oso con widgets.
    }
  }

  void _onRiveInit(Artboard artboard) {
    final machineName = artboard.stateMachines.isNotEmpty
        ? artboard.stateMachines.first.name
        : 'Login Machine';
    final controller = StateMachineController.fromArtboard(
      artboard,
      machineName,
    );
    if (controller != null) {
      artboard.addController(controller);
      _isChecking = controller.findInput<bool>('isChecking') as SMIBool?;
      _isHandsUp = controller.findInput<bool>('isHandsUp') as SMIBool?;
      _numLook = controller.findInput<double>('numLook') as SMINumber?;
      _trigSuccess = controller.findInput<bool>('trigSuccess') as SMITrigger?;
      _trigFail = controller.findInput<bool>('trigFail') as SMITrigger?;
      _aplicarEstado();
    }
  }

  // Pasa los valores del widget a los inputs de la animación
  void _aplicarEstado() {
    _isChecking?.change(widget.mirandoCampo);
    _isHandsUp?.change(widget.tapandoOjos);
    _numLook?.change(((widget.mirada + 1) * 50).clamp(0, 100).toDouble());
  }

  @override
  void didUpdateWidget(OsoLogin oldWidget) {
    super.didUpdateWidget(oldWidget);
    _aplicarEstado();
    if (widget.exitos > oldWidget.exitos) {
      _trigSuccess?.fire();
    }
    if (widget.fallos > oldWidget.fallos) {
      _trigFail?.fire();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tieneRive) {
      return SizedBox(
        height: 180,
        child: RiveAnimation.asset(
          'assets/rive/oso_login.riv',
          fit: BoxFit.contain,
          onInit: _onRiveInit,
        ),
      );
    }
    return _OsoDibujado(tapandoOjos: widget.tapandoOjos, mirada: widget.mirada);
  }
}

// Oso hecho con puros widgets: círculo café, orejas, ojos y hocico.
// Las pupilas se mueven con AnimatedPositioned según el campo activo.
class _OsoDibujado extends StatelessWidget {
  final bool tapandoOjos;
  final double mirada;

  const _OsoDibujado({required this.tapandoOjos, required this.mirada});

  Widget _ojo() {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            left: 9 + mirada * 5,
            top: 9,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Orejas
          Positioned(top: 8, left: 62, child: _oreja()),
          Positioned(top: 8, right: 62, child: _oreja()),
          // Cabeza
          Container(
            width: 130,
            height: 130,
            decoration: const BoxDecoration(
              color: Color(0xFFB07D4F),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ojos
                Positioned(top: 42, left: 28, child: _ojo()),
                Positioned(top: 42, right: 28, child: _ojo()),
                // Hocico
                Positioned(
                  bottom: 22,
                  child: Container(
                    width: 56,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8C39E),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('• ᴥ •', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Patas que tapan los ojos al escribir la clave
          AnimatedOpacity(
            opacity: tapandoOjos ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_pata(), const SizedBox(width: 30), _pata()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _oreja() {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: Color(0xFFB07D4F),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xFFE8C39E),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _pata() {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFF8A5A33),
        shape: BoxShape.circle,
      ),
    );
  }
}
