class PartyGuest {
  final String id;
  String partyId;
  String guestId;
  String name;
  String surname;
  String phone;
  String email;
  String gender;

  int guestsCount;
  int guestsRemaining;

  final int createdAt;
  final bool isChallengeClicked;
  final bool isApproved;
  bool shouldBanUser;

  String guestStatus;

//<editor-fold desc="Data Methods">
  PartyGuest({
    required this.id,
    required this.partyId,
    required this.guestId,
    required this.name,
    required this.surname,
    required this.phone,
    required this.email,
    required this.gender,
    required this.guestsCount,
    required this.guestsRemaining,
    required this.createdAt,
    required this.isChallengeClicked,
    required this.isApproved,
    required this.shouldBanUser,
    required this.guestStatus,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartyGuest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          partyId == other.partyId &&
          guestId == other.guestId &&
          name == other.name &&
          surname == other.surname &&
          phone == other.phone &&
          email == other.email &&
          gender == other.gender &&
          guestsCount == other.guestsCount &&
          guestsRemaining == other.guestsRemaining &&
          createdAt == other.createdAt &&
          isChallengeClicked == other.isChallengeClicked &&
          isApproved == other.isApproved &&
          shouldBanUser == other.shouldBanUser &&
          guestStatus == other.guestStatus);

  @override
  int get hashCode =>
      id.hashCode ^
      partyId.hashCode ^
      guestId.hashCode ^
      name.hashCode ^
      surname.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      gender.hashCode ^
      guestsCount.hashCode ^
      guestsRemaining.hashCode ^
      createdAt.hashCode ^
      isChallengeClicked.hashCode ^
      isApproved.hashCode ^
      shouldBanUser.hashCode ^
      guestStatus.hashCode;

  @override
  String toString() {
    return 'PartyGuest{' +
        ' id: $id,' +
        ' partyId: $partyId,' +
        ' guestId: $guestId,' +
        ' name: $name,' +
        ' surname: $surname,' +
        ' phone: $phone,' +
        ' email: $email,' +
        ' gender: $gender,' +
        ' guestsCount: $guestsCount,' +
        ' guestsRemaining: $guestsRemaining,' +
        ' createdAt: $createdAt,' +
        ' isChallengeClicked: $isChallengeClicked,' +
        ' isApproved: $isApproved,' +
        ' shouldBanUser: $shouldBanUser,' +
        ' guestStatus: $guestStatus,' +
        '}';
  }

  PartyGuest copyWith({
    String? id,
    String? partyId,
    String? guestId,
    String? name,
    String? surname,
    String? phone,
    String? email,
    String? gender,
    int? guestsCount,
    int? guestsRemaining,
    int? createdAt,
    bool? isChallengeClicked,
    bool? isApproved,
    bool? shouldBanUser,
    String? guestStatus,
  }) {
    return PartyGuest(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      guestId: guestId ?? this.guestId,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      guestsCount: guestsCount ?? this.guestsCount,
      guestsRemaining: guestsRemaining ?? this.guestsRemaining,
      createdAt: createdAt ?? this.createdAt,
      isChallengeClicked: isChallengeClicked ?? this.isChallengeClicked,
      isApproved: isApproved ?? this.isApproved,
      shouldBanUser: shouldBanUser ?? this.shouldBanUser,
      guestStatus: guestStatus ?? this.guestStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'partyId': this.partyId,
      'guestId': this.guestId,
      'name': this.name,
      'surname': this.surname,
      'phone': this.phone,
      'email': this.email,
      'gender': this.gender,
      'guestsCount': this.guestsCount,
      'guestsRemaining': this.guestsRemaining,
      'createdAt': this.createdAt,
      'isChallengeClicked': this.isChallengeClicked,
      'isApproved': this.isApproved,
      'shouldBanUser': this.shouldBanUser,
      'guestStatus': this.guestStatus,
    };
  }

  factory PartyGuest.fromMap(Map<String, dynamic> map) {
    return PartyGuest(
      id: map['id'] as String,
      partyId: map['partyId'] as String,
      guestId: map['guestId'] as String,
      name: map['name'] as String,
      surname: map['surname'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      gender: map['gender'] as String,
      guestsCount: map['guestsCount'] as int,
      guestsRemaining: map['guestsRemaining'] as int,
      createdAt: map['createdAt'] as int,
      isChallengeClicked: map['isChallengeClicked'] as bool,
      isApproved: map['isApproved'] as bool,
      shouldBanUser: map['shouldBanUser'] as bool,
      guestStatus: map['guestStatus'] as String,
    );
  }

//</editor-fold>
}