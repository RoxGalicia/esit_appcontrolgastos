// lib/database/database_helper.dart

import 'package:path/path.dart';  // Importamos path para manejar rutas de archivos
import 'package:sqflite/sqflite.dart';  // Importamos sqflite para trabajar con la base de datos SQLite
import '../models/user.dart';  // Importamos el modelo de usuario
import '../models/expense.dart';  // Importamos el modelo de gasto

/// Esta clase se encarga de todas las operaciones relacionadas con la base de datos.
/// Implementa el patrón Singleton para garantizar una única instancia de la BD.
class DatabaseHelper {
 // Implementación del patrón Singleton
 // Creamos una única instancia que será compartida en toda la aplicación
 static final DatabaseHelper _instance = DatabaseHelper._internal();
 
 // Constructor factory que devuelve la instancia ya creada
 factory DatabaseHelper() => _instance;
 
 // Constructor privado para evitar múltiples instancias
 DatabaseHelper._internal();

 // Variable estática para almacenar la instancia de la base de datos
 static Database? _database;

 /// Getter que proporciona acceso a la base de datos.
 /// Si no existe, la inicializa primero.
 Future<Database> get database async {
   // Si ya tenemos una instancia de la base de datos, la devolvemos
   if (_database != null) return _database!;
   // Si no existe, inicializamos la base de datos
   _database = await _initDatabase();
   return _database!;
 }

 /// Inicializa la base de datos creando el archivo y las tablas necesarias.
 Future<Database> _initDatabase() async {
   // Obtenemos la ruta donde se guardan las bases de datos en el dispositivo
   final databasesPath = await getDatabasesPath();
   // Combinamos la ruta con el nombre de nuestro archivo de base de datos
   final path = join(databasesPath, 'expense_tracker.db');

   // Abrimos o creamos la base de datos en la ruta especificada
   return await openDatabase(
     path,
     version: 1,  // Versión de nuestra base de datos (útil para migraciones futuras)
     onCreate: _createDatabase,  // Función que se ejecutará al crear la base de datos
   );
 }

 /// Crea las tablas necesarias en la base de datos.
 Future<void> _createDatabase(Database db, int version) async {
   // Creamos la tabla de usuarios con sus campos
   await db.execute('''
     CREATE TABLE users(
       id INTEGER PRIMARY KEY AUTOINCREMENT,  // ID autoincrementable como clave primaria
       fullName TEXT NOT NULL,                // Nombre completo (obligatorio)
       email TEXT NOT NULL UNIQUE,            // Email (obligatorio y único)
       password TEXT NOT NULL                 // Contraseña (obligatoria)
     )
   ''');

   // Creamos la tabla de gastos con sus campos
   await db.execute('''
     CREATE TABLE expenses(
       id INTEGER PRIMARY KEY AUTOINCREMENT,  // ID autoincrementable como clave primaria
       userId INTEGER NOT NULL,               // ID del usuario al que pertenece el gasto
       description TEXT NOT NULL,             // Descripción del gasto
       category TEXT NOT NULL,                // Categoría del gasto
       amount REAL NOT NULL,                  // Monto del gasto (número con decimales)
       date TEXT NOT NULL,                    // Fecha del gasto (como texto ISO8601)
       FOREIGN KEY (userId) REFERENCES users(id)  // Llave foránea que conecta con la tabla users
     )
   ''');
 }

 // ===== MÉTODOS PARA LA GESTIÓN DE USUARIOS =====

 /// Inserta un nuevo usuario en la base de datos.
 /// Retorna el ID del usuario insertado.
 Future<int> insertUser(User user) async {
   final db = await database;  // Obtenemos la instancia de la base de datos
   return await db.insert('users', user.toMap());  // Insertamos el usuario convertido a Map
 }

