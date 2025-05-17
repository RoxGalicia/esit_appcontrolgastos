// lib/models/expense.dart

class Expense {
  final int? id;
  final int userId;
  final String description;
  final String category;
  final double amount;
  final DateTime date;

  Expense({
    this.id,
    required this.userId,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
  });

  // Convertir Expense a un Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'description': description,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  // Crear un Expense desde un Map
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      userId: map['userId'],
      description: map['description'],
      category: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
    );
  }

  // Crear una copia de Expense con algunos campos modificados
  Expense copyWith({
    int? id,
    int? userId,
    String? description,
    String? category,
    double? amount,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}

// Lista de categorías predefinidas
class ExpenseCategories {
  static const List<String> categories = [
    'Alimentación',
    'Transporte',
    'Entretenimiento',
    'Salud',
    'Educación',
    'Ropa',
    'Servicios',
    'Vivienda',
    'Otros'
  ];
}