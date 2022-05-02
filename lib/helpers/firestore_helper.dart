import 'dart:io';

import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/service_table.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:bloc/helpers/firestorage_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class FirestoreHelper {
  static var logger = Logger();

  static String BLOCS = 'blocs';
  static String CATEGORIES = 'categories';
  static String CART_ITEMS = 'cartItems';
  static String CITIES = 'cities';
  static String MANAGER_SERVICES = 'manager_services';
  static String SERVICES = 'services';
  static String TABLES = 'tables';
  static String USERS = 'users';

  /** Blocs **/
  static void updateBloc(String blocId, File image) async {
    try {
      final url = await FirestorageHelper.uploadFile(
          FirestorageHelper.BLOCS, blocId, image);

      await FirebaseFirestore.instance
          .collection(BLOCS)
          .doc(blocId)
          .update({'imageUrl': url})
          .then((value) => print("Bloc image updated."))
          .catchError((error) => print("Failed to update bloc image: $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

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
    return FirebaseFirestore.instance
        .collection(CART_ITEMS)
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
        // .where('ownerId', isEqualTo: user!.uid)
        .snapshots();
  }

  /** User **/
  static Stream<QuerySnapshot<Object?>> getUserSnapshot(String customerId) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('user_id', isEqualTo: customerId)
        .snapshots();
  }

  static CollectionReference<Object?> getUsersCollection() {
    return FirebaseFirestore.instance.collection(USERS);
  }

  static void updateUser(blocUser.User user) async {
    try {
      final fileUrl = await FirestorageHelper.uploadFile(
          FirestorageHelper.USERS, user.userId, File(user.imageUrl));

      await FirebaseFirestore.instance
          .collection(USERS)
          .doc(user.userId)
          .update({
            'name': user.name,
            'image_url': fileUrl,
          })
          .then((value) => print("user image updated."))
          .catchError((error) => print("failed to update user image: $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  /** Tables **/
  static Stream<QuerySnapshot<Object?>> getTablesSnapshot(String serviceId) {
    return FirebaseFirestore.instance
        .collection(TABLES)
        .where('serviceId', isEqualTo: serviceId)
        .snapshots();
  }
}
