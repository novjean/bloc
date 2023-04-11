class User {
  String id;
  final String name;
  final String surname;
  final String email;
  final String imageUrl;
  final int clearanceLevel;
  int phoneNumber;
  String fcmToken;
  final String blocServiceId;
  int createdAt;
  int lastSeenAt;

//<editor-fold desc="Data Methods">
  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.imageUrl,
    required this.clearanceLevel,
    required this.phoneNumber,
    required this.fcmToken,
    required this.blocServiceId,
    required this.createdAt,
    required this.lastSeenAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          surname == other.surname &&
          email == other.email &&
          imageUrl == other.imageUrl &&
          clearanceLevel == other.clearanceLevel &&
          phoneNumber == other.phoneNumber &&
          fcmToken == other.fcmToken &&
          blocServiceId == other.blocServiceId &&
          createdAt == other.createdAt &&
          lastSeenAt == other.lastSeenAt);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      surname.hashCode ^
      email.hashCode ^
      imageUrl.hashCode ^
      clearanceLevel.hashCode ^
      phoneNumber.hashCode ^
      fcmToken.hashCode ^
      blocServiceId.hashCode ^
      createdAt.hashCode ^
      lastSeenAt.hashCode;

  @override
  String toString() {
    return 'User{' +
        ' id: $id,' +
        ' name: $name,' +
        ' surname: $surname,' +
        ' email: $email,' +
        ' imageUrl: $imageUrl,' +
        ' clearanceLevel: $clearanceLevel,' +
        ' phoneNumber: $phoneNumber,' +
        ' fcmToken: $fcmToken,' +
        ' blocServiceId: $blocServiceId,' +
        ' createdAt: $createdAt,' +
        ' lastSeenAt: $lastSeenAt,' +
        '}';
  }

  User copyWith({
    String? id,
    String? name,
    String? surname,
    String? email,
    String? imageUrl,
    int? clearanceLevel,
    int? phoneNumber,
    String? fcmToken,
    String? blocServiceId,
    int? createdAt,
    int? lastSeenAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      clearanceLevel: clearanceLevel ?? this.clearanceLevel,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fcmToken: fcmToken ?? this.fcmToken,
      blocServiceId: blocServiceId ?? this.blocServiceId,
      createdAt: createdAt ?? this.createdAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'surname': this.surname,
      'email': this.email,
      'imageUrl': this.imageUrl,
      'clearanceLevel': this.clearanceLevel,
      'phoneNumber': this.phoneNumber,
      'fcmToken': this.fcmToken,
      'blocServiceId': this.blocServiceId,
      'createdAt': this.createdAt,
      'lastSeenAt': this.lastSeenAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      surname: map['surname'] as String,
      email: map['email'] as String,
      imageUrl: map['imageUrl'] as String,
      clearanceLevel: map['clearanceLevel'] as int,
      phoneNumber: map['phoneNumber'] as int,
      fcmToken: map['fcmToken'] as String,
      blocServiceId: map['blocServiceId'] as String,
      createdAt: map['createdAt'] as int,
      lastSeenAt: map['lastSeenAt'] as int,
    );
  }

//</editor-fold>
}
