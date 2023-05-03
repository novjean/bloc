class Reservation {
  final String id;
  final String blocServiceId;
  final String customerId;
  final String name;
  final int phone;
  final int guestsCount;

  final int createdAt;
  final int arrivalDate;
  final String arrivalTime;

  final bool isApproved;

//<editor-fold desc="Data Methods">
  const Reservation({
    required this.id,
    required this.blocServiceId,
    required this.customerId,
    required this.name,
    required this.phone,
    required this.guestsCount,
    required this.createdAt,
    required this.arrivalDate,
    required this.arrivalTime,
    required this.isApproved,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reservation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          blocServiceId == other.blocServiceId &&
          customerId == other.customerId &&
          name == other.name &&
          phone == other.phone &&
          guestsCount == other.guestsCount &&
          createdAt == other.createdAt &&
          arrivalDate == other.arrivalDate &&
          arrivalTime == other.arrivalTime &&
          isApproved == other.isApproved);

  @override
  int get hashCode =>
      id.hashCode ^
      blocServiceId.hashCode ^
      customerId.hashCode ^
      name.hashCode ^
      phone.hashCode ^
      guestsCount.hashCode ^
      createdAt.hashCode ^
      arrivalDate.hashCode ^
      arrivalTime.hashCode ^
      isApproved.hashCode;

  @override
  String toString() {
    return 'Reservation{' +
        ' id: $id,' +
        ' blocServiceId: $blocServiceId,' +
        ' customerId: $customerId,' +
        ' name: $name,' +
        ' phone: $phone,' +
        ' guestsCount: $guestsCount,' +
        ' createdAt: $createdAt,' +
        ' arrivalDate: $arrivalDate,' +
        ' arrivalTime: $arrivalTime,' +
        ' isApproved: $isApproved,' +
        '}';
  }

  Reservation copyWith({
    String? id,
    String? blocServiceId,
    String? customerId,
    String? name,
    int? phone,
    int? guestsCount,
    int? createdAt,
    int? arrivalDate,
    String? arrivalTime,
    bool? isApproved,
  }) {
    return Reservation(
      id: id ?? this.id,
      blocServiceId: blocServiceId ?? this.blocServiceId,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      guestsCount: guestsCount ?? this.guestsCount,
      createdAt: createdAt ?? this.createdAt,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'blocServiceId': this.blocServiceId,
      'customerId': this.customerId,
      'name': this.name,
      'phone': this.phone,
      'guestsCount': this.guestsCount,
      'createdAt': this.createdAt,
      'arrivalDate': this.arrivalDate,
      'arrivalTime': this.arrivalTime,
      'isApproved': this.isApproved,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'] as String,
      blocServiceId: map['blocServiceId'] as String,
      customerId: map['customerId'] as String,
      name: map['name'] as String,
      phone: map['phone'] as int,
      guestsCount: map['guestsCount'] as int,
      createdAt: map['createdAt'] as int,
      arrivalDate: map['arrivalDate'] as int,
      arrivalTime: map['arrivalTime'] as String,
      isApproved: map['isApproved'] as bool,
    );
  }

//</editor-fold>
}