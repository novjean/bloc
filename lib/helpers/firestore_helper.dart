import 'dart:io';

import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/seat.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:bloc/helpers/firestorage_helper.dart';
import 'package:bloc/screens/manager/seats_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../db/entity/service_table.dart';

class FirestoreHelper {
  static var logger = Logger();

  static String BLOCS = 'blocs';
  static String CHATS = 'chats';
  static String CATEGORIES = 'categories';
  static String CART_ITEMS = 'cart_items';
  static String CITIES = 'cities';
  static String INVENTORY_OPTIONS = 'inventory_options';
  static String MANAGER_SERVICES = 'manager_services';
  static String PRODUCTS = 'products';
  static String SERVICES = 'services';
  static String SEATS = 'seats';
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
  static void uploadCartItem(
      CartItem cart, Timestamp timestamp, int millisecondsSinceEpoch) async {
    await FirebaseFirestore.instance.collection(CART_ITEMS).doc(cart.id).set({
      'cartId': cart.id,
      'serviceId': cart.serviceId,
      'tableNumber': cart.tableNumber,
      'cartNumber': cart.cartNumber,
      'userId': cart.userId,
      'productId': cart.productId,
      'productName': cart.productName,
      'productPrice': cart.productPrice,
      'quantity': cart.quantity,
      'createdAt': millisecondsSinceEpoch,
      'timestamp': timestamp,
      'isCompleted': false,
    });
  }

  static Stream<QuerySnapshot<Object?>> getCartItemsSnapshot(
      String serviceId, bool isCompleted) {
    return FirebaseFirestore.instance
        .collection(CART_ITEMS)
        .where('serviceId', isEqualTo: serviceId)
        .where('isCompleted', isEqualTo: isCompleted)
        // .orderBy('timestamp', descending: true) // createdAt could be used i guess
        .snapshots();
  }

  static void updateCartItemAsCompleted(CartItem cart) async {
    await FirebaseFirestore.instance.collection(CART_ITEMS).doc(cart.id).set({
      'cartId': cart.id,
      'serviceId': cart.serviceId,
      'tableNumber': cart.tableNumber,
      'cartNumber': cart.cartNumber,
      'userId': cart.userId,
      'productId': cart.productId,
      'productName': cart.productName,
      'productPrice': cart.productPrice,
      'quantity': cart.quantity,
      'createdAt': cart.createdAt,
      'timestamp': Timestamp.fromMillisecondsSinceEpoch(cart.createdAt),
      'isCompleted': true,
    });
  }

  /** Category **/
  static Stream<QuerySnapshot<Object?>> getCategories(String serviceId) {
    return FirebaseFirestore.instance
        .collection(CATEGORIES)
        .where('serviceId', isEqualTo: serviceId)
        .orderBy('sequence', descending: false)
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

  /** Chats **/
  static void sendChatMessage(String enteredMessage) async {
    final user = FirebaseAuth.instance.currentUser;

    final userData =
        await FirebaseFirestore.instance.collection(USERS).doc(user!.uid).get();
    FirebaseFirestore.instance.collection(CHATS).add({
      'text': enteredMessage,
      // timestamp available through cloud firestore
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url']
    });
  }

  static Stream<QuerySnapshot<Object?>> getChatsSnapshot() {
    return FirebaseFirestore.instance
        .collection(CHATS)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /** Products **/
  static void updateProduct(String productId, File image) async {
    try {
      final url = await FirestorageHelper.uploadFile(
          FirestorageHelper.PRODUCT_IMAGES, productId, image);

      await FirebaseFirestore.instance
          .collection(PRODUCTS)
          .doc(productId)
          .update({'imageUrl': url})
          .then((value) => print("Product image updated."))
          .catchError(
              (error) => print("Failed to update product image: $error"));
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

  static void pushServiceTableIsOccupied(
      String serviceTableId, bool isOccupied) async {
    try {
      await FirebaseFirestore.instance
          .collection(TABLES)
          .doc(serviceTableId)
          .update({'isOccupied': isOccupied})
          .then((value) => print("Table is occupied : " + serviceTableId))
          .catchError((error) => print("Failed to set isOccupy table: $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static void changeTableColor(ServiceTable table) async {
    try {
      await FirebaseFirestore.instance
          .collection(TABLES)
          .doc(table.id)
          .update({
            'colorStatus':
                table.colorStatus == SeatsManagementScreen.TABLE_GREEN
                    ? SeatsManagementScreen.TABLE_RED
                    : SeatsManagementScreen.TABLE_GREEN
          })
          .then((value) => print("Table color status changed for: " + table.id))
          .catchError((error) => print("Failed to change table color: $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  /** Seats **/
  static Stream<QuerySnapshot<Object?>> getSeatsByTableId(String tableId) {
    return FirebaseFirestore.instance
        .collection(SEATS)
        .where('tableId', isEqualTo: tableId)
        .snapshots();
  }

  static void uploadSeat(Seat seat) async {
    await FirebaseFirestore.instance
        .collection(SEATS)
        .doc(seat.id)
        .set(seat.toJson());
  }

  static void updateSeat(String seatId, String custId) async {
    try {
      await FirebaseFirestore.instance
          .collection(SEATS)
          .doc(seatId)
          .update({'custId': custId}).then((value) {
        if (custId.isEmpty) {
          logger.d("seat is now free : " + seatId);
        } else {
          print("seat is occupied by cust id: " + custId);
        }
      }).catchError(
              (error) => print("Failed to update seat with cust: $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static Stream<QuerySnapshot<Object?>> getSeats(
      String serviceId, int tableNumber) {
    return FirebaseFirestore.instance
        .collection(SEATS)
        .where('serviceId', isEqualTo: serviceId)
        .where('tableNumber', isEqualTo: tableNumber)
        .snapshots();
  }

  static Stream<QuerySnapshot<Object?>> findTableNumber(
      String serviceId, String custId) {
    return FirebaseFirestore.instance
        .collection(SEATS)
        .where('serviceId', isEqualTo: serviceId)
        .where('custId', isEqualTo: custId)
        .snapshots();
  }

  /** Inventory Options **/
  static Stream<QuerySnapshot<Object?>> getInventoryOptions() {
    return FirebaseFirestore.instance
        .collection(INVENTORY_OPTIONS)
        .orderBy('sequence', descending: true)
        .snapshots();
  }
}
