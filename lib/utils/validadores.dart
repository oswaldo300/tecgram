// Validaciones del login y el registro. Devuelven null si todo está bien,
// o el mensaje de error que se muestra bajo el campo.
class Validadores {
  Validadores._();

  static final _correoRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  // Correo: algo antes y después de la @, y un punto en el dominio
  static String? correo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Escribe tu correo electrónico';
    }
    if (!_correoRegex.hasMatch(valor.trim())) {
      return 'Escribe un correo válido';
    }
    return null;
  }

  // Nombre: al menos 2 caracteres
  static String? nombre(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Escribe tu nombre';
    }
    if (valor.trim().length < 2) {
      return 'El nombre es muy corto';
    }
    return null;
  }

  // Contraseña: mínimo 6 caracteres (lo que pide Firebase)
  static String? clave(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Escribe tu contraseña';
    }
    if (valor.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }
}
