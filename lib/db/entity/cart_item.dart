import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floor/floor.dart';

@entity
class CartItem {
  @primaryKey
  final String id;
  final String serviceId;
  final int cartNumber;
  final String userId;
  final String productId;
  final String productName;
  final double productPrice;
  int quantity;
  final String createdAt;

  CartItem(
      {required this.id,
        required this.serviceId,
      required this.cartNumber,
      required this.userId,
      required this.productId,
      required this.productName,
      required this.productPrice,
      required this.quantity,
      required this.createdAt});
}
