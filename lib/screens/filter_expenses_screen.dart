// lib/screens/filter_expenses_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../utils/constants.dart';
// import '../widgets/custom_text_field.dart';

class FilterExpensesScreen extends StatefulWidget {
  final List<Expense> expenses;

  const FilterExpensesScreen({
    super.key,
    required this.expenses,
  });

  @override
  State<FilterExpensesScreen> createState() => _FilterExpensesScreenState();
}

class _FilterExpensesScreenState extends State<FilterExpensesScreen> {
  List<String> _selectedCategories = [];
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();
  String _sortBy = 'date';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    // Inicializar con valores mínimos y máximos de los gastos actuales
    if (widget.expenses.isNotEmpty) {
      final amounts = widget.expenses.map((e) => e.amount).toList();
      final minAmount = amounts.reduce((a, b) => a < b ? a : b);
      final maxAmount = amounts.reduce((a, b) => a > b ? a : b);
      
      // Redondear para una mejor UX
      _minAmount = (minAmount * 0.8).floorToDouble();
      _maxAmount = (maxAmount * 1.2).ceilToDouble();
      
      _minAmountController.text = _minAmount.toString();
      _maxAmountController.text = _maxAmount.toString();
    }
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  List<Expense> _applyFilters() {
    return widget.expenses.where((expense) {
      // Filtrar por categorías seleccionadas
      if (_selectedCategories.isNotEmpty && 
          !_selectedCategories.contains(expense.category)) {
        return false;
      }
      
      // Filtrar por rango de fechas
      if (_startDate != null && expense.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && expense.date.isAfter(
          DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59))) {
        return false;
      }
      
      // Filtrar por monto
      final minAmount = double.tryParse(_minAmountController.text);
      final maxAmount = double.tryParse(_maxAmountController.text);
      
      if (minAmount != null && expense.amount < minAmount) {
        return false;
      }
      if (maxAmount != null && expense.amount > maxAmount) {
        return false;
      }
      
      return true;
    }).toList()
      ..sort((a, b) {
        int comparison;
        
        // Ordenar según el criterio seleccionado
        switch (_sortBy) {
          case 'date':
            comparison = a.date.compareTo(b.date);
            break;
          case 'amount':
            comparison = a.amount.compareTo(b.amount);
            break;
          case 'category':
            comparison = a.category.compareTo(b.category);
            break;
          case 'description':
            comparison = a.description.compareTo(b.description);
            break;
          default:
            comparison = a.date.compareTo(b.date);
            break;
        }
        
        // Invertir si es descendente
        return _sortAscending ? comparison : -comparison;
      });
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? _startDate ?? DateTime.now().subtract(const Duration(days: 30))
          : _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Si la fecha de fin es menor que la de inicio, ajustarla
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          // Si la fecha de inicio es mayor que la de fin, ajustarla
          if (_startDate != null && _startDate!.isAfter(_endDate!)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCategories = [];
      _startDate = null;
      _endDate = null;
      
      if (widget.expenses.isNotEmpty) {
        final amounts = widget.expenses.map((e) => e.amount).toList();
        final minAmount = amounts.reduce((a, b) => a < b ? a : b);
        final maxAmount = amounts.reduce((a, b) => a > b ? a : b);
        
        _minAmount = (minAmount * 0.8).floorToDouble();
        _maxAmount = (maxAmount * 1.2).ceilToDouble();
        
        _minAmountController.text = _minAmount.toString();
        _maxAmountController.text = _maxAmount.toString();
      } else {
        _minAmountController.text = '';
        _maxAmountController.text = '';
      }
      
      _sortBy = 'date';
      _sortAscending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros Avanzados'),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              'Restablecer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtro por categorías
            const Text(
              'Categorías',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseCategories.categories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppConstants.primaryColor
                        : Colors.grey[800],
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Filtro por fechas
            const Text(
              'Rango de Fechas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _startDate != null
                                ? DateFormat('dd/MM/yyyy').format(_startDate!)
                                : 'Fecha inicial',
                            style: TextStyle(
                              color: _startDate != null
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _endDate != null
                                ? DateFormat('dd/MM/yyyy').format(_endDate!)
                                : 'Fecha final',
                            style: TextStyle(
                              color: _endDate != null
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Filtro por monto
            const Text(
              'Rango de Monto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Mínimo',
                      prefixIcon: const Icon(Icons.attach_money, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Máximo',
                      prefixIcon: const Icon(Icons.attach_money, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Opciones de ordenamiento
            const Text(
              'Ordenar por',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _sortBy,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'date',
                  child: Text('Fecha'),
                ),
                DropdownMenuItem(
                  value: 'amount',
                  child: Text('Monto'),
                ),
                DropdownMenuItem(
                  value: 'category',
                  child: Text('Categoría'),
                ),
                DropdownMenuItem(
                  value: 'description',
                  child: Text('Descripción'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortBy = value;
                  });
                }
              },
            ),
            
            const SizedBox(height: 12),
            
            // Dirección de ordenamiento
            Row(
              children: [
                const Text('Orden:'),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Ascendente'),
                  selected: _sortAscending,
                  onSelected: (selected) {
                    setState(() {
                      _sortAscending = true;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Descendente'),
                  selected: !_sortAscending,
                  onSelected: (selected) {
                    setState(() {
                      _sortAscending = false;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Botón para aplicar filtros
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final filteredExpenses = _applyFilters();
                  Navigator.pop(context, filteredExpenses);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Aplicar Filtros',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}