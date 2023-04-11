class PartyGuest {
  final String id;
  String partyId;
  String guestId;
  String name;
  String surname;
  String phone;
  String email;
  int guestsCount;
  int guestsRemaining;

  final int createdAt;
  final bool isApproved;

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
    required this.guestsCount,
    required this.guestsRemaining,
    required this.createdAt,
    required this.isApproved,
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
          guestsCount == other.guestsCount &&
          guestsRemaining == other.guestsRemaining &&
          createdAt == other.createdAt &&
          isApproved == other.isApproved &&
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
      guestsCount.hashCode ^
      guestsRemaining.hashCode ^
      createdAt.hashCode ^
      isApproved.hashCode ^
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
        ' guestsCount: $guestsCount,' +
        ' guestsRemaining: $guestsRemaining,' +
        ' createdAt: $createdAt,' +
        ' isApproved: $isApproved,' +
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
    int? guestsCount,
    int? guestsRemaining,
    int? createdAt,
    bool? isApproved,
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
      guestsCount: guestsCount ?? this.guestsCount,
      guestsRemaining: guestsRemaining ?? this.guestsRemaining,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
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
      'guestsCount': this.guestsCount,
      'guestsRemaining': this.guestsRemaining,
      'createdAt': this.createdAt,
      'isApproved': this.isApproved,
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
      guestsCount: map['guestsCount'] as int,
      guestsRemaining: map['guestsRemaining'] as int,
      createdAt: map['createdAt'] as int,
      isApproved: map['isApproved'] as bool,
      guestStatus: map['guestStatus'] as String,
    );
  }

//</editor-fold>
}