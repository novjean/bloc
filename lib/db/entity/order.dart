import 'package:bloc/db/entity/cart_item.dart';

class Order {
  late int number;
  late final String customerId;
  late final List<CartItem> cartItems=[];
  double total = 0;
  late final int tableNumber;

  Order();
}