import 'package:bloc/db/entity/service_table.dart';

import '../db/entity/offer.dart';
import '../db/entity/seat.dart';
import 'firestore_helper.dart';

class Dummy {
  static Offer getDummyOffer(){
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
        productName: ''
    );
    return productOffer;
  }

  static ServiceTable getDummyTable(String blocServiceId){
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

  static Seat getDummySeat(String blocServiceId, String userId){
    Seat dummySeat = Seat(
        tableNumber: -1,
        serviceId: blocServiceId,
        id: 'dummy_seat',
        custId: userId,
        tableId: 'dummy_table');
    return dummySeat;
  }
}