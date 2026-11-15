# TecGram

Clon de Telegram hecho en Flutter. Proyecto final de la materia de
Programación Móvil — Instituto Tecnológico de Mérida.

TecGram replica las funciones básicas de Telegram: inicio de sesión con
validación, bandeja de entrada con lista de chats y sala de chat con
burbujas de mensaje. Todo funciona en local, sin servidor: los datos son
de ejemplo y los mensajes se guardan solo en memoria.

## Qué hace la app

- **Login**: pide teléfono (10 dígitos), nombre y clave, con validación
  en cada campo. Mientras verifica, el botón queda bloqueado para evitar
  toques repetidos (anti-spam). El oso de arriba reacciona: mira al campo
  que estás llenando y se tapa los ojos cuando escribes la clave.
- **Bandeja de entrada**: lista de chats con `ListView.builder`, buscador,
  avatares con iniciales, último mensaje, hora y contador de no leídos.
  Menú lateral con los datos del usuario.
- **Sala de chat**: burbujas de emisor (azul, derecha) y receptor
  (blanca, izquierda) con hora y palomitas de leído. Al mandar un mensaje
  el contacto contesta solo después de un momento.

## Cómo correrlo

```bash
flutter pub get
flutter run
```

Para compilar el APK:

```bash
flutter build apk --release
```

## Estructura del proyecto

```text
lib/
├── main.dart               # Punto de entrada, tema y pantalla inicial
├── theme/
│   └── app_theme.dart      # Colores (azul Telegram + azul ITM)
├── models/
│   ├── usuario.dart        # Usuario que inicia sesión / contacto
│   ├── chat.dart           # Conversación: contacto + mensajes
│   └── mensaje.dart        # Un mensaje (texto, hora, mío o no)
├── data/
│   └── datos_ejemplo.dart  # Chats y respuestas de ejemplo (sin servidor)
├── utils/
│   └── validadores.dart    # Validación de teléfono, nombre y clave
├── widgets/
│   ├── logo_tecgram.dart   # Logo dibujado y avatar con iniciales
│   ├── oso_login.dart      # Oso animado del login (Rive o dibujado)
│   ├── tarjeta_chat.dart   # Renglón de la bandeja de entrada
│   └── burbuja_mensaje.dart
└── screens/
    ├── pantalla_login.dart # Login con validación y anti-spam
    ├── pantalla_chats.dart # Bandeja de entrada
    └── pantalla_chat.dart  # Sala de chat con envío y auto-respuesta
```

## Decisiones de diseño

- **Gestión de estado**: solo `StatefulWidget` + `setState()`, como pide
  el proyecto. No se usó Provider ni otro paquete de estado.
- **Colores**: azul Telegram `#0088cc` como principal y azul institucional
  `#003B71` como secundario. Burbujas propias en azul claro, del otro
  en blanco.
- **Inspiración**: la interfaz sigue los patrones del cliente oficial de
  Telegram y de clientes de código abierto como Cherrygram (fork del
  cliente oficial de Android) y Mithka (cliente Flutter con TDLib). El
  código es original, escrito para este proyecto; no se copió código de
  esos repositorios.
- **Logo**: el logo es un avión de papel dibujado con widgets. El logo
  oficial del ITM no se incluye; ver `assets/images/README.md`.
- **Oso Rive**: el login intenta cargar `assets/rive/oso_login.riv`. Si no
  está el archivo, usa un oso dibujado con widgets. Ver
  `assets/rive/README.md` para conseguir el archivo.

## Convenciones de commits

Se usa [Conventional Commits](https://www.conventionalcommits.org/):

| Prefijo | Para qué |
| ------- | -------- |
| `feat:` | Nuevas pantallas o funciones |
| `fix:` | Corrección de bugs o desbordamientos |
| `ui:` | Estilos, colores, bordes o márgenes |
| `refactor:` | Limpieza de código o extracción de widgets |
| `docs:` | Cambios en documentación |

Ejemplos:

```bash
git commit -m "feat: agregar pantalla de lista de chats"
git commit -m "fix: corregir overflow en pantalla de login"
git commit -m "ui: actualizar color de burbujas de chat"
git commit -m "refactor: extraer widget de tarjeta de mensaje"
git commit -m "docs: actualizar instrucciones en README.md"
```

## Pendientes / mejoras posibles

- Guardar los chats con `shared_preferences` o SQLite para que no se
  pierdan al cerrar la app.
- Poner el logo oficial del ITM (ver `assets/images/README.md`).
- Descargar el archivo `.riv` del oso (ver `assets/rive/README.md`).
- Agregar fotos de perfil reales en lugar de iniciales.
