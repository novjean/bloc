import 'package:floor/floor.dart';

@entity
class User {
  @primaryKey
  final String userId;
  final String username;
  final String email;
  final String imageUrl;
  final int clearanceLevel;

  User(this.userId, this.username, this.email, this.imageUrl,
      this.clearanceLevel);
}
