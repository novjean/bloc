class PromoterGuest{
  final String id;
  final String name;
  final String phone;
  final String promoterId;
  final String blocUserId;

//<editor-fold desc="Data Methods">
  const PromoterGuest({
    required this.id,
    required this.name,
    required this.phone,
    required this.promoterId,
    required this.blocUserId,
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
          blocUserId == other.blocUserId);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      phone.hashCode ^
      promoterId.hashCode ^
      blocUserId.hashCode;

  @override
  String toString() {
    return 'PromoterGuest{' +
        ' id: $id,' +
        ' name: $name,' +
        ' phone: $phone,' +
        ' promoterId: $promoterId,' +
        ' blocUserId: $blocUserId,' +
        '}';
  }

  PromoterGuest copyWith({
    String? id,
    String? name,
    String? phone,
    String? promoterId,
    String? blocUserId,
  }) {
    return PromoterGuest(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      promoterId: promoterId ?? this.promoterId,
      blocUserId: blocUserId ?? this.blocUserId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'phone': this.phone,
      'promoterId': this.promoterId,
      'blocUserId': this.blocUserId,
    };
  }

  factory PromoterGuest.fromMap(Map<String, dynamic> map) {
    return PromoterGuest(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      promoterId: map['promoterId'] as String,
      blocUserId: map['blocUserId'] as String,
    );
  }

//</editor-fold>
}