import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/manager_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreHelper {
  static String CATEGORIES = 'categories';
  static String CART_ITEMS = 'cartItems';
  static String CITIES = 'cities';
  static String MANAGER_SERVICES = 'manager_services';
  static String SERVICES = 'services';
  static String USERS = 'users';


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

  /** Category **/
  static Stream<QuerySnapshot<Object?>> getCategorySnapshot(String serviceId) {
    return FirebaseFirestore.instance
        .collection(CATEGORIES)
    // .orderBy('sequence', descending: true)
        .where('serviceId', isEqualTo: serviceId)
        .snapshots();
  }

  /** Cities **/
  static Stream<QuerySnapshot<Object?>> getCitiesSnapshot() {
    return FirebaseFirestore.instance.collection(CITIES).snapshots();
  }

  /** Manager Services **/
  static Stream<QuerySnapshot<Object?>> getManagerServicesSnapshot() {
    return FirebaseFirestore.instance.collection(MANAGER_SERVICES).snapshots();
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

  /** User **/
  static Stream<QuerySnapshot<Object?>> getUserSnapshot(String customerId) {
    return FirebaseFirestore.instance.collection(USERS)
        .where('user_id', isEqualTo: customerId)
        .snapshots();  }



}