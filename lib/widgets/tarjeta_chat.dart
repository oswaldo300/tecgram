import 'package:flutter/material.dart';
import 'package:tecgram/models/chat.dart';
import 'package:tecgram/theme/app_theme.dart';
import 'package:tecgram/widgets/logo_tecgram.dart';

// Un renglón de la bandeja de entrada: avatar, nombre, último mensaje,
// hora y contador de mensajes sin leer.
class TarjetaChat extends StatelessWidget {
  final Chat chat;
  final VoidCallback alTocar;

  const TarjetaChat({super.key, required this.chat, required this.alTocar});

  @override
  Widget build(BuildContext context) {
    final ultimo = chat.ultimoMensaje;
    return ListTile(
      onTap: alTocar,
      leading: AvatarIniciales(
        iniciales: chat.contacto.iniciales,
        nombre: chat.contacto.nombre,
      ),
      title: Row(
        children: [
          if (chat.fijado)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.push_pin, size: 14, color: AppTheme.textoGris),
            ),
          Expanded(
            child: Text(
              chat.contacto.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Text(
            chat.horaCorta,
            style: TextStyle(
              fontSize: 12,
              color:
                  chat.sinLeer > 0 ? AppTheme.azulTelegram : AppTheme.textoGris,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          if (ultimo != null && ultimo.esMio)
            const Padding(
              padding: EdgeInsets.only(right: 3),
              child:
                  Icon(Icons.done_all, size: 16, color: AppTheme.azulTelegram),
            ),
          Expanded(
            child: Text(
              ultimo?.texto ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textoGris),
            ),
          ),
          if (chat.sinLeer > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: const BoxDecoration(
                color: AppTheme.azulTelegram,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${chat.sinLeer}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
