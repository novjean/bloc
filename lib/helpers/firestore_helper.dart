import 'dart:io';

import 'package:bloc/db/entity/bloc.dart';
import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/category.dart';
import 'package:bloc/db/entity/guest_wifi.dart';
import 'package:bloc/db/entity/offer.dart';
import 'package:bloc/db/entity/order_bloc.dart';
import 'package:bloc/db/entity/party.dart';
import 'package:bloc/db/entity/seat.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:bloc/helpers/firestorage_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../db/entity/product.dart';
import '../db/entity/service_table.dart';
import '../db/entity/sos.dart';
import '../utils/string_utils.dart';

/**
 * Tips:
 * 1. when the stream builder querying is being run more than once, create an index in firebase db
 * 2.
 * **/
class FirestoreHelper {
  static var logger = Logger();

  static String BLOCS = 'blocs';
  static String BOOKINGS = 'bookings';
  static String CHATS = 'chats';
  static String CAPTAIN_SERVICES = 'captain_services';
  static String CATEGORIES = 'categories';
  static String CART_ITEMS = 'cart_items';
  static String CITIES = 'cities';
  static String GUEST_WIFIS = 'guest_wifis';
  static String INVENTORY_OPTIONS = 'inventory_options';
  static String MANAGER_SERVICES = 'manager_services';
  static String MANAGER_SERVICE_OPTIONS = 'manager_service_options';
  static String OFFERS = 'offers';
  static String ORDERS = 'orders';
  static String PARTIES = 'parties';
  static String PRODUCTS = 'products';
  static String BLOC_SERVICES = 'services';
  static String SEATS = 'seats';
  static String SOS = 'sos';
  static String TABLES = 'tables';
  static String USERS = 'users';
  static String USER_LEVELS = 'user_levels';

  static int TABLE_PRIVATE_TYPE_ID = 1;
  static int TABLE_COMMUNITY_TYPE_ID = 2;

