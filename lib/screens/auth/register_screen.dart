
import 'package:flutter/material.dart';
import '../../database/database_helper.dart'; // Para acceder a la base de datos
import '../../models/user.dart'; // Modelo de usuario
import '../../utils/constants.dart'; // Constantes de la aplicación
import '../../utils/validators.dart'; // Validadores de formularios
import '../../widgets/custom_text_field.dart'; // Widget personalizado para campos de texto

/// Pantalla de registro de nuevos usuarios.
/// Permite a los usuarios crear una nueva cuenta en la aplicación.
class RegisterScreen extends StatefulWidget {
 const RegisterScreen({super.key});

 @override
 State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
 // Clave global para identificar y validar el formulario
 final _formKey = GlobalKey<FormState>();
 
 // Controladores para los campos de texto
 final _fullNameController = TextEditingController(); // Para el nombre completo
 final _emailController = TextEditingController(); // Para el correo electrónico
 final _passwordController = TextEditingController(); // Para la contraseña
 final _confirmPasswordController = TextEditingController(); // Para confirmar la contraseña
 
 // Instancia del helper de base de datos para realizar operaciones
 final _databaseHelper = DatabaseHelper();
 
 // Bandera para mostrar/ocultar indicador de carga durante el proceso de registro
 bool _isLoading = false;

 @override
 void dispose() {
   // Liberamos los recursos de los controladores cuando se destruye el widget
   _fullNameController.dispose();
   _emailController.dispose();
   _passwordController.dispose();
   _confirmPasswordController.dispose();
   super.dispose();
 }

 /// Método que maneja el proceso de registro de nuevo usuario.
 /// Verifica que el correo no exista y crea un nuevo usuario en la base de datos.
 Future<void> _register() async {
   // Primero validamos que el formulario sea correcto
   if (_formKey.currentState!.validate()) {
     // Activamos el indicador de carga
     setState(() {
       _isLoading = true;
     });

     try {
       // Verificar si el correo ya está registrado en la base de datos
       final existingUser = await _databaseHelper.getUserByEmail(
         _emailController.text.trim(), // Eliminamos espacios en blanco
       );

       if (existingUser != null) {
         // Si el correo ya existe, mostramos un mensaje de error
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text('Este correo electrónico ya está registrado'),
               backgroundColor: Colors.red,
             ),
           );
         }
         return; // Terminamos la ejecución aquí para no continuar con el registro
       }

       // Creamos un nuevo objeto User con los datos del formulario
       final newUser = User(
         fullName: _fullNameController.text.trim(), // Nombre completo sin espacios adicionales
         email: _emailController.text.trim(), // Email sin espacios adicionales
         password: _passwordController.text, // Contraseña tal como fue ingresada
       );

       // Guardamos el nuevo usuario en la base de datos
       await _databaseHelper.insertUser(newUser);

       // Si el widget sigue montado, mostramos mensaje de éxito y regresamos a login
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Cuenta creada exitosamente. Por favor inicie sesión.'),
             backgroundColor: Colors.green,
           ),
         );
         
         // Regresar a la pantalla de login
         Navigator.pop(context);
       }
     } catch (e) {
       // Si ocurre un error durante el registro, mostramos el mensaje
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Error al registrar usuario: ${e.toString()}'),
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
   // Construimos la interfaz de la pantalla de registro
   return Scaffold(
     appBar: AppBar(
       title: const Text(AppConstants.registerTitle),
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
               // Icono de registro
               const Icon(
                 Icons.person_add,
                 size: 70,
                 color: AppConstants.primaryColor,
               ),
               const SizedBox(height: 30),
               // Campo de nombre completo
               CustomTextField(
                 label: 'Nombre Completo',
                 hint: 'Ingrese su nombre completo',
                 controller: _fullNameController,
                 validator: (value) => Validators.validateNotEmpty(value, 'nombre completo'),
                 prefixIcon: const Icon(Icons.person), // Icono decorativo
               ),
               // Campo de correo electrónico
               CustomTextField(
                 label: 'Correo Electrónico',
                 hint: 'Ingrese su correo electrónico',
                 controller: _emailController,
                 validator: Validators.validateEmail, // Validador de email
                 keyboardType: TextInputType.emailAddress, // Teclado optimizado para emails
                 prefixIcon: const Icon(Icons.email), // Icono decorativo
               ),
               // Campo de contraseña
               CustomTextField(
                 label: 'Contraseña',
                 hint: 'Ingrese su contraseña (mínimo 6 caracteres)',
                 controller: _passwordController,
                 validator: Validators.validatePassword, // Validador de contraseña
                 obscureText: true, // Oculta los caracteres ingresados
                 prefixIcon: const Icon(Icons.lock), // Icono decorativo
               ),
               // Campo para confirmar contraseña
               CustomTextField(
                 label: 'Confirmar Contraseña',
                 hint: 'Confirme su contraseña',
                 controller: _confirmPasswordController,
                 // Validador que compara ambas contraseñas
                 validator: (value) => Validators.validatePasswordMatch(
                   _passwordController.text,
                   value,
                 ),
                 obscureText: true, // Oculta los caracteres ingresados
                 prefixIcon: const Icon(Icons.lock_outline), // Icono decorativo
               ),
               const SizedBox(height: 30),
               // Botón de registro
               ElevatedButton(
                 onPressed: _isLoading ? null : _register, // Desactivamos el botón durante la carga
                 child: _isLoading
                     ? const SizedBox(
                         height: 20,
                         width: 20,
                         child: CircularProgressIndicator(
                           color: Colors.white,
                           strokeWidth: 2,
                         ),
                       ) // Indicador de carga
                     : const Text('Crear Cuenta'), // Texto normal
               ),
               const SizedBox(height: 20),
               // Opción para ir a inicio de sesión si ya tiene cuenta
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Text('¿Ya tiene una cuenta?'),
                   TextButton(
                     onPressed: () {
                       // Regresamos a la pantalla de login
                       Navigator.pop(context);
                     },
                     child: const Text('Iniciar Sesión'),
                   ),
                 ],
               ),
             ],
           ),
         ),
       ),
     ),
   );
 }
}