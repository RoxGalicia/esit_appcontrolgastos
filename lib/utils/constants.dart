// lib/utils/constants.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppConstants {
  // Colores principales de la aplicación
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color accentColor = Color(0xFF388E3C);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF212121);
  static const Color expenseColor = Color(0xFFE53935);
  static const Color incomeColor = Color(0xFF43A047);

  // Textos para mensajes
  static const String appName = 'Control de Gastos';
  static const String loginTitle = 'Iniciar Sesión';
  static const String registerTitle = 'Crear Cuenta';
  static const String recoverPasswordTitle = 'Recuperar Contraseña';
  static const String dashboardTitle = 'Panel Principal';
  static const String addExpenseTitle = 'Agregar Gasto';
  static const String editExpenseTitle = 'Editar Gasto';
  static const String confirmDeleteTitle = '¿Eliminar Gasto?';
  static const String confirmDeleteMessage = '¿Está seguro que desea eliminar este gasto? Esta acción no se puede deshacer.';

  // SharedPreferences keys
  static const String userIdKey = 'userId';
  static const String userEmailKey = 'userEmail';
  static const String userFullNameKey = 'userFullName';
  static const String isLoggedInKey = 'isLoggedIn';

  // Formatos de fecha
  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );
}

// Clase para gestionar la información de sesión del usuario
class UserSession {
  static int? userId;
  static String? userEmail;
  static String? userFullName;
  static bool isLoggedIn = false;
}