  /** Blocs **/
  static void pushBloc(Bloc bloc) async {
    try {
      await FirebaseFirestore.instance
          .collection(BLOCS)
          .doc(bloc.id)
          .set(bloc.toMap());
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static Future<QuerySnapshot<Object?>> pullBlocs() {
    return FirebaseFirestore.instance
        .collection(BLOCS)
        .where('isActive', isEqualTo: true)
        .get();
  }

  static getBlocs() {
    return FirebaseFirestore.instance.collection(BLOCS).snapshots();
  }

  static getBlocsByCityId(String cityId) {
    return FirebaseFirestore.instance
        .collection(BLOCS)
        .where('cityId', isEqualTo: cityId)
        .snapshots();
  }

  static void updateBloc(String id, File image) async {
    try {
      final url = await FirestorageHelper.uploadFile(
          FirestorageHelper.BLOCS_IMAGES, id, image);

      await FirebaseFirestore.instance
          .collection(BLOCS)
          .doc(id)
          .update({'imageUrl': url})
          .then((value) => print("bloc image updated."))
          .catchError((error) => print("failed to update bloc image: $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  /** Bloc Services **/
  static void pushBlocService(BlocService blocService) async {
    try {
      await FirebaseFirestore.instance
          .collection(BLOC_SERVICES)
          .doc(blocService.id)
          .set(blocService.toMap());
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static pullAllBlocServices() {
    return FirebaseFirestore.instance.collection(BLOC_SERVICES).get();
  }

  static Future<QuerySnapshot<Object?>> pullBlocService(String blocId) {
    return FirebaseFirestore.instance
        .collection(BLOC_SERVICES)
        .where('blocId', isEqualTo: blocId)
        .get();
  }

  static getBlocServices(String blocId) {
    return FirebaseFirestore.instance
        .collection(BLOC_SERVICES)
        .where('blocId', isEqualTo: blocId)
        .snapshots();
  }

  static Stream<QuerySnapshot> getAllBlocServices() {
    return FirebaseFirestore.instance.collection(BLOC_SERVICES).snapshots();
  }

  /** Bookings **/

  /** Cart Items **/
  static void pushCartItem(CartItem cartItem) async {
    try {
      await FirebaseFirestore.instance
          .collection(CART_ITEMS)
          .doc(cartItem.cartId)
          .set(cartItem.toMap());
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  // static void uploadCartItem(
  //     CartItem cart, Timestamp timestamp, int millisecondsSinceEpoch) async {
  //   await FirebaseFirestore.instance
  //       .collection(CART_ITEMS)
  //       .doc(cart.cartId)
  //       .set({
  //     'cartId': cart.cartId,
  //     'serviceId': cart.serviceId,
  //     'billId': cart.billId,
  //     'tableNumber': cart.tableNumber,
  //     'cartNumber': cart.cartNumber,
  //     'userId': cart.userId,
  //     'productId': cart.productId,
  //     'productName': cart.productName,
  //     'productPrice': cart.productPrice,
  //     'quantity': cart.quantity,
  //     'createdAt': millisecondsSinceEpoch,
  //     'timestamp': timestamp,
  //     'isCompleted': false,
  //     'isCommunity': cart.isCommunity,
  //     'isBilled': cart.isBilled,
  //   });
  // }

  static Stream<QuerySnapshot<Object?>> getCartItemsSnapshot(
      String serviceId, bool isCompleted) {
    return FirebaseFirestore.instance
        .collection(CART_ITEMS)
        .where('serviceId', isEqualTo: serviceId)
        .where('isCompleted', isEqualTo: isCompleted)
        .snapshots();
  }

  static Stream<QuerySnapshot<Object?>> getCartItemsCommunity(
      String serviceId, bool isCompleted) {
    return FirebaseFirestore.instance
        .collection(CART_ITEMS)
        .where('serviceId', isEqualTo: serviceId)
        .where('isCompleted', isEqualTo: isCompleted)
        .where('isCommunity', isEqualTo: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Object?>> getCartItemsByCompleteBilled(
      String serviceId, bool isCompleted, bool isBilled) {
    return FirebaseFirestore.instance
        .collection(CART_ITEMS)
        .where('serviceId', isEqualTo: serviceId)
        .where('isCompleted', isEqualTo: isCompleted)
        .where('isBilled', isEqualTo: isBilled)
        .orderBy('createdAt',
            descending: true) // createdAt could be used i guess
        .snapshots();
  }

  static Future<QuerySnapshot<Object?>> pullBilledCartItemsByBloc(
    String serviceId,
    bool isCompleted,
    bool isBilled,
  ) {
    return FirebaseFirestore.instance
        .collection(CART_ITEMS)
        .where('serviceId', isEqualTo: serviceId)
        .where('isCompleted', isEqualTo: isCompleted)
        .where('isBilled', isEqualTo: isBilled)
        .orderBy('createdAt',
            descending: true) // createdAt could be used i guess
        .get();
  }

  static Future<QuerySnapshot<Object?>> pullBilledCartItemsByUser(
    String userId,
    bool isCompleted,
    bool isBilled,
  ) {
    return FirebaseFirestore.instance
        .collection(CART_ITEMS)
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: isCompleted)
        .where('isBilled', isEqualTo: isBilled)
        .orderBy('createdAt',
            descending: true) // createdAt could be used i guess
        .get();
  }

  static Future<QuerySnapshot<Object?>> pullCompletedCartItemsByUser(
    String userId,
    bool isCompleted,
  ) {
    return FirebaseFirestore.instance
        .collection(CART_ITEMS)
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: isCompleted)
        .orderBy('createdAt',
            descending: true) // createdAt could be used i guess
        .get();
  }

  static Stream<QuerySnapshot<Object?>> getUserCartItems(
      String userId, bool isCompleted) {
    return FirebaseFirestore.instance
        .collection(CART_ITEMS)
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: isCompleted)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  static void updateCartItemAsCompleted(CartItem cart) async {
    try {
      await FirebaseFirestore.instance
          .collection(CART_ITEMS)
          .doc(cart.cartId)
          .update({
            'isCompleted': true,
          })
          .then((value) =>
              print("cart item " + cart.cartId + " marked as complete."))
          .catchError((error) =>
              print("Failed to update cart item completed : $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static void updateCartItemBilled(String cartId, String billId) async {
    try {
      await FirebaseFirestore.instance
          .collection(CART_ITEMS)
          .doc(cartId)
          .update({
            'billId': billId,
            'isBilled': true,
          })
          .then((value) =>
              print("cart item " + cartId + " is part of bill id : " + billId))
          .catchError((error) =>
              print("Failed to update bill id for cart item : $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static void deleteCartItem(String cartId) {
    FirebaseFirestore.instance.collection(CART_ITEMS).doc(cartId).delete();
  }

  /** Category **/
  static void pushCategory(Category category) async {
    try {
      await FirebaseFirestore.instance
          .collection(CATEGORIES)
          .doc(category.id)
          .set(category.toMap());
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static pullCategories(String blocServiceId) {
    return FirebaseFirestore.instance
        .collection(CATEGORIES)
        .where('serviceId', isEqualTo: blocServiceId)
        .orderBy('sequence', descending: false)
        .get();
  }

  static Stream<QuerySnapshot<Object?>> getCategories(String serviceId) {
    return FirebaseFirestore.instance
        .collection(CATEGORIES)
        .where('serviceId', isEqualTo: serviceId)
        .orderBy('sequence', descending: false)
        .snapshots();
  }

  /** Captain Services **/
  static Stream<QuerySnapshot<Object?>> getCaptainServices() {
    return FirebaseFirestore.instance
        .collection(CAPTAIN_SERVICES)
        .orderBy('sequence', descending: false)
        .snapshots();
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
      'userImage': userData.data()!['imageUrl']
    });
  }

  static Stream<QuerySnapshot<Object?>> getChatsSnapshot() {
    return FirebaseFirestore.instance
        .collection(CHATS)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /** Cities **/
  static Stream<QuerySnapshot<Object?>> getCitiesSnapshot() {
    return FirebaseFirestore.instance.collection(CITIES).snapshots();
  }

  /** Guest Wifi **/
  static Future<QuerySnapshot<Map<String, dynamic>>> pullGuestWifi(
      String blocServiceId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.GUEST_WIFIS)
        .where('blocServiceId', isEqualTo: blocServiceId)
        .get();
  }

  static void pushGuestWifi(GuestWifi wifi) async {
    try {
      await FirebaseFirestore.instance
          .collection(GUEST_WIFIS)
          .doc(wifi.id)
          .set(wifi.toMap());
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  /** Inventory Options **/
  static Stream<QuerySnapshot<Object?>> getInventoryOptions() {
    return FirebaseFirestore.instance
        .collection(INVENTORY_OPTIONS)
        .orderBy('sequence', descending: false)
        .snapshots();
  }

  /** Manager Services **/
  static Stream<QuerySnapshot<Object?>> getManagerServicesSnapshot() {
    return FirebaseFirestore.instance
        .collection(MANAGER_SERVICES)
        .orderBy('sequence', descending: false)
        .snapshots();
  }

  /** Manager Service Options **/
  static Stream<QuerySnapshot<Object?>> getManagerServiceOptions(
      String service) {
    return FirebaseFirestore.instance
        .collection(MANAGER_SERVICE_OPTIONS)
        .where('service', isEqualTo: service)
        .orderBy('sequence', descending: false)
        .snapshots();
  }

  /** Offers **/
  static void insertOffer(Offer offer) {
    FirebaseFirestore.instance
        .collection(OFFERS)
        .doc(offer.id)
        .set(offer.toMap());
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullOffers(
      String blocServiceId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.OFFERS)
        .where('blocServiceId', isEqualTo: blocServiceId)
        .get();
  }

  static Stream<QuerySnapshot<Object?>> getOffers(String blocServiceId) {
    return FirebaseFirestore.instance
        .collection(OFFERS)
        .where('blocServiceId', isEqualTo: blocServiceId)
        .snapshots();
  }

  static Stream<QuerySnapshot<Object?>> getActiveOffers(
      String blocServiceId, bool isActive) {
    return FirebaseFirestore.instance
        .collection(OFFERS)
        .where('blocServiceId', isEqualTo: blocServiceId)
        .where('isActive', isEqualTo: isActive)
        .snapshots();
  }

  static void deleteOffer(String docId) {
    FirebaseFirestore.instance.collection(OFFERS).doc(docId).delete();
  }

  /** Order **/
  static void pushOrder(OrderBloc order) async {
    try {
      await FirebaseFirestore.instance
          .collection(ORDERS)
          .doc(order.id)
          .set(order.toMap());
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  /** Party **/
  static void pushParty(Party party) async {
    try {
      await FirebaseFirestore.instance
          .collection(PARTIES)
          .doc(party.id)
          .set(party.toMap());
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullParties(
      int timeNow, bool isActive) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTIES)
        .where('startTime', isGreaterThan: timeNow)
        .where('isActive', isEqualTo: isActive)
        .orderBy('startTime', descending: false)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullPartiesByEndTime(
      int timeNow, bool isActive) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTIES)
        .where('startTime', isGreaterThan: timeNow)
        .where('isActive', isEqualTo: isActive)
        .orderBy('startTime', descending: false)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullUpcomingParty(
      int timeNow) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTIES)
        .where('startTime', isGreaterThan: timeNow)
        .where('isActive', isEqualTo: true)
        .orderBy('startTime', descending: false)
        .limit(1)
        .get();
  }

  static getParties(String blocServiceId) {
    return FirebaseFirestore.instance
        .collection(PARTIES)
        .where('blocServiceId', isEqualTo: blocServiceId)
        .snapshots();
  }

  /** Products **/
  static void pushProduct(Product product) async {
    try {
      await FirebaseFirestore.instance
          .collection(PRODUCTS)
          .doc(product.id)
          .set(product.toMap());
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullProduct(
      String productId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PRODUCTS)
        .where('id', isEqualTo: productId)
        .get();
  }

  static getProductsByType(String serviceId, String type) {
    return FirebaseFirestore.instance
        .collection(PRODUCTS)
        .where('serviceId', isEqualTo: serviceId)
        .where('type', isEqualTo: type)
        .orderBy('name', descending: false)
        .snapshots();
  }

  static getProductsByCategory(String serviceId, String category) {
    return FirebaseFirestore.instance
        .collection(PRODUCTS)
        .where('serviceId', isEqualTo: serviceId)
        .where('category', isEqualTo: category)
        .where('isAvailable', isEqualTo: true)
        .snapshots();
  }

  static getProductsByCategoryType(String blocServiceId, String type) {
    return FirebaseFirestore.instance
        .collection(PRODUCTS)
        .where('serviceId', isEqualTo: blocServiceId)
        .where('type', isEqualTo: type)
        .where('isAvailable', isEqualTo: true)
        // .orderBy('sequence', descending: false)
        .snapshots();
  }

  static void updateProductImage(String productId, File image) async {
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

  static void updateProduct(Product product) async {
    int timestamp = Timestamp.now().millisecondsSinceEpoch;
    if (product.priceCommunity > product.priceHighest) {
      product = product.copyWith(priceHighest: product.priceCommunity);
      product = product.copyWith(priceHighestTime: timestamp);
    } else if (product.priceCommunity < product.priceLowest) {
      product = product.copyWith(priceLowest: product.priceCommunity);
      product = product.copyWith(priceLowestTime: timestamp);
    }

    try {
      await FirebaseFirestore.instance
          .collection(PRODUCTS)
          .doc(product.id)
          .update(product.toMap())
          .then((value) => print("Product updated."))
          .catchError((error) => print("Failed to update product : $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static void setProductOfferRunning(
      String productId, bool isOfferRunning) async {
    try {
      await FirebaseFirestore.instance
          .collection(PRODUCTS)
          .doc(productId)
          .update({'isOfferRunning': isOfferRunning})
          .then((value) => print("Product id " +
              productId +
              " is set to offer " +
              isOfferRunning.toString()))
          .catchError((error) =>
              print("Failed to update product offer status: $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static void deleteProduct(String productId) {
    FirebaseFirestore.instance.collection(PRODUCTS).doc(productId).delete();
  }

  /** Seats **/
  static Future<QuerySnapshot<Map<String, dynamic>>> pullSeats(String tableId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.SEATS)
        .where('tableId', isEqualTo: tableId)
        .get();
  }

  static Stream<QuerySnapshot<Object?>> getSeatsByTableId(String tableId) {
    return FirebaseFirestore.instance
        .collection(SEATS)
        .where('tableId', isEqualTo: tableId)
        .snapshots();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullCustomerSeat(
      String blocId, String userId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.SEATS)
        .where('serviceId', isEqualTo: blocId)
        .where('custId', isEqualTo: userId)
        .get();
  }

  static void pushSeat(Seat seat) async {
    await FirebaseFirestore.instance
        .collection(SEATS)
        .doc(seat.id)
        .set(seat.toMap());
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

  static void deleteSeat(Seat seat) {
    FirebaseFirestore.instance.collection(SEATS).doc(seat.id).delete();
  }

  /** SOS **/
  static void sendSOSMessage(String? token, String name, int phoneNumber,
      int tableNumber, String tableId, String seatId) async {
    int timeMilliSec = Timestamp.now().millisecondsSinceEpoch;

    Sos sos = Sos(
        id: StringUtils.getRandomString(20),
        token: token,
        name: name,
        phoneNumber: phoneNumber,
        tableNumber: tableNumber,
        tableId: tableId,
        seatId: seatId,
        timestamp: timeMilliSec);

    FirebaseFirestore.instance.collection(SOS).doc(sos.id).set(sos.toMap());
  }

  /** Tables **/
  static Future<QuerySnapshot<Map<String, dynamic>>> pullSeatTable(
      String tableId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.TABLES)
        .where('id', isEqualTo: tableId)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullTableByNumber(
      String blocServiceId, int tableNumber) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.TABLES)
        .where('serviceId', isEqualTo: blocServiceId)
        .where('tableNumber', isEqualTo: tableNumber)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullTableById(
      String blocServiceId, String tableId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.TABLES)
        .where('serviceId', isEqualTo: blocServiceId)
        .where('id', isEqualTo: tableId)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullTablesByCaptainId(
      String blocServiceId, String captainId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.TABLES)
        .where('serviceId', isEqualTo: blocServiceId)
        .where('captainId', isEqualTo: captainId)
        .orderBy('tableNumber', descending: false)
        .get();
  }

  static Stream<QuerySnapshot<Object?>> getTables(String serviceId) {
    return FirebaseFirestore.instance
        .collection(TABLES)
        .where('serviceId', isEqualTo: serviceId)
        .snapshots();
  }

  static Stream<QuerySnapshot<Object?>> getTablesByTypeAndUser(
      String serviceId, String userId, String tableType) {
    int colorType = TABLE_COMMUNITY_TYPE_ID;
    if (tableType == 'private') {
      colorType = TABLE_PRIVATE_TYPE_ID;
    }

    return FirebaseFirestore.instance
        .collection(TABLES)
        .where('serviceId', isEqualTo: serviceId)
        .where('captainId', isEqualTo: userId)
        .where('type', isEqualTo: colorType)
        .snapshots();
  }

  static Stream<QuerySnapshot<Object?>> getTablesByType(
      String serviceId, String tableType) {
    int colorType = TABLE_COMMUNITY_TYPE_ID;
    if (tableType == 'private') {
      colorType = TABLE_PRIVATE_TYPE_ID;
    }

    return FirebaseFirestore.instance
        .collection(TABLES)
        .where('serviceId', isEqualTo: serviceId)
        .where('type', isEqualTo: colorType)
        .orderBy('tableNumber', descending: false)
        .snapshots();
  }

  static void pushTable(ServiceTable table) async {
    try {
      await FirebaseFirestore.instance
          .collection(TABLES)
          .doc(table.id)
          .set(table.toMap());
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static void setTableOccupyStatus(String tableId, bool isOccupied) async {
    try {
      await FirebaseFirestore.instance
          .collection(TABLES)
          .doc(tableId)
          .update({'isOccupied': isOccupied})
          .then((value) => print("Table is occupied : " + tableId))
          .catchError((error) => print("Failed to set isOccupy table: $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static void setTableType(ServiceTable table, int newType) async {
    try {
      await FirebaseFirestore.instance
          .collection(TABLES)
          .doc(table.id)
          .update({'type': newType})
          .then((value) => print("table " +
              table.tableNumber.toString() +
              " type changed to type id " +
              newType.toString()))
          .catchError((error) => print("Failed to change table color: $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static void setTableCaptain(String tableId, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection(TABLES)
          .doc(tableId)
          .update({'captainId': userId})
          .then((value) =>
              print("table id " + tableId + " has captain id " + userId))
          .catchError(
              (error) => print("Failed to set captain to table : $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static void setTableActiveStatus(String tableId, bool isActive) async {
    try {
      await FirebaseFirestore.instance
          .collection(TABLES)
          .doc(tableId)
          .update({'isActive': isActive})
          .then((value) => print("table id " +
              tableId +
              " has active status of " +
              isActive.toString()))
          .catchError(
              (error) => print("Failed to set isActive to table : $error"));
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
            'type': table.type == FirestoreHelper.TABLE_COMMUNITY_TYPE_ID
                ? FirestoreHelper.TABLE_PRIVATE_TYPE_ID
                : FirestoreHelper.TABLE_COMMUNITY_TYPE_ID
          })
          .then((value) => print("Table color status changed for: " + table.id))
          .catchError((error) => print("Failed to change table color: $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  /** User **/
  static void pushUser(blocUser.User user) async {
    try {
      await FirebaseFirestore.instance
          .collection(USERS)
          .doc(user.id)
          .set(user.toMap());
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  // static Future<void> insertUser(
  //     String email, String password, File? image, String username) async {
  //   final _auth = FirebaseAuth.instance;
  //   UserCredential authResult = await _auth.createUserWithEmailAndPassword(
  //       email: email, password: password);
  //
  //   final url = await FirestorageHelper.uploadFile(
  //       FirestorageHelper.USERS, authResult.user!.uid, image!);
  //
  //   blocUser.User user = blocUser.User(
  //       id: authResult.user!.uid,
  //       name: '',
  //       phoneNumber: 0,
  //       clearanceLevel: 1,
  //       email: email,
  //       fcmToken: '',
  //       imageUrl: url,
  //       username: username,
  //       blocServiceId: '');
  //
  //   await FirebaseFirestore.instance
  //       .collection(USERS)
  //       .doc(authResult.user!.uid)
  //       .set(user.toMap());
  // }

  static insertPhoneUser(blocUser.User user) async {
    await FirebaseFirestore.instance
        .collection(USERS)
        .doc(user.id)
        .set(user.toMap());
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullUser(String userId) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('id', isEqualTo: userId)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullUsersByLevel(
      int level) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('clearanceLevel', isEqualTo: level)
        .get();
  }

  static Stream<QuerySnapshot<Object?>> getUsers(int clearanceLevel) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('clearanceLevel', isLessThan: clearanceLevel)
        // .orderBy('sequence', descending: false)
        .snapshots();
  }

  static getUsersByLevel(int level) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('clearanceLevel', isEqualTo: level)
        // .orderBy('name', descending : false)
        .snapshots();
  }

  static Stream<QuerySnapshot<Object?>> getUsersInRange(
      int lowLevel, int highLevel) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('clearanceLevel', whereIn: [lowLevel, highLevel])
        // .orderBy('sequence', descending: false)
        .snapshots();
  }

  static CollectionReference<Object?> getUsersCollection() {
    return FirebaseFirestore.instance.collection(USERS);
  }

  static void updateUser(blocUser.User user, bool isPhotoChanged) async {
    if (isPhotoChanged) {
      var fileUrl = user.imageUrl;
      try {
        fileUrl = await FirestorageHelper.uploadFile(
            FirestorageHelper.USERS,
            user.name.trim() + '_' + StringUtils.getRandomString(15),
            File(user.imageUrl));
        user = user.copyWith(imageUrl: fileUrl);
      } catch (err) {
        logger.e(err);
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection(USERS)
          .doc(user.id)
          .update(user.toMap())
          .then((value) => print("user has been updated in firebase."))
          .catchError((error) =>
              print("failed updating user in firebase. error: " + error));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static void updateUserFcmToken(String userId, String? token) async {
    try {
      await FirebaseFirestore.instance
          .collection(USERS)
          .doc(userId)
          .update({
            'fcmToken': token,
          })
          .then((value) =>
              print(userId + " user fcm token updated to : " + token!))
          .catchError(
              (error) => print("failed to update user fcm token: $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static void updateUserBlocId(String userId, String blocServiceId) async {
    try {
      await FirebaseFirestore.instance
          .collection(USERS)
          .doc(userId)
          .update({
            'blocServiceId': blocServiceId,
          })
          .then((value) => print(
              userId + " user bloc service id updated to : " + blocServiceId))
          .catchError((error) =>
              print("failed to update user bloc service id : $error"));
    } on PlatformException catch (err) {
      logger.e(err.message);
    } catch (err) {
      logger.e(err);
    }
  }

  static void deleteUser(blocUser.User user) {
    FirebaseFirestore.instance.collection(USERS).doc(user.id).delete();
  }

  /** User Level **/
  static pullUserLevels(int clearanceLevel) {
    return FirebaseFirestore.instance
        .collection(USER_LEVELS)
        .where('level', isLessThan: clearanceLevel)
        .orderBy('level', descending: false)
        .get();
  }
}
