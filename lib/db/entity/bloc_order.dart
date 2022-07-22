import 'package:bloc/db/entity/cart_item.dart';

class BlocOrder {
  late int number;
  late final String customerId;
  late final List<CartItem> cartItems=[];
  double total = 0;
  late final int tableNumber;

  BlocOrder();
}