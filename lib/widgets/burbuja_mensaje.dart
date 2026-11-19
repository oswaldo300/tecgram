import 'package:flutter/material.dart';
import 'package:tecgram/models/mensaje.dart';
import 'package:tecgram/theme/app_theme.dart';

// Burbuja de mensaje: a la derecha y azul si es mía,
// a la izquierda y blanca si es del otro. Igual que en Telegram,
// la hora va dentro de la burbuja, abajo a la derecha.
class BurbujaMensaje extends StatelessWidget {
  final Mensaje mensaje;

  const BurbujaMensaje({super.key, required this.mensaje});

  String get _hora {
    final h = mensaje.hora;
    return '${h.hour}:${h.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final esMio = mensaje.esMio;
    return Align(
      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: esMio ? AppTheme.burbujaMia : AppTheme.burbujaOtro,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(esMio ? 14 : 4),
            bottomRight: Radius.circular(esMio ? 4 : 14),
          ),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 1, offset: Offset(0, 1)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                mensaje.texto,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _hora,
                  style:
                      const TextStyle(fontSize: 11, color: AppTheme.textoGris),
                ),
                if (esMio) ...[
                  const SizedBox(width: 3),
                  Icon(
                    mensaje.leido ? Icons.done_all : Icons.done,
                    size: 15,
                    color: mensaje.leido
                        ? AppTheme.azulTelegram
                        : AppTheme.textoGris,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
