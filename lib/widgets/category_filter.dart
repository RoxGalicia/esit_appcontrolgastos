// lib/widgets/category_filter.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const CategoryFilter({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtrar por categoría:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Opción "Todos"
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('Todos'),
                  selected: selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) {
                      onCategorySelected(null);
                    }
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: selectedCategory == null
                        ? AppConstants.primaryColor
                        : Colors.grey[800],
                    fontWeight: selectedCategory == null
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              // Opciones de categorías
              ...categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: selectedCategory == category,
                    onSelected: (selected) {
                      if (selected) {
                        onCategorySelected(category);
                      } else {
                        onCategorySelected(null);
                      }
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: _getCategoryColor(category).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: selectedCategory == category
                          ? _getCategoryColor(category)
                          : Colors.grey[800],
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Alimentación':
        return Colors.orange;
      case 'Transporte':
        return Colors.blue;
      case 'Entretenimiento':
        return Colors.purple;
      case 'Salud':
        return Colors.red;
      case 'Educación':
        return Colors.brown;
      case 'Ropa':
        return Colors.pink;
      case 'Servicios':
        return Colors.teal;
      case 'Vivienda':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}