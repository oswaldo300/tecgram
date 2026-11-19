// Usuario de la app (el que inicia sesión) o contacto de un chat.
// Se guarda solo en memoria: no hay servidor, es un clon local.
class Usuario {
  final String nombre;
  final String telefono;
  final String iniciales; // se muestran en el avatar si no hay foto
  final String correo; // vacío en los contactos de ejemplo

  const Usuario({
    required this.nombre,
    required this.telefono,
    required this.iniciales,
    this.correo = '',
  });

  // Saca las iniciales del nombre: "Ana Pérez" -> "AP"
  factory Usuario.desdeNombre(
    String nombre,
    String telefono, {
    String correo = '',
  }) {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    final ini = partes.map((p) => p[0].toUpperCase()).take(2).join();
    return Usuario(
      nombre: nombre.trim(),
      telefono: telefono,
      iniciales: ini,
      correo: correo,
    );
  }
}
