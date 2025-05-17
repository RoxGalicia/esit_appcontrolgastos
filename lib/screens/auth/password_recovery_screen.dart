
import 'package:flutter/material.dart';
import '../../database/database_helper.dart'; // Para acceder a la base de datos
import '../../utils/constants.dart'; // Constantes de la aplicación
import '../../utils/validators.dart'; // Validadores de formularios
import '../../widgets/custom_text_field.dart'; // Widget personalizado para campos de texto

/// Pantalla para recuperar la contraseña olvidada.
/// Implementa un proceso de dos pasos: primero verificar el email y luego permitir cambiar la contraseña.
class PasswordRecoveryScreen extends StatefulWidget {
 const PasswordRecoveryScreen({Key? key}) : super(key: key);

 @override
 State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
 // Clave global para identificar y validar el formulario
 final _formKey = GlobalKey<FormState>();
 
 // Controladores para los campos de texto
 final _emailController = TextEditingController(); // Para el campo de email
 final _newPasswordController = TextEditingController(); // Para la nueva contraseña
 final _confirmPasswordController = TextEditingController(); // Para confirmar la nueva contraseña
 
 // Instancia del helper de base de datos para realizar operaciones
 final _databaseHelper = DatabaseHelper();
 
 // Estado de la pantalla
 bool _isLoading = false; // Indica si hay una operación en proceso
 bool _isEmailVerified = false; // Indica si el email ha sido verificado

 @override
 void dispose() {
   // Liberamos los recursos de los controladores cuando se destruye el widget
   _emailController.dispose();
   _newPasswordController.dispose();
   _confirmPasswordController.dispose();
   super.dispose();
 }

