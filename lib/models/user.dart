// lib/models/user.dart

class User {
  final int? id;
  final String fullName;
  final String email;
  final String password;

  User({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
  });

  // Convertir User a un Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
    };
  }

  // Crear un User desde un Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      password: map['password'],
    );
  }

  // Crear una copia de User con algunos campos modificados
  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}