import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tecgram/data/datos_ejemplo.dart';
import 'package:tecgram/models/chat.dart';
import 'package:tecgram/models/mensaje.dart';
import 'package:tecgram/theme/app_theme.dart';
import 'package:tecgram/widgets/burbuja_mensaje.dart';
import 'package:tecgram/widgets/logo_tecgram.dart';

// Sala de chat individual: burbujas de mensajes, campo de texto y botón
// de enviar. Al mandar un mensaje se agrega con setState y el contacto
// contesta solo después de un momento (respuesta simulada).
class PantallaChat extends StatefulWidget {
  final Chat chat;

  const PantallaChat({super.key, required this.chat});

  @override
  State<PantallaChat> createState() => _PantallaChatState();
}

class _PantallaChatState extends State<PantallaChat> {
  final _mensajeController = TextEditingController();
  final _scrollController = ScrollController();
  final _focoMensaje = FocusNode();
  final _random = Random();

  late List<Mensaje> _mensajes;
  bool _escribiendo = false; // muestra el "escribiendo..." del contacto
  Timer? _timerRespuesta;

  @override
  void initState() {
    super.initState();
    // Copia de los mensajes: así se pueden agregar sin tocar los datos base
    _mensajes = List.of(widget.chat.mensajes);
    // Baja hasta el último mensaje cuando se abre la sala
    WidgetsBinding.instance.addPostFrameCallback((_) => _bajarAlFinal());
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    _focoMensaje.dispose();
    _timerRespuesta?.cancel();
    super.dispose();
  }

  void _bajarAlFinal() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _enviarMensaje() {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _mensajes.add(
        Mensaje(texto: texto, hora: DateTime.now(), esMio: true),
      );
    });
    _mensajeController.clear();
    _bajarAlFinal();

    // El contacto "escribe" y contesta después de 1.5 segundos
    setState(() => _escribiendo = true);
    _timerRespuesta?.cancel();
    _timerRespuesta = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final respuesta =
          DatosEjemplo.respuestas[_random.nextInt(DatosEjemplo.respuestas.length)];
      setState(() {
        _escribiendo = false;
        _mensajes.add(
          Mensaje(texto: respuesta, hora: DateTime.now(), esMio: false),
        );
      });
      _bajarAlFinal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fondoChat,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            AvatarIniciales(
              iniciales: widget.chat.contacto.iniciales,
              nombre: widget.chat.contacto.nombre,
              radio: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.contacto.nombre,
                    style: const TextStyle(fontSize: 17),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _escribiendo ? 'escribiendo...' : 'en línea',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Las llamadas no están en este MVP'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opciones del chat')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _mensajes.length,
                itemBuilder: (context, index) {
                  return BurbujaMensaje(mensaje: _mensajes[index]);
                },
              ),
            ),
            if (_escribiendo)
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 4),
                  child: Text(
                    'escribiendo...',
                    style: TextStyle(color: AppTheme.textoGris, fontSize: 13),
                  ),
                ),
              ),
            _campoMensaje(),
          ],
        ),
      ),
    );
  }

  // Campo para escribir + botón de enviar (o micrófono si está vacío)
  Widget _campoMensaje() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            color: AppTheme.textoGris,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emojis próximamente')),
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: _mensajeController,
              focusNode: _focoMensaje,
              decoration: const InputDecoration(
                hintText: 'Mensaje',
                border: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _enviarMensaje(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.attach_file),
            color: AppTheme.textoGris,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Adjuntos próximamente')),
              );
            },
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.azulTelegram,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send),
              color: Colors.white,
              onPressed: _enviarMensaje,
            ),
          ),
        ],
      ),
    );
  }
}
