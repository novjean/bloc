class Reservation {
  final String id;
  final String blocServiceId;
  // final String customerId;
  final String name;
  final int phone;
  final int guestsCount;

  final int createdAt;
  final int arrivalDate;
  final String arrivalTime;

//<editor-fold desc="Data Methods">
  const Reservation({
    required this.id,
    required this.blocServiceId,
    required this.name,
    required this.phone,
    required this.guestsCount,
    required this.createdAt,
    required this.arrivalDate,
    required this.arrivalTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reservation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          blocServiceId == other.blocServiceId &&
          name == other.name &&
          phone == other.phone &&
          guestsCount == other.guestsCount &&
          createdAt == other.createdAt &&
          arrivalDate == other.arrivalDate &&
          arrivalTime == other.arrivalTime);

  @override
  int get hashCode =>
      id.hashCode ^
      blocServiceId.hashCode ^
      name.hashCode ^
      phone.hashCode ^
      guestsCount.hashCode ^
      createdAt.hashCode ^
      arrivalDate.hashCode ^
      arrivalTime.hashCode;

  @override
  String toString() {
    return 'Reservation{' +
        ' id: $id,' +
        ' blocServiceId: $blocServiceId,' +
        ' name: $name,' +
        ' phone: $phone,' +
        ' guestsCount: $guestsCount,' +
        ' createdAt: $createdAt,' +
        ' arrivalDate: $arrivalDate,' +
        ' arrivalTime: $arrivalTime,' +
        '}';
  }

  Reservation copyWith({
    String? id,
    String? blocServiceId,
    String? name,
    int? phone,
    int? guestsCount,
    int? createdAt,
    int? arrivalDate,
    String? arrivalTime,
  }) {
    return Reservation(
      id: id ?? this.id,
      blocServiceId: blocServiceId ?? this.blocServiceId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      guestsCount: guestsCount ?? this.guestsCount,
      createdAt: createdAt ?? this.createdAt,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      arrivalTime: arrivalTime ?? this.arrivalTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'blocServiceId': this.blocServiceId,
      'name': this.name,
      'phone': this.phone,
      'guestsCount': this.guestsCount,
      'createdAt': this.createdAt,
      'arrivalDate': this.arrivalDate,
      'arrivalTime': this.arrivalTime,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'] as String,
      blocServiceId: map['blocServiceId'] as String,
      name: map['name'] as String,
      phone: map['phone'] as int,
      guestsCount: map['guestsCount'] as int,
      createdAt: map['createdAt'] as int,
      arrivalDate: map['arrivalDate'] as int,
      arrivalTime: map['arrivalTime'] as String,
    );
  }

//</editor-fold>
}