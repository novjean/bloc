import 'package:floor/floor.dart';

@entity
class User {
  @primaryKey
  final String userId;
  final String username;
  final String email;
  final String imageUrl;
  final int clearanceLevel;
  final int phoneNumber;
  final String name;

  const User(
      {required this.userId,
      required this.username,
      required this.email,
      required this.imageUrl,
      required this.clearanceLevel,
      required this.phoneNumber,
      required this.name});

  User copy({
    String? userId,
    String? username,
    String? email,
    String? imageUrl,
    int? clearanceLevel,
    int? phoneNumber,
    String? name,
  }) =>
      User(
        userId: userId ?? this.userId,
        username: username ?? this.username,
        email: email ?? this.email,
        imageUrl: imageUrl ?? this.imageUrl,
        clearanceLevel: clearanceLevel ?? this.clearanceLevel,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        name: name ?? this.name,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'email': email,
        'imageUrl': imageUrl,
        'clearanceLevel': clearanceLevel,
        'phoneNumber': phoneNumber,
        'name': name,
      };

  static User fromJson(Map<String, dynamic> json) => User(
        userId: json['userId'],
        username: json['username'],
        email: json['email'],
        imageUrl: json['imageUrl'],
        clearanceLevel: json['clearanceLevel'],
        phoneNumber: json['phoneNumber'],
        name: json['name'],
      );
}
