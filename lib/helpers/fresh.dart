import 'package:bloc/db/entity/history_music.dart';
import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/db/entity/ui_photo.dart';

import '../db/entity/ad.dart';
import '../db/entity/bloc.dart';
import '../db/entity/category.dart';
import '../db/entity/celebration.dart';
import '../db/entity/challenge.dart';
import '../db/entity/genre.dart';
import '../db/entity/lounge.dart';
import '../db/entity/party.dart';
import '../db/entity/product.dart';
import '../db/entity/reservation.dart';
import '../db/entity/ticket.dart';
import '../db/entity/user.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../utils/constants.dart';
import '../utils/logx.dart';
import 'dummy.dart';
import 'firestore_helper.dart';

class Fresh {
  static const String _TAG = 'Fresh';

  /** ad **/
  static Ad freshAdMap(Map<String, dynamic> map, bool shouldUpdate) {
    Ad ad = Dummy.getDummyAd('');

    bool shouldPush = true;

    try {
      ad = ad.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ad id not exist');
    }
    try {
      ad = ad.copyWith(title: map['title'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ad title not exist for ad id: ${ad.id}');
      shouldPush = true;
    }
    try {
      ad = ad.copyWith(message: map['message'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ad message not exist for ad id: ${ad.id}');
      shouldPush = true;
    }
    try {
      ad = ad.copyWith(type: map['type'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ad type not exist for ad id: ${ad.id}');
      shouldPush = true;
    }
    try {
      ad = ad.copyWith(blocId: map['blocId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ad blocId not exist for ad id: ${ad.id}');
      shouldPush = true;
    }
    try {
      ad = ad.copyWith(partyId: map['partyId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ad partyId not exist for ad id: ${ad.id}');
      shouldPush = true;
    }
    try {
      ad = ad.copyWith(hits: map['hits'] as int);
    } catch (e) {
      Logx.em(_TAG, 'ad hits not exist for ad id: ${ad.id}');
      shouldPush = true;
    }
    try {
      ad = ad.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'ad createdAt not exist for ad id: ${ad.id}');
      shouldPush = true;
    }
    try {
      ad = ad.copyWith(isActive: map['isActive'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'ad isActive not exist for ad id: ${ad.id}');
      shouldPush = true;
    }

    if (shouldPush &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating ad ${ad.id}');
      FirestoreHelper.pushAd(ad);
    }

    return ad;
  }

  static Ad freshAd(Ad ad) {
    Ad freshAd = Dummy.getDummyAd('');

    try {
      freshAd = freshAd.copyWith(id: ad.id);
    } catch (e) {
      Logx.em(_TAG, 'ad id not exist');
    }
    try {
      freshAd = freshAd.copyWith(title: ad.title);
    } catch (e) {
      Logx.em(_TAG, 'ad title not exist for ad id: ${ad.id}');
    }
    try {
      freshAd = freshAd.copyWith(message: ad.message);
    } catch (e) {
      Logx.em(_TAG, 'ad message not exist for ad id: ${ad.id}');
    }
    try {
      freshAd = freshAd.copyWith(type: ad.type);
    } catch (e) {
      Logx.em(_TAG, 'ad type not exist for ad id: ${ad.id}');
    }
    try {
      freshAd = freshAd.copyWith(blocId: ad.blocId);
    } catch (e) {
      Logx.em(_TAG, 'ad blocId not exist for ad id: ${ad.id}');
    }
    try {
      freshAd = freshAd.copyWith(partyId: ad.partyId);
    } catch (e) {
      Logx.em(_TAG, 'ad partyId not exist for ad id: ' + ad.id);
    }
    try {
      freshAd = freshAd.copyWith(hits: ad.hits);
    } catch (e) {
      Logx.em(_TAG, 'ad hits not exist for ad id: ' + ad.id);
    }
    try {
      freshAd = freshAd.copyWith(createdAt: ad.createdAt);
    } catch (e) {
      Logx.em(_TAG, 'ad createdAt not exist for ad id: ' + ad.id);
    }
    try {
      freshAd = freshAd.copyWith(isActive: ad.isActive);
    } catch (e) {
      Logx.em(_TAG, 'ad isActive not exist for ad id: ' + ad.id);
    }

    return freshAd;
  }

  /** bloc **/
  static Bloc freshBlocMap(Map<String, dynamic> map, bool shouldUpdate) {
    Bloc bloc = Dummy.getDummyBloc('');

    bool shouldPush = true;

    try {
      bloc = bloc.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc id not exist');
    }
    try {
      bloc = bloc.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc name not exist for bloc id: ' + bloc.id);
      shouldPush = true;
    }
    try {
      bloc = bloc.copyWith(cityId: map['cityId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc cityId not exist for bloc id: ' + bloc.id);
      shouldPush = true;
    }
    try {
      bloc = bloc.copyWith(addressLine1: map['addressLine1'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc addressLine1 not exist for bloc id: ' + bloc.id);
      shouldPush = true;
    }
    try {
      bloc = bloc.copyWith(addressLine2: map['addressLine2'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc addressLine2 not exist for bloc id: ' + bloc.id);
      shouldPush = true;
    }
    try {
      bloc = bloc.copyWith(pinCode: map['pinCode'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc pinCode not exist for bloc id: ' + bloc.id);
      shouldPush = true;
    }
    try {
      bloc = bloc.copyWith(ownerId: map['ownerId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc ownerId not exist for bloc id: ' + bloc.id);
      shouldPush = true;
    }
    try {
      bloc = bloc.copyWith(createdAt: map['createdAt'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc createdAt not exist for bloc id: ' + bloc.id);
      shouldPush = true;
    }
    try {
      bloc = bloc.copyWith(isActive: map['isActive'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'bloc isActive not exist for bloc id: ' + bloc.id);
      shouldPush = true;
    }
    try {
      bloc = bloc.copyWith(imageUrls: List<String>.from(map['imageUrls']));
    } catch (e) {
      Logx.em(_TAG, 'bloc imageUrls not exist for bloc id: ' + bloc.id);
      List<String> temp = [];
      bloc = bloc.copyWith(imageUrls: temp);
      shouldPush = true;
    }

    if (shouldPush &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.em(_TAG, 'updating bloc ' + bloc.id);
      FirestoreHelper.pushBloc(bloc);
    }

    return bloc;
  }

  static Bloc freshBloc(Bloc bloc) {
    Bloc freshBloc = Dummy.getDummyBloc('');

    try {
      freshBloc = freshBloc.copyWith(id: bloc.id);
    } catch (e) {
      Logx.em(_TAG, 'bloc id not exist');
    }
    try {
      freshBloc = freshBloc.copyWith(name: bloc.name);
    } catch (e) {
      Logx.em(_TAG, 'bloc name not exist for bloc id: ' + bloc.id);
    }
    try {
      freshBloc = freshBloc.copyWith(cityId: bloc.cityId);
    } catch (e) {
      Logx.em(_TAG, 'bloc cityId not exist for bloc id: ' + bloc.id);
    }
    try {
      freshBloc = freshBloc.copyWith(addressLine1: bloc.addressLine1);
    } catch (e) {
      Logx.em(_TAG, 'bloc addressLine1 not exist for bloc id: ' + bloc.id);
    }
    try {
      freshBloc = freshBloc.copyWith(addressLine2: bloc.addressLine2);
    } catch (e) {
      Logx.em(_TAG, 'bloc addressLine2 not exist for bloc id: ' + bloc.id);
    }
    try {
      freshBloc = freshBloc.copyWith(pinCode: bloc.pinCode);
    } catch (e) {
      Logx.em(_TAG, 'bloc pinCode not exist for bloc id: ' + bloc.id);
    }
    try {
      freshBloc = freshBloc.copyWith(ownerId: bloc.ownerId);
    } catch (e) {
      Logx.em(_TAG, 'bloc ownerId not exist for bloc id: ' + bloc.id);
    }
    try {
      freshBloc = freshBloc.copyWith(createdAt: bloc.createdAt);
    } catch (e) {
      Logx.em(_TAG, 'bloc createdAt not exist for bloc id: ' + bloc.id);
    }
    try {
      freshBloc = freshBloc.copyWith(isActive: bloc.isActive);
    } catch (e) {
      Logx.em(_TAG, 'bloc isActive not exist for bloc id: ' + bloc.id);
    }
    try {
      freshBloc = freshBloc.copyWith(imageUrls: bloc.imageUrls);
    } catch (e) {
      Logx.em(_TAG, 'bloc imageUrls not exist for bloc id: ' + bloc.id);
    }

    return freshBloc;
  }

  /** category **/
  static Category freshCategoryMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    Category category = Dummy.getDummyCategory('');

    bool shouldPush = true;

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
      Logx.i(_TAG, 'updating category ' + category.id);
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

  /** celebration **/
  static Celebration freshCelebrationMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    Celebration celebration =
        Dummy.getDummyCelebration(Constants.blocServiceId);
    bool shouldPush = true;

    try {
      celebration = celebration.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'celebration id not exist');
    }
    try {
      celebration = celebration.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'celebration name not exist for id: ' + celebration.id);
      shouldPush = true;
    }
    try {
      celebration = celebration.copyWith(surname: map['surname'] as String);
    } catch (e) {
      Logx.em(_TAG, 'celebration surname not exist for id: ' + celebration.id);
      shouldPush = true;
    }
    try {
      celebration =
          celebration.copyWith(blocServiceId: map['blocServiceId'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'celebration blocServiceId not exist for id: ' + celebration.id);
      shouldPush = true;
    }
    try {
      celebration =
          celebration.copyWith(customerId: map['customerId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration customerId not exist for id: ' + celebration.id);
      shouldPush = true;
    }
    try {
      celebration = celebration.copyWith(phone: map['phone'] as int);
    } catch (e) {
      Logx.em(_TAG, 'celebration phone not exist for id: ' + celebration.id);
      shouldPush = true;
    }

    try {
      celebration =
          celebration.copyWith(guestsCount: map['guestsCount'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration guestsCount not exist for id: ' + celebration.id);
      shouldPush = true;
    }
    try {
      celebration = celebration.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration createdAt not exist for id: ' + celebration.id);
      shouldPush = true;
    }
    try {
      celebration =
          celebration.copyWith(arrivalDate: map['arrivalDate'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration arrivalDate not exist for id: ' + celebration.id);
      shouldPush = true;
    }
    try {
      celebration =
          celebration.copyWith(arrivalTime: map['arrivalTime'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration arrivalTime not exist for id: ' + celebration.id);
      shouldPush = true;
    }
    try {
      celebration =
          celebration.copyWith(durationHours: map['durationHours'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'celebration durationHours not exist for id: ' + celebration.id);
      shouldPush = true;
    }

    try {
      celebration = celebration.copyWith(
          bottleProductIds: List<String>.from(map['bottleProductIds']));
    } catch (e) {
      Logx.em(_TAG,
          'celebration bottleProductIds not exist for id: ' + celebration.id);
      shouldPush = true;
    }
    try {
      celebration = celebration.copyWith(
          bottleNames: List<String>.from(map['bottleNames']));
    } catch (e) {
      Logx.em(
          _TAG, 'celebration bottleNames not exist for id: ' + celebration.id);
      shouldPush = true;
    }
    try {
      celebration =
          celebration.copyWith(specialRequest: map['specialRequest'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'celebration specialRequest not exist for id: ' + celebration.id);
      shouldPush = true;
    }
    try {
      celebration = celebration.copyWith(occasion: map['occasion'] as String);
    } catch (e) {
      Logx.em(_TAG, 'reservation occasion not exist for id: ' + celebration.id);
      shouldPush = true;
    }
    try {
      celebration = celebration.copyWith(isApproved: map['isApproved'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration isApproved not exist for id: ' + celebration.id);
      shouldPush = true;
    }

    if (shouldPush && shouldUpdate) {
      Logx.i(_TAG, 'updating celebration ' + celebration.id);
      FirestoreHelper.pushCelebration(celebration);
    }

    return celebration;
  }

  static Celebration freshCelebration(Celebration celebration) {
    Celebration fresh = Dummy.getDummyCelebration(Constants.blocServiceId);

    try {
      fresh = fresh.copyWith(id: celebration.id);
    } catch (e) {
      Logx.em(_TAG, 'celebration id not exist');
    }
    try {
      fresh = fresh.copyWith(name: celebration.name);
    } catch (e) {
      Logx.em(_TAG, 'celebration name not exist for id: ' + celebration.id);
    }
    try {
      fresh = fresh.copyWith(surname: celebration.surname);
    } catch (e) {
      Logx.em(_TAG, 'celebration surname not exist for id: ' + celebration.id);
    }
    try {
      fresh = fresh.copyWith(blocServiceId: celebration.blocServiceId);
    } catch (e) {
      Logx.em(_TAG,
          'celebration blocServiceId not exist for id: ' + celebration.id);
    }
    try {
      fresh = fresh.copyWith(customerId: celebration.customerId);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration customerId not exist for id: ' + celebration.id);
    }
    try {
      fresh = fresh.copyWith(phone: celebration.phone);
    } catch (e) {
      Logx.em(_TAG, 'celebration phone not exist for id: ' + celebration.id);
    }

    try {
      fresh = fresh.copyWith(guestsCount: celebration.guestsCount);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration guestsCount not exist for id: ' + celebration.id);
    }
    try {
      fresh = fresh.copyWith(createdAt: celebration.createdAt);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration createdAt not exist for id: ' + celebration.id);
    }
    try {
      fresh = fresh.copyWith(arrivalDate: celebration.arrivalDate);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration arrivalDate not exist for id: ' + celebration.id);
    }
    try {
      fresh = fresh.copyWith(arrivalTime: celebration.arrivalTime);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration arrivalTime not exist for id: ' + celebration.id);
    }
    try {
      fresh = fresh.copyWith(durationHours: celebration.durationHours);
    } catch (e) {
      Logx.em(_TAG,
          'celebration durationHours not exist for id: ' + celebration.id);
    }

    try {
      fresh = fresh.copyWith(bottleProductIds: celebration.bottleProductIds);
    } catch (e) {
      Logx.em(_TAG,
          'celebration bottleProductIds not exist for id: ' + celebration.id);
    }
    try {
      fresh = fresh.copyWith(bottleNames: celebration.bottleNames);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration bottleNames not exist for id: ' + celebration.id);
    }
    try {
      fresh = fresh.copyWith(specialRequest: celebration.specialRequest);
    } catch (e) {
      Logx.em(_TAG,
          'celebration specialRequest not exist for id: ' + celebration.id);
    }
    try {
      fresh = fresh.copyWith(occasion: celebration.occasion);
    } catch (e) {
      Logx.em(_TAG, 'celebration occasion not exist for id: ' + celebration.id);
    }

    try {
      fresh = fresh.copyWith(isApproved: celebration.isApproved);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration isApproved not exist for id: ' + celebration.id);
    }

    return fresh;
  }

  /** challenge **/
  static Challenge freshChallengeMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    Challenge challenge = Dummy.getDummyChallenge();

    bool shouldPush = true;

    try {
      challenge = challenge.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge id not exist');
    }
    try {
      challenge = challenge.copyWith(level: map['level'] as int);
    } catch (e) {
      Logx.em(_TAG, 'challenge level not exist for id: ' + challenge.id);
      shouldPush = true;
    }
    try {
      challenge = challenge.copyWith(title: map['title'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge title not exist for id: ' + challenge.id);
      shouldPush = true;
    }
    try {
      challenge = challenge.copyWith(description: map['description'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge description not exist for id: ' + challenge.id);
      shouldPush = true;
    }
    try {
      challenge = challenge.copyWith(points: map['points'] as int);
    } catch (e) {
      Logx.em(_TAG, 'challenge points not exist for id: ' + challenge.id);
      shouldPush = true;
    }
    try {
      challenge = challenge.copyWith(clickCount: map['clickCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'challenge clickCount not exist for id: ' + challenge.id);
      shouldPush = true;
    }
    try {
      challenge = challenge.copyWith(dialogTitle: map['dialogTitle'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge dialogTitle not exist for id: ' + challenge.id);
      shouldPush = true;
    }
    try {
      challenge = challenge.copyWith(
          dialogAcceptText: map['dialogAcceptText'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'challenge dialogAcceptText not exist for id: ' + challenge.id);
      shouldPush = true;
    }
    try {
      challenge = challenge.copyWith(
          dialogAccept2Text: map['dialogAccept2Text'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'challenge dialogAccept2Text not exist for id: ' + challenge.id);
      shouldPush = true;
    }

    if (shouldPush &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating challenge ' + challenge.id);
      FirestoreHelper.pushChallenge(challenge);
    }

    return challenge;
  }

  static Challenge freshChallenge(Challenge challenge) {
    Challenge freshChallenge = Dummy.getDummyChallenge();

    try {
      freshChallenge = freshChallenge.copyWith(id: challenge.id);
    } catch (e) {
      Logx.em(_TAG, 'challenge id not exist');
    }
    try {
      freshChallenge = freshChallenge.copyWith(level: challenge.level);
    } catch (e) {
      Logx.em(
          _TAG, 'challenge level not exist for challenge id: ' + challenge.id);
    }
    try {
      freshChallenge = freshChallenge.copyWith(title: challenge.title);
    } catch (e) {
      Logx.em(
          _TAG, 'challenge title not exist for challenge id: ' + challenge.id);
    }
    try {
      freshChallenge =
          freshChallenge.copyWith(description: challenge.description);
    } catch (e) {
      Logx.em(_TAG,
          'challenge description not exist for challenge id: ' + challenge.id);
    }
    try {
      freshChallenge = freshChallenge.copyWith(points: challenge.points);
    } catch (e) {
      Logx.em(
          _TAG, 'challenge points not exist for challenge id: ' + challenge.id);
    }
    try {
      freshChallenge =
          freshChallenge.copyWith(clickCount: challenge.clickCount);
    } catch (e) {
      Logx.em(_TAG,
          'challenge clickCount not exist for challenge id: ' + challenge.id);
    }
    try {
      freshChallenge =
          freshChallenge.copyWith(dialogTitle: challenge.dialogTitle);
    } catch (e) {
      Logx.em(_TAG,
          'challenge dialogTitle not exist for challenge id: ' + challenge.id);
    }
    try {
      freshChallenge =
          freshChallenge.copyWith(dialogAcceptText: challenge.dialogAcceptText);
    } catch (e) {
      Logx.em(
          _TAG,
          'challenge dialogAcceptText not exist for challenge id: ' +
              challenge.id);
    }
    try {
      freshChallenge = freshChallenge.copyWith(
          dialogAccept2Text: challenge.dialogAccept2Text);
    } catch (e) {
      Logx.em(
          _TAG,
          'challenge dialogAccept2Text not exist for challenge id: ' +
              challenge.id);
    }

    return freshChallenge;
  }

  /** genre **/
  static Genre freshGenreMap(Map<String, dynamic> map, bool shouldUpdate) {
    Genre genre = Dummy.getDummyGenre();

    bool shouldPush = true;

    try {
      genre = genre.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'genre id not exist');
    }
    try {
      genre = genre.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'genre name not exist for id: ' + genre.id);
      shouldPush = true;
    }

    if (shouldPush &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating genre ' + genre.id);
      FirestoreHelper.pushGenre(genre);
    }

    return genre;
  }

  static Genre freshGenre(Genre genre) {
    Genre freshGenre = Dummy.getDummyGenre();

    try {
      freshGenre = freshGenre.copyWith(id: genre.id);
    } catch (e) {
      Logx.em(_TAG, 'genre id not exist');
    }
    try {
      freshGenre = freshGenre.copyWith(name: genre.name);
    } catch (e) {
      Logx.em(_TAG, 'genre name not exist for id: ' + genre.id);
    }

    return freshGenre;
  }

  /** history music **/
  static HistoryMusic freshHistoryMusicMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    HistoryMusic historyMusic = Dummy.getDummyHistoryMusic();

    bool shouldPush = true;

    try {
      historyMusic = historyMusic.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'historyMusic id not exist');
    }
    try {
      historyMusic = historyMusic.copyWith(userId: map['userId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'historyMusic userId not exist for id: ${historyMusic.id}');
      shouldPush = true;
    }
    try {
      historyMusic = historyMusic.copyWith(genre: map['genre'] as String);
    } catch (e) {
      Logx.em(_TAG, 'historyMusic genre not exist for id: ${historyMusic.id}');
      shouldPush = true;
    }
    try {
      historyMusic = historyMusic.copyWith(count: map['count'] as int);
    } catch (e) {
      Logx.em(_TAG, 'historyMusic count not exist for id: ${historyMusic.id}');
      shouldPush = true;
    }

    if (shouldPush && shouldUpdate) {
      Logx.i(_TAG, 'updating history music ${historyMusic.id}');
      FirestoreHelper.pushHistoryMusic(historyMusic);
    }

    return historyMusic;
  }

  static HistoryMusic freshHistoryMusic(HistoryMusic historyMusic) {
    HistoryMusic fresh = Dummy.getDummyHistoryMusic();

    try {
      fresh = fresh.copyWith(id: historyMusic.id);
    } catch (e) {
      Logx.em(_TAG, 'historyMusic id not exist');
    }
    try {
      fresh = fresh.copyWith(userId: historyMusic.userId);
    } catch (e) {
      Logx.em(_TAG, 'historyMusic userId not exist for id: ${historyMusic.id}');
    }
    try {
      fresh = fresh.copyWith(genre: historyMusic.genre);
    } catch (e) {
      Logx.em(_TAG, 'historyMusic genre not exist for id: ${historyMusic.id}');
    }
    try {
      fresh = fresh.copyWith(count: historyMusic.count);
    } catch (e) {
      Logx.em(_TAG, 'historyMusic count not exist for id: ${historyMusic.id}');
    }

    return fresh;
  }

  /** lounge **/
  static Lounge freshLoungeMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    Lounge lounge = Dummy.getDummyLounge();

    bool shouldPush = true;

    try {
      lounge = lounge.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'lounge id not exist');
    }
    try {
      lounge = lounge.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'lounge name not exist for id: ${lounge.id}');
      shouldPush = true;
    }
    try {
      lounge = lounge.copyWith(type: map['type'] as String);
    } catch (e) {
      Logx.em(_TAG, 'lounge type not exist for id: ${lounge.id}');
      shouldPush = true;
    }

    try {
      lounge = lounge.copyWith(admins: List<String>.from(map['admins']));
    } catch (e) {
      Logx.em(_TAG, 'lounge admins not exist for id: ${lounge.id}');
      shouldPush = true;
    }
    try {
      lounge = lounge.copyWith(members: List<String>.from(map['members']));
    } catch (e) {
      Logx.em(_TAG, 'lounge members not exist for id: ${lounge.id}');
      shouldPush = true;
    }

    try {
      lounge = lounge.copyWith(creationTime: map['creationTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'lounge creationTime not exist for id: ${lounge.id}');
      shouldPush = true;
    }
    try {
      lounge = lounge.copyWith(isActive: map['isActive'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'lounge isActive not exist for id: ${lounge.id}');
      shouldPush = true;
    }


    if (shouldPush && shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating lounge ${lounge.id}');
      FirestoreHelper.pushLounge(lounge);
    }

    return lounge;
  }

  static Lounge freshLounge(Lounge lounge) {
    Lounge fresh = Dummy.getDummyLounge();

    try {
      fresh = fresh.copyWith(id: lounge.id);
    } catch (e) {
      Logx.em(_TAG, 'lounge id not exist');
    }
    try {
      fresh = fresh.copyWith(name: lounge.name);
    } catch (e) {
      Logx.em(_TAG, 'lounge name not exist for id: ${lounge.id}');
    }
    try {
      fresh = fresh.copyWith(type: lounge.type);
    } catch (e) {
      Logx.em(_TAG, 'lounge type not exist for id: ${lounge.id}');
    }
    try {
      fresh = fresh.copyWith(admins: lounge.admins);
    } catch (e) {
      Logx.em(_TAG, 'lounge admins not exist for id: ${lounge.id}');
    }
    try {
      fresh = fresh.copyWith(members: lounge.members);
    } catch (e) {
      Logx.em(_TAG, 'lounge members not exist for id: ${lounge.id}');
    }
    try {
      fresh = fresh.copyWith(creationTime: lounge.creationTime);
    } catch (e) {
      Logx.em(_TAG, 'lounge creationTime not exist for id: ${lounge.id}');
    }
    try {
      fresh = fresh.copyWith(isActive: lounge.isActive);
    } catch (e) {
      Logx.em(_TAG, 'lounge isActive not exist for id: ${lounge.id}');
    }

    return fresh;
  }


  /** party **/
  static Party freshPartyMap(Map<String, dynamic> map, bool shouldUpdate) {
    Party party = Dummy.getDummyParty(UserPreferences.myUser.blocServiceId);
    bool shouldPushParty = true;

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
      party = party.copyWith(eventName: map['eventName'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party eventName not exist for party id: ' + party.id);
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
      Logx.em(_TAG, 'party blocServiceId not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(type: map['type'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party type not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(chapter: map['chapter'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party chapter not exist for party id: ' + party.id);
      shouldPushParty = true;
    }

    try {
      party = party.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party imageUrl not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(storyImageUrl: map['storyImageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party storyImageUrl not exist for party id: ' + party.id);
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
      party = party.copyWith(isBigAct: map['isBigAct'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'party isBigAct not exist for party id: ' + party.id);
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
      party = party.copyWith(isEmailRequired: map['isEmailRequired'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'party isEmailRequired not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(guestListEndTime: map['guestListEndTime'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'party guestListEndTime not exist for party id: ' + party.id);
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
      party = party.copyWith(isTicketed: map['isTicketed'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'party isTicketed not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(ticketsSoldCount: map['ticketsSoldCount'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'party ticketsSoldCount not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party =
          party.copyWith(ticketsSalesTotal: map['ticketsSalesTotal'] as double);
    } catch (e) {
      Logx.em(
          _TAG, 'party ticketsSalesTotal not exist for party id: ' + party.id);
      shouldPushParty = true;
    }

    try {
      party =
          party.copyWith(isChallengeActive: map['isChallengeActive'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'party isChallengeActive not exist for party id: ' + party.id);
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(
          overrideChallengeNum: map['overrideChallengeNum'] as int);
    } catch (e) {
      Logx.em(_TAG, 'party overrideChallengeNum not exist for id: ${party.id}');
      shouldPushParty = true;
    }
    try {
      party = party.copyWith(genre: map['genre'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party genre not exist for party id: ' + party.id);
      shouldPushParty = true;
    }

    try {
      party = party.copyWith(artistIds: List<String>.from(map['artistIds']));
    } catch (e) {
      Logx.em(_TAG, 'party artistIds not exist for id: ' + party.id);
      shouldPushParty = true;
    }

    if (shouldPushParty &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating party ' + party.id);
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
      freshParty = freshParty.copyWith(eventName: party.eventName);
    } catch (e) {
      Logx.em(_TAG, 'party eventName not exist for party id: ' + party.id);
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
      freshParty = freshParty.copyWith(type: party.type);
    } catch (e) {
      Logx.em(_TAG, 'party type not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(chapter: party.chapter);
    } catch (e) {
      Logx.em(_TAG, 'party chapter not exist for party id: ' + party.id);
    }

    try {
      freshParty = freshParty.copyWith(imageUrl: party.imageUrl);
    } catch (e) {
      Logx.em(_TAG, 'party imageUrl not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(storyImageUrl: party.storyImageUrl);
    } catch (e) {
      Logx.em(_TAG, 'party storyImageUrl not exist for party id: ' + party.id);
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
      freshParty = freshParty.copyWith(isBigAct: party.isBigAct);
    } catch (e) {
      Logx.em(_TAG, 'party isBigAct not exist for party id: ' + party.id);
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
      freshParty =
          freshParty.copyWith(guestListEndTime: party.guestListEndTime);
    } catch (e) {
      Logx.em(
          _TAG, 'party guestListEndTime not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(isEmailRequired: party.isEmailRequired);
    } catch (e) {
      Logx.em(
          _TAG, 'party isEmailRequired not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(guestListRules: party.guestListRules);
    } catch (e) {
      Logx.em(_TAG, 'party guestListRules not exist for party id: ' + party.id);
    }
    try {
      freshParty = freshParty.copyWith(clubRules: party.clubRules);
    } catch (e) {
      Logx.em(_TAG, 'party clubRules not exist for party id: ' + party.id);
    }

    try {
      freshParty = freshParty.copyWith(isTicketed: party.isTicketed);
    } catch (e) {
      Logx.em(_TAG, 'party isTicketed not exist for party id: ' + party.id);
    }
    try {
      freshParty =
          freshParty.copyWith(ticketsSoldCount: party.ticketsSoldCount);
    } catch (e) {
      Logx.em(
          _TAG, 'party ticketsSoldCount not exist for party id: ' + party.id);
    }
    try {
      freshParty =
          freshParty.copyWith(ticketsSalesTotal: party.ticketsSalesTotal);
    } catch (e) {
      Logx.em(
          _TAG, 'party ticketsSalesTotal not exist for party id: ' + party.id);
    }

    try {
      freshParty =
          freshParty.copyWith(isChallengeActive: party.isChallengeActive);
    } catch (e) {
      Logx.em(
          _TAG, 'party isChallengeActive not exist for party id: ' + party.id);
    }
    try {
      freshParty =
          freshParty.copyWith(overrideChallengeNum: party.overrideChallengeNum);
    } catch (e) {
      Logx.em(_TAG, 'party overrideChallengeNum not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(genre: party.genre);
    } catch (e) {
      Logx.em(_TAG, 'party genre not exist for party id: ${party.id}');
    }

    try {
      freshParty = freshParty.copyWith(artistIds: party.artistIds);
    } catch (e) {
      Logx.em(_TAG, 'party artistIds not exist for id: ${party.id}');
    }

    return freshParty;
  }

  /** Party Guest **/
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
      freshGuest = freshGuest.copyWith(surname: partyGuest.surname);
    } catch (e) {
      Logx.em(_TAG,
          'party guest surname not exist for party guest id: ' + partyGuest.id);
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
      freshGuest = freshGuest.copyWith(
          isChallengeClicked: partyGuest.isChallengeClicked);
    } catch (e) {
      Logx.em(_TAG,
          'party guest isChallengeClicked not exist for id: ${partyGuest.id}');
    }
    try {
      freshGuest = freshGuest.copyWith(shouldBanUser: partyGuest.shouldBanUser);
    } catch (e) {
      Logx.em(
          _TAG, 'party guest shouldBanUser not exist for id: ${partyGuest.id}');
    }

    try {
      freshGuest = freshGuest.copyWith(guestStatus: partyGuest.guestStatus);
    } catch (e) {
      Logx.em(
          _TAG,
          'party guest guestStatus not exist for party guest id: ' +
              partyGuest.id);
    }
    try {
      freshGuest = freshGuest.copyWith(gender: partyGuest.gender);
    } catch (e) {
      Logx.em(_TAG,
          'party guest gender not exist for party guest id: ' + partyGuest.id);
    }

    return freshGuest;
  }

  static PartyGuest freshPartyGuestMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    PartyGuest partyGuest = Dummy.getDummyPartyGuest();
    bool shouldPush = true;

    try {
      partyGuest = partyGuest.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest id not exist');
    }
    try {
      partyGuest = partyGuest.copyWith(partyId: map['partyId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest partyId not exist for id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(guestId: map['guestId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest guestId not exist for id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest name not exist for id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(surname: map['surname'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest surname not exist for id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(phone: map['phone'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest phone not exist for id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(email: map['email'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest email not exist for id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(guestsCount: map['guestsCount'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'partyGuest guestsCount not exist for id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest =
          partyGuest.copyWith(guestsRemaining: map['guestsRemaining'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'partyGuest guestsRemaining not exist for id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest createdAt not exist for id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(isApproved: map['isApproved'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest isApproved not exist for id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(
          isChallengeClicked: map['isChallengeClicked'] as bool);
    } catch (e) {
      Logx.em(_TAG,
          'partyGuest isChallengeClicked not exist for id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest =
          partyGuest.copyWith(shouldBanUser: map['shouldBanUser'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'partyGuest shouldBanUser not exist for id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest =
          partyGuest.copyWith(guestStatus: map['guestStatus'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'partyGuest guestStatus not exist for id: ' + partyGuest.id);
      shouldPush = true;
    }
    try {
      partyGuest = partyGuest.copyWith(gender: map['gender'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest gender not exist for id: ' + partyGuest.id);
      shouldPush = true;
    }

    if (shouldPush &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.PROMOTER_LEVEL) {
      Logx.i(_TAG, 'updating party guest ' + partyGuest.id);
      FirestoreHelper.pushPartyGuest(partyGuest);
    }

    return partyGuest;
  }

  /** product **/
  static Product freshProductMap(Map<String, dynamic> map, bool shouldUpdate) {
    Product product = Dummy.getDummyProduct('', UserPreferences.myUser.id);

    bool shouldPushProduct = true;
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
      product = product.copyWith(isOfferRunning: map['isOfferRunning'] as bool);
    } catch (e) {
      Logx.em(_TAG,
          'product isOfferRunning not exist for product id: ' + product.id);
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
      Logx.i(_TAG, 'updating product ' + product.id);
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
      Logx.em(_TAG,
          'product isOfferRunning not exist for product id: ' + product.id);
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

  /** reservation **/
  static Reservation freshReservationMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    Reservation reservation =
        Dummy.getDummyReservation(Constants.blocServiceId);
    bool shouldPush = true;

    try {
      reservation = reservation.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'reservation id not exist');
    }
    try {
      reservation = reservation.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'reservation name not exist for reservation id: ' + reservation.id);
      shouldPush = true;
    }
    try {
      reservation =
          reservation.copyWith(blocServiceId: map['blocServiceId'] as String);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation blocServiceId not exist for reservation id: ' +
              reservation.id);
      shouldPush = true;
    }
    try {
      reservation =
          reservation.copyWith(customerId: map['customerId'] as String);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation customerId not exist for reservation id: ' +
              reservation.id);
      shouldPush = true;
    }
    try {
      reservation = reservation.copyWith(phone: map['phone'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'reservation phone not exist for reservation id: ' + reservation.id);
      shouldPush = true;
    }
    try {
      reservation =
          reservation.copyWith(guestsCount: map['guestsCount'] as int);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation guestsCount not exist for reservation id: ' +
              reservation.id);
      shouldPush = true;
    }
    try {
      reservation = reservation.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation createdAt not exist for reservation id: ' +
              reservation.id);
      shouldPush = true;
    }
    try {
      reservation =
          reservation.copyWith(arrivalDate: map['arrivalDate'] as int);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation arrivalDate not exist for reservation id: ' +
              reservation.id);
      shouldPush = true;
    }
    try {
      reservation =
          reservation.copyWith(arrivalTime: map['arrivalTime'] as String);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation arrivalTime not exist for reservation id: ' +
              reservation.id);
      shouldPush = true;
    }

    try {
      reservation = reservation.copyWith(
          bottleProductIds: List<String>.from(map['bottleProductIds']));
    } catch (e) {
      Logx.em(_TAG,
          'reservation bottleProductIds not exist for id: ' + reservation.id);
      shouldPush = true;
    }
    try {
      reservation = reservation.copyWith(
          bottleNames: List<String>.from(map['bottleNames']));
    } catch (e) {
      Logx.em(
          _TAG, 'reservation bottleNames not exist for id: ' + reservation.id);
      shouldPush = true;
    }
    try {
      reservation =
          reservation.copyWith(specialRequest: map['specialRequest'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'reservation specialRequest not exist for id: ' + reservation.id);
      shouldPush = true;
    }
    try {
      reservation = reservation.copyWith(occasion: map['occasion'] as String);
    } catch (e) {
      Logx.em(_TAG, 'reservation occasion not exist for id: ' + reservation.id);
      shouldPush = true;
    }
    try {
      reservation = reservation.copyWith(isApproved: map['isApproved'] as bool);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation isApproved not exist for reservation id: ' +
              reservation.id);
      shouldPush = true;
    }

    if (shouldPush && shouldUpdate) {
      Logx.i(_TAG, 'updating reservation ' + reservation.id);
      FirestoreHelper.pushReservation(reservation);
    }

    return reservation;
  }

  static Reservation freshReservation(Reservation reservation) {
    Reservation freshReservation =
        Dummy.getDummyReservation(Constants.blocServiceId);

    try {
      freshReservation = freshReservation.copyWith(id: reservation.id);
    } catch (e) {
      Logx.em(_TAG, 'reservation id not exist');
    }
    try {
      freshReservation = freshReservation.copyWith(name: reservation.name);
    } catch (e) {
      Logx.em(_TAG,
          'reservation name not exist for reservation id: ' + reservation.id);
    }
    try {
      freshReservation =
          freshReservation.copyWith(blocServiceId: reservation.blocServiceId);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation blocServiceId not exist for reservation id: ' +
              reservation.id);
    }
    try {
      freshReservation =
          freshReservation.copyWith(customerId: reservation.customerId);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation customerId not exist for reservation id: ' +
              reservation.id);
    }
    try {
      freshReservation = freshReservation.copyWith(phone: reservation.phone);
    } catch (e) {
      Logx.em(_TAG,
          'reservation phone not exist for reservation id: ' + reservation.id);
    }
    try {
      freshReservation =
          freshReservation.copyWith(guestsCount: reservation.guestsCount);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation guestsCount not exist for reservation id: ' +
              reservation.id);
    }
    try {
      freshReservation =
          freshReservation.copyWith(createdAt: reservation.createdAt);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation createdAt not exist for reservation id: ' +
              reservation.id);
    }
    try {
      freshReservation =
          freshReservation.copyWith(arrivalDate: reservation.arrivalDate);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation arrivalDate not exist for reservation id: ' +
              reservation.id);
    }
    try {
      freshReservation =
          freshReservation.copyWith(arrivalTime: reservation.arrivalTime);
    } catch (e) {
      Logx.em(
          _TAG, 'reservation arrivalTime not exist for id: ' + reservation.id);
    }

    try {
      freshReservation = freshReservation.copyWith(
          bottleProductIds: reservation.bottleProductIds);
    } catch (e) {
      Logx.em(_TAG,
          'reservation bottleProductIds not exist for id: ' + reservation.id);
    }
    try {
      freshReservation =
          freshReservation.copyWith(bottleNames: reservation.bottleNames);
    } catch (e) {
      Logx.em(
          _TAG, 'reservation bottleNames not exist for id: ' + reservation.id);
    }
    try {
      freshReservation =
          freshReservation.copyWith(specialRequest: reservation.specialRequest);
    } catch (e) {
      Logx.em(_TAG,
          'reservation specialRequest not exist for id: ' + reservation.id);
    }
    try {
      freshReservation =
          freshReservation.copyWith(occasion: reservation.occasion);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation occasion not exist for reservation id: ' +
              reservation.id);
    }

    try {
      freshReservation =
          freshReservation.copyWith(isApproved: reservation.isApproved);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation isApproved not exist for reservation id: ' +
              reservation.id);
    }

    return freshReservation;
  }

  /** ticket **/
  static Ticket freshTicketMap(Map<String, dynamic> map, bool shouldUpdate) {
    Ticket ticket = Dummy.getDummyTicket();
    bool shouldPush = true;

    try {
      ticket = ticket.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ticket id not exist');
    }
    try {
      ticket = ticket.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ticket name not exist for ticket id: ' + ticket.id);
      shouldPush = true;
    }

    try {
      ticket = ticket.copyWith(partyId: map['partyId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ticket partyId not exist for ticket id: ' + ticket.id);
      shouldPush = true;
    }
    try {
      ticket = ticket.copyWith(customerId: map['customerId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ticket customerId not exist for ticket id: ' + ticket.id);
      shouldPush = true;
    }
    try {
      ticket = ticket.copyWith(transactionId: map['transactionId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'ticket transactionId not exist for ticket id: ' + ticket.id);
      shouldPush = true;
    }
    try {
      ticket = ticket.copyWith(phone: map['phone'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ticket phone not exist for ticket id: ' + ticket.id);
      shouldPush = true;
    }
    try {
      ticket = ticket.copyWith(email: map['email'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ticket email not exist for ticket id: ' + ticket.id);
      shouldPush = true;
    }
    try {
      ticket = ticket.copyWith(entryCount: map['entryCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'ticket entryCount not exist for ticket id: ' + ticket.id);
      shouldPush = true;
    }
    try {
      ticket =
          ticket.copyWith(entriesRemaining: map['entriesRemaining'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'ticket entriesRemaining not exist for ticket id: ' + ticket.id);
      shouldPush = true;
    }
    try {
      ticket = ticket.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'ticket createdAt not exist for ticket id: ' + ticket.id);
      shouldPush = true;
    }
    try {
      ticket = ticket.copyWith(isPaid: map['isPaid'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'ticket isPaid not exist for ticket id: ' + ticket.id);
      shouldPush = true;
    }

    if (shouldPush && shouldUpdate) {
      Logx.i(_TAG, 'updating ticket ' + ticket.id);
      FirestoreHelper.pushTicket(ticket);
    }

    return ticket;
  }

  static Ticket freshTicket(Ticket ticket) {
    Ticket freshTicket = Dummy.getDummyTicket();

    try {
      freshTicket = freshTicket.copyWith(id: ticket.id);
    } catch (e) {
      Logx.em(_TAG, 'ticket id not exist');
    }
    try {
      freshTicket = freshTicket.copyWith(name: ticket.name);
    } catch (e) {
      Logx.em(_TAG, 'ticket name not exist for ticket id: ' + ticket.id);
    }
    try {
      freshTicket = freshTicket.copyWith(partyId: ticket.partyId);
    } catch (e) {
      Logx.em(_TAG, 'ticket partyId not exist for ticket id: ' + ticket.id);
    }
    try {
      freshTicket = freshTicket.copyWith(customerId: ticket.customerId);
    } catch (e) {
      Logx.em(_TAG, 'ticket customerId not exist for ticket id: ' + ticket.id);
    }
    try {
      freshTicket = freshTicket.copyWith(transactionId: ticket.transactionId);
    } catch (e) {
      Logx.em(
          _TAG, 'ticket transactionId not exist for ticket id: ' + ticket.id);
    }
    try {
      freshTicket = freshTicket.copyWith(phone: ticket.phone);
    } catch (e) {
      Logx.em(_TAG, 'ticket phone not exist for ticket id: ' + ticket.id);
    }
    try {
      freshTicket = freshTicket.copyWith(email: ticket.email);
    } catch (e) {
      Logx.em(_TAG, 'ticket email not exist for ticket id: ' + ticket.id);
    }
    try {
      freshTicket = freshTicket.copyWith(entryCount: ticket.entryCount);
    } catch (e) {
      Logx.em(_TAG, 'ticket entryCount not exist for ticket id: ' + ticket.id);
    }
    try {
      freshTicket =
          freshTicket.copyWith(entriesRemaining: ticket.entriesRemaining);
    } catch (e) {
      Logx.em(_TAG,
          'ticket entriesRemaining not exist for ticket id: ' + ticket.id);
    }
    try {
      freshTicket = freshTicket.copyWith(createdAt: ticket.createdAt);
    } catch (e) {
      Logx.em(_TAG, 'ticket createdAt not exist for ticket id: ' + ticket.id);
    }
    try {
      freshTicket = freshTicket.copyWith(isPaid: ticket.isPaid);
    } catch (e) {
      Logx.em(_TAG, 'ticket isPaid not exist for ticket id: ' + ticket.id);
    }

    return freshTicket;
  }

  /** ui photo **/
  static UiPhoto freshUiPhotoMap(Map<String, dynamic> map, bool shouldUpdate) {
    UiPhoto uiPhoto = Dummy.getDummyUiPhoto();
    bool shouldPush = true;

    try {
      uiPhoto = uiPhoto.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'uiPhoto id not exist');
    }
    try {
      uiPhoto = uiPhoto.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'uiPhoto name not exist for id: ' + uiPhoto.id);
      shouldPush = true;
    }
    try {
      uiPhoto =
          uiPhoto.copyWith(imageUrls: List<String>.from(map['imageUrls']));
    } catch (e) {
      Logx.em(_TAG, 'uiPhoto imageUrls not exist for id: ' + uiPhoto.id);
      List<String> temp = [];
      uiPhoto = uiPhoto.copyWith(imageUrls: temp);
      shouldPush = true;
    }

    if (shouldPush && shouldUpdate) {
      Logx.i(_TAG, 'updating uiPhoto ' + uiPhoto.id);
      FirestoreHelper.pushUiPhoto(uiPhoto);
    }

    return uiPhoto;
  }

  static UiPhoto freshUiPhoto(UiPhoto uiPhoto) {
    UiPhoto freshUiPhoto = Dummy.getDummyUiPhoto();

    try {
      freshUiPhoto = freshUiPhoto.copyWith(id: uiPhoto.id);
    } catch (e) {
      Logx.em(_TAG, 'uiPhoto id not exist');
    }
    try {
      freshUiPhoto = freshUiPhoto.copyWith(name: uiPhoto.name);
    } catch (e) {
      Logx.em(_TAG, 'uiPhoto name not exist for id: ' + uiPhoto.id);
    }
    try {
      freshUiPhoto = freshUiPhoto.copyWith(imageUrls: uiPhoto.imageUrls);
    } catch (e) {
      Logx.em(_TAG, 'uiPhoto imageUrls not exist for id: ' + uiPhoto.id);
    }

    return freshUiPhoto;
  }

  /** user **/
  static User freshUserMap(Map<String, dynamic> map, bool shouldUpdate) {
    User user = Dummy.getDummyUser();
    bool shouldPushUser = true;

    try {
      user = user.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user id not exist');
    }
    try {
      user = user.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user name not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(surname: map['surname'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user surname not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(phoneNumber: map['phoneNumber'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user phoneNumber not exist for user id: ' + user.id);
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
      user = user.copyWith(gender: map['gender'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user gender not exist for user id: ' + user.id);
      shouldPushUser = true;
    }

    try {
      user = user.copyWith(clearanceLevel: map['clearanceLevel'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user clearanceLevel not exist for user id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(challengeLevel: map['challengeLevel'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user challengeLevel not exist for user id: ' + user.id);
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

    try {
      user = user.copyWith(isBanned: map['isBanned'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'user isBanned not exist for id: ' + user.id);
      shouldPushUser = true;
    }
    try {
      user = user.copyWith(isAppUser: map['isAppUser'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'user isAppUser not exist for id: ${user.id}');
      shouldPushUser = true;
    }

    if (shouldPushUser && shouldUpdate) {
      Logx.i(_TAG, 'updating user ' + user.id);
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
      freshUser = freshUser.copyWith(name: user.name);
    } catch (e) {
      Logx.em(_TAG, 'name not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(surname: user.surname);
    } catch (e) {
      Logx.em(_TAG, 'user surname not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(gender: user.gender);
    } catch (e) {
      Logx.em(_TAG, 'user gender not exist for user id: ' + user.id);
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
      freshUser = freshUser.copyWith(challengeLevel: user.challengeLevel);
    } catch (e) {
      Logx.em(_TAG, 'user challengeLevel not exist for user id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(phoneNumber: user.phoneNumber);
    } catch (e) {
      Logx.em(_TAG, 'user phoneNumber not exist for user id: ' + user.id);
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
    try {
      freshUser = freshUser.copyWith(isBanned: user.isBanned);
    } catch (e) {
      Logx.em(_TAG, 'user isBanned not exist for id: ' + user.id);
    }
    try {
      freshUser = freshUser.copyWith(isAppUser: user.isAppUser);
    } catch (e) {
      Logx.em(_TAG, 'user isAppUser not exist for id: ' + user.id);
    }

    return freshUser;
  }
}
