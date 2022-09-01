import 'package:floor/floor.dart';

@entity
class ServiceTable {
  @primaryKey
  String id;
  String serviceId;
  String captainId;
  int tableNumber;
  int capacity;
  bool isOccupied;
  int type;

//<editor-fold desc="Data Methods">

  ServiceTable({
    required this.id,
    required this.serviceId,
    required this.captainId,
    required this.tableNumber,
    required this.capacity,
    required this.isOccupied,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceTable &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serviceId == other.serviceId &&
          captainId == other.captainId &&
          tableNumber == other.tableNumber &&
          capacity == other.capacity &&
          isOccupied == other.isOccupied &&
          type == other.type);

  @override
  int get hashCode =>
      id.hashCode ^
      serviceId.hashCode ^
      captainId.hashCode ^
      tableNumber.hashCode ^
      capacity.hashCode ^
      isOccupied.hashCode ^
      type.hashCode;

  @override
  String toString() {
    return 'ServiceTable{' +
        ' id: $id,' +
        ' serviceId: $serviceId,' +
        ' captainId: $captainId,' +
        ' tableNumber: $tableNumber,' +
        ' capacity: $capacity,' +
        ' isOccupied: $isOccupied,' +
        ' type: $type,' +
        '}';
  }

  ServiceTable copyWith({
    String? id,
    String? serviceId,
    String? captainId,
    int? tableNumber,
    int? capacity,
    bool? isOccupied,
    int? type,
  }) {
    return ServiceTable(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      captainId: captainId ?? this.captainId,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      isOccupied: isOccupied ?? this.isOccupied,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'serviceId': this.serviceId,
      'captainId': this.captainId,
      'tableNumber': this.tableNumber,
      'capacity': this.capacity,
      'isOccupied': this.isOccupied,
      'type': this.type,
    };
  }

  factory ServiceTable.fromMap(Map<String, dynamic> map) {
    return ServiceTable(
      id: map['id'] as String,
      serviceId: map['serviceId'] as String,
      captainId: map['captainId'] as String,
      tableNumber: map['tableNumber'] as int,
      capacity: map['capacity'] as int,
      isOccupied: map['isOccupied'] as bool,
      type: map['type'] as int,
    );
  }

//</editor-fold>
}
