import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

// Oso animado del login, estilo Telegram.
// Primero intenta cargar el archivo Rive (assets/rive/oso_login.riv).
// Si el archivo no existe, muestra el oso dibujado con widgets:
// los ojos siguen el campo activo y se tapa los ojos al escribir la clave.
class OsoLogin extends StatefulWidget {
  // true = el usuario está escribiendo la clave (el oso se tapa los ojos)
  final bool tapandoOjos;
  // -1 = mira a la izquierda (teléfono), 1 = a la derecha, 0 = al centro
  final double mirada;

  const OsoLogin({super.key, this.tapandoOjos = false, this.mirada = 0});

  @override
  State<OsoLogin> createState() => _OsoLoginState();
}

class _OsoLoginState extends State<OsoLogin> {
  bool _tieneRive = false;

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

  @override
  Widget build(BuildContext context) {
    if (_tieneRive) {
      // Animación de Rive (state machine "Login Machine" del oso clásico)
      return const SizedBox(
        height: 180,
        child: RiveAnimation.asset(
          'assets/rive/oso_login.riv',
          fit: BoxFit.contain,
        ),
      );
    }
    return _OsoDibujado(
      tapandoOjos: widget.tapandoOjos,
      mirada: widget.mirada,
    );
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
          Positioned(
            top: 8,
            left: 62,
            child: _oreja(),
          ),
          Positioned(
            top: 8,
            right: 62,
            child: _oreja(),
          ),
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
                Positioned(
                  top: 42,
                  left: 28,
                  child: _ojo(),
                ),
                Positioned(
                  top: 42,
                  right: 28,
                  child: _ojo(),
                ),
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
              children: [
                _pata(),
                const SizedBox(width: 30),
                _pata(),
              ],
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
