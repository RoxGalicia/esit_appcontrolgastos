
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Para guardar datos de sesión
import '../../database/database_helper.dart'; // Para acceder a la base de datos
import '../../utils/constants.dart'; // Constantes de la aplicación
import '../../utils/validators.dart'; // Validadores de formularios
import '../../widgets/custom_text_field.dart'; // Widget personalizado para campos de texto
import '../dashboard_screen.dart'; // Pantalla principal de la aplicación
import 'register_screen.dart'; // Pantalla de registro
import 'password_recovery_screen.dart'; // Pantalla de recuperación de contraseña

/// Pantalla de inicio de sesión.
/// Esta es la primera pantalla que verá el usuario si no ha iniciado sesión.
class LoginScreen extends StatefulWidget {
 const LoginScreen({super.key});

 @override
 State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
 // Clave global para identificar y validar el formulario
 final _formKey = GlobalKey<FormState>();
 
 // Controladores para los campos de texto
 final _emailController = TextEditingController(); // Para el campo de correo electrónico
 final _passwordController = TextEditingController(); // Para el campo de contraseña
 
 // Instancia del helper de base de datos para realizar operaciones
 final _databaseHelper = DatabaseHelper();
 
 // Bandera para mostrar/ocultar indicador de carga durante el proceso de login
 bool _isLoading = false;

 @override
 void dispose() {
   // Liberamos los recursos de los controladores cuando se destruye el widget
   _emailController.dispose();
   _passwordController.dispose();
   super.dispose();
 }

 /// Método que maneja el proceso de inicio de sesión.
 /// Valida las credenciales del usuario contra la base de datos.
 Future<void> _login() async {
   // Primero validamos que el formulario sea correcto
   if (_formKey.currentState!.validate()) {
     // Activamos el indicador de carga
     setState(() {
       _isLoading = true;
     });

     try {
       // Intentamos autenticar al usuario con las credenciales proporcionadas
       final user = await _databaseHelper.authenticateUser(
         _emailController.text.trim(), // Eliminamos espacios en blanco del email
         _passwordController.text,
       );

       if (user != null) {
         // Si la autenticación es exitosa, guardamos los datos de sesión
         final prefs = await SharedPreferences.getInstance();
         await prefs.setInt(AppConstants.userIdKey, user.id!);
         await prefs.setString(AppConstants.userEmailKey, user.email);
         await prefs.setString(AppConstants.userFullNameKey, user.fullName);
         await prefs.setBool(AppConstants.isLoggedInKey, true);

         // Actualizamos la información de sesión en memoria
         UserSession.userId = user.id;
         UserSession.userEmail = user.email;
         UserSession.userFullName = user.fullName;
         UserSession.isLoggedIn = true;

         // Navegamos al dashboard si el widget todavía está montado
         if (mounted) {
           Navigator.pushReplacement(
             context,
             MaterialPageRoute(builder: (context) => const DashboardScreen()),
           );
         }
       } else {
         // Si las credenciales son incorrectas, mostramos un mensaje de error
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text('Correo electrónico o contraseña incorrectos'),
               backgroundColor: Colors.red,
             ),
           );
         }
       }
     } catch (e) {
       // Si ocurre un error durante la autenticación, mostramos el mensaje
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Error al iniciar sesión: ${e.toString()}'),
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
   // Construimos la interfaz de la pantalla de inicio de sesión
   return Scaffold(
     body: SafeArea(
       child: SingleChildScrollView(
         padding: const EdgeInsets.all(20),
         child: Form(
           key: _formKey, // Asociamos la clave del formulario
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.stretch,
             children: [
               const SizedBox(height: 60), // Espacio superior
               // Icono principal de la aplicación
               const Icon(
                 Icons.account_balance_wallet,
                 size: 80,
                 color: AppConstants.primaryColor,
               ),
               const SizedBox(height: 20),
               // Nombre de la aplicación
               Text(
                 AppConstants.appName,
                 style: Theme.of(context).textTheme.displayLarge,
                 textAlign: TextAlign.center,
               ),
               const SizedBox(height: 10),
               // Título de la pantalla de login
               Text(
                 AppConstants.loginTitle,
                 style: Theme.of(context).textTheme.displayMedium,
                 textAlign: TextAlign.center,
               ),
               const SizedBox(height: 40),
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
                 hint: 'Ingrese su contraseña',
                 controller: _passwordController,
                 validator: Validators.validatePassword, // Validador de contraseña
                 obscureText: true, // Oculta los caracteres ingresados
                 prefixIcon: const Icon(Icons.lock), // Icono decorativo
               ),
               const SizedBox(height: 10),
               // Enlace para recuperar contraseña
               Align(
                 alignment: Alignment.centerRight,
                 child: TextButton(
                   onPressed: () {
                     // Navegamos a la pantalla de recuperación de contraseña
                     Navigator.push(
                       context, 
                       MaterialPageRoute(
                         builder: (context) => const PasswordRecoveryScreen(),
                       ),
                     );
                   },
                   child: const Text('¿Olvidó su contraseña?'),
                 ),
               ),
               const SizedBox(height: 20),
               // Botón de inicio de sesión
               ElevatedButton(
                 onPressed: _isLoading ? null : _login, // Desactivamos el botón durante la carga
                 child: _isLoading
                     ? const SizedBox(
                         height: 20,
                         width: 20,
                         child: CircularProgressIndicator(
                           color: Colors.white,
                           strokeWidth: 2,
                         ),
                       ) // Indicador de carga
                     : const Text('Iniciar Sesión'), // Texto normal
               ),
               const SizedBox(height: 20),
               // Opción para crear una nueva cuenta
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Text('¿No tiene una cuenta?'),
                   TextButton(
                     onPressed: () {
                       // Navegamos a la pantalla de registro
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => const RegisterScreen(),
                         ),
                       );
                     },
                     child: const Text('Registrarse'),
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