
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Para almacenamiento local
import 'package:intl/date_symbol_data_local.dart'; // Para formatos de fecha localizados
import 'screens/auth/login_screen.dart'; // Pantalla de inicio de sesión
import 'screens/dashboard_screen.dart'; // Pantalla principal
import 'utils/constants.dart'; // Constantes de la aplicación
import 'utils/theme.dart'; // Tema de la aplicación

/// Punto de entrada principal de la aplicación.
/// Configura el entorno e inicia la app con la pantalla correspondiente según la sesión.
void main() async {
 // Aseguramos que Flutter esté inicializado
 WidgetsFlutterBinding.ensureInitialized();
 
 // Inicializamos el formato de fecha para español (México)
 // Esto permite que los formatos de fecha se muestren correctamente en español
 await initializeDateFormatting('es_MX', null);
 
 // Verificamos si hay una sesión activa guardada en el dispositivo
 final prefs = await SharedPreferences.getInstance();
 
 // Obtenemos los datos de sesión guardados
 final userId = prefs.getInt(AppConstants.userIdKey);
 final email = prefs.getString(AppConstants.userEmailKey);
 final fullName = prefs.getString(AppConstants.userFullNameKey);
 final isLoggedIn = prefs.getBool(AppConstants.isLoggedInKey) ?? false; // Por defecto false
 
 // Si tenemos todos los datos necesarios, restauramos la sesión
 if (userId != null && email != null && fullName != null && isLoggedIn) {
   // Guardamos los datos en la clase UserSession para acceso global
   UserSession.userId = userId;
   UserSession.userEmail = email;
   UserSession.userFullName = fullName;
   UserSession.isLoggedIn = true;
 }
 
 // Iniciamos la aplicación, pasando el estado de login
 runApp(MyApp(isLoggedIn: UserSession.isLoggedIn));
}

/// Widget raíz de la aplicación.
/// Configura el tema y determina qué pantalla mostrar según el estado de login.
class MyApp extends StatelessWidget {
 final bool isLoggedIn; // Indica si hay una sesión activa
 
 const MyApp({super.key, required this.isLoggedIn});

 @override
 Widget build(BuildContext context) {
   return MaterialApp(
     title: AppConstants.appName, // Título de la aplicación
     theme: AppTheme.lightTheme, // Aplicamos el tema personalizado
     debugShowCheckedModeBanner: false, // Quitamos la etiqueta de debug
     // Mostramos la pantalla principal o la de login según el estado de sesión
     home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
   );
 }
}