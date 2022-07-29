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
  final String blocId;

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
    required this.blocId,
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
          fcmToken == other.fcmToken &&
          blocId == other.blocId);

  @override
  int get hashCode =>
      id.hashCode ^
      username.hashCode ^
      email.hashCode ^
      imageUrl.hashCode ^
      clearanceLevel.hashCode ^
      phoneNumber.hashCode ^
      name.hashCode ^
      fcmToken.hashCode ^
      blocId.hashCode;

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
        ' blocId: $blocId,' +
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
    String? blocId,
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
      blocId: blocId ?? this.blocId,
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
      'blocId': this.blocId,
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
      blocId: map['blocId'] as String,
    );
  }

//</editor-fold>
}
