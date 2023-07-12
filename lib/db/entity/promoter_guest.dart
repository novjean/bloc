class PromoterGuest{
  final String id;
  final String name;
  final String phone;
  final String promoterId;
  final String partyGuestId;
  final String blocUserId;

  final int createdAt;
  final bool hasAttended;

//<editor-fold desc="Data Methods">
  const PromoterGuest({
    required this.id,
    required this.name,
    required this.phone,
    required this.promoterId,
    required this.partyGuestId,
    required this.blocUserId,
    required this.createdAt,
    required this.hasAttended,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PromoterGuest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phone == other.phone &&
          promoterId == other.promoterId &&
          partyGuestId == other.partyGuestId &&
          blocUserId == other.blocUserId &&
          createdAt == other.createdAt &&
          hasAttended == other.hasAttended);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      phone.hashCode ^
      promoterId.hashCode ^
      partyGuestId.hashCode ^
      blocUserId.hashCode ^
      createdAt.hashCode ^
      hasAttended.hashCode;

  @override
  String toString() {
    return 'PromoterGuest{' +
        ' id: $id,' +
        ' name: $name,' +
        ' phone: $phone,' +
        ' promoterId: $promoterId,' +
        ' partyGuestId: $partyGuestId,' +
        ' blocUserId: $blocUserId,' +
        ' createdAt: $createdAt,' +
        ' hasAttended: $hasAttended,' +
        '}';
  }

  PromoterGuest copyWith({
    String? id,
    String? name,
    String? phone,
    String? promoterId,
    String? partyGuestId,
    String? blocUserId,
    int? createdAt,
    bool? hasAttended,
  }) {
    return PromoterGuest(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      promoterId: promoterId ?? this.promoterId,
      partyGuestId: partyGuestId ?? this.partyGuestId,
      blocUserId: blocUserId ?? this.blocUserId,
      createdAt: createdAt ?? this.createdAt,
      hasAttended: hasAttended ?? this.hasAttended,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'phone': this.phone,
      'promoterId': this.promoterId,
      'partyGuestId': this.partyGuestId,
      'blocUserId': this.blocUserId,
      'createdAt': this.createdAt,
      'hasAttended': this.hasAttended,
    };
  }

  factory PromoterGuest.fromMap(Map<String, dynamic> map) {
    return PromoterGuest(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      promoterId: map['promoterId'] as String,
      partyGuestId: map['partyGuestId'] as String,
      blocUserId: map['blocUserId'] as String,
      createdAt: map['createdAt'] as int,
      hasAttended: map['hasAttended'] as bool,
    );
  }

//</editor-fold>
}