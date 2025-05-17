
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Para gestionar datos de sesión
import '../database/database_helper.dart'; // Para acceder a la base de datos
import '../models/expense.dart'; // Modelo de gastos
import '../utils/constants.dart'; // Constantes de la aplicación
import '../widgets/expense_list.dart'; // Widget de lista de gastos
import '../widgets/summary_card.dart'; // Widget de tarjeta resumen
import '../widgets/category_filter.dart'; // Widget de filtro por categorías
import 'auth/login_screen.dart'; // Pantalla de inicio de sesión
import 'expense_form_screen.dart'; // Pantalla de formulario de gastos

/// Pantalla principal (Dashboard) de la aplicación.
/// Muestra el resumen y listado de gastos del usuario con opciones de filtrado.
class DashboardScreen extends StatefulWidget {
 const DashboardScreen({super.key});

 @override
 State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
 // Instancia del helper de base de datos para realizar operaciones
 final _databaseHelper = DatabaseHelper();
 
 // Listas de gastos (original y filtrada)
 List<Expense> _expenses = []; // Todos los gastos del usuario
 List<Expense> _filteredExpenses = []; // Gastos filtrados por categoría
 
 // Variables para los totales
 double _totalExpenses = 0; // Total de todos los gastos
 double _filteredTotalExpenses = 0; // Total de los gastos filtrados
 
 // Estado de carga
 bool _isLoading = true;
 
 // Categoría seleccionada para filtrar (null si no hay filtro)
 String? _selectedCategory;

 @override
 void initState() {
   super.initState();
   // Cargamos los gastos cuando se inicia la pantalla
   _loadExpenses();
 }

