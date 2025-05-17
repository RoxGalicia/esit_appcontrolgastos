// lib/widgets/expense_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formateo de números y fechas
import '../models/expense.dart'; // Modelo de gasto
import '../utils/constants.dart'; // Constantes de la aplicación

/// Widget que representa una tarjeta de gasto individual.
/// Muestra la información de un gasto en un formato visual agradable.
class ExpenseCard extends StatelessWidget {
 final Expense expense; // El gasto a mostrar
 final VoidCallback onEdit; // Función a ejecutar al editar
 final VoidCallback onDelete; // Función a ejecutar al eliminar

 const ExpenseCard({
   Key? key,
   required this.expense,
   required this.onEdit,
   required this.onDelete,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
   // Formateador para mostrar el monto como moneda (ejemplo: $1,234.56)
   final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
   
   // Creamos una tarjeta que representa un gasto
   return Card(
     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
     child: InkWell(
       onTap: onEdit, // Al tocar la tarjeta, entramos en modo edición
       child: Padding(
         padding: const EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 // Icono de categoría personalizado (según el tipo de gasto)
                 getCategoryIcon(),
                 const SizedBox(width: 16),
                 // Columna central con los detalles del gasto
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       // Descripción del gasto (resaltada)
                       Text(
                         expense.description,
                         style: const TextStyle(
                           fontWeight: FontWeight.bold,
                           fontSize: 16,
                         ),
                       ),
                       const SizedBox(height: 4),
                       // Categoría del gasto
                       Text(
                         expense.category,
                         style: TextStyle(
                           color: Colors.grey[600],
                           fontSize: 14,
                         ),
                       ),
                       const SizedBox(height: 4),
                       // Fecha del gasto formateada (dd/mm/aaaa)
                       Text(
                         DateFormat('dd/MM/yyyy').format(expense.date),
                         style: TextStyle(
                           color: Colors.grey[600],
                           fontSize: 14,
                         ),
                       ),
                     ],
                   ),
                 ),
                 // Columna derecha con el monto y botones de acción
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [
                     // Monto del gasto formateado como moneda
                     Text(
                       currencyFormat.format(expense.amount),
                       style: const TextStyle(
                         fontWeight: FontWeight.bold,
                         fontSize: 16,
                         color: AppConstants.expenseColor, // Color rojo para gastos
                       ),
                     ),
                     const SizedBox(height: 8),
                     // Botones de editar y eliminar
                     Row(
                       children: [
                         // Botón de editar (lápiz azul)
                         IconButton(
                           icon: const Icon(
                             Icons.edit,
                             color: Colors.blue,
                             size: 20,
                           ),
                           onPressed: onEdit, // Ejecuta la función de edición
                           constraints: const BoxConstraints(),
                           padding: const EdgeInsets.all(4),
                           visualDensity: VisualDensity.compact, // Botón más compacto
                         ),
                         const SizedBox(width: 8),
                         // Botón de eliminar (basurero rojo)
                         IconButton(
                           icon: const Icon(
                             Icons.delete,
                             color: Colors.red,
                             size: 20,
                           ),
                           onPressed: onDelete, // Ejecuta la función de eliminación
                           constraints: const BoxConstraints(),
                           padding: const EdgeInsets.all(4),
                           visualDensity: VisualDensity.compact, // Botón más compacto
                         ),
                       ],
                     ),
                   ],
                 ),
               ],
             ),
           ],
         ),
       ),
     ),
   );
 }

 /// Genera un icono personalizado según la categoría del gasto.
 /// Cada categoría tiene un icono y color específico para identificación visual.
 Widget getCategoryIcon() {
   // Variables para el icono y color
   IconData iconData;
   Color iconColor;

   // Seleccionamos el icono y color según la categoría
   switch (expense.category) {
     case 'Alimentación':
       iconData = Icons.restaurant; // Icono de restaurante
       iconColor = Colors.orange; // Color naranja
       break;
     case 'Transporte':
       iconData = Icons.directions_car; // Icono de auto
       iconColor = Colors.blue; // Color azul
       break;
     case 'Entretenimiento':
       iconData = Icons.movie; // Icono de cine
       iconColor = Colors.purple; // Color morado
       break;
     case 'Salud':
       iconData = Icons.medical_services; // Icono médico
       iconColor = Colors.red; // Color rojo
       break;
     case 'Educación':
       iconData = Icons.school; // Icono de escuela
       iconColor = Colors.brown; // Color marrón
       break;
     case 'Ropa':
       iconData = Icons.shopping_bag; // Icono de bolsa de compras
       iconColor = Colors.pink; // Color rosa
       break;
     case 'Servicios':
       iconData = Icons.home; // Icono de hogar
       iconColor = Colors.teal; // Color verde azulado
       break;
     case 'Vivienda':
       iconData = Icons.house; // Icono de casa
       iconColor = Colors.green; // Color verde
       break;
     default:
       iconData = Icons.category; // Icono genérico
       iconColor = Colors.grey; // Color gris
       break;
   }

   // Creamos un contenedor con el icono
   return Container(
     padding: const EdgeInsets.all(8),
     // Fondo del color de la categoría con baja opacidad
     decoration: BoxDecoration(
       color: iconColor.withOpacity(0.1),
       borderRadius: BorderRadius.circular(8),
     ),
     // Icono con el color de la categoría
     child: Icon(
       iconData,
       color: iconColor,
       size: 24,
     ),
   );
 }
}