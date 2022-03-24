import 'package:bloc/db/entity/cart_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreHelper {
  static String CART_ITEMS = 'cartItems';
  static String CITIES = 'cities';
  static String SERVICES = 'services';

  /** Cart Items **/
  static void uploadCartItem(CartItem cart) async {
    await FirebaseFirestore.instance.collection(CART_ITEMS).doc(cart.id).set({
      'cartId': cart.id,
      'serviceId': cart.serviceId,
      'cartNumber': cart.cartNumber,
      'userId': cart.userId,
      'productId': cart.productId,
      'productName': cart.productName,
      'productPrice': cart.productPrice,
      'quantity': cart.quantity,
      'createdAt': cart.createdAt
    });
  }

  static Stream<QuerySnapshot<Object?>> getCartItemsSnapshot(String serviceId) {
    return FirebaseFirestore.instance.collection(CART_ITEMS)
        .where('serviceId', isEqualTo: serviceId)
        .snapshots();
  }

  /** Cities **/
  static Stream<QuerySnapshot<Object?>> getCitiesSnapshot() {
    return FirebaseFirestore.instance.collection(CITIES).snapshots();
  }

  /** Services **/
  static Stream<QuerySnapshot> getServicesSnapshot() {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection(SERVICES)
    // .orderBy('sequence', descending: true)
        .where('ownerId', isEqualTo: user!.uid)
        .snapshots();
  }
}