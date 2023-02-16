import 'package:bloc/db/entity/category.dart';
import 'package:bloc/db/entity/guest_wifi.dart';
import 'package:bloc/db/entity/service_table.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../db/entity/bloc.dart';
import '../db/entity/bloc_service.dart';
import '../db/entity/offer.dart';
import '../db/entity/party.dart';
import '../db/entity/product.dart';
import '../db/entity/seat.dart';
import '../db/entity/user.dart';
import '../db/shared_preferences/user_preferences.dart';
import 'firestore_helper.dart';

class Dummy {
  static Offer getDummyOffer() {
    Offer productOffer = new Offer(
        blocServiceId: '',
        creationTime: 0,
        description: '',
        endTime: 0,
        id: '',
        isActive: false,
        isCommunityOffer: false,
        isPrivateOffer: false,
        offerPercent: 0,
        offerPriceCommunity: 0,
        offerPricePrivate: 0,
        productId: '',
        productName: '');
    return productOffer;
  }

  static ServiceTable getDummyTable(String blocServiceId) {
    ServiceTable dummyTable = ServiceTable(
        id: 'dummy_table',
        captainId: '',
        capacity: 0,
        isActive: false,
        isOccupied: false,
        serviceId: blocServiceId,
        tableNumber: -1,
        type: FirestoreHelper.TABLE_PRIVATE_TYPE_ID);
    return dummyTable;
  }

  static Seat getDummySeat(String blocServiceId, String userId) {
    Seat dummySeat = Seat(
        tableNumber: -1,
        serviceId: blocServiceId,
        id: StringUtils.getRandomString(28),
        custId: userId,
        tableId: '');
    return dummySeat;
  }

  static getDummyProduct(String blocServiceId, String userId) {
    int time = Timestamp.now().millisecondsSinceEpoch;

    Product dummyProduct = Product(
        serviceId: blocServiceId,
        ownerId: userId,
        name: '',
        imageUrl: '',
        createdAt: time,
        id: StringUtils.getRandomString(28),
        description: '',
        category: 'Beer',
        isAvailable: false,
        isOfferRunning: false,
        price: 0,
        priceCommunity: 0,
        priceHighest: 0,
        priceHighestTime: time,
        priceLowestTime: time,
        type: 'Alcohol',
        priceLowest: 0,
        isVeg: true);

    return dummyProduct;
  }

  static getDummyBloc(String cityId) {
    int time = Timestamp.now().millisecondsSinceEpoch;

    Bloc dummyBloc = Bloc(
        id: StringUtils.getRandomString(28),
        createdAt: time.toString(),
        imageUrl: '',
        name: '',
        ownerId: UserPreferences.myUser.id,
        addressLine1: '',
        addressLine2: '',
        cityId: cityId,
        isActive: false,
        pinCode: '');

    return dummyBloc;
  }

  static getDummyBlocService(String blocId) {
    BlocService dummyBlocService = BlocService(
      ownerId: UserPreferences.myUser.id,
      name: '',
      imageUrl: '',
      createdAt: Timestamp.now().millisecondsSinceEpoch.toString(),
      type: '',
      id: StringUtils.getRandomString(28),
      blocId: blocId,
      emailId: '',
      primaryPhone: 0,
      secondaryPhone: 0,
    );

    return dummyBlocService;
  }

  static getDummyParty(String blocId) {
    Party dummyParty = Party(
        id: StringUtils.getRandomString(28),
        createdAt: Timestamp.now().millisecondsSinceEpoch,
        imageUrl: '',
        name: '',
        ownerId: UserPreferences.myUser.id,
        isActive: false,
        isTBA: true,
        description: '',
        blocServiceId: '',
        endTime: 0,
        instagramUrl: '',
        startTime: 0,
        ticketUrl: '',
        listenUrl: '');

    return dummyParty;
  }

  static getDummyUser() {
    User dummyUser = User(
        blocServiceId: '',
        clearanceLevel: 1,
        email: '',
        fcmToken: '',
        id: StringUtils.getRandomString(28),
        imageUrl: '',
        name: '',
        phoneNumber: 0,
        username: '');

    return dummyUser;
  }

  static getDummyCategory(String serviceId) {
    Category dummyCategory = Category(
        id: StringUtils.getRandomString(28),
        name: '',
        imageUrl: '',
        createdAt: Timestamp.now().millisecondsSinceEpoch,
        ownerId: UserPreferences.myUser.id,
        sequence: -1,
        serviceId: serviceId,
        type: 'Alcohol');
    return dummyCategory;
  }

  static GuestWifi getDummyWifi(String blocServiceId) {
    GuestWifi dummyWifi = GuestWifi(
        id: StringUtils.getRandomString(28),
        name: '',
        password: '',
        blocServiceId: blocServiceId,
        creationTime: Timestamp.now().millisecondsSinceEpoch);
    return dummyWifi;
  }
}
