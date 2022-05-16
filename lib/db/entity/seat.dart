
import 'package:floor/floor.dart';

@entity
class Seat {
  @primaryKey
  String id;
  String custId;
  String serviceId;
  int tableNumber;

  Seat({
    required this.id,
    required this.serviceId,
    required this.tableNumber,
    required this.custId,
  });

  static Seat fromJson(Map<String, dynamic> json) => Seat(
    id: json['id'],
    serviceId: json['serviceId'],
    tableNumber: json['tableNumber'],
    custId: json['custId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceId': serviceId,
    'tableNumber': tableNumber,
    'custId': custId,
  };
}