 /// Busca un usuario por su email.
 /// Retorna el objeto User si existe, o null si no se encuentra.
 Future<User?> getUserByEmail(String email) async {
   final db = await database;
   // Consultamos la tabla users filtrando por email
   final List<Map<String, dynamic>> maps = await db.query(
     'users',
     where: 'email = ?',  // Condición de búsqueda
     whereArgs: [email],  // Valor para la condición (evita inyección SQL)
   );

   // Si encontramos resultados, convertimos el primero en un objeto User
   if (maps.isNotEmpty) {
     return User.fromMap(maps.first);
   }
   return null;  // Si no hay resultados, devolvemos null
 }

 /// Verifica las credenciales de un usuario para el inicio de sesión.
 /// Retorna el objeto User si las credenciales son correctas, o null si no coinciden.
 Future<User?> authenticateUser(String email, String password) async {
   final db = await database;
   // Consultamos la tabla users filtrando por email y password
   final List<Map<String, dynamic>> maps = await db.query(
     'users',
     where: 'email = ? AND password = ?',
     whereArgs: [email, password],
   );

   // Si encontramos coincidencia, creamos y devolvemos el objeto User
   if (maps.isNotEmpty) {
     return User.fromMap(maps.first);
   }
   return null;  // Credenciales incorrectas
 }

 /// Actualiza la contraseña de un usuario.
 /// Retorna el número de filas afectadas (1 si se actualizó correctamente, 0 si no).
 Future<int> updateUserPassword(String email, String newPassword) async {
   final db = await database;
   // Actualizamos el campo password en la tabla users donde el email coincida
   return await db.update(
     'users',
     {'password': newPassword},  // Nuevos valores
     where: 'email = ?',         // Condición
     whereArgs: [email],         // Valor para la condición
   );
 }

 // ===== MÉTODOS PARA LA GESTIÓN DE GASTOS =====

 /// Inserta un nuevo gasto en la base de datos.
 /// Retorna el ID del gasto insertado.
 Future<int> insertExpense(Expense expense) async {
   final db = await database;
   return await db.insert('expenses', expense.toMap());
 }

 /// Actualiza un gasto existente.
 /// Retorna el número de filas afectadas (1 si se actualizó correctamente).
 Future<int> updateExpense(Expense expense) async {
   final db = await database;
   return await db.update(
     'expenses',
     expense.toMap(),      // Datos actualizados
     where: 'id = ?',      // Condición por ID
     whereArgs: [expense.id],  // ID del gasto a actualizar
   );
 }

 /// Elimina un gasto por su ID.
 /// Retorna el número de filas afectadas (1 si se eliminó correctamente).
 Future<int> deleteExpense(int id) async {
   final db = await database;
   return await db.delete(
     'expenses',
     where: 'id = ?',  // Condición por ID
     whereArgs: [id],  // ID del gasto a eliminar
   );
 }

 /// Obtiene todos los gastos de un usuario específico.
 /// Retorna una lista de objetos Expense ordenados por fecha (más recientes primero).
 Future<List<Expense>> getUserExpenses(int userId) async {
   final db = await database;
   // Consultamos todos los gastos del usuario
   final List<Map<String, dynamic>> maps = await db.query(
     'expenses',
     where: 'userId = ?',   // Filtramos por el ID del usuario
     whereArgs: [userId],
     orderBy: 'date DESC',  // Ordenamos por fecha descendente (más recientes primero)
   );

   // Convertimos cada Map en un objeto Expense y devolvemos la lista
   return List.generate(maps.length, (i) {
     return Expense.fromMap(maps[i]);
   });
 }

 /// Calcula el monto total de gastos de un usuario.
 /// Retorna la suma de todos los gastos o 0.0 si no hay gastos.
 Future<double> getTotalExpenses(int userId) async {
   final db = await database;
   // Ejecutamos una consulta SQL que suma la columna amount
   final result = await db.rawQuery(
     'SELECT SUM(amount) as total FROM expenses WHERE userId = ?',
     [userId],
   );
   
   // Si no hay resultados o la suma es null, devolvemos 0.0, de lo contrario la suma
   return result.first['total'] == null ? 0.0 : result.first['total'] as double;
 }
}