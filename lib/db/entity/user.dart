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
        'user_id': userId,
        'username': username,
        'email': email,
        'image_url': imageUrl,
        'clearance_level': clearanceLevel,
        'phone_number': phoneNumber,
        'name': name,
      };

  static User fromJson(Map<String, dynamic> json) => User(
        userId: json['user_id'],
        username: json['username'],
        email: json['email'],
        imageUrl: json['image_url'],
        clearanceLevel: json['clearance_level'],
        phoneNumber: json['phone_number'],
        name: json['name'],
      );
}
