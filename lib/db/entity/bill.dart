import 'bloc_order.dart';

class Bill {
  String billId;
  String custId;
  List<BlocOrder> orders;

  Bill({required this.billId, required this.custId, required this.orders});
}