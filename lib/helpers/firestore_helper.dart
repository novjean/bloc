import 'dart:io';

import 'package:bloc/db/entity/bloc.dart';
import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/category.dart';
import 'package:bloc/db/entity/challenge.dart';
import 'package:bloc/db/entity/genre.dart';
import 'package:bloc/db/entity/guest_wifi.dart';
import 'package:bloc/db/entity/history_music.dart';
import 'package:bloc/db/entity/offer.dart';
import 'package:bloc/db/entity/order_bloc.dart';
import 'package:bloc/db/entity/party.dart';
import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/db/entity/reservation.dart';
import 'package:bloc/db/entity/seat.dart';
import 'package:bloc/db/entity/ticket.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:bloc/helpers/firestorage_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../db/entity/ad.dart';
import '../db/entity/product.dart';
import '../db/entity/service_table.dart';
import '../db/entity/sos.dart';
import '../utils/logx.dart';
import '../utils/string_utils.dart';

/**
 * Tips:
 * 1. when the stream builder querying is being run more than once, create an index in firebase db
 * **/
class FirestoreHelper {
  static const String _TAG = 'FirestoreHelper';
  static var logger = Logger();

  static String ADS = 'ads';
  static String BLOCS = 'blocs';
  static String CHATS = 'chats';
  static String CAPTAIN_SERVICES = 'captain_services';
  static String CATEGORIES = 'categories';
  static String CART_ITEMS = 'cart_items';
  static String CHALLENGES = 'challenges';
  static String CITIES = 'cities';
  static String GENRES = 'genres';
  static String GUEST_WIFIS = 'guest_wifis';
  static String HISTORY_MUSIC = 'history_music';
  static String INVENTORY_OPTIONS = 'inventory_options';
  static String MANAGER_SERVICES = 'manager_services';
  static String MANAGER_SERVICE_OPTIONS = 'manager_service_options';
  static String OFFERS = 'offers';
  static String ORDERS = 'orders';
  static String PARTIES = 'parties';
  static String PARTY_GUESTS = 'party_guests';
  static String PRODUCTS = 'products';
  static String BLOC_SERVICES = 'services';
  static String RESERVATIONS = 'reservations';
  static String SEATS = 'seats';
  static String SOS = 'sos';
  static String TABLES = 'tables';
  static String TICKETS = 'tickets';
  static String USERS = 'users';
  static String USER_LEVELS = 'user_levels';

  static int TABLE_PRIVATE_TYPE_ID = 1;
  static int TABLE_COMMUNITY_TYPE_ID = 2;

