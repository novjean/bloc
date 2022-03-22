import 'package:bloc/db/entity/cart_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  static void uploadCartItem(CartItem cart) async {
    await FirebaseFirestore.instance.collection('cartItems').doc(cart.id).set({
      'cartId': cart.id,
      'cartNumber': cart.cartNumber,
      'userId': cart.userId,
      'productId': cart.productId,
      'productName': cart.productName,
      'productPrice': cart.productPrice,
      'quantity': cart.quantity,
      'createdAt': cart.createdAt
    });
  }
}