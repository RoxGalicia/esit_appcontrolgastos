
import 'package:flutter/material.dart';
import '../models/expense.dart'; // Modelo de gasto
import 'expense_card.dart'; // Widget de tarjeta de gasto

/// Widget que muestra una lista de gastos.
/// Gestiona estados de carga y lista vacía mostrando mensajes apropiados.
class ExpenseList extends StatelessWidget {
 final List<Expense> expenses; // Lista de gastos a mostrar
 final Function(Expense) onEditExpense; // Callback para editar un gasto
 final Function(Expense) onDeleteExpense; // Callback para eliminar un gasto
 final bool isLoading; // Indicador de carga

 const ExpenseList({
   super.key,
   required this.expenses,
   required this.onEditExpense,
   required this.onDeleteExpense,
   this.isLoading = false, // Por defecto no está cargando
 });

 @override
 Widget build(BuildContext context) {
   // Si está cargando, mostramos un indicador de progreso centrado
   if (isLoading) {
     return const Center(
       child: CircularProgressIndicator(),
     );
   }

   // Si no hay gastos, mostramos un mensaje indicando que la lista está vacía
   if (expenses.isEmpty) {
     return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           // Icono grande de recibo
           Icon(
             Icons.receipt_long,
             size: 80,
             color: Colors.grey[400], // Gris claro para no ser muy intrusivo
           ),
           const SizedBox(height: 16),
           // Mensaje principal
           Text(
             'No hay gastos registrados',
             style: TextStyle(
               fontSize: 16,
               color: Colors.grey[600], // Gris medio para legibilidad
             ),
           ),
           const SizedBox(height: 8),
           // Instrucción para el usuario
           Text(
             'Toca el botón "+" para agregar un gasto',
             style: TextStyle(
               fontSize: 14,
               color: Colors.grey[500], // Gris un poco más claro para mensaje secundario
             ),
           ),
         ],
       ),
     );
   }

   // Si hay gastos, construimos la lista de tarjetas
   return ListView.builder(
     itemCount: expenses.length, // Número de gastos en la lista
     physics: const NeverScrollableScrollPhysics(), // Desactivamos el scroll propio de ListView
     shrinkWrap: true, // Para que se ajuste al contenido
     itemBuilder: (context, index) {
       // Obtenemos el gasto actual
       final expense = expenses[index];
       // Creamos una tarjeta para cada gasto
       return ExpenseCard(
         expense: expense, // Pasamos el gasto a mostrar
         onEdit: () => onEditExpense(expense), // Pasamos el callback de edición
         onDelete: () => onDeleteExpense(expense), // Pasamos el callback de eliminación
       );
     },
   );
 }
}