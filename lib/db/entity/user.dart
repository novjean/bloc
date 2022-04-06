import 'package:floor/floor.dart';

@entity
class User {
  @primaryKey
  final String userId;
  final String username;
  final String email;
  final String imageUrl;
  final int clearanceLevel;
  final String name;

  User(
      {required this.userId,
      required this.username,
      required this.email,
      required this.imageUrl,
      required this.clearanceLevel,
      required this.name});
}
