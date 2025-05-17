
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formateo de números
import '../utils/constants.dart'; // Constantes de la aplicación

/// Widget que muestra un resumen de los gastos en una tarjeta atractiva.
/// Presenta el total de gastos y el número de transacciones.
class SummaryCard extends StatelessWidget {
 final double totalExpenses; // Monto total de gastos
 final int totalTransactions; // Número total de transacciones

 const SummaryCard({
   super.key,
   required this.totalExpenses,
   required this.totalTransactions,
 });

 @override
 Widget build(BuildContext context) {
   // Formateador para mostrar el monto como moneda (ejemplo: $1,234.56)
   final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

   // Creamos una tarjeta con diseño elevado y bordes redondeados
   return Card(
     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
     elevation: 2, // Sombra sutil
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(12), // Bordes más redondeados
     ),
     // Contenedor con gradiente de color
     child: Container(
       width: double.infinity, // Ocupa todo el ancho disponible
       padding: const EdgeInsets.all(16),
       // Decoración con gradiente y bordes redondeados
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(12),
         // Gradiente de color que va desde el color primario al color de acento
         gradient: const LinearGradient(
           begin: Alignment.topLeft,
           end: Alignment.bottomRight,
           colors: [
             AppConstants.primaryColor, // Verde oscuro (desde arriba-izquierda)
             AppConstants.accentColor, // Verde más claro (hacia abajo-derecha)
           ],
         ),
       ),
       // Contenido de la tarjeta
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           // Título de la tarjeta
           const Text(
             'Resumen de Gastos',
             style: TextStyle(
               fontSize: 18,
               fontWeight: FontWeight.bold,
               color: Colors.white, // Texto blanco para buen contraste
             ),
           ),
           const SizedBox(height: 16),
           // Fila que contiene las dos columnas de información
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacia las columnas
             children: [
               // Columna izquierda: Gasto Total
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   // Etiqueta descriptiva
                   const Text(
                     'Gasto Total',
                     style: TextStyle(
                       fontSize: 14,
                       color: Colors.white70, // Blanco semi-transparente
                     ),
                   ),
                   const SizedBox(height: 8),
                   // Valor formateado como moneda
                   Text(
                     currencyFormat.format(totalExpenses),
                     style: const TextStyle(
                       fontSize: 24, // Tamaño grande para destacar
                       fontWeight: FontWeight.bold,
                       color: Colors.white,
                     ),
                   ),
                 ],
               ),
               // Columna derecha: Número de Transacciones
               Column(
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: [
                   // Etiqueta descriptiva
                   const Text(
                     'Transacciones',
                     style: TextStyle(
                       fontSize: 14,
                       color: Colors.white70, // Blanco semi-transparente
                     ),
                   ),
                   const SizedBox(height: 8),
                   // Número de transacciones
                   Text(
                     totalTransactions.toString(), // Convertimos a string
                     style: const TextStyle(
                       fontSize: 24, // Tamaño grande para destacar
                       fontWeight: FontWeight.bold,
                       color: Colors.white,
                     ),
                   ),
                 ],
               ),
             ],
           ),
         ],
       ),
     ),
   );
 }
}