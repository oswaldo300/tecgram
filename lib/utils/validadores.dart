// Validaciones del login por teléfono. Devuelven null si todo está bien,
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

  // Nombre: al menos 2 letras, solo letras y espacios (con acentos y ñ)
  static String? nombre(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Escribe tu nombre';
    }
    final nombre = valor.trim();
    if (nombre.length < 2) {
      return 'El nombre es muy corto';
    }
    final soloLetras = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$");
    if (!soloLetras.hasMatch(nombre)) {
      return 'El nombre solo puede tener letras';
    }
    return null;
  }
}
