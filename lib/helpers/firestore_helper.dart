import 'dart:io';

import 'package:bloc/db/entity/ad_campaign.dart';
import 'package:bloc/db/entity/bloc.dart';
import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/db/entity/captain_service.dart';
import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/category.dart';
import 'package:bloc/db/entity/celebration.dart';
import 'package:bloc/db/entity/challenge.dart';
import 'package:bloc/db/entity/challenge_action.dart';
import 'package:bloc/db/entity/config.dart';
import 'package:bloc/db/entity/friend_notification.dart';
import 'package:bloc/db/entity/lounge_chat.dart';
import 'package:bloc/db/entity/genre.dart';
import 'package:bloc/db/entity/guest_wifi.dart';
import 'package:bloc/db/entity/history_music.dart';
import 'package:bloc/db/entity/notification_test.dart';
import 'package:bloc/db/entity/offer.dart';
import 'package:bloc/db/entity/order_bloc.dart';
import 'package:bloc/db/entity/party.dart';
import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/db/entity/party_interest.dart';
import 'package:bloc/db/entity/party_tix_tier.dart';
import 'package:bloc/db/entity/promoter.dart';
import 'package:bloc/db/entity/promoter_guest.dart';
import 'package:bloc/db/entity/quick_order.dart';
import 'package:bloc/db/entity/quick_table.dart';
import 'package:bloc/db/entity/reservation.dart';
import 'package:bloc/db/entity/seat.dart';
import 'package:bloc/db/entity/tix_tier_item.dart';
import 'package:bloc/db/entity/ui_photo.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:bloc/db/entity/user_lounge.dart';
import 'package:bloc/helpers/firestorage_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../db/entity/ad.dart';
import '../db/entity/city.dart';
import '../db/entity/friend.dart';
import '../db/entity/lounge.dart';
import '../db/entity/party_photo.dart';
import '../db/entity/support_chat.dart';
import '../db/entity/tix.dart';
import '../db/entity/product.dart';
import '../db/entity/service_table.dart';
import '../db/entity/sos.dart';
import '../db/entity/tix_backup.dart';
import '../db/entity/user_bloc.dart';
import '../db/entity/user_photo.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../routes/route_constants.dart';
import '../utils/logx.dart';
import '../utils/string_utils.dart';

/**
 * Tips:
 * 1. when the stream builder querying is being run more than once, create an index in firebase db
 * **/
class FirestoreHelper {
  static const String _TAG = 'FirestoreHelper';

  static String ADS = 'ads';
  static String AD_CAMPAIGNS = 'ad_campaigns';
  static String BLOCS = 'blocs';
  static String CAPTAIN_SERVICES = 'captain_services';
  static String CATEGORIES = 'categories';
  static String CART_ITEMS = 'cart_items';
  static String CHALLENGES = 'challenges';
  static String CHALLENGE_ACTIONS = 'challenge_actions';
  static String CELEBRATIONS = 'celebrations';
  static String CITIES = 'cities';
  static String CONFIGS = 'configs';
  static String FRIENDS = 'friends';
  static String FRIEND_NOTIFICATIONS = 'friend_notifications';
  static String GENRES = 'genres';
  static String GUEST_WIFIS = 'guest_wifis';
  static String HISTORY_MUSIC = 'history_music';
  static String INVENTORY_OPTIONS = 'inventory_options';
  static String LOUNGES = 'lounges';
  static String LOUNGE_CHATS = 'lounge_chats';
  static String MANAGER_SERVICES = 'manager_services';
  static String MANAGER_SERVICE_OPTIONS = 'manager_service_options';
  static String NOTIFICATION_TESTS = 'notification_tests';
  static String OFFERS = 'offers';
  static String ORDERS = 'orders';
  static String PARTIES = 'parties';
  static String PARTY_GUESTS = 'party_guests';
  static String PARTY_INTERESTS = 'party_interests';
  static String PARTY_PHOTOS = 'party_photos';
  static String PARTY_TIX_TIERS = 'party_tix_tiers';
  static String PRODUCTS = 'products';
  static String PROMOTERS = 'promoters';
  static String PROMOTER_GUESTS = 'promoter_guests';
  static String BLOC_SERVICES = 'services';
  static String QUICK_ORDERS = 'quick_orders';
  static String QUICK_TABLES = 'quick_tables';
  static String RESERVATIONS = 'reservations';
  static String SEATS = 'seats';
  static String SUPPORT_CHATS = 'support_chats';
  static String SOS = 'sos';
  static String TABLES = 'tables';
  static String TIXS = 'tixs';
  static String TIX_BACKUPS = 'tix_backups';
  static String TIX_TIERS = 'tix_tiers';
  static String UI_PHOTOS = 'ui_photos';
  static String USERS = 'users';
  static String USER_BLOCS = 'user_blocs';
  static String USER_LEVELS = 'user_levels';
  static String USER_LOUNGES = 'user_lounges';
  static String USER_PHOTOS = 'user_photos';

  static String CHAT_TYPE_TEXT = 'text';
  static String CHAT_TYPE_IMAGE = 'image';

  static int TABLE_PRIVATE_TYPE_ID = 1;
  static int TABLE_COMMUNITY_TYPE_ID = 2;


