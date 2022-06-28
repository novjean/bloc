class Sos {
  String id;
  String? token;
  String name;
  int phoneNumber;
  int tableNumber;
  String tableId;
  String seatId;
  int timestamp;

//<editor-fold desc="Data Methods">

  Sos({
    required this.id,
    this.token,
    required this.name,
    required this.phoneNumber,
    required this.tableNumber,
    required this.tableId,
    required this.seatId,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sos &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          token == other.token &&
          name == other.name &&
          phoneNumber == other.phoneNumber &&
          tableNumber == other.tableNumber &&
          tableId == other.tableId &&
          seatId == other.seatId &&
          timestamp == other.timestamp);

  @override
  int get hashCode =>
      id.hashCode ^
      token.hashCode ^
      name.hashCode ^
      phoneNumber.hashCode ^
      tableNumber.hashCode ^
      tableId.hashCode ^
      seatId.hashCode ^
      timestamp.hashCode;

  @override
  String toString() {
    return 'Sos{' +
        ' id: $id,' +
        ' token: $token,' +
        ' name: $name,' +
        ' phoneNumber: $phoneNumber,' +
        ' tableNumber: $tableNumber,' +
        ' tableId: $tableId,' +
        ' seatId: $seatId,' +
        ' timestamp: $timestamp,' +
        '}';
  }

  Sos copyWith({
    String? id,
    String? token,
    String? name,
    int? phoneNumber,
    int? tableNumber,
    String? tableId,
    String? seatId,
    int? timestamp,
  }) {
    return Sos(
      id: id ?? this.id,
      token: token ?? this.token,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      tableNumber: tableNumber ?? this.tableNumber,
      tableId: tableId ?? this.tableId,
      seatId: seatId ?? this.seatId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'token': this.token,
      'name': this.name,
      'phoneNumber': this.phoneNumber,
      'tableNumber': this.tableNumber,
      'tableId': this.tableId,
      'seatId': this.seatId,
      'timestamp': this.timestamp,
    };
  }

  factory Sos.fromMap(Map<String, dynamic> map) {
    return Sos(
      id: map['id'] as String,
      token: map['token'] as String,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as int,
      tableNumber: map['tableNumber'] as int,
      tableId: map['tableId'] as String,
      seatId: map['seatId'] as String,
      timestamp: map['timestamp'] as int,
    );
  }

//</editor-fold>
}