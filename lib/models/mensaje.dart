// Un mensaje dentro de una sala de chat.
class Mensaje {
  final String texto;
  final DateTime hora;
  final bool esMio; // true = lo mandé yo, false = lo mandó el otro
  final bool leido;

  const Mensaje({
    required this.texto,
    required this.hora,
    required this.esMio,
    this.leido = false,
  });

  Mensaje copiadoComoLeido() {
    return Mensaje(texto: texto, hora: hora, esMio: esMio, leido: true);
  }
}
