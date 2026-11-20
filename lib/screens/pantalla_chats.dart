import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tecgram/data/datos_ejemplo.dart';
import 'package:tecgram/models/chat.dart';
import 'package:tecgram/models/usuario.dart';
import 'package:tecgram/screens/pantalla_chat.dart';
import 'package:tecgram/screens/pantalla_login.dart';
import 'package:tecgram/theme/app_theme.dart';
import 'package:tecgram/widgets/logo_tecgram.dart';
import 'package:tecgram/widgets/tarjeta_chat.dart';

// Bandeja de entrada: lista de conversaciones.
// Se usa ListView.builder para que solo se dibujen los renglones visibles
// (así no gasta memoria aunque haya muchos chats).
class PantallaChats extends StatefulWidget {
  final Usuario usuario;

  const PantallaChats({super.key, required this.usuario});

  @override
  State<PantallaChats> createState() => _PantallaChatsState();
}

class _PantallaChatsState extends State<PantallaChats> {
  final _busquedaController = TextEditingController();
  List<Chat> _chats = [];
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _chats = DatosEjemplo.chats;
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  // Chats que coinciden con lo que se escribió en el buscador
  List<Chat> get _chatsFiltrados {
    if (_filtro.isEmpty) return _chats;
    final q = _filtro.toLowerCase();
    return _chats
        .where((c) => c.contacto.nombre.toLowerCase().contains(q))
        .toList();
  }

  // Abre la sala de chat y al regresar marca sus mensajes como leídos
  Future<void> _abrirChat(Chat chat) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PantallaChat(chat: chat)),
    );
    setState(() {
      final i = _chats.indexWhere((c) => c.id == chat.id);
      if (i >= 0) {
        final leidos = chat.mensajes.map((m) => m.copiadoComoLeido()).toList();
        _chats[i] = Chat(
          id: chat.id,
          contacto: chat.contacto,
          mensajes: leidos,
          fijado: chat.fijado,
          silenciado: chat.silenciado,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _chatsFiltrados;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TaroGram',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Usa el buscador de abajo para filtrar chats'),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (valor) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$valor estará disponible pronto')),
              );
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'Nuevo grupo', child: Text('Nuevo grupo')),
              PopupMenuItem(value: 'Ajustes', child: Text('Ajustes')),
            ],
          ),
        ],
      ),
      drawer: _menuLateral(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                hintText: 'Buscar chats',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFEBE0F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (texto) => setState(() => _filtro = texto),
            ),
          ),
          Expanded(
            child: filtrados.isEmpty
                ? const Center(child: Text('No hay chats con ese nombre'))
                : ListView.builder(
                    itemCount: filtrados.length,
                    itemBuilder: (context, index) {
                      final chat = filtrados[index];
                      return TarjetaChat(
                        chat: chat,
                        alTocar: () => _abrirChat(chat),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nuevo chat: elige un contacto de la lista'),
            ),
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  // Cierra la sesión en Firebase y regresa a la pantalla de inicio de sesión
  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que deseas cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cerrar sesión: $e')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PantallaLogin()),
      (route) => false,
    );
  }

  // Menú lateral estilo Telegram con los datos del usuario
  Widget _menuLateral() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppTheme.azulTelegram,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AvatarIniciales(
                    iniciales: widget.usuario.iniciales,
                    nombre: widget.usuario.nombre,
                    radio: 32,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.usuario.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.usuario.correo.isNotEmpty
                        ? widget.usuario.correo
                        : '${widget.usuario.telefono}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Nuevo grupo'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Contactos'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Mensajes guardados'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes'),
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade700),
              title: Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _cerrarSesion();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'TaroGram v1.0.0',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