 /// Carga los gastos del usuario desde la base de datos.
 /// También verifica si hay una sesión activa.
 Future<void> _loadExpenses() async {
   // Activamos el indicador de carga
   setState(() {
     _isLoading = true;
   });

   try {
     // Verificar si hay información de sesión en memoria
     if (UserSession.userId == null) {
       // Si no hay, intentamos cargar desde SharedPreferences
       final prefs = await SharedPreferences.getInstance();
       final userId = prefs.getInt(AppConstants.userIdKey);
       final email = prefs.getString(AppConstants.userEmailKey);
       final fullName = prefs.getString(AppConstants.userFullNameKey);
       final isLoggedIn = prefs.getBool(AppConstants.isLoggedInKey) ?? false;

       // Si encontramos los datos en SharedPreferences, los cargamos en memoria
       if (userId != null && email != null && fullName != null && isLoggedIn) {
         UserSession.userId = userId;
         UserSession.userEmail = email;
         UserSession.userFullName = fullName;
         UserSession.isLoggedIn = true;
       } else {
         // Si no hay datos de sesión, redirigimos al login
         if (mounted) {
           Navigator.pushReplacement(
             context,
             MaterialPageRoute(builder: (context) => const LoginScreen()),
           );
         }
         return; // Terminamos la ejecución para no continuar con la carga de gastos
       }
     }

     // Cargamos los gastos del usuario desde la base de datos
     final expenses = await _databaseHelper.getUserExpenses(UserSession.userId!);
     // Calculamos el total de gastos
     final totalExpenses = await _databaseHelper.getTotalExpenses(UserSession.userId!);

     // Actualizamos el estado con los datos cargados
     setState(() {
       _expenses = expenses;
       _filteredExpenses = expenses; // Inicialmente mostramos todos los gastos
       _totalExpenses = totalExpenses;
       _filteredTotalExpenses = totalExpenses; // Inicialmente el total filtrado es igual al total
       _isLoading = false; // Desactivamos el indicador de carga
     });
   } catch (e) {
     // Si ocurre un error durante la carga, mostramos un mensaje
     if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('Error al cargar datos: ${e.toString()}'),
           backgroundColor: Colors.red,
         ),
       );
       // Desactivamos el indicador de carga aunque haya error
       setState(() {
         _isLoading = false;
       });
     }
   }
 }

 /// Filtra los gastos por categoría seleccionada.
 /// Si category es null, muestra todos los gastos.
 void _filterExpensesByCategory(String? category) {
   setState(() {
     _selectedCategory = category;
     
     if (category == null) {
       // Si no hay categoría seleccionada, mostramos todos los gastos
       _filteredExpenses = _expenses;
       _filteredTotalExpenses = _totalExpenses;
     } else {
       // Filtramos los gastos por la categoría seleccionada
       _filteredExpenses = _expenses.where((expense) => expense.category == category).toList();
       
       // Calculamos el total de los gastos filtrados
       _filteredTotalExpenses = _filteredExpenses.fold(
         0, (sum, expense) => sum + expense.amount);
     }
   });
 }

 /// Maneja la edición de un gasto existente.
 /// Navega a la pantalla de formulario y recarga los gastos si hubo cambios.
 Future<void> _onEditExpense(Expense expense) async {
   // Navegamos a la pantalla de formulario pasando el gasto a editar
   final result = await Navigator.push(
     context,
     MaterialPageRoute(
       builder: (context) => ExpenseFormScreen(
         expense: expense, // Pasamos el gasto existente para editar
       ),
     ),
   );

   // Si el resultado es true, significa que se editó el gasto
   if (result == true) {
     // Recargamos los gastos para ver los cambios
     _loadExpenses();
   }
 }

 /// Maneja la eliminación de un gasto.
 /// Muestra un diálogo de confirmación antes de eliminar.
 Future<void> _onDeleteExpense(Expense expense) async {
   // Mostramos un diálogo de confirmación
   showDialog(
     context: context,
     builder: (BuildContext context) {
       return AlertDialog(
         title: const Text(AppConstants.confirmDeleteTitle),
         content: const Text(AppConstants.confirmDeleteMessage),
         actions: [
           // Botón para cancelar la eliminación
           TextButton(
             onPressed: () {
               Navigator.of(context).pop(); // Cerramos el diálogo
             },
             child: const Text('Cancelar'),
           ),
           // Botón para confirmar la eliminación
           TextButton(
             onPressed: () async {
               Navigator.of(context).pop(); // Cerramos el diálogo
               try {
                 // Eliminamos el gasto de la base de datos
                 await _databaseHelper.deleteExpense(expense.id!);
                 // Recargamos los gastos para ver los cambios
                 _loadExpenses();
                 // Mostramos mensaje de éxito
                 if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(
                       content: Text('Gasto eliminado exitosamente'),
                       backgroundColor: Colors.green,
                     ),
                   );
                 }
               } catch (e) {
                 // Si ocurre un error durante la eliminación, mostramos mensaje
                 if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                       content: Text('Error al eliminar gasto: ${e.toString()}'),
                       backgroundColor: Colors.red,
                     ),
                   );
                 }
               }
             },
             child: const Text('Eliminar'),
           ),
         ],
       );
     },
   );
 }

 /// Maneja el cierre de sesión del usuario.
 /// Limpia los datos de sesión y redirige a la pantalla de login.
 Future<void> _logout() async {
   // Eliminamos los datos de sesión de SharedPreferences
   final prefs = await SharedPreferences.getInstance();
   await prefs.clear();
   
   // Limpiamos los datos de sesión en memoria
   UserSession.userId = null;
   UserSession.userEmail = null;
   UserSession.userFullName = null;
   UserSession.isLoggedIn = false;

   // Redirigimos al login
   if (mounted) {
     Navigator.pushReplacement(
       context,
       MaterialPageRoute(builder: (context) => const LoginScreen()),
     );
   }
 }

 @override
 Widget build(BuildContext context) {
   // Construimos la interfaz del dashboard
   return Scaffold(
     appBar: AppBar(
       title: const Text(AppConstants.dashboardTitle),
       actions: [
         // Botón para recargar los datos
         IconButton(
           icon: const Icon(Icons.refresh),
           onPressed: _loadExpenses,
           tooltip: 'Actualizar datos',
         ),
         // Botón para cerrar sesión
         IconButton(
           icon: const Icon(Icons.logout),
           onPressed: _logout,
           tooltip: 'Cerrar sesión',
         ),
       ],
     ),
     // Usamos RefreshIndicator para permitir recargar con el gesto pull-to-refresh
     body: RefreshIndicator(
       onRefresh: _loadExpenses,
       child: _isLoading
           ? const Center(child: CircularProgressIndicator()) // Indicador de carga
           : SingleChildScrollView(
               physics: const AlwaysScrollableScrollPhysics(), // Permite scroll aunque haya poco contenido
               padding: const EdgeInsets.all(16),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   // Saludo personalizado
                   Text(
                     'Hola, ${UserSession.userFullName}',
                     style: Theme.of(context).textTheme.titleLarge,
                   ),
                   const SizedBox(height: 4),
                   // Subtítulo de la pantalla
                   Text(
                     'Resumen de tus gastos personales',
                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                           color: Colors.grey[600],
                         ),
                   ),
                   const SizedBox(height: 16),
                   // Tarjeta resumen con los totales
                   SummaryCard(
                     totalExpenses: _filteredTotalExpenses, // Usamos los totales filtrados
                     totalTransactions: _filteredExpenses.length,
                   ),
                   const SizedBox(height: 24),
                   // Título de la sección de transacciones
                   const Text(
                     'Transacciones recientes',
                     style: TextStyle(
                       fontSize: 18,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   // Widget de filtrado por categorías (solo si hay gastos)
                   if (_expenses.isNotEmpty) ...[
                     const SizedBox(height: 8),
                     CategoryFilter(
                       categories: ExpenseCategories.categories, // Lista de categorías disponibles
                       selectedCategory: _selectedCategory, // Categoría actualmente seleccionada
                       onCategorySelected: _filterExpensesByCategory, // Función de callback
                     ),
                   ],
                   const SizedBox(height: 16),
                   // Lista de gastos (filtrados)
                   ExpenseList(
                     expenses: _filteredExpenses, // Lista de gastos a mostrar
                     onEditExpense: _onEditExpense, // Callback para editar
                     onDeleteExpense: _onDeleteExpense, // Callback para eliminar
                   ),
                 ],
               ),
             ),
     ),
     // Botón flotante para agregar un nuevo gasto
     floatingActionButton: FloatingActionButton(
       onPressed: () async {
         // Navegamos a la pantalla de formulario (modo creación)
         final result = await Navigator.push(
           context,
           MaterialPageRoute(
             builder: (context) => const ExpenseFormScreen(), // Sin pasar expense (modo creación)
           ),
         );

         // Si el resultado es true, significa que se creó un gasto
         if (result == true) {
           // Recargamos los gastos para ver el nuevo gasto
           _loadExpenses();
         }
       },
       tooltip: 'Agregar gasto',
       child: const Icon(Icons.add), // Icono de suma
     ),
   );
 }
}