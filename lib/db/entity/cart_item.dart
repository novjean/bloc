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
  final int createdAt;

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

  static CartItem fromJson(Map<String, dynamic> json) => CartItem(
    id: json['cartId'],
    serviceId: json['serviceId'],
    cartNumber: json['cartNumber'],
    userId: json['userId'],
    productId: json['productId'],
    productName: json['productName'],
    productPrice: json['productPrice'],
    quantity: json['quantity'],
    createdAt: json['createdAt']
  );

  Map<String, dynamic> toJson() => {
    'cartId': id,
    'serviceId': serviceId,
    'cartNumber': cartNumber,
    'userId': userId,
    'productId': productId,
    'productName': productName,
    'productPrice': productPrice,
    'quantity': quantity,
    'createdAt': createdAt
  };
}