  /** ads **/
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
      Logx.em(_TAG, e.toString());
    }
  }

  static getAds(String blocId) {
    return FirebaseFirestore.instance
        .collection(ADS)
        .where('blocId', isEqualTo: blocId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static pullAds() {
    return FirebaseFirestore.instance
        .collection(ADS)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();
  }

  static void updateAdHit(String id) {
    FirebaseFirestore.instance
        .collection(ADS)
        .doc(id)
        .update({"hits": FieldValue.increment(1)},);
  }

  static void updateAdReach(String id) {
    FirebaseFirestore.instance
        .collection(ADS)
        .doc(id)
        .update({"reach": FieldValue.increment(1)},);
  }

  static void deleteAd(String docId) {
    FirebaseFirestore.instance.collection(ADS).doc(docId).delete();
  }

  /** Ad Campaigns **/
  static void pushAdCampaign(AdCampaign adCampaign) async {
    try {
      await FirebaseFirestore.instance
          .collection(AD_CAMPAIGNS)
          .doc(adCampaign.id)
          .set(adCampaign.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static pullAdCampaign() {
    return FirebaseFirestore.instance
        .collection(AD_CAMPAIGNS)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
  }

  static pullAdCampaignByStorySize(bool isStorySize) {
    return FirebaseFirestore.instance
        .collection(AD_CAMPAIGNS)
        .where('isActive', isEqualTo: true)
        .where('isStorySize', isEqualTo: isStorySize)
        .get();
  }

  static pullAdCampaignByPartyId(String partyId) {
    return FirebaseFirestore.instance
        .collection(AD_CAMPAIGNS)
        // .where('isActive', isEqualTo: true)
        .where('partyId', isEqualTo: partyId)
        .get();
  }

  static getAdCampaigns() {
    return FirebaseFirestore.instance
        .collection(AD_CAMPAIGNS)
        .snapshots();
  }

  static void updateAdCampaignClickCount(String docId) {
    FirebaseFirestore.instance
        .collection(AD_CAMPAIGNS)
        .doc(docId)
        .update({"clickCount": FieldValue.increment(1)},);
  }

  static void deleteAdCampaign(String docId) {
    FirebaseFirestore.instance.collection(AD_CAMPAIGNS).doc(docId).delete();
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
      Logx.em(_TAG, e.toString());
    }
  }

  static Future<QuerySnapshot<Object?>> pullBlocs() {
    return FirebaseFirestore.instance
        .collection(BLOCS)
        .where('isActive', isEqualTo: true)
        .orderBy('orderPriority', descending: false)
        .get();
  }

  static Future<QuerySnapshot<Object?>> pullBlocById(String id) {
    return FirebaseFirestore.instance
        .collection(BLOCS)
        .where('id', isEqualTo: id)
        // .where('isActive', isEqualTo: true)
        .get();
  }

  static pullBlocsPromoter() {
    return FirebaseFirestore.instance.collection(BLOCS)
        // .where('isActive', isEqualTo: true)
        .orderBy('orderPriority', descending: false)
        .get();
  }

  static getBlocsByCityId(String cityId) {
    return FirebaseFirestore.instance
        .collection(BLOCS)
        .where('cityId', isEqualTo: cityId)
        .orderBy('orderPriority', descending: false)
        .snapshots();
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
      Logx.em(_TAG, e.toString());
    }
  }

  static pullAllBlocServices() {
    return FirebaseFirestore.instance.collection(BLOC_SERVICES).get();
  }

  static Future<QuerySnapshot<Object?>> pullBlocServiceById(String id) {
    return FirebaseFirestore.instance
        .collection(BLOC_SERVICES)
        .where('id', isEqualTo: id)
        .get();
  }

  static Future<QuerySnapshot<Object?>> pullBlocServiceByBlocId(String blocId) {
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
      Logx.em(_TAG, e.toString());
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
        Logx.i(_TAG, "cart item ${cart.cartId} marked as complete.");
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to update cart item completed', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
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
        Logx.i(_TAG, "cart item $cartId is part of bill id : $billId");
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to update bill id for cart item', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
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
      Logx.em(_TAG, e.toString());
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullCategories(
      String blocServiceId) {
    return FirebaseFirestore.instance
        .collection(CATEGORIES)
        .where('serviceId', isEqualTo: blocServiceId)
        .orderBy('sequence', descending: false)
        .get();
  }

  static pullCategoriesInBlocIds(String blocServiceId) {
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

  static void deleteCategory(String docId) {
    FirebaseFirestore.instance.collection(CATEGORIES).doc(docId).delete();
  }

  /** captain services **/
  static void pushCaptainService(CaptainService captainService) async {
    try {
      await FirebaseFirestore.instance
          .collection(CAPTAIN_SERVICES)
          .doc(captainService.id)
          .set(captainService.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static Stream<QuerySnapshot<Object?>> getCaptainServices() {
    return FirebaseFirestore.instance
        .collection(CAPTAIN_SERVICES)
        .orderBy('sequence', descending: false)
        .snapshots();
  }

  /** celebrations **/
  static void pushCelebration(Celebration celebration) async {
    try {
      await FirebaseFirestore.instance
          .collection(CELEBRATIONS)
          .doc(celebration.id)
          .set(celebration.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static Stream<QuerySnapshot<Object?>> getCelebrationsByBlocId(
      String blocServiceId) {
    return FirebaseFirestore.instance
        .collection(CELEBRATIONS)
        .where('blocServiceId', isEqualTo: blocServiceId)
        .orderBy('arrivalDate', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Object?>> getCelebrationsByUser(String userId) {
    return FirebaseFirestore.instance
        .collection(CELEBRATIONS)
        .where('customerId', isEqualTo: userId)
        .snapshots();
  }

  static Stream<QuerySnapshot<Object?>> getCelebrations() {
    return FirebaseFirestore.instance
        .collection(CELEBRATIONS)
        .orderBy('arrivalDate', descending: true)
        .snapshots();
  }

  static void deleteCelebration(String docId) {
    FirebaseFirestore.instance.collection(CELEBRATIONS).doc(docId).delete();
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
      Logx.em(_TAG, e.toString());
    }
  }

  static void updateChallengeClickCount(String docId) {
    FirebaseFirestore.instance
        .collection(CHALLENGES)
        .doc(docId)
        .update({"clickCount": FieldValue.increment(1)},);
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

  /** challenge actions **/
  static void pushChallengeAction(ChallengeAction ca) async {
    try {
      await FirebaseFirestore.instance
          .collection(CHALLENGE_ACTIONS)
          .doc(ca.id)
          .set(ca.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static pullChallengeActions(String challengeId) {
    return FirebaseFirestore.instance
        .collection(CHALLENGE_ACTIONS)
        .where('challengeId', isEqualTo: challengeId)
        .get();
  }

  static void deleteChallengeAction(String docId) {
    FirebaseFirestore.instance.collection(CHALLENGE_ACTIONS).doc(docId).delete();
  }

  /** lounge chats **/
  static void pushLoungeChat(LoungeChat chat) async {
    try {
      await FirebaseFirestore.instance
          .collection(LOUNGE_CHATS)
          .doc(chat.id)
          .set(chat.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static pullLoungePhotoChats(String loungeId) {
    return FirebaseFirestore.instance
        .collection(LOUNGE_CHATS)
        .where('loungeId', isEqualTo: loungeId)
        .where('type', isNotEqualTo: 'text')
        .get();
  }

  static pullLoungeChats(String loungeId) {
    return FirebaseFirestore.instance
        .collection(LOUNGE_CHATS)
        .where('loungeId', isEqualTo: loungeId)
        .get();
  }

  static Stream<QuerySnapshot<Object?>> getLoungeChats(String loungeId) {
    return FirebaseFirestore.instance
        .collection(LOUNGE_CHATS)
        .where('loungeId', isEqualTo: loungeId)
        .orderBy('time', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Object?>> getLastLoungeChat(String loungeId) {
    return FirebaseFirestore.instance
        .collection(LOUNGE_CHATS)
        .where('loungeId', isEqualTo: loungeId)
        .orderBy('time', descending: true)
        .limit(1)
        .snapshots();
  }

  static void updateLoungeChatViewCount(String docId) {
    FirebaseFirestore.instance
        .collection(LOUNGE_CHATS)
        .doc(docId)
        .update({"views": FieldValue.increment(1)},);
  }

  static void deleteLoungeChat(String docId) {
    FirebaseFirestore.instance.collection(LOUNGE_CHATS).doc(docId).delete();
  }

  /** city **/
  static void pushCity(City city) async {
    try {
      await FirebaseFirestore.instance
          .collection(CITIES)
          .doc(city.id)
          .set(city.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static Stream<QuerySnapshot<Object?>> getCitiesSnapshot() {
    return FirebaseFirestore.instance.collection(CITIES).snapshots();
  }

  /** config **/
  static void pushConfig(Config config) async {
    try {
      await FirebaseFirestore.instance
          .collection(CONFIGS)
          .doc(config.id)
          .set(config.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static pullConfig(String blocServiceId, String configName) {
    return FirebaseFirestore.instance
        .collection(CONFIGS)
        .where('blocServiceId', isEqualTo: blocServiceId)
        .where('name', isEqualTo: configName)
        .get();
  }

  static getConfigs() {
    return FirebaseFirestore.instance
        .collection(CONFIGS)
        .orderBy('name', descending: false)
        .snapshots();
  }

  static void deleteConfig(String docId) {
    FirebaseFirestore.instance.collection(CONFIGS).doc(docId).delete();
  }

  /** friend **/
  static void pushFriend(Friend friend) async {
    try {
      await FirebaseFirestore.instance
          .collection(FRIENDS)
          .doc(friend.id)
          .set(friend.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static getManageFriends() {
    return FirebaseFirestore.instance
        .collection(FRIENDS)
        .orderBy('friendshipDate', descending: true)
        .snapshots();
  }

  static getUserFriends(String userId) {
    return FirebaseFirestore.instance
        .collection(FRIENDS)
        .where('userId', isEqualTo: userId)
        .orderBy('friendshipDate', descending: true)
        .snapshots();
  }

  static pullFriends(String userId) {
    return FirebaseFirestore.instance
        .collection(FRIENDS)
        .where('userId', isEqualTo: userId)
        .orderBy('friendshipDate', descending: true)
        .get();
  }

  static pullFriend(String userId, String friendUserId) {
    return FirebaseFirestore.instance
        .collection(FRIENDS)
        .where('userId', isEqualTo: userId)
        .where('friendUserId', isEqualTo: friendUserId)
        .get();
  }

  static pullFriendsOfUsers(List<String> tagIds) {
    return FirebaseFirestore.instance
        .collection(FRIENDS)
        .where('userId', whereIn: tagIds)
        .get();
  }

  static pullFriendConnections(String userId) {
    return FirebaseFirestore.instance
        .collection(FRIENDS)
        .where(Filter.or(
        Filter('userId', isEqualTo: userId),
          Filter('friendUserId', isEqualTo: userId)))
        .get();
  }

  static void deleteFriend(String docId) {
    FirebaseFirestore.instance.collection(FRIENDS).doc(docId).delete();
  }

  /** friend notification **/
  static void pushFriendNotification(FriendNotification friendNotification) async {
    try {
      await FirebaseFirestore.instance
          .collection(FRIEND_NOTIFICATIONS)
          .doc(friendNotification.id)
          .set(friendNotification.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static pullFriendNotifications() {
    return FirebaseFirestore.instance
        .collection(FRIEND_NOTIFICATIONS)
        .get();
  }

  static void deleteFriendNotification(String docId) {
    FirebaseFirestore.instance.collection(FRIEND_NOTIFICATIONS).doc(docId).delete();
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
      Logx.em(_TAG, e.toString());
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullGenres() {
    return FirebaseFirestore.instance
        .collection(GENRES)
        .orderBy('name', descending: false)
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
      Logx.em(_TAG, e.toString());
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
      Logx.em(_TAG, e.toString());
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullHistoryMusic(
      String userId, String genre) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.HISTORY_MUSIC)
        .where('userId', isEqualTo: userId)
        .where('genre', isEqualTo: genre)
        .limit(1)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullHistoryMusicByUser(
      String userId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.HISTORY_MUSIC)
        .where('userId', isEqualTo: userId)
        .get();
  }

  static void deleteHistoryMusic(String docId) {
    FirebaseFirestore.instance.collection(HISTORY_MUSIC).doc(docId).delete();
  }

  /** inventory options **/
  static Stream<QuerySnapshot<Object?>> getInventoryOptions() {
    return FirebaseFirestore.instance
        .collection(INVENTORY_OPTIONS)
        .orderBy('sequence', descending: false)
        .snapshots();
  }

  /** lounge **/
  static void pushLounge(Lounge lounge) async {
    try {
      await FirebaseFirestore.instance
          .collection(LOUNGES)
          .doc(lounge.id)
          .set(lounge.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static void updateLoungeLastChat(
      String loungeId, String lastChat, int lastChatTime) async {
    try {
      await FirebaseFirestore.instance
          .collection(LOUNGES)
          .doc(loungeId)
          .update({'lastChat': lastChat, 'lastChatTime': lastChatTime});
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullLounges() {
    return FirebaseFirestore.instance
        .collection(LOUNGES)
        .orderBy('name', descending: false)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullLounge(String id) {
    return FirebaseFirestore.instance
        .collection(LOUNGES)
        .where('id', isEqualTo: id)
        .get();
  }

  static Stream<QuerySnapshot<Object?>> getLounges() {
    return FirebaseFirestore.instance
        .collection(LOUNGES)
        .orderBy('lastChatTime', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Object?>> getActiveLounges() {
    return FirebaseFirestore.instance
        .collection(LOUNGES)
        .orderBy('lastChatTime', descending: true)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  static void deleteLounge(String docId) {
    FirebaseFirestore.instance.collection(LOUNGES).doc(docId).delete();
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

  /** notification test **/
  static void pushNotificationTest(NotificationTest notificationTest) async {
    try {
      await FirebaseFirestore.instance
          .collection(NOTIFICATION_TESTS)
          .doc(notificationTest.id)
          .set(notificationTest.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static getNotificationTests() {
    return FirebaseFirestore.instance
        .collection(NOTIFICATION_TESTS)
        .snapshots();
  }

  static void deleteNotificationTest(String docId) {
    FirebaseFirestore.instance.collection(NOTIFICATION_TESTS).doc(docId).delete();
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
      Logx.em(_TAG, e.toString());
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
      Logx.em(_TAG, e.toString());
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
      Logx.em(_TAG, e.toString());
    }
  }

  static void updatePartyViewCount(String docId) {
    FirebaseFirestore.instance
        .collection(PARTIES)
        .doc(docId)
        .update({"views": FieldValue.increment(1)},);
  }

  static void updatePartyShareCount(String docId) {
    FirebaseFirestore.instance
        .collection(PARTIES)
        .doc(docId)
        .update({"shareCount": FieldValue.increment(1)},);
  }

  static pullParties(String serviceId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTIES)
        .where('blocServiceId', isEqualTo: serviceId)
        .orderBy('name', descending: false)
        .get();
  }

  static pullPartiesTicketed() {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTIES)
        .where('isTix', isEqualTo: true)
        .orderBy('endTime', descending: true)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullParty(String partyId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTIES)
        .where('id', isEqualTo: partyId)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullPartyByNameChapter(
      String name, String chapter) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTIES)
        .where('name', isEqualTo: name)
        .where('chapter', isEqualTo: chapter)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullPartyByNameGenre(
      String name, String genre) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTIES)
        .where('name', isEqualTo: name)
        .where('genre', isEqualTo: genre)
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

  static Future<QuerySnapshot<Map<String, dynamic>>> pullPartyArtists() {
    return FirebaseFirestore.instance
        .collection(PARTIES)
        .where('type', isEqualTo: 'artist')
        .orderBy('name', descending: false)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullPartyArtistsByIds(
      List<String> artistIds) {
    return FirebaseFirestore.instance
        .collection(PARTIES)
        .where('id', whereIn: artistIds)
        .get();
  }

  // static getPartyByType(String blocServiceId, String type) {
  //   return FirebaseFirestore.instance
  //       .collection(PARTIES)
  //       .where('blocServiceId', isEqualTo: blocServiceId)
  //       .where('type', isEqualTo: type)
  //       .orderBy('name', descending: false)
  //       .snapshots();
  // }

  static getPartyArtists(List<String> artistIds) {
    return FirebaseFirestore.instance
        .collection(PARTIES)
        .where('id', whereIn: artistIds)
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

  static void deleteParty(Party party) {
    FirebaseFirestore.instance.collection(PARTIES).doc(party.id).delete();
  }

  /** party guests **/
  static Future<QuerySnapshot<Map<String, dynamic>>> pullPartyGuest(
      String partyGuestId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTY_GUESTS)
        .where('id', isEqualTo: partyGuestId)
        .get();
  }

  //todo: need to remove the index a couple of builds later
  static getPartyGuestsByPartyId(String partyId) {
    return FirebaseFirestore.instance
        .collection(PARTY_GUESTS)
        .where('partyId', isEqualTo: partyId)
        .snapshots();
  }

  static pullPartyGuestsByPartyId(String partyId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTY_GUESTS)
        .where('partyId', isEqualTo: partyId)
        .get();
  }

  static pullPartyGuestsByUser(String guestId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTY_GUESTS)
        .where('guestId', isEqualTo: guestId)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullPartyGuestByUser(
      String guestId, String partyId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTY_GUESTS)
        .where('partyId', isEqualTo: partyId)
        .where('guestId', isEqualTo: guestId)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullGuestListRequested(
      String userId) {
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
      Logx.em(_TAG, e.toString());
    }
  }

  static getGuestLists() {
    return FirebaseFirestore.instance
        .collection(PARTY_GUESTS)
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

  static void deletePartyGuest(String docId) {
    FirebaseFirestore.instance
        .collection(PARTY_GUESTS)
        .doc(docId)
        .delete();
  }

  /** party interest **/
  static void pushPartyInterest(PartyInterest partyInterest) async {
    try {
      await FirebaseFirestore.instance
          .collection(PARTY_INTERESTS)
          .doc(partyInterest.id)
          .set(partyInterest.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static pullPartyInterest(String partyId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTY_INTERESTS)
        .where('partyId', isEqualTo: partyId)
        .get();
  }

  /** party photo **/
  static void pushPartyPhoto(PartyPhoto partyPhoto) async {
    try {
      await FirebaseFirestore.instance
          .collection(PARTY_PHOTOS)
          .doc(partyPhoto.id)
          .set(partyPhoto.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static pullPartyPhotos() {
    return FirebaseFirestore.instance
        .collection(PARTY_PHOTOS)
        .orderBy('partyDate', descending: true)
        .get();
  }

  static pullPartyPhotosByUserId(String userId) {
    return FirebaseFirestore.instance
        .collection(PARTY_PHOTOS)
        .where('tags', arrayContains: userId)
        .orderBy('partyDate', descending: true)
        .get();
  }

  static pullPartyPhoto(String partyPhotoId) {
    return FirebaseFirestore.instance
        .collection(PARTY_PHOTOS)
        .where('id', isEqualTo: partyPhotoId)
        .get();
  }

  static getPartyPhotos(String blocServiceId) {
    return FirebaseFirestore.instance
        .collection(PARTY_PHOTOS)
        .where('blocServiceId', isEqualTo: blocServiceId)
        .orderBy('partyDate', descending: true)
        .snapshots();
  }

  static Future updatePartyPhotoDownloadCount(String docId) {
    return FirebaseFirestore.instance
        .collection(PARTY_PHOTOS)
        .doc(docId)
        .update({"downloadCount": FieldValue.increment(1)},);
  }

  static void updatePartyPhotoViewCount(String docId) {
    FirebaseFirestore.instance
        .collection(PARTY_PHOTOS)
        .doc(docId)
        .update({"views": FieldValue.increment(1)},);
  }

  static void deletePartyPhoto(String docId) {
    FirebaseFirestore.instance
        .collection(PARTY_PHOTOS)
        .doc(docId)
        .delete();
  }

  /** party tix tier **/
  static void pushPartyTixTier(PartyTixTier partyTixTier) async {
    try {
      await FirebaseFirestore.instance
          .collection(PARTY_TIX_TIERS)
          .doc(partyTixTier.id)
          .set(partyTixTier.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static pullPartyTixTiers(String partyId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PARTY_TIX_TIERS)
        .where('partyId', isEqualTo: partyId)
        .orderBy('tierLevel', descending: true)
        .get();
  }

  static getPartyTixTiers(String partyId) {
    return FirebaseFirestore.instance
        .collection(PARTY_TIX_TIERS)
        .where('partyId', isEqualTo: partyId)
        .orderBy('tierLevel', descending: true)
        .snapshots();
  }

  static void deletePartyTixTier(String docId) {
    FirebaseFirestore.instance
        .collection(PARTY_TIX_TIERS)
        .doc(docId)
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
      Logx.em(_TAG, e.toString());
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>>  pullProductsByType(String serviceId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PRODUCTS)
        .where('serviceId', isEqualTo: serviceId)
        .orderBy('name', descending: false)
        .get();
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

  Stream<QuerySnapshot<Object?>> getProductByCategories(
      String serviceId, List<String> categoryNames) {
    return FirebaseFirestore.instance
        .collection(PRODUCTS)
        .where('serviceId', isEqualTo: serviceId)
        .where('category', whereIn: categoryNames)
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
      Logx.em(_TAG, e.toString());
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
            "product id $productId is set to offer $isOfferRunning");
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to update product offer status', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static void deleteProduct(String productId) {
    FirebaseFirestore.instance.collection(PRODUCTS).doc(productId).delete();
  }

  /** promoter **/
  static void pushPromoter(Promoter promoter) async {
    try {
      await FirebaseFirestore.instance
          .collection(PROMOTERS)
          .doc(promoter.id)
          .set(promoter.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static pullPromoters() {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PROMOTERS)
        .orderBy('name', descending: false)
        .get();
  }

  static pullPromoter(String id) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.PROMOTERS)
        .where('id', isEqualTo: id)
        .get();
  }


  static getPromoters() {
    return FirebaseFirestore.instance
        .collection(PROMOTERS)
        .orderBy('name', descending: true)
        .snapshots();
  }

  static void deletePromoter(String docId) {
    FirebaseFirestore.instance.collection(PROMOTERS).doc(docId).delete();
  }

  /** promoter guest **/
  static void pushPromoterGuest(PromoterGuest promoterGuest) async {
    try {
      await FirebaseFirestore.instance
          .collection(PROMOTER_GUESTS)
          .doc(promoterGuest.id)
          .set(promoterGuest.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static pullAllPromoterGuests() {
    return FirebaseFirestore.instance
        .collection(PROMOTER_GUESTS)
        .get();
  }

  static pullPromoterGuests(String promoterId) {
    return FirebaseFirestore.instance
        .collection(PROMOTER_GUESTS)
        .where('promoterId', isEqualTo: promoterId)
        .get();
  }

  static pullPromoterGuestsByBlocUserId(String blocUserId) {
    return FirebaseFirestore.instance
        .collection(PROMOTER_GUESTS)
        .where('blocUserId', isEqualTo: blocUserId)
        .get();
  }

  static pullPromoterGuest(String partyGuestId) {
    return FirebaseFirestore.instance
        .collection(PROMOTER_GUESTS)
        .where('partyGuestId', isEqualTo: partyGuestId)
        .get();
  }

  static void deletePromoterGuest(String docId) {
    FirebaseFirestore.instance.collection(PROMOTER_GUESTS).doc(docId).delete();
  }

  /** quick order **/
  static void pushQuickOrder(QuickOrder quickOrder) async {
    try {
      await FirebaseFirestore.instance
          .collection(QUICK_ORDERS)
          .doc(quickOrder.id)
          .set(quickOrder.toMap()).then((res){
        Logx.ist(_TAG, 'your order has been placed, thank you!');
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static pullQuickOrders(String custId) {
    return FirebaseFirestore.instance
        .collection(QUICK_ORDERS)
        .where('custId', isEqualTo: custId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  static getQuickOrders(String custId) {
    return FirebaseFirestore.instance
        .collection(QUICK_ORDERS)
        .where('custId', isEqualTo: custId)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  static getAllQuickOrders() {
    return FirebaseFirestore.instance
        .collection(QUICK_ORDERS)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  static void deleteQuickOrder(String docId) {
    FirebaseFirestore.instance.collection(QUICK_ORDERS).doc(docId).delete();
  }


  /** quick table **/
  static Future<void> pushQuickTable(QuickTable quickTable, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection(QUICK_TABLES)
          .doc(quickTable.id)
          .set(quickTable.toMap()).then((res) {
        GoRouter.of(context).pushNamed(RouteConstants.menuRouteName,
            params: {
              'id': UserPreferences.getBlocId(),
            });
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static pullQuickTable(int phoneNumber) {
    return FirebaseFirestore.instance
        .collection(QUICK_TABLES)
        .where('phone', isEqualTo: phoneNumber)
        .get();
  }

  static void deleteQuickTable(String docId) {
    FirebaseFirestore.instance.collection(QUICK_TABLES).doc(docId).delete();
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
      Logx.em(_TAG, e.toString());
    }
  }

  // static pullReservationsByEndTime(int timeNow, bool isApproved) {
  //   return FirebaseFirestore.instance
  //       .collection(FirestoreHelper.RESERVATIONS)
  //       .where('arrivalDate', isGreaterThan: timeNow)
  //       .where('isApproved', isEqualTo: isApproved)
  //       .orderBy('arrivalDate', descending: false)
  //       .get();
  // }

  static pullReservationsByUser(String userId) {
    return FirebaseFirestore.instance
        .collection(FirestoreHelper.RESERVATIONS)
        .where('customerId', isGreaterThan: userId)
        .get();
  }

  static Stream<QuerySnapshot<Object?>> getReservations() {
    return FirebaseFirestore.instance
        .collection(RESERVATIONS)
        .orderBy('arrivalDate', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Object?>> getReservationsByBlocId(
      String blocServiceId) {
    return FirebaseFirestore.instance
        .collection(RESERVATIONS)
        .where('blocServiceId', isEqualTo: blocServiceId)
        .orderBy('arrivalDate', descending: true)
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
      Logx.em(_TAG, e.toString());
    }
  }

  static void updateSeat(String seatId, String custId) async {
    try {
      await FirebaseFirestore.instance
          .collection(SEATS)
          .doc(seatId)
          .update({'custId': custId}).then((value) {
        if (custId.isEmpty) {
          Logx.i(_TAG, "seat is now free : $seatId");
        } else {
          Logx.i(_TAG, "seat is occupied by cust id: $custId");
        }
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to update seat with cust', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
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

  /** support chats **/
  static void pushSupportChat(SupportChat chat) async {
    try {
      await FirebaseFirestore.instance
          .collection(SUPPORT_CHATS)
          .doc(chat.id)
          .set(chat.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static Stream<QuerySnapshot<Object?>> getSupportChats(String userId) {
    return FirebaseFirestore.instance
        .collection(SUPPORT_CHATS)
        .where('userId', isEqualTo: userId)
        .orderBy('time', descending: true)
        .snapshots();
  }

  static getAllSupportChats() {
    return FirebaseFirestore.instance
        .collection(SUPPORT_CHATS)
        .orderBy('time', descending: true)
        .snapshots();
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
      Logx.em(_TAG, e.toString());
    }
  }

  static void setTableOccupyStatus(String tableId, bool isOccupied) async {
    try {
      await FirebaseFirestore.instance
          .collection(TABLES)
          .doc(tableId)
          .update({'isOccupied': isOccupied}).then((value) {
        Logx.i(_TAG, "table is occupied : $tableId");
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to set isOccupy table', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
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
            "table ${table.tableNumber} type changed to type id $newType");
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to change table color', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static void setTableCaptain(String tableId, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection(TABLES)
          .doc(tableId)
          .update({'captainId': userId}).then((value) {
        Logx.i(_TAG, "table id $tableId has captain id $userId");
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to set captain to table', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
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
            "table id $tableId has active status of $isActive");
      }).catchError((e, s) {
        Logx.ex(_TAG, 'Failed to set isActive to table', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static void changeTableColor(ServiceTable table) async {
    try {
      await FirebaseFirestore.instance.collection(TABLES).doc(table.id).update({
        'type': table.type == FirestoreHelper.TABLE_COMMUNITY_TYPE_ID
            ? FirestoreHelper.TABLE_PRIVATE_TYPE_ID
            : FirestoreHelper.TABLE_COMMUNITY_TYPE_ID
      }).then((value) {
        Logx.i(_TAG, "table color status changed for: ${table.id}");
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to change table color', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  /** ui photo **/
  static void pushUiPhoto(UiPhoto uiPhoto) async {
    try {
      await FirebaseFirestore.instance
          .collection(UI_PHOTOS)
          .doc(uiPhoto.id)
          .set(uiPhoto.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullUiPhoto(String name) {
    return FirebaseFirestore.instance
        .collection(UI_PHOTOS)
        .where('name', isEqualTo: name)
        .get();
  }

  /** tix **/
  static void pushTix(Tix tix) async {
    try {
      await FirebaseFirestore.instance
          .collection(TIXS)
          .doc(tix.id)
          .set(tix.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static pullAllTix() {
    return FirebaseFirestore.instance
        .collection(TIXS)
        .get();
  }

  static pullTix(String tixId) {
    return FirebaseFirestore.instance
        .collection(TIXS)
        .where('id', isEqualTo: tixId)
        .get();
  }

  static pullTixsByPartyId(String partyId) {
    return FirebaseFirestore.instance
        .collection(TIXS)
        .where('partyId', isEqualTo: partyId)
        .orderBy('userName', descending: false)
        .get();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getTixs() {
    return FirebaseFirestore.instance
        .collection(TIXS)
        .orderBy('dateTime', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllTixsByPartyId(String partyId) {
    return FirebaseFirestore.instance
        .collection(TIXS)
        .where('partyId', isEqualTo: partyId)
        .orderBy('creationTime', descending: false)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getTixsByPartyId(String partyId) {
    return FirebaseFirestore.instance
        .collection(TIXS)
        .where('partyId', isEqualTo: partyId)
        .where('isSuccess', isEqualTo: true)
        .orderBy('userName', descending: false)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getTix(String tixId) {
    return FirebaseFirestore.instance
        .collection(TIXS)
        .where('id', isEqualTo: tixId)
        .snapshots();
  }

  static getTixsByUser(String userId) {
    return FirebaseFirestore.instance
        .collection(TIXS)
        .where('userId', isEqualTo: userId)
        .where('isSuccess', isEqualTo: true)
        .orderBy('creationTime', descending: false)
        .snapshots();
  }

  static void deleteTix(String docId) {
    FirebaseFirestore.instance.collection(TIXS).doc(docId).delete();
  }

  /** tix backup **/
  static void pushTixBackup(TixBackup tix) async {
    try {
      await FirebaseFirestore.instance
          .collection(TIX_BACKUPS)
          .doc(tix.id)
          .set(tix.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  /** tix tier **/
  static void pushTixTier(TixTier tixTier) async {
    try {
      await FirebaseFirestore.instance
          .collection(TIX_TIERS)
          .doc(tixTier.id)
          .set(tixTier.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static pullTixTiers(String partyId) {
    return FirebaseFirestore.instance
        .collection(TIX_TIERS)
        .where('partyId', isEqualTo: partyId)
        .get();
  }

  static pullTixTier(String id) {
    return FirebaseFirestore.instance
        .collection(TIX_TIERS)
        .where('id', isEqualTo: id)
        .get();
  }

  static pullTixTiersByTixId(String tixId) {
    return FirebaseFirestore.instance
        .collection(TIX_TIERS)
        .where('tixId', isEqualTo: tixId)
        .get();
  }

  static getTixTiers(String tixId) {
    return FirebaseFirestore.instance
        .collection(TIX_TIERS)
        .where('tixId', isEqualTo: tixId)
        .snapshots();
  }

  static void deleteTixTier(String docId) {
    FirebaseFirestore.instance.collection(TIX_TIERS).doc(docId).delete();
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
      Logx.em(_TAG, e.toString());
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullUser(String userId) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('id', isEqualTo: userId)
        .get();
  }

  static pullUserByPhoneNumber(int phone) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('phoneNumber', isEqualTo: phone)
        .get();
  }

  static pullUserByUsername(String username) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('username', isEqualTo: username)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> pullUsersByLevel(
      int level) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('clearanceLevel', isEqualTo: level)
        .get();
  }

  static Future<QuerySnapshot<Object?>> pullUsersGreaterThanLevel(
      int clearanceLevel) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('clearanceLevel', isGreaterThanOrEqualTo: clearanceLevel)
        .get();
  }

  static Future<QuerySnapshot<Object?>> pullUsersLesserThanLevel(
      int clearanceLevel) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('clearanceLevel', isLessThanOrEqualTo: clearanceLevel)
        .orderBy('name', descending: false)
        .get();
  }

  static pullUsersByIds(List<String> userIds) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('id', whereIn: userIds)
        .get();
  }

  static pullUsersApp() {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('isAppUser', isEqualTo: true)
        .orderBy('name', descending: false)
        .get();
  }

  static Future<QuerySnapshot<Object?>> pullUsersSortedName() {
    return FirebaseFirestore.instance
        .collection(USERS)
        .orderBy('name', descending: false)
        .get();
  }

  static Stream<QuerySnapshot<Object?>> getUsersLessThanLevel(
      int clearanceLevel) {
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

  static getUsersByLevelAndMode(int level, bool isAppUser) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('clearanceLevel', isEqualTo: level)
        .where('isAppUser', isEqualTo: isAppUser)
        .orderBy('lastSeenAt', descending: true)
        .snapshots();
  }

  static getUsersByLevelAndGenderAndMode(
      int level, String gender, bool isAppUser) {
    return FirebaseFirestore.instance
        .collection(USERS)
        .where('clearanceLevel', isEqualTo: level)
        .where('gender', isEqualTo: gender)
        .where('isAppUser', isEqualTo: isAppUser)
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
        Logx.em(_TAG, e.toString());
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
      Logx.em(_TAG, e.toString());
    }
  }

  static void updateUserFcmToken(String userId, String? token) async {
    try {
      await FirebaseFirestore.instance.collection(USERS).doc(userId).update({
        'fcmToken': token,
      }).then((value) {
        Logx.i(_TAG, "$userId user fcm token updated to : ${token!}");
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to update user fcm token', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static void updateUserBlocId(String userId, String blocServiceId) async {
    try {
      await FirebaseFirestore.instance.collection(USERS).doc(userId).update({
        'blocServiceId': blocServiceId,
      }).then((value) {
        Logx.i(_TAG, '$userId user bloc service id updated to : $blocServiceId');
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to update user bloc service id', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static void updateUserLastReviewTime() async {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;

    try {
      await FirebaseFirestore.instance.collection(USERS).doc(UserPreferences.myUser.id).update({
        'lastReviewTime': timeNow,
      }).then((value) {
        Logx.i(_TAG, "user last review time updated}");
      }).catchError((e, s) {
        Logx.ex(_TAG, 'failed to update last review time', e, s);
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static void deleteUser(String docId) {
    FirebaseFirestore.instance.collection(USERS).doc(docId).delete();
  }

  /** user level **/
  static pullUserLevels(int clearanceLevel) {
    return FirebaseFirestore.instance
        .collection(USER_LEVELS)
        .where('level', isLessThan: clearanceLevel)
        .orderBy('level', descending: false)
        .get();
  }

  /** user bloc **/
  static pushUserBloc(UserBloc userBloc) async {
    try {
      await FirebaseFirestore.instance
          .collection(USER_BLOCS)
          .doc(userBloc.id)
          .set(userBloc.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static Future<QuerySnapshot<Object?>> pullUserBlocs(String userId) {
    return FirebaseFirestore.instance
        .collection(USER_BLOCS)
        .where('userId', isEqualTo: userId)
        .get();
  }

  static pullUserBloc(String userId, String blocServiceId) {
    return FirebaseFirestore.instance
        .collection(USER_BLOCS)
        .where('userId', isEqualTo: userId)
        .where('blocServiceId', isEqualTo: blocServiceId)
        .get();
  }

  static void deleteUserBloc(String docId) {
    FirebaseFirestore.instance.collection(USER_BLOCS).doc(docId).delete();
  }

  /** user lounge **/
  static pushUserLounge(UserLounge userLounge) async {
    try {
      await FirebaseFirestore.instance
          .collection(USER_LOUNGES)
          .doc(userLounge.id)
          .set(userLounge.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static Future<QuerySnapshot<Object?>> pullUserLoungeMembers(String loungeId) {
    return FirebaseFirestore.instance
        .collection(USER_LOUNGES)
        .where('loungeId', isEqualTo: loungeId)
        .get();
  }

  static pullUserLounges(String userId) {
    return FirebaseFirestore.instance
        .collection(USER_LOUNGES)
        .where('userId', isEqualTo: userId)
        .get();
  }

  static pullUserLounge(String userId, String loungeId) {
    return FirebaseFirestore.instance
        .collection(USER_LOUNGES)
        .where('userId', isEqualTo: userId)
        .where('loungeId', isEqualTo: loungeId)
        .get();
  }

  static getUserLoungeMembers(String loungeId) {
    return FirebaseFirestore.instance
        .collection(USER_LOUNGES)
        .where('loungeId', isEqualTo: loungeId)
        .snapshots();
  }

  static void updateUserLoungeLastAccessed(String userLoungeId) async {
    try {
      await FirebaseFirestore.instance
          .collection(USER_LOUNGES)
          .doc(userLoungeId)
          .update({'lastAccessedTime': Timestamp.now().millisecondsSinceEpoch});
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static void updateUserLoungeBanned(String userLoungeId, bool isBanned) async {
    try {
      await FirebaseFirestore.instance
          .collection(USER_LOUNGES)
          .doc(userLoungeId)
          .update({'isBanned': Timestamp.now().millisecondsSinceEpoch});
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static void deleteUserLounge(String docId) {
    FirebaseFirestore.instance.collection(USER_LOUNGES).doc(docId).delete();
  }

  /** user photo **/
  static pushUserPhoto(UserPhoto userPhoto) async {
    try {
      await FirebaseFirestore.instance
          .collection(USER_PHOTOS)
          .doc(userPhoto.id)
          .set(userPhoto.toMap());
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      Logx.em(_TAG, e.toString());
    }
  }

  static pullUserPhoto(String userId, String partyPhotoId) {
    return FirebaseFirestore.instance
        .collection(USER_PHOTOS)
        .where('userId', isEqualTo: userId)
        .where('partyPhotoId', isEqualTo: partyPhotoId)
        .get();
  }

  static pullUserPhotos(String userId) {
    return FirebaseFirestore.instance
        .collection(USER_PHOTOS)
        .where('userId', isEqualTo: userId)
        .get();
  }

  static pullUserPhotosByPartyPhotoId(String partyPhotoId) {
    return FirebaseFirestore.instance
        .collection(USER_PHOTOS)
        .where('partyPhotoId', isEqualTo: partyPhotoId)
        .get();
  }

  static getUserPhotos() {
    return FirebaseFirestore.instance
        .collection(USER_PHOTOS)
        .orderBy('tagTime', descending: true)
        .snapshots();
  }

  static void deleteUserPhoto(String docId) {
    FirebaseFirestore.instance.collection(USER_PHOTOS).doc(docId).delete();
  }


}