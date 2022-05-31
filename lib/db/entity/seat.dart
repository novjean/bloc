
import 'package:floor/floor.dart';

@entity
class Seat {
  @primaryKey
  String id;
  String custId;
  String serviceId;
  String tableId;
  int tableNumber;

  Seat({
    required this.id,
    required this.serviceId,
    required this.tableNumber,
    required this.tableId,
    required this.custId,
  });

  static Seat fromJson(Map<String, dynamic> json) => Seat(
    id: json['id'],
    serviceId: json['serviceId'],
    tableNumber: json['tableNumber'],
    tableId: json['tableId'],
    custId: json['custId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceId': serviceId,
    'tableNumber': tableNumber,
    'tableId': tableId,
    'custId': custId,
  };
}