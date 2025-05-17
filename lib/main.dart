// lib/main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar formato de fecha para español
  await initializeDateFormatting('es_MX', null);
  
  // Verificar si hay una sesión activa
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt(AppConstants.userIdKey);
  final email = prefs.getString(AppConstants.userEmailKey);
  final fullName = prefs.getString(AppConstants.userFullNameKey);
  final isLoggedIn = prefs.getBool(AppConstants.isLoggedInKey) ?? false;
  
  if (userId != null && email != null && fullName != null && isLoggedIn) {
    // Guardar datos de sesión
    UserSession.userId = userId;
    UserSession.userEmail = email;
    UserSession.userFullName = fullName;
    UserSession.isLoggedIn = true;
  }
  
  runApp(MyApp(isLoggedIn: UserSession.isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}