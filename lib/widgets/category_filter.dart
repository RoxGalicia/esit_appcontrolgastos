
import 'package:flutter/material.dart';
import '../utils/constants.dart'; // Para acceder a los colores constantes

/// Widget para filtrar gastos por categoría.
/// Muestra una fila horizontal de chips seleccionables, una por cada categoría.
class CategoryFilter extends StatelessWidget {
 final List<String> categories; // Lista de categorías disponibles
 final String? selectedCategory; // Categoría actualmente seleccionada (null = todas)
 final Function(String?) onCategorySelected; // Callback cuando se selecciona una categoría

 const CategoryFilter({
   super.key,
   required this.categories,
   required this.selectedCategory,
   required this.onCategorySelected,
 });

 @override
 Widget build(BuildContext context) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       // Título del filtro
       const Text(
         'Filtrar por categoría:',
         style: TextStyle(
           fontSize: 14,
           fontWeight: FontWeight.w500,
         ),
       ),
       const SizedBox(height: 8),
       // ListView horizontal para permitir scroll si hay muchas categorías
       SizedBox(
         height: 40, // Altura fija para el contenedor de chips
         child: ListView(
           scrollDirection: Axis.horizontal, // Desplazamiento horizontal
           children: [
             // Opción "Todos" para mostrar todos los gastos (sin filtro)
             Padding(
               padding: const EdgeInsets.only(right: 8),
               child: FilterChip(
                 label: const Text('Todos'),
                 // Seleccionado cuando no hay categoría seleccionada (filtro desactivado)
                 selected: selectedCategory == null,
                 // Al seleccionar, enviamos null para indicar "mostrar todos"
                 onSelected: (selected) {
                   if (selected) {
                     onCategorySelected(null);
                   }
                 },
                 backgroundColor: Colors.grey[200], // Color de fondo normal
                 selectedColor: AppConstants.primaryColor.withOpacity(0.2), // Color cuando está seleccionado
                 // Estilo de texto que cambia según el estado
                 labelStyle: TextStyle(
                   // Color de texto basado en selección
                   color: selectedCategory == null
                       ? AppConstants.primaryColor // Color primario si está seleccionado
                       : Colors.grey[800], // Gris oscuro si no
                   // Negrita cuando está seleccionado
                   fontWeight: selectedCategory == null
                       ? FontWeight.bold
                       : FontWeight.normal,
                 ),
               ),
             ),
             // Generamos un chip por cada categoría en la lista
             ...categories.map((category) {
               return Padding(
                 padding: const EdgeInsets.only(right: 8),
                 child: FilterChip(
                   label: Text(category),
                   // Seleccionado cuando coincide con la categoría actual
                   selected: selectedCategory == category,
                   // Al seleccionar, enviamos la categoría o null si ya estaba seleccionada
                   onSelected: (selected) {
                     if (selected) {
                       onCategorySelected(category); // Activar filtro
                     } else {
                       onCategorySelected(null); // Desactivar filtro
                     }
                   },
                   backgroundColor: Colors.grey[200], // Color de fondo normal
                   // Color cuando está seleccionado (basado en la categoría)
                   selectedColor: _getCategoryColor(category).withOpacity(0.2),
                   // Estilo de texto que cambia según el estado
                   labelStyle: TextStyle(
                     // Color basado en selección y categoría
                     color: selectedCategory == category
                         ? _getCategoryColor(category) // Color de la categoría si está seleccionada
                         : Colors.grey[800], // Gris oscuro si no
                     // Negrita cuando está seleccionado
                     fontWeight: selectedCategory == category
                         ? FontWeight.bold
                         : FontWeight.normal,
                   ),
                 ),
               );
             }).toList(),
           ],
         ),
       ),
     ],
   );
 }

 /// Devuelve un color específico para cada categoría.
 /// Esto ayuda a identificar visualmente las categorías con colores distintivos.
 Color _getCategoryColor(String category) {
   switch (category) {
     case 'Alimentación':
       return Colors.orange; // Naranja para gastos de comida
     case 'Transporte':
       return Colors.blue; // Azul para gastos de transporte
     case 'Entretenimiento':
       return Colors.purple; // Morado para entretenimiento
     case 'Salud':
       return Colors.red; // Rojo para gastos médicos
     case 'Educación':
       return Colors.brown; // Marrón para gastos educativos
     case 'Ropa':
       return Colors.pink; // Rosa para gastos en ropa
     case 'Servicios':
       return Colors.teal; // Verde azulado para servicios
     case 'Vivienda':
       return Colors.green; // Verde para gastos de vivienda
     default:
       return Colors.grey; // Gris para otras categorías no específicas
   }
 }
}