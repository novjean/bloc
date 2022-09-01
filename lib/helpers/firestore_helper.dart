import 'dart:io';

import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/offer.dart';
import 'package:bloc/db/entity/seat.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:bloc/helpers/firestorage_helper.dart';
import 'package:bloc/screens/manager/tables/seats_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../db/entity/product.dart';
import '../db/entity/service_table.dart';
import '../db/entity/sos.dart';
import '../utils/string_utils.dart';

class FirestoreHelper {
  static var logger = Logger();

  static String BLOCS = 'blocs';
  static String CHATS = 'chats';
  static String CAPTAIN_SERVICES = 'captain_services';
  static String CATEGORIES = 'categories';
  static String CART_ITEMS = 'cart_items';
  static String CITIES = 'cities';
  static String INVENTORY_OPTIONS = 'inventory_options';
  static String MANAGER_SERVICES = 'manager_services';
  static String MANAGER_SERVICE_OPTIONS = 'manager_service_options';
  static String OFFERS = 'offers';
  static String PRODUCTS = 'products';
  static String SERVICES = 'services';
  static String SEATS = 'seats';
  static String SOS = 'sos';
  static String TABLES = 'tables';
  static String USERS = 'users';

  static int TABLE_PRIVATE_TYPE_ID = 1;
  static int TABLE_COMMUNITY_TYPE_ID = 2;

  /** Blocs **/
  static getBlocs() {
    return FirebaseFirestore.instance.collection(BLOCS).snapshots();
  }

  static getBloc(String blocId) {
    return FirebaseFirestore.instance
        .collection(SERVICES)
        .where('blocId', isEqualTo: blocId)
        .snapshots();
  }

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

  static Stream<QuerySnapshot<Object?>> getCartItemsCommunity(
      String serviceId, bool isCompleted) {
    return FirebaseFirestore.instance
        .collection(CART_ITEMS)
        .where('serviceId', isEqualTo: serviceId)
        .where('isCompleted', isEqualTo: isCompleted)
        .where('isCommunity', isEqualTo: true)
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

  /** Inventory Options **/
  static Stream<QuerySnapshot<Object?>> getInventoryOptions() {
    return FirebaseFirestore.instance
        .collection(INVENTORY_OPTIONS)
        .orderBy('sequence', descending: true)
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

  /** Products **/
  static void insertProduct(
      String productId,
      String productName,
      String categoryType,
      String productCategory,
      String productDescription,
      String productPrice,
      String serviceId,
      String imageUrl,
      String userId,
      bool bool) async {
    double price = 0.0;

    try {
      price = double.parse(productPrice);
    } catch (err) {
      int intPrice = int.parse(productPrice);
      price = intPrice.toDouble();
    }

    int timeMilliSec = Timestamp.now().millisecondsSinceEpoch;

    try {
      await FirebaseFirestore.instance.collection(PRODUCTS).doc(productId).set({
        'id': productId,
        'name': productName,
        'type': categoryType,
        'category': productCategory,
        'description': productDescription,
        'price': price,
        'serviceId': serviceId,
        'imageUrl': imageUrl,
        'ownerId': userId,
        'createdAt': timeMilliSec,
        'isAvailable': false,
        'priceHighest': price,
        'priceLowest': price,
        'priceHighestTime': timeMilliSec,
        'priceLowestTime': timeMilliSec,
      });
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

  static getProducts(String serviceId) {
    return FirebaseFirestore.instance
        .collection(PRODUCTS)
        .where('serviceId', isEqualTo: serviceId)
        .orderBy('name', descending: false)
        .snapshots();
  }

  static getProductsByType(String serviceId, String type) {
    return FirebaseFirestore.instance
        .collection(PRODUCTS)
        .where('serviceId', isEqualTo: serviceId)
        .where('type', isEqualTo: type)
        .where('isAvailable', isEqualTo: true)
        // .orderBy('sequence', descending: false)
        .snapshots();
  }

  static getProductsByCategory(String serviceId, String category) {
    return FirebaseFirestore.instance
        .collection(PRODUCTS)
        .where('serviceId', isEqualTo: serviceId)
        .where('category', isEqualTo: category)
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

  /** Services **/
  static Stream<QuerySnapshot> getServicesSnapshot() {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection(SERVICES)
        // .orderBy('sequence', descending: true)
        // .where('ownerId', isEqualTo: user!.uid)
        .snapshots();
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
  static Stream<QuerySnapshot<Object?>> getTables(String serviceId) {
    return FirebaseFirestore.instance
        .collection(TABLES)
        .where('serviceId', isEqualTo: serviceId)
        .snapshots();
  }

  static Stream<QuerySnapshot<Object?>> getTablesByType(
      String serviceId, String tableType) {
    int colorType = TABLE_COMMUNITY_TYPE_ID;
    if (tableType == 'Private') {
      colorType = TABLE_PRIVATE_TYPE_ID;
    }

    return FirebaseFirestore.instance
        .collection(TABLES)
        .where('serviceId', isEqualTo: serviceId)
        .where('type', isEqualTo: colorType)
        .snapshots();
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
  static Future<void> insertUser(
      String email, String password, File? image, String username) async {
    final _auth = FirebaseAuth.instance;
    UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    final url = await FirestorageHelper.uploadFile(
        FirestorageHelper.USERS, authResult.user!.uid, image!);

    blocUser.User user = blocUser.User(
        id: authResult.user!.uid,
        name: 'Superstar',
        phoneNumber: 0,
        clearanceLevel: 1,
        email: email,
        fcmToken: '',
        imageUrl: url,
        username: username,
        blocServiceId: '');

    await FirebaseFirestore.instance
        .collection(USERS)
        .doc(authResult.user!.uid)
        .set(user.toMap());
  }

  static insertPhoneUser(blocUser.User user) async {
    await FirebaseFirestore.instance
        .collection(USERS)
        .doc(user.id)
        .set(user.toMap());
  }

  static Stream<QuerySnapshot<Object?>> getUsers(int clearanceLevel) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('clearanceLevel', isLessThan: clearanceLevel)
        // .orderBy('sequence', descending: false)
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
            FirestorageHelper.USERS, user.id, File(user.imageUrl));
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

/** Reference **/
// _buildProducts(BuildContext context, String _category) {
//   FirebaseFirestore.instance
//       .collection(FirestoreHelper.PRODUCTS)
//       .where('serviceId', isEqualTo: widget.service.id)
//       .where('category', isEqualTo: _category)
//       .get()
//       .then(
//         (res) {
//       print("Successfully completed");
//       List<Product> products = [];
//       for (int i = 0; i < res.docs.length; i++) {
//         DocumentSnapshot document = res.docs[i];
//         Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
//         final Product product = Product.fromMap(data);
//         BlocRepository.insertProduct(widget.dao, product);
//         products.add(product);
//
//         if (i == res.docs.length - 1) {
//           // _displayProductsList(context, products);
//         }
//       }
//     },
//     onError: (e) => print("Error completing: $e"),
//   );
// }

}
