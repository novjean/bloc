import 'bloc_order.dart';

class Bill {
  String custId;
  List<BlocOrder> orders;

  Bill(this.custId, this.orders);
}