  /** Ads **/
  static void pushAd(Ad ad) async {
    try {
      await FirebaseFirestore.instance
          .collection(ADS)
          .doc(ad.id)
          .set(ad.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static getAds(String blocId) {
    return FirebaseFirestore.instance
        .collection(ADS)
        .where('blocId', isEqualTo: blocId)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  static void deleteAd(String docId) {
    FirebaseFirestore.instance.collection(ADS).doc(docId).delete();
  }

  /** Blocs **/
  static void pushBloc(Bloc bloc) async {
    try {
      await FirebaseFirestore.instance
          .collection(BLOCS)
          .doc(bloc.id)
          .set(bloc.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static Future<QuerySnapshot<Object?>> pullBlocs() {
    return FirebaseFirestore.instance
        .collection(BLOCS)
        .where('isActive', isEqualTo: true)
        .get();
  }

  static pullBlocsPromoter() {
    return FirebaseFirestore.instance.collection(BLOCS).get();
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
          .update({'imageUrl': url}).then((value) {
        Logx.i(_TAG, 'bloc image updated');
      }).catchError((e, s) {
        Logx.e(_TAG, e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  /** bloc services **/
  static void pushBlocService(BlocService blocService) async {
    try {
      await FirebaseFirestore.instance
          .collection(BLOC_SERVICES)
          .doc(blocService.id)
          .set(blocService.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
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

  /** cart items **/
  static void pushCartItem(CartItem cartItem) async {
    try {
      await FirebaseFirestore.instance
          .collection(CART_ITEMS)
          .doc(cartItem.cartId)
          .set(cartItem.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

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
        .orderBy('createdAt', descending: true)
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
        .orderBy('createdAt', descending: true)
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
        .orderBy('createdAt', descending: true)
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
      }).then((value) {
        Logx.i(_TAG, "cart item " + cart.cartId + " marked as complete.");
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to update cart item completed', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
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
      }).then((value) {
        Logx.i(_TAG, "cart item " + cartId + " is part of bill id : " + billId);
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to update bill id for cart item', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static void deleteCartItem(String cartId) {
    FirebaseFirestore.instance.collection(CART_ITEMS).doc(cartId).delete();
  }

  /** category **/
  static void pushCategory(Category category) async {
    try {
      await FirebaseFirestore.instance
          .collection(CATEGORIES)
          .doc(category.id)
          .set(category.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static pullCategories(String blocServiceId) {
    return FirebaseFirestore.instance
        .collection(CATEGORIES)
        .where('serviceId', isEqualTo: blocServiceId)
        .orderBy('sequence', descending: false)
        .get();
  }

  static pullCategoriesNew(String blocServiceId) {
    return FirebaseFirestore.instance
        .collection(CATEGORIES)
        .where('blocIds', arrayContains: blocServiceId)
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

  /** captain services **/
  static Stream<QuerySnapshot<Object?>> getCaptainServices() {
    return FirebaseFirestore.instance
        .collection(CAPTAIN_SERVICES)
        .orderBy('sequence', descending: false)
        .snapshots();
  }

  /** challenges **/
  static void pushChallenge(Challenge challenge) async {
    try {
      await FirebaseFirestore.instance
          .collection(CHALLENGES)
          .doc(challenge.id)
          .set(challenge.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullChallenges() {
    return FirebaseFirestore.instance
        .collection(CHALLENGES)
        .orderBy('level', descending: false)
        .get();
  }

  static Stream<QuerySnapshot<Object?>> getChallenges() {
    return FirebaseFirestore.instance
        .collection(CHALLENGES)
        .orderBy('level', descending: false)
        .snapshots();
  }

  static void deleteChallenge(String docId) {
    FirebaseFirestore.instance.collection(CHALLENGES).doc(docId).delete();
  }

  /** chats **/
  static void sendChatMessage(String enteredMessage) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      final userData = await FirebaseFirestore.instance
          .collection(USERS)
          .doc(user!.uid)
          .get();
      FirebaseFirestore.instance.collection(CHATS).add({
        'text': enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': userData.data()!['username'],
        'userImage': userData.data()!['imageUrl']
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static Stream<QuerySnapshot<Object?>> getChatsSnapshot() {
    return FirebaseFirestore.instance
        .collection(CHATS)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /** cities **/
  static Stream<QuerySnapshot<Object?>> getCitiesSnapshot() {
    return FirebaseFirestore.instance.collection(CITIES).snapshots();
  }

  /** genre **/
  static void pushGenre(Genre genre) async {
    try {
      await FirebaseFirestore.instance
          .collection(GENRES)
          .doc(genre.id)
          .set(genre.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullGenres() {
    return FirebaseFirestore.instance
        .collection(GENRES)
        .get();
  }

  static getGenres() {
    return FirebaseFirestore.instance
        .collection(GENRES)
        .orderBy('name', descending: false)
        .snapshots();
  }

  static void deleteGenre(String docId) {
    FirebaseFirestore.instance.collection(GENRES).doc(docId).delete();
  }

  /** guest wifi **/
  static Future<QuerySnapshot<Map<String, dynamic>>> pullGuestWifi(
      String blocServiceId) {
    return FirebaseFirestore.instance
        .collection(GUEST_WIFIS)
        .where('blocServiceId', isEqualTo: blocServiceId)
        .get();
  }

  static void pushGuestWifi(GuestWifi wifi) async {
    try {
      await FirebaseFirestore.instance
          .collection(GUEST_WIFIS)
          .doc(wifi.id)
          .set(wifi.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  /** history music **/
  static void pushHistoryMusic(HistoryMusic historyMusic) async {
    try {
      await FirebaseFirestore.instance
          .collection(HISTORY_MUSIC)
          .doc(historyMusic.id)
          .set(historyMusic.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullHistoryMusic(String userId, String genre) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.HISTORY_MUSIC)
        .where('userId', isEqualTo: userId)
        .where('genre', isEqualTo: genre)
        .limit(1)
        .get();
  }


  /** inventory options **/
  static Stream<QuerySnapshot<Object?>> getInventoryOptions() {
    return FirebaseFirestore.instance
        .collection(INVENTORY_OPTIONS)
        .orderBy('sequence', descending: false)
        .snapshots();
  }

  /** manager services **/
  static Stream<QuerySnapshot<Object?>> getManagerServicesSnapshot() {
    return FirebaseFirestore.instance
        .collection(MANAGER_SERVICES)
        .orderBy('sequence', descending: false)
        .snapshots();
  }

  /** manager service options **/
  static Stream<QuerySnapshot<Object?>> getManagerServiceOptions(
      String service) {
    return FirebaseFirestore.instance
        .collection(MANAGER_SERVICE_OPTIONS)
        .where('service', isEqualTo: service)
        .orderBy('sequence', descending: false)
        .snapshots();
  }

  /** offers **/
  static void pushOffer(Offer offer) async {
    try {
      await FirebaseFirestore.instance
          .collection(OFFERS)
          .doc(offer.id)
          .set(offer.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
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

  /** order **/
  static void pushOrder(OrderBloc order) async {
    try {
      await FirebaseFirestore.instance
          .collection(ORDERS)
          .doc(order.id)
          .set(order.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  /** party **/
  static void pushParty(Party party) async {
    try {
      await FirebaseFirestore.instance
          .collection(PARTIES)
          .doc(party.id)
          .set(party.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullParty(String partyId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTIES)
        .where('id', isEqualTo: partyId)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullPartiesByEndTime(
      int timeNow, bool isActive) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTIES)
        .where('endTime', isGreaterThan: timeNow)
        .where('isActive', isEqualTo: isActive)
        .orderBy('endTime', descending: false)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullPastParties(
      int timeNow, bool isTBA) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTIES)
        .where('endTime', isLessThanOrEqualTo: timeNow)
        .where('isTBA', isEqualTo: isTBA)
        .where('isBigAct', isEqualTo: true)
        .orderBy('endTime', descending: true)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullActiveGuestListParties(
      int timeNow) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTIES)
        .where('isActive', isEqualTo: true)
        .where('isGuestListActive', isEqualTo: true)
        .orderBy('endTime', descending: false)
        .get();
  }

  static getPartyByType(String blocServiceId, String type) {
    return FirebaseFirestore.instance
        .collection(PARTIES)
        .where('blocServiceId', isEqualTo: blocServiceId)
        .where('type', isEqualTo: type)
        .orderBy('name', descending: false)
        .snapshots();
  }


  static getUpcomingParties(int timeNow) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTIES)
        .where('endTime', isGreaterThan: timeNow)
        .where('isActive', isEqualTo: true)
        .where('type', isEqualTo: 'event')
        .orderBy('endTime', descending: false)
        .snapshots();
  }

  static getUpcomingGuestListParties(int timeNow) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTIES)
        .where('endTime', isGreaterThan: timeNow)
        .where('isActive', isEqualTo: true)
        .where('isGuestListActive', isEqualTo: true)
        .orderBy('endTime', descending: false)
        .snapshots();
  }

  // static Future<QuerySnapshot<Map<String, dynamic>>> pullUpcomingPartyByEndTime(
  //     int timeNow) {
  //   return FirebaseFirestore.instance
  //       .collection(FirestoreHelper.PARTIES)
  //       .where('endTime', isGreaterThan: timeNow)
  //       .where('isActive', isEqualTo: true)
  //       .orderBy('endTime', descending: false)
  //       .limit(1)
  //       .get();
  // }

  static void deleteParty(Party party) {
    FirebaseFirestore.instance
        .collection(PARTIES)
        .doc(party.id)
        .delete();
  }

  /** party guests **/
  static Future<QuerySnapshot<Map<String, dynamic>>> pullPartyGuest(
      String partyGuestId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTY_GUESTS)
        .where('id', isEqualTo: partyGuestId)
        .get();
  }

  static getPartyGuestsByPartyId(String partyId) {
    return FirebaseFirestore.instance
        .collection(PARTY_GUESTS)
        .where('partyId', isEqualTo: partyId)
        .where('isApproved', isEqualTo: true)
        .orderBy('name', descending: false)
        .snapshots();
  }


  static Future<QuerySnapshot<Map<String, dynamic>>> pullPartyGuestByUser(String guestId, String partyId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTY_GUESTS)
        .where('partyId', isEqualTo: partyId)
        .where('guestId', isEqualTo: guestId)
        .get();
  }


  static Future<QuerySnapshot<Map<String, dynamic>>> pullGuestListRequested(String userId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTY_GUESTS)
        .where('guestId', isEqualTo: userId)
        .get();
  }

  static void pushPartyGuest(PartyGuest partyGuest) async {
    try {
      await FirebaseFirestore.instance
          .collection(PARTY_GUESTS)
          .doc(partyGuest.id)
          .set(partyGuest.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static getGuestLists() {
    return FirebaseFirestore.instance.collection(PARTY_GUESTS)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static getPartyGuestList(String partyId) {
    return FirebaseFirestore.instance
        .collection(PARTY_GUESTS)
        .where('partyId', isEqualTo: partyId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static getPartyGuestListByUser(String guestId) {
    return FirebaseFirestore.instance
        .collection(PARTY_GUESTS)
        .where('guestId', isEqualTo: guestId)
        .snapshots();
  }

  static void deletePartyGuest(PartyGuest partyGuest) {
    FirebaseFirestore.instance
        .collection(PARTY_GUESTS)
        .doc(partyGuest.id)
        .delete();
  }

  /** products **/
  static void pushProduct(Product product) async {
    try {
      await FirebaseFirestore.instance
          .collection(PRODUCTS)
          .doc(product.id)
          .set(product.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullProduct(
      String productId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PRODUCTS)
        .where('id', isEqualTo: productId)
        .get();
  }

  static pullProductsByBottle(String blocServiceId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PRODUCTS)
        .where('blocIds', arrayContains: blocServiceId)
        .where('priceBottle', isGreaterThan: 0)
        .where('isAvailable', isEqualTo: true)
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
        .snapshots();
  }

  static getProductsByCategoryTypeNew(String blocServiceId, String type) {
    return FirebaseFirestore.instance
        .collection(PRODUCTS)
        .where('blocIds', arrayContains: blocServiceId)
        .where('type', isEqualTo: type)
        .where('isAvailable', isEqualTo: true)
        .snapshots();
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
          .then((value) {
        Logx.i(_TAG, "product updated");
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to update product', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static void setProductOfferRunning(
      String productId, bool isOfferRunning) async {
    try {
      await FirebaseFirestore.instance
          .collection(PRODUCTS)
          .doc(productId)
          .update({'isOfferRunning': isOfferRunning}).then((value) {
        Logx.i(
            _TAG,
            "product id " +
                productId +
                " is set to offer " +
                isOfferRunning.toString());
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to update product offer status', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static void deleteProduct(String productId) {
    FirebaseFirestore.instance.collection(PRODUCTS).doc(productId).delete();
  }

  /** reservations **/
  static void pushReservation(Reservation reservation) async {
    try {
      await FirebaseFirestore.instance
          .collection(RESERVATIONS)
          .doc(reservation.id)
          .set(reservation.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static pullReservationsByEndTime(int timeNow, bool isApproved) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.RESERVATIONS)
        .where('arrivalDate', isGreaterThan: timeNow)
        .where('isApproved', isEqualTo: isApproved)
        .orderBy('arrivalDate', descending: false)
        .get();
  }

  static Stream<QuerySnapshot<Object?>> getReservations() {
    return FirebaseFirestore.instance
        .collection(RESERVATIONS)
        .orderBy('arrivalDate', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Object?>> getReservationsByBlocId(String blocServiceId) {
    return FirebaseFirestore.instance
        .collection(RESERVATIONS)
        .where('blocServiceId', isEqualTo: blocServiceId)
        .orderBy('arrivalDate', descending: false)
        .snapshots();
  }

  static getReservationsByUser(String userId) {
    return FirebaseFirestore.instance
        .collection(RESERVATIONS)
        .where('customerId', isEqualTo: userId)
        .snapshots();
  }


  static void deleteReservation(String docId) {
    FirebaseFirestore.instance.collection(RESERVATIONS).doc(docId).delete();
  }

  /** seats **/
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
    try {
      await FirebaseFirestore.instance
          .collection(SEATS)
          .doc(seat.id)
          .set(seat.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static void updateSeat(String seatId, String custId) async {
    try {
      await FirebaseFirestore.instance
          .collection(SEATS)
          .doc(seatId)
          .update({'custId': custId}).then((value) {
        if (custId.isEmpty) {
          Logx.i(_TAG, "seat is now free : " + seatId);
        } else {
          Logx.i(_TAG, "seat is occupied by cust id: " + custId);
        }
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to update seat with cust', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
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

  /** sos **/
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

  /** tables **/
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
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static void setTableOccupyStatus(String tableId, bool isOccupied) async {
    try {
      await FirebaseFirestore.instance
          .collection(TABLES)
          .doc(tableId)
          .update({'isOccupied': isOccupied}).then((value) {
        Logx.i(_TAG, "table is occupied : " + tableId);
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to set isOccupy table', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static void setTableType(ServiceTable table, int newType) async {
    try {
      await FirebaseFirestore.instance
          .collection(TABLES)
          .doc(table.id)
          .update({'type': newType}).then((value) {
        Logx.i(
            _TAG,
            "table " +
                table.tableNumber.toString() +
                " type changed to type id " +
                newType.toString());
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to change table color', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static void setTableCaptain(String tableId, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection(TABLES)
          .doc(tableId)
          .update({'captainId': userId}).then((value) {
        Logx.i(_TAG, "table id " + tableId + " has captain id " + userId);
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to set captain to table', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static void setTableActiveStatus(String tableId, bool isActive) async {
    try {
      await FirebaseFirestore.instance
          .collection(TABLES)
          .doc(tableId)
          .update({'isActive': isActive}).then((value) {
        Logx.i(
            _TAG,
            "table id " +
                tableId +
                " has active status of " +
                isActive.toString());
      }).catchError((e, s) {
        Logx.ex(_TAG, 'Failed to set isActive to table', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static void changeTableColor(ServiceTable table) async {
    try {
      await FirebaseFirestore.instance.collection(TABLES).doc(table.id).update({
        'type': table.type == FirestoreHelper.TABLE_COMMUNITY_TYPE_ID
            ? FirestoreHelper.TABLE_PRIVATE_TYPE_ID
            : FirestoreHelper.TABLE_COMMUNITY_TYPE_ID
      }).then((value) {
        Logx.i(_TAG, "table color status changed for: " + table.id);
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to change table color', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  /** ticket **/
  static void pushTicket(Ticket ticket) async {
    try {
      await FirebaseFirestore.instance
          .collection(TICKETS)
          .doc(ticket.id)
          .set(ticket.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }


  /** user **/
  static void pushUser(blocUser.User user) async {
    try {
      await FirebaseFirestore.instance
          .collection(USERS)
          .doc(user.id)
          .set(user.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
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
        .snapshots();
  }

  static getUsersByLevel(int level) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('clearanceLevel', isEqualTo: level)
        .orderBy('lastSeenAt', descending: true)
        .snapshots();
  }

  static getUsersByLevelAndGender(int level, String gender) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('clearanceLevel', isEqualTo: level)
        .where('gender', isEqualTo: gender)
        .orderBy('lastSeenAt', descending: true)
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
      } on PlatformException catch (e, s) {
        Logx.e(_TAG, e, s);
      } on Exception catch (e, s) {
        Logx.e(_TAG, e, s);
      } catch (e) {
        logger.e(e);
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection(USERS)
          .doc(user.id)
          .update(user.toMap())
          .then((value) {
        Logx.i(_TAG, "user has been updated in firebase.");
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed updating user in firebase', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static void updateUserFcmToken(String userId, String? token) async {
    try {
      await FirebaseFirestore.instance.collection(USERS).doc(userId).update({
        'fcmToken': token,
      }).then((value) {
        Logx.i(_TAG, userId + " user fcm token updated to : " + token!);
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to update user fcm token', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static void updateUserBlocId(String userId, String blocServiceId) async {
    try {
      await FirebaseFirestore.instance.collection(USERS).doc(userId).update({
        'blocServiceId': blocServiceId,
      }).then((value) {
        Logx.i(_TAG,
            userId + " user bloc service id updated to : " + blocServiceId);
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to update user bloc service id', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
    }
  }

  static void deleteUser(blocUser.User user) {
    FirebaseFirestore.instance.collection(USERS).doc(user.id).delete();
  }

  /** user level **/
  static pullUserLevels(int clearanceLevel) {
    return FirebaseFirestore.instance
        .collection(USER_LEVELS)
        .where('level', isLessThan: clearanceLevel)
        .orderBy('level', descending: false)
        .get();
  }


}
