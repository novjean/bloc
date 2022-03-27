import 'package:bloc/db/entity/cart_item.dart';

class Order {
  final String customerId;
  late final List<CartItem> cartItems=[];

  Order(this.customerId);
}