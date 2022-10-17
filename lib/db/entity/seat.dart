
import 'package:floor/floor.dart';

@entity
class Seat {
  @primaryKey
  String id;
  String custId;
  String serviceId;
  String tableId;
  int tableNumber;

//<editor-fold desc="Data Methods">

  Seat({
    required this.id,
    required this.custId,
    required this.serviceId,
    required this.tableId,
    required this.tableNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Seat &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          custId == other.custId &&
          serviceId == other.serviceId &&
          tableId == other.tableId &&
          tableNumber == other.tableNumber);

  @override
  int get hashCode =>
      id.hashCode ^
      custId.hashCode ^
      serviceId.hashCode ^
      tableId.hashCode ^
      tableNumber.hashCode;

  @override
  String toString() {
    return 'Seat{' +
        ' id: $id,' +
        ' custId: $custId,' +
        ' serviceId: $serviceId,' +
        ' tableId: $tableId,' +
        ' tableNumber: $tableNumber,' +
        '}';
  }

  Seat copyWith({
    String? id,
    String? custId,
    String? serviceId,
    String? tableId,
    int? tableNumber,
  }) {
    return Seat(
      id: id ?? this.id,
      custId: custId ?? this.custId,
      serviceId: serviceId ?? this.serviceId,
      tableId: tableId ?? this.tableId,
      tableNumber: tableNumber ?? this.tableNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'custId': this.custId,
      'serviceId': this.serviceId,
      'tableId': this.tableId,
      'tableNumber': this.tableNumber,
    };
  }

  factory Seat.fromMap(Map<String, dynamic> map) {
    return Seat(
      id: map['id'] as String,
      custId: map['custId'] as String,
      serviceId: map['serviceId'] as String,
      tableId: map['tableId'] as String,
      tableNumber: map['tableNumber'] as int,
    );
  }

//</editor-fold>
}