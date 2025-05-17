
/// Clase que representa un gasto en nuestra aplicación.
/// Contiene toda la información relacionada con una transacción de gasto.
class Expense {
 final int? id;            // ID único del gasto (nullable porque es asignado por la base de datos)
 final int userId;         // ID del usuario al que pertenece este gasto
 final String description; // Descripción o concepto del gasto
 final String category;    // Categoría del gasto (ej: Alimentación, Transporte, etc.)
 final double amount;      // Monto del gasto
 final DateTime date;      // Fecha en que se realizó el gasto

 /// Constructor para crear una instancia de Expense.
 /// Solo el id es opcional, los demás campos son requeridos.
 Expense({
   this.id,
   required this.userId,
   required this.description,
   required this.category,
   required this.amount,
   required this.date,
 });

 /// Convierte una instancia de Expense a un Map<String, dynamic>.
 /// Esto es necesario para guardar el objeto en la base de datos SQLite.
 Map<String, dynamic> toMap() {
   return {
     'id': id,
     'userId': userId,
     'description': description,
     'category': category,
     'amount': amount,
     'date': date.toIso8601String(), // Convertimos la fecha a formato ISO8601 para almacenarla como texto
   };
 }

 /// Constructor factory que crea una instancia de Expense desde un Map.
 /// Esto es útil para convertir los datos obtenidos de la base de datos a objetos Expense.
 factory Expense.fromMap(Map<String, dynamic> map) {
   return Expense(
     id: map['id'],
     userId: map['userId'],
     description: map['description'],
     category: map['category'],
     amount: map['amount'],
     date: DateTime.parse(map['date']), // Convertimos el texto almacenado de vuelta a un objeto DateTime
   );
 }

 /// Método que crea una copia del objeto con algunos campos modificados.
 /// Útil para actualizar un gasto sin tener que reescribir todos los campos.
 /// Los campos no especificados mantienen su valor original.
 Expense copyWith({
   int? id,
   int? userId,
   String? description,
   String? category,
   double? amount,
   DateTime? date,
 }) {
   return Expense(
     id: id ?? this.id,                         // Si no se proporciona un nuevo id, usar el actual
     userId: userId ?? this.userId,             // Si no se proporciona un nuevo userId, usar el actual
     description: description ?? this.description, // Y así sucesivamente...
     category: category ?? this.category,
     amount: amount ?? this.amount,
     date: date ?? this.date,
   );
 }
}

/// Clase que contiene las categorías predefinidas para los gastos.
/// Usamos una clase separada para mantener el código organizado.
class ExpenseCategories {
 /// Lista estática de categorías disponibles para clasificar los gastos.
 /// Estas categorías se mostrarán en el formulario de agregar/editar gastos.
 static const List<String> categories = [
   'Alimentación',    // Gastos en comida, restaurantes, mercado
   'Transporte',      // Gastos en transporte público, gasolina, mantenimiento vehicular
   'Entretenimiento', // Gastos en cine, eventos, streaming, videojuegos
   'Salud',           // Gastos médicos, medicamentos, consultas
   'Educación',       // Gastos en materiales educativos, cursos, colegiaturas
   'Ropa',            // Gastos en vestimenta, calzado, accesorios
   'Servicios',       // Gastos en electricidad, agua, internet, teléfono
   'Vivienda',        // Gastos en renta, hipoteca, mantenimiento del hogar
   'Otros'            // Cualquier gasto que no encaje en las categorías anteriores
 ];
}