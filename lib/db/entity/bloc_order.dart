import 'package:bloc/db/entity/cart_item.dart';

class BlocOrder {
  late int sequence;
  late final String customerId;
  late final List<CartItem> cartItems=[];
  double total = 0;
  late final int tableNumber;
  final int createdAt;

  BlocOrder({required this.createdAt});
}