import '../db/entity/offer.dart';

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
}