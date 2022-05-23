import 'order.dart';

class Bill {
  String custId;
  List<Order> orders;

  Bill(this.custId, this.orders);
}