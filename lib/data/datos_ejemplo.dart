import 'package:tecgram/models/chat.dart';
import 'package:tecgram/models/mensaje.dart';
import 'package:tecgram/models/usuario.dart';

// Datos de ejemplo: como no hay servidor, los chats viven aquí.
// Al abrir un chat, la lista de mensajes se copia para poder agregar
// mensajes nuevos sin tocar estos datos originales.
class DatosEjemplo {
  DatosEjemplo._();

  static final _ahora = DateTime.now();

  static DateTime hace({int minutos = 0, int horas = 0}) {
    return _ahora.subtract(Duration(minutes: minutos, hours: horas));
  }

  static List<Chat> get chats {
    return [
      Chat(
        id: '1',
        fijado: true,
        contacto: const Usuario(
          nombre: 'Equipo Proyecto Final',
          telefono: '9990000001',
          iniciales: 'PF',
        ),
        mensajes: [
          Mensaje(
            texto: '¿Ya quedó el login con el oso?',
            hora: hace(minutos: 12),
            esMio: false,
          ),
          Mensaje(
            texto: 'Ya casi, solo falta el bloqueo anti-spam',
            hora: hace(minutos: 10),
            esMio: true,
            leido: true,
          ),
          Mensaje(
            texto: 'Perfecto, mañana lo revisamos en clase',
            hora: hace(minutos: 5),
            esMio: false,
          ),
        ],
      ),
      Chat(
        id: '2',
        contacto: const Usuario(
          nombre: 'Ana Pérez',
          telefono: '9991234567',
          iniciales: 'AP',
        ),
        mensajes: [
          Mensaje(
            texto: '¿Me pasas tus apuntes de móvil?',
            hora: hace(minutos: 32),
            esMio: false,
          ),
          Mensaje(
            texto: 'Claro, te los mando en la noche',
            hora: hace(minutos: 28),
            esMio: true,
            leido: true,
          ),
        ],
      ),
      Chat(
        id: '3',
        contacto: const Usuario(
          nombre: 'Profe Carlos',
          telefono: '9997654321',
          iniciales: 'PC',
        ),
        mensajes: [
          Mensaje(
            texto: 'Recuerden: el proyecto se entrega el viernes',
            hora: hace(horas: 2),
            esMio: false,
          ),
          Mensaje(
            texto: 'Entendido, profe. Gracias',
            hora: hace(horas: 1, minutos: 50),
            esMio: true,
            leido: true,
          ),
        ],
      ),
      Chat(
        id: '4',
        contacto: const Usuario(
          nombre: 'Grupo Programación Móvil',
          telefono: '9990000004',
          iniciales: 'PM',
        ),
        mensajes: [
          Mensaje(
            texto: 'Luis: ¿alguien ya hizo el ListView.builder?',
            hora: hace(horas: 3),
            esMio: false,
          ),
        ],
      ),
      Chat(
        id: '5',
        contacto: const Usuario(
          nombre: 'Luis Tec',
          telefono: '9992223344',
          iniciales: 'LT',
        ),
        mensajes: [
          Mensaje(
            texto: 'Mañana nos vemos en la biblioteca',
            hora: hace(horas: 5),
            esMio: false,
          ),
          Mensaje(
            texto: 'Va, a las 10',
            hora: hace(horas: 5),
            esMio: true,
            leido: true,
          ),
        ],
      ),
      Chat(
        id: '6',
        contacto: const Usuario(
          nombre: 'Mamá',
          telefono: '9998887766',
          iniciales: 'M',
        ),
        mensajes: [
          Mensaje(
            texto: '¿Ya comiste, hijo?',
            hora: hace(horas: 7),
            esMio: false,
          ),
        ],
      ),
      Chat(
        id: '7',
        contacto: const Usuario(
          nombre: 'Biblioteca ITM',
          telefono: '9990000007',
          iniciales: 'BI',
        ),
        mensajes: [
          Mensaje(
            texto: 'Tu libro vence mañana, puedes renovarlo en línea',
            hora: hace(horas: 9),
            esMio: false,
            leido: true,
          ),
        ],
      ),
      Chat(
        id: '8',
        contacto: const Usuario(
          nombre: 'Servicio Social',
          telefono: '9990000008',
          iniciales: 'SS',
        ),
        mensajes: [
          Mensaje(
            texto: 'Faltan 20 horas por registrar este mes',
            hora: hace(horas: 26),
            esMio: false,
            leido: true,
          ),
        ],
      ),
    ];
  }

  // Respuestas automáticas para simular que el otro contesta
  static const respuestas = [
    '¡Va, suena bien!',
    'Ok, lo reviso y te digo',
    'Jaja, sí',
    'Perfecto, gracias',
    '¿Mañana en la escuela lo vemos?',
    'Claro, sin problema',
  ];
}
