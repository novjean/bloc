import 'package:bloc/db/entity/service_table.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../db/entity/bloc.dart';
import '../db/entity/offer.dart';
import '../db/entity/product.dart';
import '../db/entity/seat.dart';
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
        id: 'dummy_seat',
        custId: userId,
        tableId: 'dummy_table');
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
      id: StringUtils.getRandomString(20),
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
    );

    return dummyProduct;
  }

  static getDummyBloc(String cityId) {
    int time = Timestamp.now().millisecondsSinceEpoch;

    Bloc dummyBloc = Bloc(
        id: StringUtils.getRandomString(20),
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
}