 /// Método para verificar si el email existe en la base de datos.
 /// Este es el primer paso del proceso de recuperación.
 Future<void> _verifyEmail() async {
   // Validamos el formulario (en este punto solo el campo de email)
   if (_formKey.currentState!.validate()) {
     // Activamos el indicador de carga
     setState(() {
       _isLoading = true;
     });

     try {
       // Buscamos si existe un usuario con el email proporcionado
       final user = await _databaseHelper.getUserByEmail(
         _emailController.text.trim(), // Eliminamos espacios en blanco
       );

       if (user != null) {
         // Si el usuario existe, cambiamos al segundo paso (ingresar nueva contraseña)
         setState(() {
           _isEmailVerified = true;
         });
       } else {
         // Si el usuario no existe, mostramos un mensaje de error
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text('No existe cuenta asociada a este correo electrónico'),
               backgroundColor: Colors.red,
             ),
           );
         }
       }
     } catch (e) {
       // Si ocurre un error durante la verificación, mostramos el mensaje
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Error al verificar correo: ${e.toString()}'),
             backgroundColor: Colors.red,
           ),
         );
       }
     } finally {
       // Finalmente, desactivamos el indicador de carga si el widget está montado
       if (mounted) {
         setState(() {
           _isLoading = false;
         });
       }
     }
   }
 }

 /// Método para actualizar la contraseña en la base de datos.
 /// Este es el segundo paso del proceso de recuperación.
 Future<void> _resetPassword() async {
   // Validamos el formulario completo (email, nueva contraseña y confirmación)
   if (_formKey.currentState!.validate()) {
     // Activamos el indicador de carga
     setState(() {
       _isLoading = true;
     });

     try {
       // Intentamos actualizar la contraseña en la base de datos
       final result = await _databaseHelper.updateUserPassword(
         _emailController.text.trim(),
         _newPasswordController.text,
       );

       if (result > 0) {
         // Si se actualizó correctamente (al menos una fila afectada)
         if (mounted) {
           // Mostramos mensaje de éxito
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text('Contraseña actualizada exitosamente. Por favor inicie sesión.'),
               backgroundColor: Colors.green,
             ),
           );
           
           // Regresamos a la pantalla de login
           Navigator.pop(context);
         }
       } else {
         // Si no se actualizó ninguna fila, mostramos error
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text('Error al actualizar contraseña'),
               backgroundColor: Colors.red,
             ),
           );
         }
       }
     } catch (e) {
       // Si ocurre un error durante la actualización, mostramos el mensaje
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Error al restablecer contraseña: ${e.toString()}'),
             backgroundColor: Colors.red,
           ),
         );
       }
     } finally {
       // Finalmente, desactivamos el indicador de carga si el widget está montado
       if (mounted) {
         setState(() {
           _isLoading = false;
         });
       }
     }
   }
 }

 @override
 Widget build(BuildContext context) {
   // Construimos la interfaz de recuperación de contraseña
   return Scaffold(
     appBar: AppBar(
       title: const Text(AppConstants.recoverPasswordTitle),
     ),
     body: SafeArea(
       child: SingleChildScrollView(
         padding: const EdgeInsets.all(20),
         child: Form(
           key: _formKey, // Asociamos la clave del formulario
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.stretch,
             children: [
               const SizedBox(height: 20),
               // Icono representativo de reseteo de contraseña
               const Icon(
                 Icons.lock_reset,
                 size: 70,
                 color: AppConstants.primaryColor,
               ),
               const SizedBox(height: 20),
               // Texto instructivo que cambia según el paso en el que estemos
               Text(
                 _isEmailVerified
                     ? 'Ingrese su nueva contraseña' // Paso 2: Cambiar contraseña
                     : 'Ingrese su correo electrónico para recuperar su contraseña', // Paso 1: Verificar email
                 style: Theme.of(context).textTheme.bodyLarge,
                 textAlign: TextAlign.center,
               ),
               const SizedBox(height: 30),
               // Campo de correo electrónico (deshabilitado después de verificar)
               CustomTextField(
                 label: 'Correo Electrónico',
                 hint: 'Ingrese su correo electrónico',
                 controller: _emailController,
                 validator: Validators.validateEmail, // Validador de email
                 keyboardType: TextInputType.emailAddress, // Teclado optimizado para emails
                 prefixIcon: const Icon(Icons.email), // Icono decorativo
                 enabled: !_isEmailVerified, // Se deshabilita después de verificar
               ),
               // Estos campos solo aparecen después de verificar el email
               if (_isEmailVerified) ...[
                 // Campo para la nueva contraseña
                 CustomTextField(
                   label: 'Nueva Contraseña',
                   hint: 'Ingrese su nueva contraseña (mínimo 6 caracteres)',
                   controller: _newPasswordController,
                   validator: Validators.validatePassword, // Validador de contraseña
                   obscureText: true, // Oculta los caracteres ingresados
                   prefixIcon: const Icon(Icons.lock), // Icono decorativo
                 ),
                 // Campo para confirmar la nueva contraseña
                 CustomTextField(
                   label: 'Confirmar Nueva Contraseña',
                   hint: 'Confirme su nueva contraseña',
                   controller: _confirmPasswordController,
                   // Validador que compara ambas contraseñas
                   validator: (value) => Validators.validatePasswordMatch(
                     _newPasswordController.text,
                     value,
                   ),
                   obscureText: true, // Oculta los caracteres ingresados
                   prefixIcon: const Icon(Icons.lock_outline), // Icono decorativo
                 ),
               ],
               const SizedBox(height: 30),
               // Botón principal que cambia según el paso del proceso
               ElevatedButton(
                 onPressed: _isLoading
                     ? null // Deshabilitado durante la carga
                     : (_isEmailVerified ? _resetPassword : _verifyEmail), // Acción según el paso
                 child: _isLoading
                     ? const SizedBox(
                         height: 20,
                         width: 20,
                         child: CircularProgressIndicator(
                           color: Colors.white,
                           strokeWidth: 2,
                         ),
                       ) // Indicador de carga
                     : Text(_isEmailVerified
                         ? 'Cambiar Contraseña' // Texto para el paso 2
                         : 'Verificar Correo'), // Texto para el paso 1
               ),
               const SizedBox(height: 20),
               // Botón para volver a la pantalla de inicio de sesión
               TextButton(
                 onPressed: () {
                   Navigator.pop(context);
                 },
                 child: const Text('Volver al Inicio de Sesión'),
               ),
             ],
           ),
         ),
       ),
     ),
   );
 }
}