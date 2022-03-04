import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floor/floor.dart';

@entity
class CartItem {
  @primaryKey
  final String id;
  final int cartNumber;
  final String userId;
  final String productId;
  final String productName;
  final int productPrice;
  int quantity;
  final String createdAt;

  CartItem(this.id, this.cartNumber, this.userId, this.productId,
      this.productName, this.productPrice, this.quantity, this.createdAt);
}