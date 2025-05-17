
/// Clase que representa a un usuario en nuestra aplicación.
/// Contiene toda la información personal y de autenticación del usuario.
class User {
 final int? id;       // ID único del usuario (nullable porque es asignado por la base de datos)
 final String fullName; // Nombre completo del usuario
 final String email;    // Correo electrónico (usado para iniciar sesión)
 final String password; // Contraseña del usuario (en una app real, esto debería estar hasheado)

 /// Constructor para crear una instancia de User.
 /// Solo el id es opcional, los demás campos son requeridos.
 User({
   this.id,
   required this.fullName,
   required this.email,
   required this.password,
 });

 /// Convierte una instancia de User a un Map<String, dynamic>.
 /// Esto es necesario para guardar el objeto en la base de datos SQLite.
 Map<String, dynamic> toMap() {
   return {
     'id': id,               // ID del usuario (puede ser null si es un nuevo usuario)
     'fullName': fullName,   // Nombre completo
     'email': email,         // Correo electrónico
     'password': password,   // Contraseña
   };
 }

 /// Constructor factory que crea una instancia de User desde un Map.
 /// Esto es útil para convertir los datos obtenidos de la base de datos a objetos User.
 factory User.fromMap(Map<String, dynamic> map) {
   return User(
     id: map['id'],                // Obtenemos el ID desde el map
     fullName: map['fullName'],    // Obtenemos el nombre completo
     email: map['email'],          // Obtenemos el email
     password: map['password'],    // Obtenemos la contraseña
   );
 }

 /// Método que crea una copia del objeto con algunos campos modificados.
 /// Útil para actualizar información del usuario sin tener que reescribir todos los campos.
 /// Los campos no especificados mantienen su valor original.
 User copyWith({
   int? id,
   String? fullName,
   String? email,
   String? password,
 }) {
   return User(
     id: id ?? this.id,                 // Si no se proporciona un nuevo id, usar el actual
     fullName: fullName ?? this.fullName, // Si no se proporciona un nuevo nombre, usar el actual
     email: email ?? this.email,        // Y así sucesivamente...
     password: password ?? this.password,
   );
 }
}