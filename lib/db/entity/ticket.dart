class Ticket {
  final String id;
  String partyId;
  String customerId;
  final String transactionId;
  String name;
  String phone;
  String email;
  int entryCount;
  int entriesRemaining;

  final int createdAt;
  final bool isPaid;

//<editor-fold desc="Data Methods">
  Ticket({
    required this.id,
    required this.partyId,
    required this.customerId,
    required this.transactionId,
    required this.name,
    required this.phone,
    required this.email,
    required this.entryCount,
    required this.entriesRemaining,
    required this.createdAt,
    required this.isPaid,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ticket &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          partyId == other.partyId &&
          customerId == other.customerId &&
          transactionId == other.transactionId &&
          name == other.name &&
          phone == other.phone &&
          email == other.email &&
          entryCount == other.entryCount &&
          entriesRemaining == other.entriesRemaining &&
          createdAt == other.createdAt &&
          isPaid == other.isPaid);

  @override
  int get hashCode =>
      id.hashCode ^
      partyId.hashCode ^
      customerId.hashCode ^
      transactionId.hashCode ^
      name.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      entryCount.hashCode ^
      entriesRemaining.hashCode ^
      createdAt.hashCode ^
      isPaid.hashCode;

  @override
  String toString() {
    return 'Ticket{' +
        ' id: $id,' +
        ' partyId: $partyId,' +
        ' customerId: $customerId,' +
        ' transactionId: $transactionId,' +
        ' name: $name,' +
        ' phone: $phone,' +
        ' email: $email,' +
        ' entryCount: $entryCount,' +
        ' entriesRemaining: $entriesRemaining,' +
        ' createdAt: $createdAt,' +
        ' isPaid: $isPaid,' +
        '}';
  }

  Ticket copyWith({
    String? id,
    String? partyId,
    String? customerId,
    String? transactionId,
    String? name,
    String? phone,
    String? email,
    int? entryCount,
    int? entriesRemaining,
    int? createdAt,
    bool? isPaid,
  }) {
    return Ticket(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      customerId: customerId ?? this.customerId,
      transactionId: transactionId ?? this.transactionId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      entryCount: entryCount ?? this.entryCount,
      entriesRemaining: entriesRemaining ?? this.entriesRemaining,
      createdAt: createdAt ?? this.createdAt,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'partyId': this.partyId,
      'customerId': this.customerId,
      'transactionId': this.transactionId,
      'name': this.name,
      'phone': this.phone,
      'email': this.email,
      'entryCount': this.entryCount,
      'entriesRemaining': this.entriesRemaining,
      'createdAt': this.createdAt,
      'isPaid': this.isPaid,
    };
  }

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'] as String,
      partyId: map['partyId'] as String,
      customerId: map['customerId'] as String,
      transactionId: map['transactionId'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      entryCount: map['entryCount'] as int,
      entriesRemaining: map['entriesRemaining'] as int,
      createdAt: map['createdAt'] as int,
      isPaid: map['isPaid'] as bool,
    );
  }

//</editor-fold>
}