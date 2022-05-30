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

  ServiceTable({
    required this.id,
    required this.serviceId,
    required this.tableNumber,
    required this.capacity,
    required this.isOccupied,
    required this.colorStatus,
  });

  static ServiceTable fromJson(Map<String, dynamic> json) => ServiceTable(
    id: json['id'],
    serviceId: json['serviceId'],
    tableNumber: json['tableNumber'],
    capacity: json['capacity'],
    isOccupied: json['isOccupied'],
    colorStatus: json['colorStatus'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceId': serviceId,
    'tableNumber': tableNumber,
    'capacity': capacity,
    'isOccupied': isOccupied,
    'colorStatus': colorStatus,
  };
}
