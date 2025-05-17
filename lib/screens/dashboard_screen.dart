// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/expense.dart';
import '../utils/constants.dart';
import '../widgets/expense_list.dart';
import '../widgets/summary_card.dart';
import '../widgets/category_filter.dart';
import 'auth/login_screen.dart';
import 'expense_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _databaseHelper = DatabaseHelper();
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  double _totalExpenses = 0;
  double _filteredTotalExpenses = 0;
  bool _isLoading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (UserSession.userId == null) {
        // Cargar datos de sesión si no existen
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt(AppConstants.userIdKey);
        final email = prefs.getString(AppConstants.userEmailKey);
        final fullName = prefs.getString(AppConstants.userFullNameKey);
        final isLoggedIn = prefs.getBool(AppConstants.isLoggedInKey) ?? false;

        if (userId != null && email != null && fullName != null && isLoggedIn) {
          UserSession.userId = userId;
          UserSession.userEmail = email;
          UserSession.userFullName = fullName;
          UserSession.isLoggedIn = true;
        } else {
          // Redirigir al login si no hay sesión
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
          return;
        }
      }

      // Cargar gastos del usuario
      final expenses = await _databaseHelper.getUserExpenses(UserSession.userId!);
      final totalExpenses = await _databaseHelper.getTotalExpenses(UserSession.userId!);

      setState(() {
        _expenses = expenses;
        _filteredExpenses = expenses;
        _totalExpenses = totalExpenses;
        _filteredTotalExpenses = totalExpenses;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterExpensesByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      
      if (category == null) {
        // Si no hay categoría seleccionada, mostrar todos los gastos
        _filteredExpenses = _expenses;
        _filteredTotalExpenses = _totalExpenses;
      } else {
        // Filtrar gastos por categoría seleccionada
        _filteredExpenses = _expenses.where((expense) => expense.category == category).toList();
        
        // Calcular el total de gastos filtrados
        _filteredTotalExpenses = _filteredExpenses.fold(
          0, (sum, expense) => sum + expense.amount);
      }
    });
  }

  Future<void> _onEditExpense(Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseFormScreen(
          expense: expense,
        ),
      ),
    );

    if (result == true) {
      _loadExpenses();
    }
  }

  Future<void> _onDeleteExpense(Expense expense) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppConstants.confirmDeleteTitle),
          content: const Text(AppConstants.confirmDeleteMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _databaseHelper.deleteExpense(expense.id!);
                  _loadExpenses();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gasto eliminado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    UserSession.userId = null;
    UserSession.userEmail = null;
    UserSession.userFullName = null;
    UserSession.isLoggedIn = false;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExpenses,
            tooltip: 'Actualizar datos',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadExpenses,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${UserSession.userFullName}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Resumen de tus gastos personales',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 16),
                    SummaryCard(
                      totalExpenses: _filteredTotalExpenses,
                      totalTransactions: _filteredExpenses.length,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Transacciones recientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_expenses.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      CategoryFilter(
                        categories: ExpenseCategories.categories,
                        selectedCategory: _selectedCategory,
                        onCategorySelected: _filterExpensesByCategory,
                      ),
                    ],
                    const SizedBox(height: 16),
                    ExpenseList(
                      expenses: _filteredExpenses,
                      onEditExpense: _onEditExpense,
                      onDeleteExpense: _onDeleteExpense,
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExpenseFormScreen(),
            ),
          );

          if (result == true) {
            _loadExpenses();
          }
        },
        tooltip: 'Agregar gasto',
        child: const Icon(Icons.add),
      ),
    );
  }
}