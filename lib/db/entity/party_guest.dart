class PartyGuest {
  final String id;
  String partyId;
  String guestId;
  String name;
  String phone;
  String email;
  int guestsCount;

  String instagramUrl;

  final int createdAt;
  final bool isApproved;

//<editor-fold desc="Data Methods">

  PartyGuest({
    required this.id,
    required this.partyId,
    required this.guestId,
    required this.name,
    required this.phone,
    required this.email,
    required this.guestsCount,
    required this.instagramUrl,
    required this.createdAt,
    required this.isApproved,
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
          phone == other.phone &&
          email == other.email &&
          guestsCount == other.guestsCount &&
          instagramUrl == other.instagramUrl &&
          createdAt == other.createdAt &&
          isApproved == other.isApproved);

  @override
  int get hashCode =>
      id.hashCode ^
      partyId.hashCode ^
      guestId.hashCode ^
      name.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      guestsCount.hashCode ^
      instagramUrl.hashCode ^
      createdAt.hashCode ^
      isApproved.hashCode;

  @override
  String toString() {
    return 'PartyGuest{' +
        ' id: $id,' +
        ' partyId: $partyId,' +
        ' guestId: $guestId,' +
        ' name: $name,' +
        ' phone: $phone,' +
        ' email: $email,' +
        ' guestsCount: $guestsCount,' +
        ' instagramUrl: $instagramUrl,' +
        ' createdAt: $createdAt,' +
        ' isApproved: $isApproved,' +
        '}';
  }

  PartyGuest copyWith({
    String? id,
    String? partyId,
    String? guestId,
    String? name,
    String? phone,
    String? email,
    int? guestsCount,
    String? instagramUrl,
    int? createdAt,
    bool? isApproved,
  }) {
    return PartyGuest(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      guestId: guestId ?? this.guestId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      guestsCount: guestsCount ?? this.guestsCount,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'partyId': this.partyId,
      'guestId': this.guestId,
      'name': this.name,
      'phone': this.phone,
      'email': this.email,
      'guestsCount': this.guestsCount,
      'instagramUrl': this.instagramUrl,
      'createdAt': this.createdAt,
      'isApproved': this.isApproved,
    };
  }

  factory PartyGuest.fromMap(Map<String, dynamic> map) {
    return PartyGuest(
      id: map['id'] as String,
      partyId: map['partyId'] as String,
      guestId: map['guestId'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      guestsCount: map['guestsCount'] as int,
      instagramUrl: map['instagramUrl'] as String,
      createdAt: map['createdAt'] as int,
      isApproved: map['isApproved'] as bool,
    );
  }

//</editor-fold>
}