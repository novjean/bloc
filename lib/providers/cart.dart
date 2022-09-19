import 'package:flutter/material.dart';

import '../db/entity/cart_item.dart';

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  // this is used for retrieving the list of items in the cart
  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.productPrice * cartItem.quantity;
    });
    return total;
  }

  void addItem(
      String cartId,
      String serviceId,
      String billId,
      int tableNumber,
      int cartNumber,
      String userId,
      String productId,
      String productName,
      double productPrice,
      bool isCommunity,
      int quantity,
      int timestamp,
      bool isCompleted) {
    String key = getCartKey(productId, productPrice);
    if (_items.containsKey(key)) {
      // change the quantity
      _items.update(
          key,
          (existingCartItem) => CartItem(
              cartId: existingCartItem.cartId,
              serviceId: existingCartItem.serviceId,
              billId: existingCartItem.billId,
              tableNumber: existingCartItem.tableNumber,
              cartNumber: existingCartItem.cartNumber,
              userId: existingCartItem.userId,
              productId: existingCartItem.productId,
              productName: existingCartItem.productName,
              productPrice: existingCartItem.productPrice,
              isCommunity: existingCartItem.isCommunity,
              quantity: existingCartItem.quantity + quantity,
              createdAt: existingCartItem.createdAt,
              isCompleted: existingCartItem.isCompleted,));
    } else {
      _items.putIfAbsent(
          key,
          () => CartItem(
              cartId: cartId,
              serviceId: serviceId,
              billId: billId,
              tableNumber: tableNumber,
              cartNumber: cartNumber,
              userId: userId,
              productId: productId,
              productName: productName,
              productPrice: productPrice,
              isCommunity: isCommunity,
              quantity: quantity,
              createdAt: timestamp,
              isCompleted: isCompleted));
    }
    notifyListeners();
  }

  void removeItem(String key) {
    _items.remove(key);
    notifyListeners();
  }

  // void removeSingleItem(String productId) {
  //   if (!_items.containsKey(productId)) {
  //     return;
  //   }
  //   if (_items[productId]!.quantity > 1) {
  //     _items.update(
  //         productId,
  //         (existingCartItem) => CartItem(
  //             id: existingCartItem.id,
  //             serviceId: existingCartItem.serviceId,
  //             tableNumber: existingCartItem.tableNumber,
  //             cartNumber: existingCartItem.cartNumber,
  //             userId: existingCartItem.userId,
  //             productId: existingCartItem.productId,
  //             productName: existingCartItem.productName,
  //             productPrice: existingCartItem.productPrice,
  //             quantity: existingCartItem.quantity - 1,
  //             createdAt: existingCartItem.createdAt,
  //             isCompleted: existingCartItem.isCompleted));
  //   } else {
  //     _items.remove(productId);
  //   }
  //   notifyListeners();
  // }

  void clear() {
    _items = {};
    notifyListeners();
  }

  static String getCartKey(String productId, double productPrice) {
    return productId + productPrice.toStringAsFixed(0);
  }
}
