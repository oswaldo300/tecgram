// Validaciones del login. Devuelven null si todo está bien,
// o el mensaje de error que se muestra bajo el campo.
class Validadores {
  Validadores._();

  // Teléfono mexicano: 10 dígitos, solo números
  static String? telefono(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Escribe tu número de teléfono';
    }
    final limpio = valor.replaceAll(RegExp(r'\D'), '');
    if (limpio.length != 10) {
      return 'El teléfono debe tener 10 dígitos';
    }
    return null;
  }

  // Nombre: al menos 2 letras, solo letras y espacios
  static String? nombre(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Escribe tu nombre';
    }
    if (valor.trim().length < 2) {
      return 'El nombre es muy corto';
    }
    return null;
  }

  // Clave del demo: mínimo 4 caracteres
  static String? clave(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Escribe tu clave';
    }
    if (valor.length < 4) {
      return 'La clave debe tener al menos 4 caracteres';
    }
    return null;
  }
}
