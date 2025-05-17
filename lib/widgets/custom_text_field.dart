// lib/widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para formateadores de entrada

/// Widget personalizado para campos de texto en formularios.
/// Proporciona un campo de texto con etiqueta, validación y estilo consistente.
class CustomTextField extends StatelessWidget {
 final String label; // Etiqueta que aparece encima del campo
 final String? hint; // Texto de sugerencia que aparece dentro del campo
 final TextEditingController controller; // Controlador para manejar el texto
 final String? Function(String?)? validator; // Función de validación
 final bool obscureText; // Si el texto debe ocultarse (para contraseñas)
 final TextInputType keyboardType; // Tipo de teclado a mostrar
 final Widget? prefixIcon; // Icono que aparece al inicio del campo
 final Widget? suffixIcon; // Icono que aparece al final del campo
 final bool enabled; // Si el campo está habilitado para edición
 final int? maxLines; // Número máximo de líneas (para texto multilínea)
 final int? maxLength; // Longitud máxima de caracteres permitidos
 final List<TextInputFormatter>? inputFormatters; // Formateadores de entrada
 final void Function(String)? onChanged; // Callback cuando cambia el texto

 /// Constructor para crear un campo de texto personalizado.
 /// Solo la etiqueta y el controlador son obligatorios.
 const CustomTextField({
   super.key,
   required this.label,
   this.hint,
   required this.controller,
   this.validator,
   this.obscureText = false, // Por defecto el texto es visible
   this.keyboardType = TextInputType.text, // Por defecto teclado de texto
   this.prefixIcon,
   this.suffixIcon,
   this.enabled = true, // Por defecto el campo está habilitado
   this.maxLines = 1, // Por defecto una sola línea
   this.maxLength,
   this.inputFormatters,
   this.onChanged,
 });

 @override
 Widget build(BuildContext context) {
   // Construimos el layout del campo personalizado
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       // Etiqueta descriptiva del campo
       Text(
         label,
         style: const TextStyle(
           fontSize: 14,
           fontWeight: FontWeight.w500,
           color: Colors.black87,
         ),
       ),
       const SizedBox(height: 8), // Espacio entre la etiqueta y el campo
       // Campo de texto con validación (TextFormField)
       TextFormField(
         controller: controller, // Controlador para acceder al texto
         validator: validator, // Función de validación (muestra errores)
         obscureText: obscureText, // Si debe ocultar el texto (para contraseñas)
         keyboardType: keyboardType, // Tipo de teclado (numérico, email, etc.)
         enabled: enabled, // Si el campo está habilitado o deshabilitado
         maxLines: maxLines, // Número máximo de líneas visibles
         maxLength: maxLength, // Número máximo de caracteres permitidos
         inputFormatters: inputFormatters, // Formateadores de entrada (ej: solo números)
         onChanged: onChanged, // Función que se ejecuta al cambiar el texto
         // Decoración visual del campo
         decoration: InputDecoration(
           hintText: hint, // Texto de sugerencia
           prefixIcon: prefixIcon, // Icono al inicio (opcional)
           suffixIcon: suffixIcon, // Icono al final (opcional)
         ),
       ),
       const SizedBox(height: 16), // Espacio después del campo
     ],
   );
 }
}