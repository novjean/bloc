import 'package:bloc/db/entity/party_guest.dart';

import '../db/entity/category.dart';
import '../db/entity/party.dart';
import '../db/entity/product.dart';
import '../db/entity/user.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../utils/constants.dart';
import '../utils/logx.dart';
import 'dummy.dart';
import 'firestore_helper.dart';

class Fresh {
  static const String _TAG = 'Fresh';

  /** category **/
  static Category freshCategoryMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    Category category = Dummy.getDummyCategory('');

    bool shouldPush = false;

    try {
      category = category.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'category id not exist');
    }
    try {
      category = category.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'category name not exist for category id: ' + category.id);
      shouldPush = true;
    }
    try {
      category = category.copyWith(type: map['type'] as String);
    } catch (e) {
      Logx.em(_TAG, 'category type not exist for category id: ' + category.id);
      shouldPush = true;
    }
    try {
      category = category.copyWith(serviceId: map['serviceId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'category serviceId not exist for category id: ' + category.id);
      shouldPush = true;
    }
    try {
      category = category.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'category imageUrl not exist for category id: ' + category.id);
      shouldPush = true;
    }
    try {
      category = category.copyWith(ownerId: map['ownerId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'category ownerId not exist for category id: ' + category.id);
      shouldPush = true;
    }
    try {
      category = category.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'category createdAt not exist for category id: ' + category.id);
      shouldPush = true;
    }
    try {
      category = category.copyWith(sequence: map['sequence'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'category sequence not exist for category id: ' + category.id);
      shouldPush = true;
    }
    try {
      category = category.copyWith(description: map['description'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'category description not exist for category id: ' + category.id);
      shouldPush = true;
    }
    try {
      category = category.copyWith(blocIds: List<String>.from(map['blocIds']));
    } catch (e) {
      Logx.em(
          _TAG, 'category blocIds not exist for category id: ' + category.id);
      List<String> existingBlocIds = [category.serviceId];
      category = category.copyWith(blocIds: existingBlocIds);
      shouldPush = true;
    }

    if (shouldPush &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.em(_TAG, 'updating category ' + category.id);
      FirestoreHelper.pushCategory(category);
    }

    return category;
  }

  static Category freshCategory(Category category) {
    Category freshCategory = Dummy.getDummyCategory('');

    try {
      freshCategory = freshCategory.copyWith(id: category.id);
    } catch (e) {
      Logx.em(_TAG, 'category id not exist');
    }
    try {
      freshCategory = freshCategory.copyWith(name: category.name);
    } catch (e) {
      Logx.em(_TAG, 'category name not exist for category id: ' + category.id);
    }
    try {
      freshCategory = freshCategory.copyWith(type: category.type);
    } catch (e) {
      Logx.em(_TAG, 'category type not exist for category id: ' + category.id);
    }
    try {
      freshCategory = freshCategory.copyWith(serviceId: category.serviceId);
    } catch (e) {
      Logx.em(
          _TAG, 'category serviceId not exist for category id: ' + category.id);
    }
    try {
      freshCategory = freshCategory.copyWith(imageUrl: category.imageUrl);
    } catch (e) {
      Logx.em(
          _TAG, 'category imageUrl not exist for category id: ' + category.id);
    }
    try {
      freshCategory = freshCategory.copyWith(ownerId: category.ownerId);
    } catch (e) {
      Logx.em(
          _TAG, 'category ownerId not exist for category id: ' + category.id);
    }
    try {
      freshCategory = freshCategory.copyWith(createdAt: category.createdAt);
    } catch (e) {
      Logx.em(
          _TAG, 'category createdAt not exist for category id: ' + category.id);
    }
    try {
      freshCategory = freshCategory.copyWith(sequence: category.sequence);
    } catch (e) {
      Logx.em(
          _TAG, 'category sequence not exist for category id: ' + category.id);
    }
    try {
      freshCategory = freshCategory.copyWith(description: category.description);
    } catch (e) {
      Logx.em(_TAG,
          'category description not exist for category id: ' + category.id);
    }
    try {
      freshCategory = freshCategory.copyWith(blocIds: category.blocIds);
    } catch (e) {
      Logx.em(
          _TAG, 'category blocIds not exist for category id: ' + category.id);
    }

    return freshCategory;
  }

  /** party **/
  static Party freshPartyMap(Map<String, dynamic> map, bool shouldUpdate) {
    Party party = Dummy.getDummyParty(UserPreferences.myUser.blocServiceId);
    bool shouldPushParty = false;

    try {
      party = party.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party id not exist');
    }
    try {
      party = party.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party name not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(description: map['description'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party description not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(blocServiceId: map['blocServiceId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'blocServiceId name not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party imageUrl not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(instagramUrl: map['instagramUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party instagramUrl not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(ticketUrl: map['ticketUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party ticketUrl not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(listenUrl: map['listenUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party listenUrl not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'party createdAt not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(startTime: map['startTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'party startTime not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(endTime: map['endTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'party endTime not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(ownerId: map['ownerId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party ownerId not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(isTBA: map['isTBA'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'party isTBA not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(isActive: map['isActive'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'party isActive not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(eventName: map['eventName'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party eventName not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party =
          party.copyWith(isGuestListActive: map['isGuestListActive'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'party isGuestListActive not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(guestListCount: map['guestListCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'party guestListCount not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(guestListEndTime: map['guestListEndTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'party guestListEndTime not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(isEmailRequired: map['isEmailRequired'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'party isEmailRequired not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(clubRules: map['clubRules'] as String);
      if (party.clubRules.isEmpty) {
        party = party.copyWith(clubRules: Constants.clubRules);
        shouldPushParty = true;
      }
    } catch (e) {
      Logx.em(_TAG, 'party clubRules not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(guestListRules: map['guestListRules'] as String);
      if (party.guestListRules.isEmpty) {
        party = party.copyWith(guestListRules: Constants.guestListRules);
        shouldPushParty = true;
      }
    } catch (e) {
      Logx.em(_TAG, 'party guestListRules not exist for party id: ' + party.id);
      shouldPushParty = true;
    }

    if (shouldPushParty &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.em(_TAG, 'updating party ' + party.id);
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
    } catch (e) {
      Logx.em(_TAG, 'party id not exist');
    }
    try {
      freshParty = freshParty.copyWith(name: party.name);
    } catch (e) {
      Logx.em(_TAG, 'party name not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(description: party.description);
    } catch (e) {
      Logx.em(_TAG, 'party description not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(blocServiceId: party.blocServiceId);
    } catch (e) {
      Logx.em(_TAG, 'party blocServiceId not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(imageUrl: party.imageUrl);
    } catch (e) {
      Logx.em(_TAG, 'party imageUrl not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(instagramUrl: party.instagramUrl);
    } catch (e) {
      Logx.em(_TAG, 'party instagramUrl not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(ticketUrl: party.ticketUrl);
    } catch (e) {
      Logx.em(_TAG, 'party ticketUrl not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(listenUrl: party.listenUrl);
    } catch (e) {
      Logx.em(_TAG, 'party listenUrl not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(createdAt: party.createdAt);
    } catch (e) {
      Logx.em(_TAG, 'party createdAt not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(startTime: party.startTime);
    } catch (e) {
      Logx.em(_TAG, 'party startTime not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(endTime: party.endTime);
    } catch (e) {
      Logx.em(_TAG, 'party endTime not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(ownerId: party.ownerId);
    } catch (e) {
      Logx.em(_TAG, 'party ownerId not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(isTBA: party.isTBA);
    } catch (e) {
      Logx.em(_TAG, 'party isTBA not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(isActive: party.isActive);
    } catch (e) {
      Logx.em(_TAG, 'party isActive not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(eventName: party.eventName);
    } catch (e) {
      Logx.em(_TAG, 'party eventName not exist for party id: ' + party.id);
    }
    try {
      freshParty =
          freshParty.copyWith(isGuestListActive: party.isGuestListActive);
    } catch (e) {
      Logx.em(
          _TAG, 'party isGuestListActive not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(guestListCount: party.guestListCount);
    } catch (e) {
      Logx.em(_TAG, 'party guestListCount not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(guestListEndTime: party.guestListEndTime);
    } catch (e) {
      Logx.em(_TAG, 'party guestListEndTime not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(isEmailRequired: party.isEmailRequired);
    } catch (e) {
      Logx.em(
          _TAG, 'party isEmailRequired not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(clubRules: party.clubRules);
    } catch (e) {
      Logx.em(_TAG, 'party clubRules not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(guestListRules: party.guestListRules);
    } catch (e) {
      Logx.em(_TAG, 'party guestListRules not exist for party id: ' + party.id);
    }

    return freshParty;
  }

  static PartyGuest freshPartyGuest(PartyGuest partyGuest) {
    PartyGuest freshGuest = Dummy.getDummyPartyGuest();

    try {
      freshGuest = freshGuest.copyWith(id: partyGuest.id);
    } catch (e) {
      Logx.em(_TAG, 'party guest id not exist');
    }
    try {
      freshGuest = freshGuest.copyWith(name: partyGuest.name);
    } catch (e) {
      Logx.em(_TAG,
          'party guest name not exist for party guest id: ' + partyGuest.id);
    }
    try {
      freshGuest = freshGuest.copyWith(partyId: partyGuest.partyId);
    } catch (e) {
      Logx.em(_TAG,
          'party guest partyId not exist for party guest id: ' + partyGuest.id);
    }
    try {
      freshGuest = freshGuest.copyWith(guestId: partyGuest.guestId);
    } catch (e) {
      Logx.em(_TAG,
          'party guest guestId not exist for party guest id: ' + partyGuest.id);
    }
    try {
      freshGuest = freshGuest.copyWith(phone: partyGuest.phone);
    } catch (e) {
      Logx.em(_TAG,
          'party guest phone not exist for party guest id: ' + partyGuest.id);
    }
    try {
      freshGuest = freshGuest.copyWith(email: partyGuest.email);
    } catch (e) {
      Logx.em(_TAG,
          'party guest email not exist for party guest id: ' + partyGuest.id);
    }
    try {
      freshGuest = freshGuest.copyWith(guestsCount: partyGuest.guestsCount);
    } catch (e) {
      Logx.em(
          _TAG,
          'party guest guestsCount not exist for party guest id: ' +
              partyGuest.id);
    }
    try {
      freshGuest =
          freshGuest.copyWith(guestsRemaining: partyGuest.guestsRemaining);
    } catch (e) {
      Logx.em(
          _TAG,
          'party guest guestsRemaining not exist for party guest id: ' +
              partyGuest.id);
    }
    try {
      freshGuest = freshGuest.copyWith(createdAt: partyGuest.createdAt);
    } catch (e) {
      Logx.em(
          _TAG,
          'party guest createdAt not exist for party guest id: ' +
              partyGuest.id);
    }
    try {
      freshGuest = freshGuest.copyWith(isApproved: partyGuest.isApproved);
    } catch (e) {
      Logx.em(
          _TAG,
          'party guest isApproved not exist for party guest id: ' +
              partyGuest.id);
    }

    try {
      freshGuest = freshGuest.copyWith(guestStatus: partyGuest.guestStatus);
    } catch (e) {
      Logx.em(
          _TAG,
          'party guest guestStatus not exist for party guest id: ' +
              partyGuest.id);
    }

    return freshGuest;
  }

  static PartyGuest freshPartyGuestMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    PartyGuest partyGuest = Dummy.getDummyPartyGuest();
    bool shouldPush = false;

    try {
      partyGuest = partyGuest.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest id not exist');
    }
    try {
      partyGuest = partyGuest.copyWith(partyId: map['partyId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'partyGuest partyId not exist for user id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(guestId: map['guestId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'partyGuest guestId not exist for user id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest name not exist for user id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(phone: map['phone'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest phone not exist for user id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(email: map['email'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest email not exist for user id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(guestsCount: map['guestsCount'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'partyGuest guestsCount not exist for user id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest =
          partyGuest.copyWith(guestsRemaining: map['guestsRemaining'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'partyGuest guestsRemaining not exist for user id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'partyGuest createdAt not exist for user id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(isApproved: map['isApproved'] as bool);
    } catch (e) {
      Logx.em(_TAG,
          'partyGuest isApproved not exist for user id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest =
          partyGuest.copyWith(guestStatus: map['guestStatus'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'partyGuest guestStatus not exist for user id: ' + partyGuest.id);
      shouldPush = true;
    }

    if (shouldPush &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.em(_TAG, 'updating party guest ' + partyGuest.id);
      FirestoreHelper.pushPartyGuest(partyGuest);
    }

    return partyGuest;
  }

  /** product **/
  static Product freshProductMap(Map<String, dynamic> map, bool shouldUpdate) {
    Product product = Dummy.getDummyProduct('', UserPreferences.myUser.id);

    bool shouldPushProduct = false;
    int intPrice = 0;

    try {
      product = product.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product id not exist');
    }
    try {
      product = product.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product name not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(price: map['price'] as double);
    } catch (e) {
      intPrice = map['price'] as int;
      product = product.copyWith(price: intPrice.toDouble());
      if (intPrice == 0) {
        Logx.i(_TAG, 'product price not exist for product id: ' + product.id);
        shouldPushProduct = true;
      }
    }
    try {
      product = product.copyWith(priceHighest: map['priceHighest'] as double);
    } catch (e) {
      intPrice = map['priceHighest'] as int;
      product = product.copyWith(priceHighest: intPrice.toDouble());
      Logx.em(
          _TAG, 'product priceHighest not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(priceLowest: map['priceLowest'] as double);
    } catch (e) {
      intPrice = map['priceLowest'] as int;
      product = product.copyWith(priceLowest: intPrice.toDouble());
      Logx.em(
          _TAG, 'product priceLowest not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product =
          product.copyWith(priceCommunity: map['priceCommunity'] as double);
    } catch (e) {
      intPrice = map['priceCommunity'] as int;
      product = product.copyWith(priceCommunity: intPrice.toDouble());
      Logx.em(_TAG,
          'product priceCommunity not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(type: map['type'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product type not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(category: map['category'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product category not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(description: map['description'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'product description not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(serviceId: map['serviceId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'product serviceId not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product imageUrl not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(ownerId: map['ownerId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product ownerId not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'product createdAt not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(isAvailable: map['isAvailable'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'product isAvailable not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product =
          product.copyWith(priceHighestTime: map['priceHighestTime'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'product priceHighestTime not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product =
          product.copyWith(priceLowestTime: map['priceLowestTime'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'product priceLowestTime not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(isOfferRunning: map['isOffeunning'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'product isOffeunning not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(isVeg: map['isVeg'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'product isVeg not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(blocIds: List<String>.from(map['blocIds']));
    } catch (e) {
      Logx.em(_TAG, 'product blocIds not exist for product id: ' + product.id);
      List<String> existingBlocIds = [product.serviceId];
      product = product.copyWith(blocIds: existingBlocIds);
      shouldPushProduct = true;
    }
    try {
      product = product.copyWith(priceBottle: map['priceBottle'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'product priceBottle not exist for product id: ' + product.id);
      shouldPushProduct = true;
    }

    if (shouldPushProduct &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.em(_TAG, 'updating product ' + product.id);
      FirestoreHelper.pushProduct(product);
    }

    return product;
  }

  static Product freshProduct(Product product) {
    Product freshProduct =
        Dummy.getDummyProduct(product.serviceId, product.ownerId);

    try {
      freshProduct = freshProduct.copyWith(id: product.id);
    } catch (e) {
      Logx.em(_TAG, 'product id not exist');
    }
    try {
      freshProduct = freshProduct.copyWith(name: product.name);
    } catch (e) {
      Logx.em(_TAG, 'product name not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(type: product.type);
    } catch (e) {
      Logx.em(_TAG, 'product type not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(category: product.category);
    } catch (e) {
      Logx.em(_TAG, 'product category not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(description: product.description);
    } catch (e) {
      Logx.em(
          _TAG, 'product description not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(price: product.price);
    } catch (e) {
      Logx.em(_TAG, 'product price not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(serviceId: product.serviceId);
    } catch (e) {
      Logx.em(
          _TAG, 'product serviceId not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(imageUrl: product.imageUrl);
    } catch (e) {
      Logx.em(_TAG, 'product imageUrl not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(ownerId: product.ownerId);
    } catch (e) {
      Logx.em(_TAG, 'product ownerId not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(createdAt: product.createdAt);
    } catch (e) {
      Logx.em(
          _TAG, 'product createdAt not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(isAvailable: product.isAvailable);
    } catch (e) {
      Logx.em(
          _TAG, 'product isAvailable not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(priceHighest: product.priceHighest);
    } catch (e) {
      Logx.em(
          _TAG, 'product priceHighest not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(priceLowest: product.priceLowest);
    } catch (e) {
      Logx.em(
          _TAG, 'product priceLowest not exist for product id: ' + product.id);
    }
    try {
      freshProduct =
          freshProduct.copyWith(priceHighestTime: product.priceHighestTime);
    } catch (e) {
      Logx.em(_TAG,
          'product priceHighestTime not exist for product id: ' + product.id);
    }
    try {
      freshProduct =
          freshProduct.copyWith(priceLowestTime: product.priceLowestTime);
    } catch (e) {
      Logx.em(_TAG,
          'product priceLowestTime not exist for product id: ' + product.id);
    }
    try {
      freshProduct =
          freshProduct.copyWith(priceCommunity: product.priceCommunity);
    } catch (e) {
      Logx.em(_TAG,
          'product priceCommunity not exist for product id: ' + product.id);
    }
    try {
      freshProduct =
          freshProduct.copyWith(isOfferRunning: product.isOfferRunning);
    } catch (e) {
      Logx.em(
          _TAG, 'product isOffeunning not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(isVeg: product.isVeg);
    } catch (e) {
      Logx.em(_TAG, 'product isVeg not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(blocIds: product.blocIds);
    } catch (e) {
      Logx.em(_TAG, 'product blocIds not exist for product id: ' + product.id);
    }
    try {
      freshProduct = freshProduct.copyWith(priceBottle: product.priceBottle);
    } catch (e) {
      Logx.em(
          _TAG, 'product priceBottle not exist for product id: ' + product.id);
    }

    return freshProduct;
  }

  /** user **/
  static User freshUserMap(Map<String, dynamic> map, bool shouldUpdate) {
    User user = Dummy.getDummyUser();
    bool shouldPushUser = false;

    try {
      user = user.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user id not exist');
    }
    try {
      user = user.copyWith(username: map['username'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user username not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(email: map['email'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user email not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user imageUrl not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(clearanceLevel: map['clearanceLevel'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user clearanceLevel not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(phoneNumber: map['phoneNumber'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user phoneNumber not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user name not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(fcmToken: map['fcmToken'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user fcmToken not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(blocServiceId: map['blocServiceId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user blocServiceId not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user createdAt not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(lastSeenAt: map['lastSeenAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user lastSeenAt not exist for user id: ' + user.id);
      shouldPushUser = true;
    }

    if (shouldPushUser &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.em(_TAG, 'updating user ' + user.id);
      FirestoreHelper.pushUser(user);
    }

    return user;
  }

  static User freshUser(User user) {
    User freshUser = Dummy.getDummyUser();

    try {
      freshUser = freshUser.copyWith(id: user.id);
    } catch (e) {
      Logx.em(_TAG, 'user id not exist');
    }
    try {
      freshUser = freshUser.copyWith(username: user.username);
    } catch (e) {
      Logx.em(_TAG, 'user username not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(email: user.email);
    } catch (e) {
      Logx.em(_TAG, 'user email not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(imageUrl: user.imageUrl);
    } catch (e) {
      Logx.em(_TAG, 'user imageUrl not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(clearanceLevel: user.clearanceLevel);
    } catch (e) {
      Logx.em(_TAG, 'user clearanceLevel not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(phoneNumber: user.phoneNumber);
    } catch (e) {
      Logx.em(_TAG, 'user phoneNumber not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(name: user.name);
    } catch (e) {
      Logx.em(_TAG, 'name not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(fcmToken: user.fcmToken);
    } catch (e) {
      Logx.em(_TAG, 'user fcmToken not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(blocServiceId: user.blocServiceId);
    } catch (e) {
      Logx.em(_TAG, 'user blocServiceId not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(createdAt: user.createdAt);
    } catch (e) {
      Logx.em(_TAG, 'user createdAt not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(lastSeenAt: user.lastSeenAt);
    } catch (e) {
      Logx.em(_TAG, 'user lastSeenAt not exist for user id: ' + user.id);
    }

    return freshUser;
  }
}
