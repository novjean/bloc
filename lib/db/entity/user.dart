class User {
  String id;
  final String name;
  final String surname;
  int phoneNumber;
  final String email;
  final String imageUrl;
  final String gender;

  final int clearanceLevel;
  final int challengeLevel;

  final String blocServiceId;
  String fcmToken;

  int createdAt;
  int lastSeenAt;

  bool isBanned;
  bool isAppUser;
  String appVersion;

//<editor-fold desc="Data Methods">
  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.phoneNumber,
    required this.email,
    required this.imageUrl,
    required this.gender,
    required this.clearanceLevel,
    required this.challengeLevel,
    required this.blocServiceId,
    required this.fcmToken,
    required this.createdAt,
    required this.lastSeenAt,
    required this.isBanned,
    required this.isAppUser,
    required this.appVersion,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          surname == other.surname &&
          phoneNumber == other.phoneNumber &&
          email == other.email &&
          imageUrl == other.imageUrl &&
          gender == other.gender &&
          clearanceLevel == other.clearanceLevel &&
          challengeLevel == other.challengeLevel &&
          blocServiceId == other.blocServiceId &&
          fcmToken == other.fcmToken &&
          createdAt == other.createdAt &&
          lastSeenAt == other.lastSeenAt &&
          isBanned == other.isBanned &&
          isAppUser == other.isAppUser &&
          appVersion == other.appVersion);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      surname.hashCode ^
      phoneNumber.hashCode ^
      email.hashCode ^
      imageUrl.hashCode ^
      gender.hashCode ^
      clearanceLevel.hashCode ^
      challengeLevel.hashCode ^
      blocServiceId.hashCode ^
      fcmToken.hashCode ^
      createdAt.hashCode ^
      lastSeenAt.hashCode ^
      isBanned.hashCode ^
      isAppUser.hashCode ^
      appVersion.hashCode;

  @override
  String toString() {
    return 'User{' +
        ' id: $id,' +
        ' name: $name,' +
        ' surname: $surname,' +
        ' phoneNumber: $phoneNumber,' +
        ' email: $email,' +
        ' imageUrl: $imageUrl,' +
        ' gender: $gender,' +
        ' clearanceLevel: $clearanceLevel,' +
        ' challengeLevel: $challengeLevel,' +
        ' blocServiceId: $blocServiceId,' +
        ' fcmToken: $fcmToken,' +
        ' createdAt: $createdAt,' +
        ' lastSeenAt: $lastSeenAt,' +
        ' isBanned: $isBanned,' +
        ' isAppUser: $isAppUser,' +
        ' appVersion: $appVersion,' +
        '}';
  }

  User copyWith({
    String? id,
    String? name,
    String? surname,
    int? phoneNumber,
    String? email,
    String? imageUrl,
    String? gender,
    int? clearanceLevel,
    int? challengeLevel,
    String? blocServiceId,
    String? fcmToken,
    int? createdAt,
    int? lastSeenAt,
    bool? isBanned,
    bool? isAppUser,
    String? appVersion,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      gender: gender ?? this.gender,
      clearanceLevel: clearanceLevel ?? this.clearanceLevel,
      challengeLevel: challengeLevel ?? this.challengeLevel,
      blocServiceId: blocServiceId ?? this.blocServiceId,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isBanned: isBanned ?? this.isBanned,
      isAppUser: isAppUser ?? this.isAppUser,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'surname': this.surname,
      'phoneNumber': this.phoneNumber,
      'email': this.email,
      'imageUrl': this.imageUrl,
      'gender': this.gender,
      'clearanceLevel': this.clearanceLevel,
      'challengeLevel': this.challengeLevel,
      'blocServiceId': this.blocServiceId,
      'fcmToken': this.fcmToken,
      'createdAt': this.createdAt,
      'lastSeenAt': this.lastSeenAt,
      'isBanned': this.isBanned,
      'isAppUser': this.isAppUser,
      'appVersion': this.appVersion,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      surname: map['surname'] as String,
      phoneNumber: map['phoneNumber'] as int,
      email: map['email'] as String,
      imageUrl: map['imageUrl'] as String,
      gender: map['gender'] as String,
      clearanceLevel: map['clearanceLevel'] as int,
      challengeLevel: map['challengeLevel'] as int,
      blocServiceId: map['blocServiceId'] as String,
      fcmToken: map['fcmToken'] as String,
      createdAt: map['createdAt'] as int,
      lastSeenAt: map['lastSeenAt'] as int,
      isBanned: map['isBanned'] as bool,
      isAppUser: map['isAppUser'] as bool,
      appVersion: map['appVersion'] as String,
    );
  }

//</editor-fold>
}
