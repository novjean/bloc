import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floor/floor.dart';

@entity
class CartItem {
  @primaryKey
  final String id;
  final int cartNumber;
  final String userId;
  final String productId;
  int quantity;
  final String createdAt;

  CartItem(this.id, this.cartNumber, this.userId, this.productId, this.quantity, this.createdAt);
}