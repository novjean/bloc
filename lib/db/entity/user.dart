import 'package:floor/floor.dart';

@entity
class User {
  @primaryKey
  final String id;
  final String username;
  final String email;
  final String imageUrl;
  final int clearanceLevel;
  final int phoneNumber;
  final String name;
  final String fcmToken;

//<editor-fold desc="Data Methods">

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.imageUrl,
    required this.clearanceLevel,
    required this.phoneNumber,
    required this.name,
    required this.fcmToken,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email &&
          imageUrl == other.imageUrl &&
          clearanceLevel == other.clearanceLevel &&
          phoneNumber == other.phoneNumber &&
          name == other.name &&
          fcmToken == other.fcmToken);

  @override
  int get hashCode =>
      id.hashCode ^
      username.hashCode ^
      email.hashCode ^
      imageUrl.hashCode ^
      clearanceLevel.hashCode ^
      phoneNumber.hashCode ^
      name.hashCode ^
      fcmToken.hashCode;

  @override
  String toString() {
    return 'User{' +
        ' id: $id,' +
        ' username: $username,' +
        ' email: $email,' +
        ' imageUrl: $imageUrl,' +
        ' clearanceLevel: $clearanceLevel,' +
        ' phoneNumber: $phoneNumber,' +
        ' name: $name,' +
        ' fcmToken: $fcmToken,' +
        '}';
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? imageUrl,
    int? clearanceLevel,
    int? phoneNumber,
    String? name,
    String? fcmToken,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      clearanceLevel: clearanceLevel ?? this.clearanceLevel,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'username': this.username,
      'email': this.email,
      'imageUrl': this.imageUrl,
      'clearanceLevel': this.clearanceLevel,
      'phoneNumber': this.phoneNumber,
      'name': this.name,
      'fcmToken': this.fcmToken,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      imageUrl: map['imageUrl'] as String,
      clearanceLevel: map['clearanceLevel'] as int,
      phoneNumber: map['phoneNumber'] as int,
      name: map['name'] as String,
      fcmToken: map['fcmToken'] as String,
    );
  }

//</editor-fold>
}
