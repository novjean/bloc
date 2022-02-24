import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floor/floor.dart';

class Cart {
  @primaryKey
  final String id;
  final String userId;
  final String productId;
  final String quantity;
  final Timestamp createdAt;

  Cart(this.id, this.userId, this.productId, this.quantity, this.createdAt);
}