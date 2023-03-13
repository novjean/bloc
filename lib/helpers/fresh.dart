import '../db/entity/party.dart';
import '../db/entity/product.dart';
import '../db/entity/user.dart';
import '../db/shared_preferences/user_preferences.dart';
import 'dummy.dart';
import 'firestore_helper.dart';

class Fresh {
  /** product **/
  static Product freshProductMap(Map<String, dynamic> map, bool shouldUpdate) {
    Product product = Dummy.getDummyProduct('', UserPreferences.myUser.id);

    bool shouldPushProduct = false;
    int intPrice = 0;

    try {
      product = product.copyWith(id: map['id'] as String);
    } catch (err) {
      print('product id not exist');
    }

    try {
      product = product.copyWith(name: map['name'] as String);
    } catch (err) {
      print('product name not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }

    try {
      product = product.copyWith(price: map['price'] as double);
    } on FormatException catch (_) {
      intPrice = map['price'] as int;
      product = product.copyWith(price: intPrice.toDouble());
    } catch (err) {
      print('product price not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }

    try {
      product = product.copyWith(priceHighest: map['priceHighest'] as double);
    } on FormatException catch (_) {
      intPrice = map['priceHighest'] as int;
      product = product.copyWith(priceHighest: intPrice.toDouble());
    } catch (err) {
      print('product priceHighest not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }

    try {
      product = product.copyWith(priceLowest: map['priceLowest'] as double);
    } on FormatException catch (_) {
      intPrice = map['priceLowest'] as int;
      product = product.copyWith(priceLowest: intPrice.toDouble());
    } catch (err) {
      print('product priceLowest not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }

    try {
      product = product.copyWith(priceCommunity: map['priceCommunity'] as double);
    } on FormatException catch (_) {
      intPrice = map['priceCommunity'] as int;
      product = product.copyWith(priceCommunity: intPrice.toDouble());
    } catch (err) {
      print('product priceCommunity not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }

    try {
      product = product.copyWith(type: map['type'] as String);
    } catch (err) {
      print('product type not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(category: map['category'] as String);
    } catch (err) {
      print('product category not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(description: map['description'] as String);
    } catch (err) {
      print('product description not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(serviceId: map['serviceId'] as String);
    } catch (err) {
      print('product serviceId not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (err) {
      print('product imageUrl not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(ownerId: map['ownerId'] as String);
    } catch (err) {
      print('product ownerId not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(createdAt: map['createdAt'] as int);
    } catch (err) {
      print('product createdAt not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(isAvailable: map['isAvailable'] as bool);
    } catch (err) {
      print('product isAvailable not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(priceHighestTime: map['priceHighestTime'] as int);
    } catch (err) {
      print('product priceHighestTime not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(priceLowestTime: map['priceLowestTime'] as int);
    } catch (err) {
      print('product priceLowestTime not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(isOfferRunning: map['isOfferRunning'] as bool);
    } catch (err) {
      print('product isOfferRunning not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(isVeg: map['isVeg'] as bool);
    } catch (err) {
      print('product isVeg not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }

    if (shouldPushProduct && shouldUpdate) {
      print('updating product ' + product.id);
      FirestoreHelper.pushProduct(product);
    }

    return product;
  }

  static Product freshProduct(Product product){
    Product freshProduct = Dummy.getDummyProduct(product.serviceId, product.ownerId);

    try {
      freshProduct = freshProduct.copyWith(name: product.name);
    } catch (err) {
      print('product name not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(type: product.type);
    } catch (err) {
      print('product type not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(category: product.category);
    } catch (err) {
      print('product category not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(description: product.description);
    } catch (err) {
      print('product description not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(price: product.price);
    } catch (err) {
      print('product price not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(serviceId: product.serviceId);
    } catch (err) {
      print('product serviceId not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(imageUrl: product.imageUrl);
    } catch (err) {
      print('product imageUrl not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(ownerId: product.ownerId);
    } catch (err) {
      print('product ownerId not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(createdAt: product.createdAt);
    } catch (err) {
      print('product createdAt not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(isAvailable: product.isAvailable);
    } catch (err) {
      print('product isAvailable not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(priceHighest: product.priceHighest);
    } catch (err) {
      print('product priceHighest not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(priceLowest: product.priceLowest);
    } catch (err) {
      print('product priceLowest not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(priceHighestTime: product.priceHighestTime);
    } catch (err) {
      print('product priceHighestTime not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(priceLowestTime: product.priceLowestTime);
    } catch (err) {
      print('product priceLowestTime not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(priceCommunity: product.priceCommunity);
    } catch (err) {
      print('product priceCommunity not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(isOfferRunning: product.isOfferRunning);
    } catch (err) {
      print('product isOfferRunning not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(isVeg: product.isVeg);
    } catch (err) {
      print('product isVeg not exist for product id: ' + product.id);
    }

    return freshProduct;
  }

  /** party **/
  static Party freshPartyMap(Map<String, dynamic> map, bool shouldUpdate) {
    Party party = Dummy.getDummyParty(UserPreferences.myUser.blocServiceId);
    bool shouldPushParty = false;

    try {
      party = party.copyWith(id: map['id'] as String);
    } catch (err) {
      print('party id not exist');
    }
    try {
      party = party.copyWith(name: map['name'] as String);
    } catch (err) {
      print('party name not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(description: map['description'] as String);
    } catch (err) {
      print('party description not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(blocServiceId: map['blocServiceId'] as String);
    } catch (err) {
      print('blocServiceId name not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (err) {
      print('party imageUrl not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(instagramUrl: map['instagramUrl'] as String);
    } catch (err) {
      print('party instagramUrl not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(ticketUrl: map['ticketUrl'] as String);
    } catch (err) {
      print('party ticketUrl not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(listenUrl: map['listenUrl'] as String);
    } catch (err) {
      print('party listenUrl not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(createdAt: map['createdAt'] as int);
    } catch (err) {
      print('party createdAt not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(startTime: map['startTime'] as int);
    } catch (err) {
      print('party startTime not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(endTime: map['endTime'] as int);
    } catch (err) {
      print('party endTime not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(ownerId: map['ownerId'] as String);
    } catch (err) {
      print('party ownerId not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(isTBA: map['isTBA'] as bool);
    } catch (err) {
      print('party isTBA not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(isActive: map['isActive'] as bool);
    } catch (err) {
      print('party isActive not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(eventName: map['eventName'] as String);
    } catch (err) {
      print('party eventName not exist for party id: ' + party.id);
      shouldPushParty = true;
    }

    if (shouldPushParty && shouldUpdate) {
      print('updating party ' + party.id);
      FirestoreHelper.pushParty(party);
    }

    return party;
  }

  static Party freshParty(Party party) {
    String blocId;

    if (party.blocServiceId.isNotEmpty) {
      blocId = party.blocServiceId;
    } else {
      blocId = UserPreferences.myUser.blocServiceId;
    }

    Party freshParty = Dummy.getDummyParty(blocId);
    try {
      freshParty = freshParty.copyWith(id: party.id);
    } catch (err) {
      print('party name not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(name: party.name);
    } catch (err) {
      print('party name not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(description: party.description);
    } catch (err) {
      print('party description not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(blocServiceId: party.blocServiceId);
    } catch (err) {
      print('party blocServiceId not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(imageUrl: party.imageUrl);
    } catch (err) {
      print('party imageUrl not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(instagramUrl: party.instagramUrl);
    } catch (err) {
      print('party instagramUrl not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(ticketUrl: party.ticketUrl);
    } catch (err) {
      print('party ticketUrl not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(listenUrl: party.listenUrl);
    } catch (err) {
      print('party listenUrl not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(createdAt: party.createdAt);
    } catch (err) {
      print('party createdAt not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(startTime: party.startTime);
    } catch (err) {
      print('party startTime not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(endTime: party.endTime);
    } catch (err) {
      print('party endTime not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(ownerId: party.ownerId);
    } catch (err) {
      print('party ownerId not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(isTBA: party.isTBA);
    } catch (err) {
      print('party isTBA not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(isActive: party.isActive);
    } catch (err) {
      print('party isActive not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(eventName: party.eventName);
    } catch (err) {
      print('party eventName not exist for party id: ' + party.id);
    }

    return freshParty;
  }

  /** user **/
  static User freshUserMap(Map<String, dynamic> map, bool shouldUpdate) {
    User user = Dummy.getDummyUser();
    bool shouldPushUser = false;

    try {
      user = user.copyWith(id: map['id'] as String);
    } catch (err) {
      print('user id not exist');
    }
    try {
      user = user.copyWith(username: map['username'] as String);
    } catch (err) {
      print('user username not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(email: map['email'] as String);
    } catch (err) {
      print('user email not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (err) {
      print('user imageUrl not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(clearanceLevel: map['clearanceLevel'] as int);
    } catch (err) {
      print('user clearanceLevel not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(phoneNumber: map['phoneNumber'] as int);
    } catch (err) {
      print('user phoneNumber not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(name: map['name'] as String);
    } catch (err) {
      print('user name not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(fcmToken: map['fcmToken'] as String);
    } catch (err) {
      print('user fcmToken not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(blocServiceId: map['blocServiceId'] as String);
    } catch (err) {
      print('user blocServiceId not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(createdAt: map['createdAt'] as int);
    } catch (err) {
      print('user createdAt not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(lastSeenAt: map['lastSeenAt'] as int);
    } catch (err) {
      print('user lastSeenAt not exist for user id: ' + user.id);
      shouldPushUser = true;
    }

    if (shouldPushUser && shouldUpdate) {
      print('updating user ' + user.id);
      FirestoreHelper.pushUser(user);
    }

    return user;
  }

  static User freshUser(User user) {
    User freshUser = Dummy.getDummyUser();

    try {
      freshUser = freshUser.copyWith(id: user.id);
    } catch (err) {
      print('user id not exist');
    }
    try {
      freshUser = freshUser.copyWith(username: user.username);
    } catch (err) {
      print('user username not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(email: user.email);
    } catch (err) {
      print('user email not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(imageUrl: user.imageUrl);
    } catch (err) {
      print('user imageUrl not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(clearanceLevel: user.clearanceLevel);
    } catch (err) {
      print('user clearanceLevel not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(phoneNumber: user.phoneNumber);
    } catch (err) {
      print('user phoneNumber not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(name: user.name);
    } catch (err) {
      print('name not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(fcmToken: user.fcmToken);
    } catch (err) {
      print('user fcmToken not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(blocServiceId: user.blocServiceId);
    } catch (err) {
      print('user blocServiceId not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(createdAt: user.createdAt);
    } catch (err) {
      print('user createdAt not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(lastSeenAt: user.lastSeenAt);
    } catch (err) {
      print('user lastSeenAt not exist for user id: ' + user.id);
    }

    return freshUser;
  }
}
