import 'package:tecgram/models/mensaje.dart';
import 'package:tecgram/models/usuario.dart';

// Una conversación de la bandeja de entrada: contacto + sus mensajes.
class Chat {
  final String id;
  final Usuario contacto;
  final List<Mensaje> mensajes;
  final bool fijado;
  final bool silenciado;

  const Chat({
    required this.id,
    required this.contacto,
    required this.mensajes,
    this.fijado = false,
    this.silenciado = false,
  });

  // Último mensaje, para mostrarlo en la lista de chats
  Mensaje? get ultimoMensaje => mensajes.isEmpty ? null : mensajes.last;

  // Cuántos mensajes sin leer tiene (solo los que me mandaron)
  int get sinLeer {
    return mensajes.where((m) => !m.esMio && !m.leido).length;
  }

  // Hora del último mensaje en formato corto: "10:24" o "ayer"
  String get horaCorta {
    final ultimo = ultimoMensaje;
    if (ultimo == null) return '';
    final ahora = DateTime.now();
    final h = ultimo.hora;
    if (h.day == ahora.day && h.month == ahora.month) {
      final mm = h.minute.toString().padLeft(2, '0');
      return '${h.hour}:$mm';
    }
    return 'ayer';
  }
}
