import 'package:flutter/material.dart';

// Logo de TecGram dibujado con widgets (sin imagen externa).
// Es un avión de papel, como el de Telegram, dentro de un círculo azul.
// El logo oficial del ITM no se incluye: ver assets/images/README.md
class LogoTecGram extends StatelessWidget {
  final double tamano;

  const LogoTecGram({super.key, this.tamano = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF54A9EB), Color(0xFF0088CC)],
        ),
      ),
      child: Icon(
        Icons.send_rounded,
        color: Colors.white,
        size: tamano * 0.5,
      ),
    );
  }
}

// Avatar redondo con las iniciales del contacto, color según su nombre
// (así cada chat tiene su color sin necesidad de fotos).
class AvatarIniciales extends StatelessWidget {
  final String iniciales;
  final String nombre;
  final double radio;

  const AvatarIniciales({
    super.key,
    required this.iniciales,
    required this.nombre,
    this.radio = 26,
  });

  // Color fijo a partir del nombre, para que no cambie entre pantallas
  Color get _color {
    const colores = [
      Color(0xFF5B8DEF),
      Color(0xFF8E44AD),
      Color(0xFF27AE60),
      Color(0xFFE67E22),
      Color(0xFF16A085),
      Color(0xFFC0392B),
    ];
    var suma = 0;
    for (final c in nombre.codeUnits) {
      suma += c;
    }
    return colores[suma % colores.length];
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radio,
      backgroundColor: _color,
      child: Text(
        iniciales,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radio * 0.7,
        ),
      ),
    );
  }
}
