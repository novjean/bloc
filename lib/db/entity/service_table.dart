import 'package:floor/floor.dart';

@entity
class ServiceTable {
  @primaryKey
  String id;
  String serviceId;
  int tableNumber;
  int capacity;
  bool isOccupied;
  int colorStatus;

//<editor-fold desc="Data Methods">

  ServiceTable({
    required this.id,
    required this.serviceId,
    required this.tableNumber,
    required this.capacity,
    required this.isOccupied,
    required this.colorStatus,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceTable &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serviceId == other.serviceId &&
          tableNumber == other.tableNumber &&
          capacity == other.capacity &&
          isOccupied == other.isOccupied &&
          colorStatus == other.colorStatus);

  @override
  int get hashCode =>
      id.hashCode ^
      serviceId.hashCode ^
      tableNumber.hashCode ^
      capacity.hashCode ^
      isOccupied.hashCode ^
      colorStatus.hashCode;

  @override
  String toString() {
    return 'ServiceTable{' +
        ' id: $id,' +
        ' serviceId: $serviceId,' +
        ' tableNumber: $tableNumber,' +
        ' capacity: $capacity,' +
        ' isOccupied: $isOccupied,' +
        ' colorStatus: $colorStatus,' +
        '}';
  }

  ServiceTable copyWith({
    String? id,
    String? serviceId,
    int? tableNumber,
    int? capacity,
    bool? isOccupied,
    int? colorStatus,
  }) {
    return ServiceTable(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      isOccupied: isOccupied ?? this.isOccupied,
      colorStatus: colorStatus ?? this.colorStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'serviceId': this.serviceId,
      'tableNumber': this.tableNumber,
      'capacity': this.capacity,
      'isOccupied': this.isOccupied,
      'colorStatus': this.colorStatus,
    };
  }

  factory ServiceTable.fromMap(Map<String, dynamic> map) {
    return ServiceTable(
      id: map['id'] as String,
      serviceId: map['serviceId'] as String,
      tableNumber: map['tableNumber'] as int,
      capacity: map['capacity'] as int,
      isOccupied: map['isOccupied'] as bool,
      colorStatus: map['colorStatus'] as int,
    );
  }

//</editor-fold>
}
