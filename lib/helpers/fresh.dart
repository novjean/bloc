import 'package:bloc/db/entity/history_music.dart';
import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/db/entity/ui_photo.dart';

import '../db/entity/ad.dart';
import '../db/entity/ad_campaign.dart';
import '../db/entity/bloc.dart';
import '../db/entity/captain_service.dart';
import '../db/entity/category.dart';
import '../db/entity/celebration.dart';
import '../db/entity/challenge.dart';
import '../db/entity/challenge_action.dart';
import '../db/entity/config.dart';
import '../db/entity/lounge_chat.dart';
import '../db/entity/genre.dart';
import '../db/entity/lounge.dart';
import '../db/entity/notification_test.dart';
import '../db/entity/party.dart';
import '../db/entity/party_interest.dart';
import '../db/entity/party_photo.dart';
import '../db/entity/product.dart';
import '../db/entity/promoter.dart';
import '../db/entity/promoter_guest.dart';
import '../db/entity/quick_order.dart';
import '../db/entity/quick_table.dart';
import '../db/entity/reservation.dart';
import '../db/entity/ticket.dart';
import '../db/entity/user.dart';
import '../db/entity/user_lounge.dart';
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
    bool isModelChanged = false;

    try {
      ad = ad.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ad id not exist');
    }
    try {
      ad = ad.copyWith(title: map['title'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ad title not exist for ad id: ${ad.id}');
      isModelChanged = true;
    }
    try {
      ad = ad.copyWith(message: map['message'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ad message not exist for ad id: ${ad.id}');
      isModelChanged = true;
    }
    try {
      ad = ad.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ad imageUrl not exist for ad id: ${ad.id}');
      isModelChanged = true;
    }
    try {
      ad = ad.copyWith(blocId: map['blocId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ad blocId not exist for ad id: ${ad.id}');
      isModelChanged = true;
    }
    try {
      ad = ad.copyWith(hits: map['hits'] as int);
    } catch (e) {
      Logx.em(_TAG, 'ad hits not exist for ad id: ${ad.id}');
      isModelChanged = true;
    }
    try {
      ad = ad.copyWith(reach: map['reach'] as int);
    } catch (e) {
      Logx.em(_TAG, 'ad reach not exist for ad id: ${ad.id}');
      isModelChanged = true;
    }
    try {
      ad = ad.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'ad createdAt not exist for ad id: ${ad.id}');
      isModelChanged = true;
    }
    try {
      ad = ad.copyWith(isActive: map['isActive'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'ad isActive not exist for ad id: ${ad.id}');
      isModelChanged = true;
    }

    try {
      ad = ad.copyWith(partyName: map['partyName'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ad partyName not exist for ad id: ${ad.id}');
      isModelChanged = true;
    }
    try {
      ad = ad.copyWith(partyChapter: map['partyChapter'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ad partyChapter not exist for ad id: ${ad.id}');
      isModelChanged = true;
    }

    if (isModelChanged &&
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
      freshAd = freshAd.copyWith(imageUrl: ad.imageUrl);
    } catch (e) {
      Logx.em(_TAG, 'ad imageUrl not exist for ad id: ${ad.id}');
    }
    try {
      freshAd = freshAd.copyWith(blocId: ad.blocId);
    } catch (e) {
      Logx.em(_TAG, 'ad blocId not exist for ad id: ${ad.id}');
    }
    try {
      freshAd = freshAd.copyWith(hits: ad.hits);
    } catch (e) {
      Logx.em(_TAG, 'ad hits not exist for ad id: ${ad.id}');
    }
    try {
      freshAd = freshAd.copyWith(reach: ad.reach);
    } catch (e) {
      Logx.em(_TAG, 'ad reach not exist for ad id: ${ad.id}');
    }
    try {
      freshAd = freshAd.copyWith(createdAt: ad.createdAt);
    } catch (e) {
      Logx.em(_TAG, 'ad createdAt not exist for id: ${ad.id}');
    }
    try {
      freshAd = freshAd.copyWith(isActive: ad.isActive);
    } catch (e) {
      Logx.em(_TAG, 'ad isActive not exist for id: ${ad.id}');
    }
    try {
      freshAd = freshAd.copyWith(partyName: ad.partyName);
    } catch (e) {
      Logx.em(_TAG, 'ad partyName not exist for id: ${ad.id}');
    }
    try {
      freshAd = freshAd.copyWith(partyChapter: ad.partyChapter);
    } catch (e) {
      Logx.em(_TAG, 'ad partyChapter not exist for id: ${ad.id}');
    }

    return freshAd;
  }

  /** ad campaign **/
  static AdCampaign freshAdCampaignMap(Map<String, dynamic> map, bool shouldUpdate) {
    AdCampaign adCampaign = Dummy.getDummyAdCampaign();

    bool isModelChanged = false;

    try {
      adCampaign = adCampaign.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign id not exist');
    }
    try {
      adCampaign = adCampaign.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign name not exist for ad campaign id: ${adCampaign.id}');
      isModelChanged = true;
    }
    try {
      adCampaign = adCampaign.copyWith(imageUrls: List<String>.from(map['imageUrls']));
    } catch (e) {
      Logx.em(_TAG, 'adCampaign imageUrls not exist for ad campaign id: ${adCampaign.id}');
      adCampaign = adCampaign.copyWith(imageUrls: []);
      isModelChanged = true;
    }
    try {
      adCampaign = adCampaign.copyWith(linkUrl: map['linkUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign linkUrl not exist for ad campaign id: ${adCampaign.id}');
      isModelChanged = true;
    }
    try {
      adCampaign = adCampaign.copyWith(adClick: map['adClick'] as int);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign adClick not exist for ad campaign id: ${adCampaign.id}');
      isModelChanged = true;
    }
    try {
      adCampaign = adCampaign.copyWith(isActive: map['isActive'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign isActive not exist for ad campaign id: ${adCampaign.id}');
      isModelChanged = true;
    }

    if (isModelChanged &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating ad campaign ${adCampaign.id}');
      FirestoreHelper.pushAdCampaign(adCampaign);
    }

    return adCampaign;
  }

  static AdCampaign freshAdCampaign(AdCampaign adCampaign) {
    AdCampaign fresh = Dummy.getDummyAdCampaign();

    try {
      fresh = fresh.copyWith(id: adCampaign.id);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign id not exist');
    }
    try {
      fresh = fresh.copyWith(name: adCampaign.name);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign name not exist for ad campaign id: ${adCampaign.id}');
    }
    try {
      fresh = fresh.copyWith(imageUrls: adCampaign.imageUrls);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign imageUrls not exist for ad campaign id: ${adCampaign.id}');
    }
    try {
      fresh = fresh.copyWith(linkUrl: adCampaign.linkUrl);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign linkUrl not exist for ad campaign id: ${adCampaign.id}');
    }
    try {
      fresh = fresh.copyWith(adClick: adCampaign.adClick);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign adClick not exist for ad campaign id: ${adCampaign.id}');
    }
    try {
      fresh = fresh.copyWith(isActive: adCampaign.isActive);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign isActive not exist for ad campaign id: ${adCampaign.id}');
    }

    return fresh;
  }

  /** bloc **/
  static Bloc freshBlocMap(Map<String, dynamic> map, bool shouldUpdate) {
    Bloc bloc = Dummy.getDummyBloc('');

    bool isModelChanged = false;

    try {
      bloc = bloc.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc id not exist');
    }
    try {
      bloc = bloc.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc name not exist for id: ${bloc.id}');
      isModelChanged = true;
    }
    try {
      bloc = bloc.copyWith(cityId: map['cityId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc cityId not exist for id: ${bloc.id}');
      isModelChanged = true;
    }
    try {
      bloc = bloc.copyWith(addressLine1: map['addressLine1'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc addressLine1 not exist for id: ${bloc.id}');
      isModelChanged = true;
    }
    try {
      bloc = bloc.copyWith(addressLine2: map['addressLine2'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc addressLine2 not exist for id: ${bloc.id}');
      isModelChanged = true;
    }
    try {
      bloc = bloc.copyWith(pinCode: map['pinCode'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc pinCode not exist for id: ${bloc.id}');
      isModelChanged = true;
    }
    try {
      bloc = bloc.copyWith(ownerId: map['ownerId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc ownerId not exist for id: ${bloc.id}');
      isModelChanged = true;
    }
    try {
      bloc = bloc.copyWith(createdAt: map['createdAt'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc createdAt not exist for bloc id: ' + bloc.id);
      isModelChanged = true;
    }
    try {
      bloc = bloc.copyWith(isActive: map['isActive'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'bloc isActive not exist for bloc id: ' + bloc.id);
      isModelChanged = true;
    }
    try {
      bloc = bloc.copyWith(imageUrls: List<String>.from(map['imageUrls']));
    } catch (e) {
      Logx.em(_TAG, 'bloc imageUrls not exist for bloc id: ' + bloc.id);
      List<String> temp = [];
      bloc = bloc.copyWith(imageUrls: temp);
      isModelChanged = true;
    }

    if (isModelChanged &&
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

  /** captain service **/
  static CaptainService freshCaptainServiceMap(Map<String, dynamic> map, bool shouldUpdate) {
    CaptainService captainService = Dummy.getDummyCaptainService();

    bool isModelChanged = false;

    try {
      captainService = captainService.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'captain service id not exist');
    }
    try {
      captainService = captainService.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'captain service name not exist for id: ${captainService.id}');
      isModelChanged = true;
    }
    try {
      captainService = captainService.copyWith(sequence: map['sequence'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'captain service sequence not exist for id: ${captainService.id}');
      isModelChanged = true;
    }
    try {
      captainService = captainService.copyWith(isActive: map['isActive'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'captain service sequence not exist for id: ${captainService.id}');
      isModelChanged = true;
    }

    if (isModelChanged &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating captain service ${captainService.id}');
      FirestoreHelper.pushCaptainService(captainService);
    }

    return captainService;
  }

  static CaptainService freshCaptainService(CaptainService captainService) {
    CaptainService fresh = Dummy.getDummyCaptainService();

    try {
      fresh = fresh.copyWith(id: captainService.id);
    } catch (e) {
      Logx.em(_TAG, 'captain service id not exist');
    }
    try {
      fresh = fresh.copyWith(name: captainService.name);
    } catch (e) {
      Logx.em(_TAG, 'captain service name not exist for id: ${captainService.id}');
    }
    try {
      fresh = fresh.copyWith(sequence: captainService.sequence);
    } catch (e) {
      Logx.em(
          _TAG, 'captain service sequence not exist for id: ${captainService.id}');
    }
    try {
      fresh = fresh.copyWith(isActive: captainService.isActive);
    } catch (e) {
      Logx.em(
          _TAG, 'captain service isActive not exist for id: ${captainService.id}');
    }

    return fresh;
  }


  /** category **/
  static Category freshCategoryMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    Category category = Dummy.getDummyCategory('');

    bool isModelChanged = false;

    try {
      category = category.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'category id not exist');
    }
    try {
      category = category.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'category name not exist for category id: ' + category.id);
      isModelChanged = true;
    }
    try {
      category = category.copyWith(type: map['type'] as String);
    } catch (e) {
      Logx.em(_TAG, 'category type not exist for category id: ' + category.id);
      isModelChanged = true;
    }
    try {
      category = category.copyWith(serviceId: map['serviceId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'category serviceId not exist for category id: ' + category.id);
      isModelChanged = true;
    }
    try {
      category = category.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'category imageUrl not exist for category id: ' + category.id);
      isModelChanged = true;
    }
    try {
      category = category.copyWith(ownerId: map['ownerId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'category ownerId not exist for category id: ' + category.id);
      isModelChanged = true;
    }
    try {
      category = category.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'category createdAt not exist for category id: ' + category.id);
      isModelChanged = true;
    }
    try {
      category = category.copyWith(sequence: map['sequence'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'category sequence not exist for category id: ' + category.id);
      isModelChanged = true;
    }
    try {
      category = category.copyWith(description: map['description'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'category description not exist for category id: ' + category.id);
      isModelChanged = true;
    }
    try {
      category = category.copyWith(blocIds: List<String>.from(map['blocIds']));
    } catch (e) {
      Logx.em(
          _TAG, 'category blocIds not exist for category id: ' + category.id);
      List<String> existingBlocIds = [category.serviceId];
      category = category.copyWith(blocIds: existingBlocIds);
      isModelChanged = true;
    }

    if (isModelChanged &&
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
    bool isModelChanged = false;

    try {
      celebration = celebration.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'celebration id not exist');
    }
    try {
      celebration = celebration.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'celebration name not exist for id: ' + celebration.id);
      isModelChanged = true;
    }
    try {
      celebration = celebration.copyWith(surname: map['surname'] as String);
    } catch (e) {
      Logx.em(_TAG, 'celebration surname not exist for id: ' + celebration.id);
      isModelChanged = true;
    }
    try {
      celebration =
          celebration.copyWith(blocServiceId: map['blocServiceId'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'celebration blocServiceId not exist for id: ' + celebration.id);
      isModelChanged = true;
    }
    try {
      celebration =
          celebration.copyWith(customerId: map['customerId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration customerId not exist for id: ' + celebration.id);
      isModelChanged = true;
    }
    try {
      celebration = celebration.copyWith(phone: map['phone'] as int);
    } catch (e) {
      Logx.em(_TAG, 'celebration phone not exist for id: ' + celebration.id);
      isModelChanged = true;
    }

    try {
      celebration =
          celebration.copyWith(guestsCount: map['guestsCount'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration guestsCount not exist for id: ' + celebration.id);
      isModelChanged = true;
    }
    try {
      celebration = celebration.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration createdAt not exist for id: ' + celebration.id);
      isModelChanged = true;
    }
    try {
      celebration =
          celebration.copyWith(arrivalDate: map['arrivalDate'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration arrivalDate not exist for id: ' + celebration.id);
      isModelChanged = true;
    }
    try {
      celebration =
          celebration.copyWith(arrivalTime: map['arrivalTime'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration arrivalTime not exist for id: ' + celebration.id);
      isModelChanged = true;
    }
    try {
      celebration =
          celebration.copyWith(durationHours: map['durationHours'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'celebration durationHours not exist for id: ' + celebration.id);
      isModelChanged = true;
    }

    try {
      celebration = celebration.copyWith(
          bottleProductIds: List<String>.from(map['bottleProductIds']));
    } catch (e) {
      Logx.em(_TAG,
          'celebration bottleProductIds not exist for id: ' + celebration.id);
      isModelChanged = true;
    }
    try {
      celebration = celebration.copyWith(
          bottleNames: List<String>.from(map['bottleNames']));
    } catch (e) {
      Logx.em(
          _TAG, 'celebration bottleNames not exist for id: ' + celebration.id);
      isModelChanged = true;
    }
    try {
      celebration =
          celebration.copyWith(specialRequest: map['specialRequest'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'celebration specialRequest not exist for id: ' + celebration.id);
      isModelChanged = true;
    }
    try {
      celebration = celebration.copyWith(occasion: map['occasion'] as String);
    } catch (e) {
      Logx.em(_TAG, 'reservation occasion not exist for id: ' + celebration.id);
      isModelChanged = true;
    }
    try {
      celebration = celebration.copyWith(isApproved: map['isApproved'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration isApproved not exist for id: ' + celebration.id);
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
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

    bool isModelChanged = false;

    try {
      challenge = challenge.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge id not exist');
    }
    try {
      challenge = challenge.copyWith(level: map['level'] as int);
    } catch (e) {
      Logx.em(_TAG, 'challenge level not exist for id: ' + challenge.id);
      isModelChanged = true;
    }
    try {
      challenge = challenge.copyWith(title: map['title'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge title not exist for id: ' + challenge.id);
      isModelChanged = true;
    }
    try {
      challenge = challenge.copyWith(description: map['description'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge description not exist for id: ' + challenge.id);
      isModelChanged = true;
    }
    try {
      challenge = challenge.copyWith(points: map['points'] as int);
    } catch (e) {
      Logx.em(_TAG, 'challenge points not exist for id: ' + challenge.id);
      isModelChanged = true;
    }
    try {
      challenge = challenge.copyWith(clickCount: map['clickCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'challenge clickCount not exist for id: ' + challenge.id);
      isModelChanged = true;
    }
    try {
      challenge = challenge.copyWith(dialogTitle: map['dialogTitle'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge dialogTitle not exist for id: ' + challenge.id);
      isModelChanged = true;
    }
    try {
      challenge = challenge.copyWith(
          dialogAcceptText: map['dialogAcceptText'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'challenge dialogAcceptText not exist for id: ' + challenge.id);
      isModelChanged = true;
    }
    try {
      challenge = challenge.copyWith(
          dialogAccept2Text: map['dialogAccept2Text'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'challenge dialogAccept2Text not exist for id: ' + challenge.id);
      isModelChanged = true;
    }

    if (isModelChanged &&
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
          _TAG, 'challenge points not exist for id: ${challenge.id}');
    }
    try {
      freshChallenge =
          freshChallenge.copyWith(clickCount: challenge.clickCount);
    } catch (e) {
      Logx.em(_TAG,
          'challenge clickCount not exist for id: ${challenge.id}');
    }
    try {
      freshChallenge =
          freshChallenge.copyWith(dialogTitle: challenge.dialogTitle);
    } catch (e) {
      Logx.em(_TAG,
          'challenge dialogTitle not exist for challenge id: ${challenge.id}');
    }
    try {
      freshChallenge =
          freshChallenge.copyWith(dialogAcceptText: challenge.dialogAcceptText);
    } catch (e) {
      Logx.em(
          _TAG,
          'challenge dialogAcceptText not exist for challenge id: ${challenge.id}');
    }
    try {
      freshChallenge = freshChallenge.copyWith(
          dialogAccept2Text: challenge.dialogAccept2Text);
    } catch (e) {
      Logx.em(
          _TAG,
          'challenge dialogAccept2Text not exist for challenge id: ${challenge.id}');
    }

    return freshChallenge;
  }

  /** challenge action **/
  static ChallengeAction freshChallengeActionMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    ChallengeAction ca = Dummy.getDummyChallengeAction('');

    bool isModelChanged = false;

    try {
      ca = ca.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge action id not exist');
    }
    try {
      ca = ca.copyWith(challengeId: map['challengeId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge action challengeId not exist for id: ${ca.id}');
      isModelChanged = true;
    }
    try {
      ca = ca.copyWith(buttonCount: map['buttonCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'challenge action buttonCount not exist for id: ${ca.id}');
      isModelChanged = true;
    }
    try {
      ca = ca.copyWith(buttonTitle: map['buttonTitle'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge action buttonTitle not exist for id: ${ca.id}');
      isModelChanged = true;
    }
    try {
      ca = ca.copyWith(action: map['action'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge action action not exist for id: ${ca.id}');
      isModelChanged = true;
    }
    try {
      ca = ca.copyWith(actionType: map['actionType'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge action actionType not exist for id: ${ca.id}');
      isModelChanged = true;
    }

    if (isModelChanged &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating challenge action ${ca.id}');
      FirestoreHelper.pushChallengeAction(ca);
    }

    return ca;
  }

  static ChallengeAction freshChallengeAction(ChallengeAction ca) {
    ChallengeAction fresh = Dummy.getDummyChallengeAction('');

    try {
      fresh = fresh.copyWith(id: ca.id);
    } catch (e) {
      Logx.em(_TAG, 'challenge action id not exist');
    }
    try {
      fresh = fresh.copyWith(challengeId: ca.challengeId);
    } catch (e) {
      Logx.em(
          _TAG, 'challenge action challengeId not exist for id: ${ca.id}');
    }
    try {
      fresh = fresh.copyWith(buttonCount: ca.buttonCount);
    } catch (e) {
      Logx.em(
          _TAG, 'challenge action buttonCount exist for id: ${ca.id}');
    }
    try {
      fresh = fresh.copyWith(buttonTitle: ca.buttonTitle);
    } catch (e) {
      Logx.em(
          _TAG, 'challenge action buttonTitle exist for id: ${ca.id}');
    }
    try {
      fresh = fresh.copyWith(action: ca.action);
    } catch (e) {
      Logx.em(
          _TAG, 'challenge action action exist for id: ${ca.id}');
    }
    try {
      fresh = fresh.copyWith(actionType: ca.actionType);
    } catch (e) {
      Logx.em(
          _TAG, 'challenge action actionType exist for id: ${ca.id}');
    }

    return fresh;
  }

  /** lounge chat **/
  static LoungeChat freshLoungeChatMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    LoungeChat chat = Dummy.getDummyLoungeChat();
    bool isModelChanged = false;

    try {
      chat = chat.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'chat id not exist');
    }
    try {
      chat = chat.copyWith(loungeId: map['loungeId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'chat loungeId not exist for id: ${chat.id}');
      isModelChanged = true;
    }
    try {
      chat = chat.copyWith(loungeName: map['loungeName'] as String);
    } catch (e) {
      Logx.em(_TAG, 'chat loungeName not exist for id: ${chat.id}');
      isModelChanged = true;
    }
    try {
      chat = chat.copyWith(userId: map['userId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'chat userId not exist for id: ${chat.id}');
      isModelChanged = true;
    }
    try {
      chat = chat.copyWith(userName: map['userName'] as String);
    } catch (e) {
      Logx.em(_TAG, 'chat userName not exist for id: ${chat.id}');
      isModelChanged = true;
    }
    try {
      chat = chat.copyWith(userImage: map['userImage'] as String);
    } catch (e) {
      Logx.em(_TAG, 'chat userImage not exist for id: ${chat.id}');
      isModelChanged = true;
    }

    try {
      chat = chat.copyWith(message: map['message'] as String);
    } catch (e) {
      Logx.em(_TAG, 'chat message not exist for id: ${chat.id}');
      isModelChanged = true;
    }
    try {
      chat = chat.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'chat imageUrl not exist for id: ${chat.id}');
      isModelChanged = true;
    }
    try {
      chat = chat.copyWith(type: map['type'] as String);
    } catch (e) {
      Logx.em(_TAG, 'chat type not exist for id: ${chat.id}');
      isModelChanged = true;
    }
    try {
      chat = chat.copyWith(time: map['time'] as int);
    } catch (e) {
      Logx.em(_TAG, 'chat time not exist for id: ${chat.id}');
      isModelChanged = true;
    }

    try {
      chat = chat.copyWith(vote: map['vote'] as int);
    } catch (e) {
      Logx.em(_TAG, 'chat vote not exist for id: ${chat.id}');
      isModelChanged = true;
    }
    try {
      chat = chat.copyWith(upVoters: List<String>.from(map['upVoters']));
    } catch (e) {
      Logx.em(_TAG, 'chat upVoters not exist for id: ${chat.id}');
      isModelChanged = true;
    }
    try {
      chat = chat.copyWith(downVoters: List<String>.from(map['downVoters']));
    } catch (e) {
      Logx.em(_TAG, 'chat downVoters not exist for id: ${chat.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating chat ${chat.id}');
      FirestoreHelper.pushLoungeChat(chat);
    }

    return chat;
  }

  static LoungeChat freshLoungeChat(LoungeChat chat) {
    LoungeChat freshChat = Dummy.getDummyLoungeChat();

    try {
      freshChat = freshChat.copyWith(id: chat.id);
    } catch (e) {
      Logx.em(_TAG, 'chat id not exist');
    }
    try {
      freshChat = freshChat.copyWith(loungeId: chat.loungeId);
    } catch (e) {
      Logx.em(
          _TAG, 'chat loungeId not exist for id: ${chat.id}');
    }
    try {
      freshChat = freshChat.copyWith(loungeName: chat.loungeName);
    } catch (e) {
      Logx.em(
          _TAG, 'chat loungeName not exist for id: ${chat.id}');
    }
    try {
      freshChat = freshChat.copyWith(userId: chat.userId);
    } catch (e) {
      Logx.em(
          _TAG, 'chat userId not exist for id: ${chat.id}');
    }
    try {
      freshChat = freshChat.copyWith(userName: chat.userName);
    } catch (e) {
      Logx.em(
          _TAG, 'chat userName not exist for id: ${chat.id}');
    }
    try {
      freshChat = freshChat.copyWith(userImage: chat.userImage);
    } catch (e) {
      Logx.em(
          _TAG, 'chat userImage not exist for id: ${chat.id}');
    }

    try {
      freshChat = freshChat.copyWith(message: chat.message);
    } catch (e) {
      Logx.em(
          _TAG, 'chat message not exist for id: ${chat.id}');
    }
    try {
      freshChat = freshChat.copyWith(imageUrl: chat.imageUrl);
    } catch (e) {
      Logx.em(
          _TAG, 'chat imageUrl not exist for id: ${chat.id}');
    }
    try {
      freshChat = freshChat.copyWith(type: chat.type);
    } catch (e) {
      Logx.em(
          _TAG, 'chat type not exist for id: ${chat.id}');
    }
    try {
      freshChat = freshChat.copyWith(time: chat.time);
    } catch (e) {
      Logx.em(
          _TAG, 'chat time not exist for id: ${chat.id}');
    }

    try {
      freshChat = freshChat.copyWith(vote: chat.vote);
    } catch (e) {
      Logx.em(
          _TAG, 'chat vote not exist for id: ${chat.id}');
    }
    try {
      freshChat = freshChat.copyWith(upVoters: chat.upVoters);
    } catch (e) {
      Logx.em(
          _TAG, 'chat upVoters not exist for id: ${chat.id}');
    }
    try {
      freshChat = freshChat.copyWith(downVoters: chat.downVoters);
    } catch (e) {
      Logx.em(
          _TAG, 'chat downVoters not exist for id: ${chat.id}');
    }

    return freshChat;
  }

  /** config **/
  static Config freshConfigMap(Map<String, dynamic> map, bool shouldUpdate) {
    Config config = Dummy.getDummyConfig(Constants.blocServiceId);

    bool isModelChanged = false;

    try {
      config = config.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'config id not exist');
    }
    try {
      config = config.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'config name not exist for id: ${config.id}');
      isModelChanged = true;
    }
    try {
      config = config.copyWith(blocServiceId: map['blocServiceId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'config blocServiceId not exist for id: ${config.id}');
      isModelChanged = true;
    }
    try {
      config = config.copyWith(value: map['value'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'config value not exist for id: ${config.id}');
      isModelChanged = true;
    }

    if (isModelChanged &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating config ${config.id}');
      FirestoreHelper.pushConfig(config);
    }

    return config;
  }

  static Config freshConfig(Config config) {
    Config freshConfig = Dummy.getDummyConfig(Constants.blocServiceId);

    try {
      freshConfig = freshConfig.copyWith(id: config.id);
    } catch (e) {
      Logx.em(_TAG, 'config id not exist');
    }
    try {
      freshConfig = freshConfig.copyWith(name: config.name);
    } catch (e) {
      Logx.em(_TAG, 'config name not exist for id: ${config.id}');
    }
    try {
      freshConfig = freshConfig.copyWith(blocServiceId: config.blocServiceId);
    } catch (e) {
      Logx.em(_TAG, 'config blocServiceId not exist for id: ${config.id}');
    }
    try {
      freshConfig = freshConfig.copyWith(value: config.value);
    } catch (e) {
      Logx.em(_TAG, 'config value not exist for id: ${config.id}');
    }

    return freshConfig;
  }

  /** genre **/
  static Genre freshGenreMap(Map<String, dynamic> map, bool shouldUpdate) {
    Genre genre = Dummy.getDummyGenre();

    bool isModelChanged = false;

    try {
      genre = genre.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'genre id not exist');
    }
    try {
      genre = genre.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'genre name not exist for id: ' + genre.id);
      isModelChanged = true;
    }

    if (isModelChanged &&
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

    bool isModelChanged = false;

    try {
      historyMusic = historyMusic.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'historyMusic id not exist');
    }
    try {
      historyMusic = historyMusic.copyWith(userId: map['userId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'historyMusic userId not exist for id: ${historyMusic.id}');
      isModelChanged = true;
    }
    try {
      historyMusic = historyMusic.copyWith(genre: map['genre'] as String);
    } catch (e) {
      Logx.em(_TAG, 'historyMusic genre not exist for id: ${historyMusic.id}');
      isModelChanged = true;
    }
    try {
      historyMusic = historyMusic.copyWith(count: map['count'] as int);
    } catch (e) {
      Logx.em(_TAG, 'historyMusic count not exist for id: ${historyMusic.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
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

    bool isModelChanged = false;

    try {
      lounge = lounge.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'lounge id not exist');
    }
    try {
      lounge = lounge.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'lounge name not exist for id: ${lounge.id}');
      isModelChanged = true;
    }
    try {
      lounge = lounge.copyWith(description: map['description'] as String);
    } catch (e) {
      Logx.em(_TAG, 'lounge description not exist for id: ${lounge.id}');
      isModelChanged = true;
    }
    try {
      lounge = lounge.copyWith(rules: map['rules'] as String);
    } catch (e) {
      Logx.em(_TAG, 'lounge rules not exist for id: ${lounge.id}');
      isModelChanged = true;
    }
    try {
      lounge = lounge.copyWith(type: map['type'] as String);
    } catch (e) {
      Logx.em(_TAG, 'lounge type not exist for id: ${lounge.id}');
      isModelChanged = true;
    }
    try {
      lounge = lounge.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'lounge imageUrl not exist for id: ${lounge.id}');
      isModelChanged = true;
    }

    try {
      lounge = lounge.copyWith(admins: List<String>.from(map['admins']));
    } catch (e) {
      Logx.em(_TAG, 'lounge admins not exist for id: ${lounge.id}');
      isModelChanged = true;
    }
    try {
      lounge = lounge.copyWith(members: List<String>.from(map['members']));
    } catch (e) {
      Logx.em(_TAG, 'lounge members not exist for id: ${lounge.id}');
      isModelChanged = true;
    }
    try {
      lounge = lounge.copyWith(exitedUserIds: List<String>.from(map['exitedUserIds']));
    } catch (e) {
      Logx.em(_TAG, 'lounge exitedUserIds not exist for id: ${lounge.id}');
      isModelChanged = true;
    }

    try {
      lounge = lounge.copyWith(creationTime: map['creationTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'lounge creationTime not exist for id: ${lounge.id}');
      isModelChanged = true;
    }

    try {
      lounge = lounge.copyWith(lastChat: map['lastChat'] as String);
    } catch (e) {
      Logx.em(_TAG, 'lounge lastChat not exist for id: ${lounge.id}');
      isModelChanged = true;
    }
    try {
      lounge = lounge.copyWith(lastChatTime: map['lastChatTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'lounge lastChatTime not exist for id: ${lounge.id}');
      isModelChanged = true;
    }

    try {
      lounge = lounge.copyWith(isActive: map['isActive'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'lounge isActive not exist for id: ${lounge.id}');
      isModelChanged = true;
    }
    try {
      lounge = lounge.copyWith(isVip: map['isVip'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'lounge isVip not exist for id: ${lounge.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate &&
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
      fresh = fresh.copyWith(description: lounge.description);
    } catch (e) {
      Logx.em(_TAG, 'lounge description not exist for id: ${lounge.id}');
    }
    try {
      fresh = fresh.copyWith(rules: lounge.rules);
    } catch (e) {
      Logx.em(_TAG, 'lounge rules not exist for id: ${lounge.id}');
    }
    try {
      fresh = fresh.copyWith(type: lounge.type);
    } catch (e) {
      Logx.em(_TAG, 'lounge type not exist for id: ${lounge.id}');
    }
    try {
      fresh = fresh.copyWith(imageUrl: lounge.imageUrl);
    } catch (e) {
      Logx.em(_TAG, 'lounge imageUrl not exist for id: ${lounge.id}');
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
      fresh = fresh.copyWith(exitedUserIds: lounge.exitedUserIds);
    } catch (e) {
      Logx.em(_TAG, 'lounge exitedUserIds not exist for id: ${lounge.id}');
    }

    try {
      fresh = fresh.copyWith(creationTime: lounge.creationTime);
    } catch (e) {
      Logx.em(_TAG, 'lounge creationTime not exist for id: ${lounge.id}');
    }

    try {
      fresh = fresh.copyWith(lastChat: lounge.lastChat);
    } catch (e) {
      Logx.em(_TAG, 'lounge lastChat not exist for id: ${lounge.id}');
    }
    try {
      fresh = fresh.copyWith(lastChatTime: lounge.lastChatTime);
    } catch (e) {
      Logx.em(_TAG, 'lounge lastChatTime not exist for id: ${lounge.id}');
    }

    try {
      fresh = fresh.copyWith(isActive: lounge.isActive);
    } catch (e) {
      Logx.em(_TAG, 'lounge isActive not exist for id: ${lounge.id}');
    }
    try {
      fresh = fresh.copyWith(isVip: lounge.isVip);
    } catch (e) {
      Logx.em(_TAG, 'lounge isVip not exist for id: ${lounge.id}');
    }

    return fresh;
  }

  /** notification test **/
  static NotificationTest freshNotificationTestMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    NotificationTest notificationTest = Dummy.getDummyNotificationTest();

    bool isModelChanged = false;

    try {
      notificationTest = notificationTest.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'notification test id not exist');
    }
    try {
      notificationTest = notificationTest.copyWith(title: map['title'] as String);
    } catch (e) {
      Logx.em(_TAG, 'notification test title not exist for id: ${notificationTest.id}');
      isModelChanged = true;
    }
    try {
      notificationTest = notificationTest.copyWith(body: map['body'] as String);
    } catch (e) {
      Logx.em(_TAG, 'notification test body not exist for id: ${notificationTest.id}');
      isModelChanged = true;
    }
    try {
      notificationTest = notificationTest.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'notification test imageUrl not exist for id: ${notificationTest.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating notification test ${notificationTest.id}');
      FirestoreHelper.pushNotificationTest(notificationTest);
    }

    return notificationTest;
  }

  static NotificationTest freshNotificationTest(NotificationTest notificationTest) {
    NotificationTest fresh = Dummy.getDummyNotificationTest();

    try {
      fresh = fresh.copyWith(id: notificationTest.id);
    } catch (e) {
      Logx.em(_TAG, 'notification test id not exist');
    }
    try {
      fresh = fresh.copyWith(title: notificationTest.title);
    } catch (e) {
      Logx.em(_TAG, 'notification test title not exist for id: ${notificationTest.id}');
    }
    try {
      fresh = fresh.copyWith(body: notificationTest.body);
    } catch (e) {
      Logx.em(_TAG, 'notification test body not exist for id: ${notificationTest.id}');
    }
    try {
      fresh = fresh.copyWith(imageUrl: notificationTest.imageUrl);
    } catch (e) {
      Logx.em(_TAG, 'notification test imageUrl not exist for id: ${notificationTest.id}');
    }

    return fresh;
  }

  /** party **/
  static Party freshPartyMap(Map<String, dynamic> map, bool shouldUpdate) {
    Party party = Dummy.getDummyParty(UserPreferences.myUser.blocServiceId);
    bool isModelChanged = false;

    try {
      party = party.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party id not exist');
    }
    try {
      party = party.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party name not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(eventName: map['eventName'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party eventName not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(description: map['description'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party description not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(blocServiceId: map['blocServiceId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party blocServiceId not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(type: map['type'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party type not exist for id: ' + party.id);
      isModelChanged = true;
    }
    try {
      party = party.copyWith(chapter: map['chapter'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party chapter not exist for id: ${party.id}');
      isModelChanged = true;
    }

    try {
      party = party.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party imageUrl not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(isSquare: map['isSquare'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'party isSquare not exist for id: ${party.id}');
      isModelChanged = true;
    }

    try {
      party = party.copyWith(storyImageUrl: map['storyImageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party storyImageUrl not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(showStoryImageUrl: map['showStoryImageUrl'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'party showStoryImageUrl not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(instagramUrl: map['instagramUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party instagramUrl not exist for id: ' + party.id);
      isModelChanged = true;
    }
    try {
      party = party.copyWith(ticketUrl: map['ticketUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party ticketUrl not exist for id: ' + party.id);
      isModelChanged = true;
    }
    try {
      party = party.copyWith(listenUrl: map['listenUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party listenUrl not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'party createdAt not exist for party id: ' + party.id);
      isModelChanged = true;
    }
    try {
      party = party.copyWith(startTime: map['startTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'party startTime not exist for party id: ' + party.id);
      isModelChanged = true;
    }
    try {
      party = party.copyWith(endTime: map['endTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'party endTime not exist for party id: ' + party.id);
      isModelChanged = true;
    }
    try {
      party = party.copyWith(ownerId: map['ownerId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party ownerId not exist for party id: ' + party.id);
      isModelChanged = true;
    }
    try {
      party = party.copyWith(isTBA: map['isTBA'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'party isTBA not exist for party id: ' + party.id);
      isModelChanged = true;
    }
    try {
      party = party.copyWith(isActive: map['isActive'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'party isActive not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(isBigAct: map['isBigAct'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'party isBigAct not exist for id: ${party.id}');
      isModelChanged = true;
    }

    try {
      party =
          party.copyWith(isGuestListActive: map['isGuestListActive'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'party isGuestListActive not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party =
          party.copyWith(isGuestListFull: map['isGuestListFull'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'party isGuestListFull not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(isGuestsCountRestricted: map['isGuestsCountRestricted'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'party isGuestsCountRestricted not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(guestListCount: map['guestListCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'party guestListCount not exist for party id: ' + party.id);
      isModelChanged = true;
    }
    try {
      party = party.copyWith(isEmailRequired: map['isEmailRequired'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'party isEmailRequired not exist for party id: ' + party.id);
      isModelChanged = true;
    }
    try {
      party = party.copyWith(guestListEndTime: map['guestListEndTime'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'party guestListEndTime not exist for party id: ' + party.id);
      isModelChanged = true;
    }
    try {
      party = party.copyWith(guestListRules: map['guestListRules'] as String);
      if (party.guestListRules.isEmpty) {
        party = party.copyWith(guestListRules: Constants.guestListRules);
        isModelChanged = true;
      }
    } catch (e) {
      Logx.em(_TAG, 'party guestListRules not exist for party id: ' + party.id);
      isModelChanged = true;
    }
    try {
      party = party.copyWith(clubRules: map['clubRules'] as String);
      if (party.clubRules.isEmpty) {
        party = party.copyWith(clubRules: Constants.clubRules);
        isModelChanged = true;
      }
    } catch (e) {
      Logx.em(_TAG, 'party clubRules not exist for id: ${party.id}');
      isModelChanged = true;
    }

    try {
      party = party.copyWith(isTicketed: map['isTicketed'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'party isTicketed not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(isTicketsDisabled: map['isTicketsDisabled'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'party isTicketsDisabled not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(ticketsSoldCount: map['ticketsSoldCount'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'party ticketsSoldCount not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party =
          party.copyWith(ticketsSalesTotal: map['ticketsSalesTotal'] as double);
    } catch (e) {
      Logx.em(
          _TAG, 'party ticketsSalesTotal not exist for id: ${party.id}');
      isModelChanged = true;
    }

    try {
      party =
          party.copyWith(isChallengeActive: map['isChallengeActive'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'party isChallengeActive not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(
          overrideChallengeNum: map['overrideChallengeNum'] as int);
    } catch (e) {
      Logx.em(_TAG, 'party overrideChallengeNum not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(genre: map['genre'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party genre not exist for id: ${party.id}');
      isModelChanged = true;
    }

    try {
      party = party.copyWith(artistIds: List<String>.from(map['artistIds']));
    } catch (e) {
      Logx.em(_TAG, 'party artistIds not exist for id: ${party.id}');
      isModelChanged = true;
    }

    try {
      party = party.copyWith(loungeId: map['loungeId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party loungeId not exist for id: ${party.id}');
      isModelChanged = true;
    }

    try {
      party = party.copyWith(imageUrls: List<String>.from(map['imageUrls']));
    } catch (e) {
      Logx.em(_TAG, 'party imageUrls not exist for id: ${party.id}');

      List<String> temp = [];
      if(party.imageUrl.isNotEmpty){
        temp.add(party.imageUrl);
      }
      party = party.copyWith(imageUrls: temp);
      isModelChanged = true;
    }

    try {
      party = party.copyWith(views: map['views'] as int);
    } catch (e) {
      Logx.em(_TAG, 'party views not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(shareCount: map['shareCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'party shareCount not exist for id: ${party.id}');
      isModelChanged = true;
    }

    if (isModelChanged &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating party ${party.id}');
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
      Logx.em(_TAG, 'party name not exist for id: ${party.id}');
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
      Logx.em(_TAG, 'party chapter not exist for id: ${party.id}');
    }

    try {
      freshParty = freshParty.copyWith(imageUrls: party.imageUrls);
    } catch (e) {
      Logx.em(_TAG, 'party imageUrls not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(imageUrl: party.imageUrl);
    } catch (e) {
      Logx.em(_TAG, 'party imageUrl not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(isSquare: party.isSquare);
    } catch (e) {
      Logx.em(_TAG, 'party isSquare not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(storyImageUrl: party.storyImageUrl);
    } catch (e) {
      Logx.em(_TAG, 'party storyImageUrl not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(showStoryImageUrl: party.showStoryImageUrl);
    } catch (e) {
      Logx.em(_TAG, 'party showStoryImageUrl not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(instagramUrl: party.instagramUrl);
    } catch (e) {
      Logx.em(_TAG, 'party instagramUrl not exist for id: ${party.id}');
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
      Logx.em(_TAG, 'party isBigAct not exist for id: ${party.id}');
    }

    try {
      freshParty =
          freshParty.copyWith(isGuestListActive: party.isGuestListActive);
    } catch (e) {
      Logx.em(
          _TAG, 'party isGuestListActive not exist for id: ${party.id}');
    }
    try {
      freshParty =
          freshParty.copyWith(isGuestListFull: party.isGuestListFull);
    } catch (e) {
      Logx.em(
          _TAG, 'party isGuestListFull not exist for id: ${party.id}');
    }
    try {
      freshParty =
          freshParty.copyWith(isGuestsCountRestricted: party.isGuestsCountRestricted);
    } catch (e) {
      Logx.em(
          _TAG, 'party isGuestsCountRestricted not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(guestListCount: party.guestListCount);
    } catch (e) {
      Logx.em(_TAG, 'party guestListCount not exist for id: ${party.id}');
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
      Logx.em(_TAG, 'party clubRules not exist for id: ${party.id}');
    }

    try {
      freshParty = freshParty.copyWith(isTicketed: party.isTicketed);
    } catch (e) {
      Logx.em(_TAG, 'party isTicketed not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(isTicketsDisabled: party.isTicketsDisabled);
    } catch (e) {
      Logx.em(_TAG, 'party isTicketsDisabled not exist for id: ${party.id}');
    }
    try {
      freshParty =
          freshParty.copyWith(ticketsSoldCount: party.ticketsSoldCount);
    } catch (e) {
      Logx.em(
          _TAG, 'party ticketsSoldCount not exist for id: ${party.id}');
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

    try {
      freshParty = freshParty.copyWith(loungeId: party.loungeId);
    } catch (e) {
      Logx.em(_TAG, 'party loungeId not exist for id: ${party.id}');
    }

    try {
      freshParty = freshParty.copyWith(views: party.views);
    } catch (e) {
      Logx.em(_TAG, 'party views not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(shareCount: party.shareCount);
    } catch (e) {
      Logx.em(_TAG, 'party shareCount not exist for id: ${party.id}');
    }

    return freshParty;
  }

  /** Party Guest **/
  static PartyGuest freshPartyGuest(PartyGuest partyGuest) {
    PartyGuest freshGuest = Dummy.getDummyPartyGuest(true);

    try {
      freshGuest = freshGuest.copyWith(id: partyGuest.id);
    } catch (e) {
      Logx.em(_TAG, 'party guest id not exist');
    }
    try {
      freshGuest = freshGuest.copyWith(name: partyGuest.name);
    } catch (e) {
      Logx.em(_TAG,
          'party guest name not exist for id: ${partyGuest.id}');
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
          'party guest email not exist for id: ${partyGuest.id}');
    }

    try {
      freshGuest = freshGuest.copyWith(guestNames: partyGuest.guestNames);
    } catch (e) {
      Logx.em(
          _TAG,
          'party guest guestNames not exist for id: ${partyGuest.id}');
    }
    try {
      freshGuest = freshGuest.copyWith(guestsCount: partyGuest.guestsCount);
    } catch (e) {
      Logx.em(
          _TAG,
          'party guest guestsCount not exist for id: ${partyGuest.id}');
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
          'party guest guestStatus not exist for id: ${partyGuest.id}');
    }
    try {
      freshGuest = freshGuest.copyWith(gender: partyGuest.gender);
    } catch (e) {
      Logx.em(_TAG,
          'party guest gender not exist for id: ${partyGuest.id}');
    }

    try {
      freshGuest = freshGuest.copyWith(promoterId: partyGuest.promoterId);
    } catch (e) {
      Logx.em(_TAG,
          'party guest promoterId not exist for id: ${partyGuest.id}');
    }
    try {
      freshGuest = freshGuest.copyWith(isVip: partyGuest.isVip);
    } catch (e) {
      Logx.em(_TAG,
          'party guest isVip not exist for id: ${partyGuest.id}');
    }

    return freshGuest;
  }

  static PartyGuest freshPartyGuestMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    PartyGuest partyGuest = Dummy.getDummyPartyGuest(true);
    bool isModelChanged = false;

    try {
      partyGuest = partyGuest.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest id not exist');
    }
    try {
      partyGuest = partyGuest.copyWith(partyId: map['partyId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest partyId not exist for id: ' + partyGuest.id);
      isModelChanged = true;
    }
    try {
      partyGuest = partyGuest.copyWith(guestId: map['guestId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest guestId not exist for id: ' + partyGuest.id);
      isModelChanged = true;
    }
    try {
      partyGuest = partyGuest.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest name not exist for id: ' + partyGuest.id);
      isModelChanged = true;
    }
    try {
      partyGuest = partyGuest.copyWith(surname: map['surname'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest surname not exist for id: ' + partyGuest.id);
      isModelChanged = true;
    }
    try {
      partyGuest = partyGuest.copyWith(phone: map['phone'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest phone not exist for id: ' + partyGuest.id);
      isModelChanged = true;
    }
    try {
      partyGuest = partyGuest.copyWith(email: map['email'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest email not exist for id: ' + partyGuest.id);
      isModelChanged = true;
    }
    try {
      partyGuest = partyGuest.copyWith(guestsCount: map['guestsCount'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'partyGuest guestsCount not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }
    try {
      partyGuest =
          partyGuest.copyWith(guestsRemaining: map['guestsRemaining'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'partyGuest guestsRemaining not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }
    try {
      partyGuest = partyGuest.copyWith(guestNames: List<String>.from(map['guestNames']));
    } catch (e) {
      Logx.em(_TAG, 'partyGuest guestNames not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }

    try {
      partyGuest = partyGuest.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest createdAt not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }
    try {
      partyGuest = partyGuest.copyWith(isApproved: map['isApproved'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest isApproved not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }
    try {
      partyGuest = partyGuest.copyWith(
          isChallengeClicked: map['isChallengeClicked'] as bool);
    } catch (e) {
      Logx.em(_TAG,
          'partyGuest isChallengeClicked not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }
    try {
      partyGuest =
          partyGuest.copyWith(shouldBanUser: map['shouldBanUser'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'partyGuest shouldBanUser not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }
    try {
      partyGuest =
          partyGuest.copyWith(guestStatus: map['guestStatus'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'partyGuest guestStatus not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }
    try {
      partyGuest = partyGuest.copyWith(gender: map['gender'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest gender not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }

    try {
      partyGuest = partyGuest.copyWith(promoterId: map['promoterId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest promoterId not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }

    try {
      partyGuest = partyGuest.copyWith(isVip: map['isVip'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest isVip not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }

    if (isModelChanged &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.PROMOTER_LEVEL) {
      Logx.i(_TAG, 'updating party guest ${partyGuest.id}');
      FirestoreHelper.pushPartyGuest(partyGuest);
    }

    return partyGuest;
  }

  /** Party Interest **/
  static PartyInterest freshPartyInterest(PartyInterest partyInterest) {
    PartyInterest fresh = Dummy.getDummyPartyInterest();

    try {
      fresh = fresh.copyWith(id: partyInterest.id);
    } catch (e) {
      Logx.em(_TAG, 'party interest id not exist');
    }
    try {
      fresh = fresh.copyWith(partyId: partyInterest.partyId);
    } catch (e) {
      Logx.em(_TAG,
          'party interest name not exist for id: ${partyInterest.id}');
    }
    try {
      fresh = fresh.copyWith(userIds: partyInterest.userIds);
    } catch (e) {
      Logx.em(_TAG,
          'party interest userIds not exist for id: ${partyInterest.id}');
    }
    try {
      fresh = fresh.copyWith(initCount: partyInterest.initCount);
    } catch (e) {
      Logx.em(_TAG,
          'party interest initCount not exist for id: ${partyInterest.id}');
    }

    return fresh;
  }

  static PartyInterest freshPartyInterestMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    PartyInterest partyInterest = Dummy.getDummyPartyInterest();
    bool isModelChanged = false;

    try {
      partyInterest = partyInterest.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyInterest id not exist');
    }
    try {
      partyInterest = partyInterest.copyWith(partyId: map['partyId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyInterest partyId not exist for id: ${partyInterest.id}');
      isModelChanged = true;
    }
    try {
      partyInterest = partyInterest.copyWith(userIds: List<String>.from(map['userIds']));
    } catch (e) {
      Logx.em(_TAG, 'party artistIds not exist for id: ${partyInterest.id}');
      isModelChanged = true;
    }
    try {
      partyInterest = partyInterest.copyWith(initCount: map['initCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'partyInterest initCount not exist for id: ${partyInterest.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating party interest ${partyInterest.id}');
      FirestoreHelper.pushPartyInterest(partyInterest);
    }
    return partyInterest;
  }

  /** party photo **/
  static PartyPhoto freshPartyPhoto(PartyPhoto partyPhoto) {
    PartyPhoto fresh = Dummy.getDummyPartyPhoto();

    try {
      fresh = fresh.copyWith(id: partyPhoto.id);
    } catch (e) {
      Logx.em(_TAG, 'party photo id not exist');
    }
    try {
      fresh = fresh.copyWith(blocServiceId: partyPhoto.blocServiceId);
    } catch (e) {
      Logx.em(_TAG,
          'party photo blocServiceId not exist for id: ${partyPhoto.id}');
    }
    try {
      fresh = fresh.copyWith(loungeId: partyPhoto.loungeId);
    } catch (e) {
      Logx.em(_TAG,
          'party photo loungeId not exist for id: ${partyPhoto.id}');
    }
    try {
      fresh = fresh.copyWith(partyName: partyPhoto.partyName);
    } catch (e) {
      Logx.em(_TAG,
          'party photo partyName not exist for id: ${partyPhoto.id}');
    }
    try {
      fresh = fresh.copyWith(createdAt: partyPhoto.createdAt);
    } catch (e) {
      Logx.em(_TAG,
          'party photo createdAt not exist for id: ${partyPhoto.id}');
    }
    try {
      fresh = fresh.copyWith(partyDate: partyPhoto.partyDate);
    } catch (e) {
      Logx.em(_TAG,
          'party photo partyDate not exist for id: ${partyPhoto.id}');
    }
    try {
      fresh = fresh.copyWith(endTime: partyPhoto.endTime);
    } catch (e) {
      Logx.em(_TAG,
          'party photo endTime not exist for id: ${partyPhoto.id}');
    }
    try {
      fresh = fresh.copyWith(likers: partyPhoto.likers);
    } catch (e) {
      Logx.em(_TAG,
          'party photo likers not exist for id: ${partyPhoto.id}');
    }
    try {
      fresh = fresh.copyWith(initLikes: partyPhoto.initLikes);
    } catch (e) {
      Logx.em(_TAG,
          'party photo initLikes not exist for id: ${partyPhoto.id}');
    }
    try {
      fresh = fresh.copyWith(downloadCount: partyPhoto.downloadCount);
    } catch (e) {
      Logx.em(_TAG,
          'party photo downloadCount not exist for id: ${partyPhoto.id}');
    }
    try {
      fresh = fresh.copyWith(views: partyPhoto.views);
    } catch (e) {
      Logx.em(_TAG,
          'party photo views not exist for id: ${partyPhoto.id}');
    }
    try {
      fresh = fresh.copyWith(imageUrl: partyPhoto.imageUrl);
    } catch (e) {
      Logx.em(_TAG,
          'party photo imageUrl not exist for id: ${partyPhoto.id}');
    }
    try {
      fresh = fresh.copyWith(imageThumbUrl: partyPhoto.imageThumbUrl);
    } catch (e) {
      Logx.em(_TAG,
          'party photo imageThumbUrl not exist for id: ${partyPhoto.id}');
    }

    return fresh;
  }

  static PartyPhoto freshPartyPhotoMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    PartyPhoto partyPhoto = Dummy.getDummyPartyPhoto();
    bool isModelChanged = false;

    try {
      partyPhoto = partyPhoto.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto id not exist');
    }
    try {
      partyPhoto = partyPhoto.copyWith(partyName: map['partyName'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto partyName not exist for id: ${partyPhoto.id}');
      isModelChanged = true;
    }
    try {
      partyPhoto = partyPhoto.copyWith(blocServiceId: map['blocServiceId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto blocServiceId not exist for id: ${partyPhoto.id}');
      isModelChanged = true;
    }
    try {
      partyPhoto = partyPhoto.copyWith(loungeId: map['loungeId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto loungeId not exist for id: ${partyPhoto.id}');
      isModelChanged = true;
    }
    try {
      partyPhoto = partyPhoto.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto createdAt not exist for id: ${partyPhoto.id}');
      isModelChanged = true;
    }
    try {
      partyPhoto = partyPhoto.copyWith(partyDate: map['partyDate'] as int);
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto partyDate not exist for id: ${partyPhoto.id}');
      isModelChanged = true;
    }
    try {
      partyPhoto = partyPhoto.copyWith(endTime: map['endTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto endTime not exist for id: ${partyPhoto.id}');
      isModelChanged = true;
    }
    try {
      partyPhoto = partyPhoto.copyWith(likers: List<String>.from(map['likers']));
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto likers not exist for id: ${partyPhoto.id}');
      isModelChanged = true;
    }
    try {
      partyPhoto = partyPhoto.copyWith(initLikes: map['initLikes'] as int);
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto initLikes not exist for id: ${partyPhoto.id}');
      isModelChanged = true;
    }
    try {
      partyPhoto = partyPhoto.copyWith(downloadCount: map['downloadCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto downloadCount not exist for id: ${partyPhoto.id}');
      isModelChanged = true;
    }
    try {
      partyPhoto = partyPhoto.copyWith(views: map['views'] as int);
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto views not exist for id: ${partyPhoto.id}');
      isModelChanged = true;
    }
    try {
      partyPhoto = partyPhoto.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto imageUrl not exist for id: ${partyPhoto.id}');
      isModelChanged = true;
    }
    try {
      partyPhoto = partyPhoto.copyWith(imageThumbUrl: map['imageThumbUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto imageThumbUrl not exist for id: ${partyPhoto.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating party photo ${partyPhoto.id}');
      FirestoreHelper.pushPartyPhoto(partyPhoto);
    }
    return partyPhoto;
  }

  /** product **/
  static Product freshProductMap(Map<String, dynamic> map, bool shouldUpdate) {
    Product product = Dummy.getDummyProduct('', UserPreferences.myUser.id);

    bool isModelChanged = false;
    int intPrice = 0;

    try {
      product = product.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product id not exist');
    }
    try {
      product = product.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product name not exist for id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product = product.copyWith(price: map['price'] as double);
    } catch (e) {
      intPrice = map['price'] as int;
      product = product.copyWith(price: intPrice.toDouble());
      if (intPrice == 0) {
        Logx.i(_TAG, 'product price not exist for product id: ' + product.id);
        isModelChanged = true;
      }
    }
    try {
      product = product.copyWith(priceHighest: map['priceHighest'] as double);
    } catch (e) {
      intPrice = map['priceHighest'] as int;
      product = product.copyWith(priceHighest: intPrice.toDouble());
      Logx.em(
          _TAG, 'product priceHighest not exist for product id: ' + product.id);
      isModelChanged = true;
    }
    try {
      product = product.copyWith(priceLowest: map['priceLowest'] as double);
    } catch (e) {
      intPrice = map['priceLowest'] as int;
      product = product.copyWith(priceLowest: intPrice.toDouble());
      Logx.em(
          _TAG, 'product priceLowest not exist for product id: ' + product.id);
      isModelChanged = true;
    }
    try {
      product =
          product.copyWith(priceCommunity: map['priceCommunity'] as double);
    } catch (e) {
      intPrice = map['priceCommunity'] as int;
      product = product.copyWith(priceCommunity: intPrice.toDouble());
      Logx.em(_TAG,
          'product priceCommunity not exist for product id: ' + product.id);
      isModelChanged = true;
    }
    try {
      product = product.copyWith(type: map['type'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product type not exist for product id: ' + product.id);
      isModelChanged = true;
    }
    try {
      product = product.copyWith(category: map['category'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product category not exist for product id: ' + product.id);
      isModelChanged = true;
    }
    try {
      product = product.copyWith(description: map['description'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'product description not exist for product id: ' + product.id);
      isModelChanged = true;
    }
    try {
      product = product.copyWith(serviceId: map['serviceId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'product serviceId not exist for product id: ' + product.id);
      isModelChanged = true;
    }
    try {
      product = product.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product imageUrl not exist for product id: ' + product.id);
      isModelChanged = true;
    }
    try {
      product = product.copyWith(ownerId: map['ownerId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product ownerId not exist for product id: ' + product.id);
      isModelChanged = true;
    }
    try {
      product = product.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'product createdAt not exist for product id: ' + product.id);
      isModelChanged = true;
    }
    try {
      product = product.copyWith(isAvailable: map['isAvailable'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'product isAvailable not exist for product id: ' + product.id);
      isModelChanged = true;
    }
    try {
      product =
          product.copyWith(priceHighestTime: map['priceHighestTime'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'product priceHighestTime not exist for product id: ' + product.id);
      isModelChanged = true;
    }
    try {
      product =
          product.copyWith(priceLowestTime: map['priceLowestTime'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'product priceLowestTime not exist for product id: ' + product.id);
      isModelChanged = true;
    }
    try {
      product = product.copyWith(isOfferRunning: map['isOfferRunning'] as bool);
    } catch (e) {
      Logx.em(_TAG,
          'product isOfferRunning not exist for product id: ' + product.id);
      isModelChanged = true;
    }
    try {
      product = product.copyWith(isVeg: map['isVeg'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'product isVeg not exist for product id: ' + product.id);
      isModelChanged = true;
    }
    try {
      product = product.copyWith(blocIds: List<String>.from(map['blocIds']));
    } catch (e) {
      Logx.em(_TAG, 'product blocIds not exist for product id: ' + product.id);
      List<String> existingBlocIds = [product.serviceId];
      product = product.copyWith(blocIds: existingBlocIds);
      isModelChanged = true;
    }
    try {
      product = product.copyWith(priceBottle: map['priceBottle'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'product priceBottle not exist for product id: ' + product.id);
      isModelChanged = true;
    }

    if (isModelChanged &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating product ${product.id}');
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
          _TAG, 'product priceBottle not exist for id: ${product.id}');
    }

    return freshProduct;
  }

  /** promoter **/
  static Promoter freshPromoterMap(Map<String, dynamic> map, bool shouldUpdate) {
    Promoter promoter = Dummy.getDummyPromoter();
    bool isModelChanged = false;

    try {
      promoter = promoter.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'promoter id not exist');
    }
    try {
      promoter = promoter.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'promoter name not exist for id: ${promoter.id}');
      isModelChanged = true;
    }
    try {
      promoter = promoter.copyWith(type: map['type'] as String);
    } catch (e) {
      Logx.em(_TAG, 'promoter type not exist for id: ${promoter.id}');
      isModelChanged = true;
    }

    if (isModelChanged &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating promoter ${promoter.id}');
      FirestoreHelper.pushPromoter(promoter);
    }

    return promoter;
  }

  static Promoter freshPromoter(Promoter promoter) {
    Promoter fresh = Dummy.getDummyPromoter();

    try {
      fresh = fresh.copyWith(id: promoter.id);
    } catch (e) {
      Logx.em(_TAG, 'promoter id not exist');
    }
    try {
      fresh = fresh.copyWith(name: promoter.name);
    } catch (e) {
      Logx.em(_TAG, 'promoter name not exist for id: ${promoter.id}');
    }
    try {
      fresh = fresh.copyWith(type: promoter.type);
    } catch (e) {
      Logx.em(_TAG, 'promoter type not exist for id: ${promoter.id}');
    }

    return fresh;
  }

  /** promoter guest **/
  static PromoterGuest freshPromoterGuestMap(Map<String, dynamic> map, bool shouldUpdate) {
    PromoterGuest promoterGuest = Dummy.getDummyPromoterGuest();
    bool isModelChanged = false;

    try {
      promoterGuest = promoterGuest.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest id not exist');
    }
    try {
      promoterGuest = promoterGuest.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest name not exist for id: ${promoterGuest.id}');
      isModelChanged = true;
    }
    try {
      promoterGuest = promoterGuest.copyWith(phone: map['phone'] as String);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest phone not exist for id: ${promoterGuest.id}');
      isModelChanged = true;
    }
    try {
      promoterGuest = promoterGuest.copyWith(promoterId: map['promoterId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest promoterId not exist for id: ${promoterGuest.id}');
      isModelChanged = true;
    }
    try {
      promoterGuest = promoterGuest.copyWith(blocUserId: map['blocUserId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest blocUserId not exist for id: ${promoterGuest.id}');
      isModelChanged = true;
    }
    try {
      promoterGuest = promoterGuest.copyWith(partyGuestId: map['partyGuestId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest partyGuestId not exist for id: ${promoterGuest.id}');
      isModelChanged = true;
    }
    try {
      promoterGuest = promoterGuest.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest createdAt not exist for id: ${promoterGuest.id}');
      isModelChanged = true;
    }
    try {
      promoterGuest = promoterGuest.copyWith(hasAttended: map['hasAttended'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest hasAttended not exist for id: ${promoterGuest.id}');
      isModelChanged = true;
    }


    if (isModelChanged &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.PROMOTER_LEVEL) {
      Logx.i(_TAG, 'updating promoter guest ${promoterGuest.id}');
      FirestoreHelper.pushPromoterGuest(promoterGuest);
    }

    return promoterGuest;
  }

  static PromoterGuest freshPromoterGuest(PromoterGuest promoterGuest) {
    PromoterGuest fresh = Dummy.getDummyPromoterGuest();

    try {
      fresh = fresh.copyWith(id: promoterGuest.id);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest id not exist');
    }
    try {
      fresh = fresh.copyWith(name: promoterGuest.name);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest name not exist for id: ${promoterGuest.id}');
    }
    try {
      fresh = fresh.copyWith(phone: promoterGuest.phone);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest phone not exist for id: ${promoterGuest.id}');
    }
    try {
      fresh = fresh.copyWith(promoterId: promoterGuest.promoterId);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest promoterId not exist for id: ${promoterGuest.id}');
    }
    try {
      fresh = fresh.copyWith(blocUserId: promoterGuest.blocUserId);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest blocUserId not exist for id: ${promoterGuest.id}');
    }
    try {
      fresh = fresh.copyWith(partyGuestId: promoterGuest.partyGuestId);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest partyGuestId not exist for id: ${promoterGuest.id}');
    }
    try {
      fresh = fresh.copyWith(createdAt: promoterGuest.createdAt);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest createdAt not exist for id: ${promoterGuest.id}');
    }
    try {
      fresh = fresh.copyWith(hasAttended: promoterGuest.hasAttended);
    } catch (e) {
      Logx.em(_TAG, 'promoter guest hasAttended not exist for id: ${promoterGuest.id}');
    }

    return fresh;
  }

  /** quick order **/
  static QuickOrder freshQuickOrderMap(Map<String, dynamic> map, bool shouldUpdate) {
    QuickOrder quickOrder = Dummy.getDummyQuickOrder();
    bool isModelChanged = false;

    try {
      quickOrder = quickOrder.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'quick order id not exist');
    }
    try {
      quickOrder = quickOrder.copyWith(custId: map['custId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'quick order custId not exist for id: ${quickOrder.id}');
      isModelChanged = true;
    }
    try {
      quickOrder = quickOrder.copyWith(custPhone: map['custPhone'] as int);
    } catch (e) {
      Logx.em(_TAG, 'quick order custPhone not exist for id: ${quickOrder.id}');
      isModelChanged = true;
    }
    try {
      quickOrder = quickOrder.copyWith(productId: map['productId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'quick order productId not exist for id: ${quickOrder.id}');
      isModelChanged = true;
    }
    try {
      quickOrder = quickOrder.copyWith(quantity: map['quantity'] as int);
    } catch (e) {
      Logx.em(_TAG, 'quick order quantity not exist for id: ${quickOrder.id}');
      isModelChanged = true;
    }
    try {
      quickOrder = quickOrder.copyWith(table: map['table'] as String);
    } catch (e) {
      Logx.em(_TAG, 'quick order table not exist for id: ${quickOrder.id}');
      isModelChanged = true;
    }
    try {
      quickOrder = quickOrder.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'quick order createdAt not exist for id: ${quickOrder.id}');
      isModelChanged = true;
    }
    try {
      quickOrder = quickOrder.copyWith(status: map['status'] as String);
    } catch (e) {
      Logx.em(_TAG, 'quick order status not exist for id: ${quickOrder.id}');
      isModelChanged = true;
    }
    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating quick order ${quickOrder.id}');
      FirestoreHelper.pushQuickOrder(quickOrder);
    }

    return quickOrder;
  }

  static QuickOrder freshQuickOrder(QuickOrder quickOrder) {
    QuickOrder fresh = Dummy.getDummyQuickOrder();

    try {
      fresh = fresh.copyWith(id: quickOrder.id);
    } catch (e) {
      Logx.em(_TAG, 'quick order id not exist');
    }
    try {
      fresh = fresh.copyWith(custId: quickOrder.custId);
    } catch (e) {
      Logx.em(_TAG, 'quick order custId not exist for id: ${quickOrder.id}');
    }
    try {
      fresh = fresh.copyWith(custPhone: quickOrder.custPhone);
    } catch (e) {
      Logx.em(_TAG, 'quick order custPhone not exist for id: ${quickOrder.id}');
    }
    try {
      fresh = fresh.copyWith(productId: quickOrder.productId);
    } catch (e) {
      Logx.em(_TAG, 'quick order productId not exist for id: ${quickOrder.id}');
    }
    try {
      fresh = fresh.copyWith(quantity: quickOrder.quantity);
    } catch (e) {
      Logx.em(_TAG, 'quick order quantity not exist for id: ${quickOrder.id}');
    }
    try {
      fresh = fresh.copyWith(table: quickOrder.table);
    } catch (e) {
      Logx.em(_TAG, 'quick order table not exist for id: ${quickOrder.id}');
    }
    try {
      fresh = fresh.copyWith(createdAt: quickOrder.createdAt);
    } catch (e) {
      Logx.em(_TAG, 'quick order createdAt not exist for id: ${quickOrder.id}');
    }
    try {
      fresh = fresh.copyWith(status: quickOrder.status);
    } catch (e) {
      Logx.em(_TAG, 'quick order status not exist for id: ${quickOrder.id}');
    }

    return fresh;
  }

  /** quick table **/
  static QuickTable freshQuickTableMap(Map<String, dynamic> map, bool shouldUpdate) {
    QuickTable quickTable = Dummy.getDummyQuickTable();
    bool isModelChanged = true;

    try {
      quickTable = quickTable.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'quick table id not exist');
    }
    try {
      quickTable = quickTable.copyWith(phone: map['phone'] as int);
    } catch (e) {
      Logx.em(_TAG, 'quick table phone not exist for id: ${quickTable.id}');
      isModelChanged = true;
    }
    try {
      quickTable = quickTable.copyWith(tableName: map['tableName'] as String);
    } catch (e) {
      Logx.em(_TAG, 'quick table tableName not exist for id: ${quickTable.id}');
      isModelChanged = true;
    }
    try {
      quickTable = quickTable.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'quick table createdAt not exist for id: ${quickTable.id}');
      isModelChanged = true;
    }

    // if (isModelChanged && shouldUpdate && UserPreferences.myUser.clearanceLevel>=Constants.ADMIN_LEVEL) {
    //   Logx.i(_TAG, 'updating quick table ${quickTable.id}');
    //   FirestoreHelper.pushQuickTable(quickTable);
    // }

    return quickTable;
  }

  static QuickTable freshQuickTable(QuickTable quickTable) {
    QuickTable fresh = Dummy.getDummyQuickTable();

    try {
      fresh = fresh.copyWith(id: quickTable.id);
    } catch (e) {
      Logx.em(_TAG, 'quick table id not exist');
    }
    try {
      fresh = fresh.copyWith(phone: quickTable.phone);
    } catch (e) {
      Logx.em(_TAG, 'quick table phone not exist for id: ${quickTable.id}');
    }
    try {
      fresh = fresh.copyWith(tableName: quickTable.tableName);
    } catch (e) {
      Logx.em(_TAG, 'quick table tableName not exist for id: ${quickTable.id}');
    }
    try {
      fresh = fresh.copyWith(createdAt: quickTable.createdAt);
    } catch (e) {
      Logx.em(_TAG, 'quick table createdAt not exist for id: ${quickTable.id}');
    }

    return fresh;
  }

  /** reservation **/
  static Reservation freshReservationMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    Reservation reservation =
    Dummy.getDummyReservation(Constants.blocServiceId);
    bool isModelChanged = false;

    try {
      reservation = reservation.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'reservation id not exist');
    }
    try {
      reservation = reservation.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'reservation name not exist for reservation id: ${reservation.id}');
      isModelChanged = true;
    }
    try {
      reservation =
          reservation.copyWith(blocServiceId: map['blocServiceId'] as String);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation blocServiceId not exist for reservation id: ' +
              reservation.id);
      isModelChanged = true;
    }
    try {
      reservation =
          reservation.copyWith(customerId: map['customerId'] as String);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation customerId not exist for reservation id: ' +
              reservation.id);
      isModelChanged = true;
    }
    try {
      reservation = reservation.copyWith(phone: map['phone'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'reservation phone not exist for reservation id: ' + reservation.id);
      isModelChanged = true;
    }
    try {
      reservation =
          reservation.copyWith(guestsCount: map['guestsCount'] as int);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation guestsCount not exist for reservation id: ' +
              reservation.id);
      isModelChanged = true;
    }
    try {
      reservation = reservation.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation createdAt not exist for reservation id: ' +
              reservation.id);
      isModelChanged = true;
    }
    try {
      reservation =
          reservation.copyWith(arrivalDate: map['arrivalDate'] as int);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation arrivalDate not exist for reservation id: ' +
              reservation.id);
      isModelChanged = true;
    }
    try {
      reservation =
          reservation.copyWith(arrivalTime: map['arrivalTime'] as String);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation arrivalTime not exist for reservation id: ' +
              reservation.id);
      isModelChanged = true;
    }

    try {
      reservation = reservation.copyWith(
          bottleProductIds: List<String>.from(map['bottleProductIds']));
    } catch (e) {
      Logx.em(_TAG,
          'reservation bottleProductIds not exist for id: ' + reservation.id);
      isModelChanged = true;
    }
    try {
      reservation = reservation.copyWith(
          bottleNames: List<String>.from(map['bottleNames']));
    } catch (e) {
      Logx.em(
          _TAG, 'reservation bottleNames not exist for id: ' + reservation.id);
      isModelChanged = true;
    }
    try {
      reservation =
          reservation.copyWith(specialRequest: map['specialRequest'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'reservation specialRequest not exist for id: ' + reservation.id);
      isModelChanged = true;
    }
    try {
      reservation = reservation.copyWith(occasion: map['occasion'] as String);
    } catch (e) {
      Logx.em(_TAG, 'reservation occasion not exist for id: ' + reservation.id);
      isModelChanged = true;
    }
    try {
      reservation = reservation.copyWith(isApproved: map['isApproved'] as bool);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation isApproved not exist for reservation id: ' +
              reservation.id);
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
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
          'reservation occasion not exist for id: ${reservation.id}');
    }

    try {
      freshReservation =
          freshReservation.copyWith(isApproved: reservation.isApproved);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation isApproved not exist for id: ${reservation.id}');
    }

    return freshReservation;
  }

  /** ticket **/
  static Ticket freshTicketMap(Map<String, dynamic> map, bool shouldUpdate) {
    Ticket ticket = Dummy.getDummyTicket();
    bool isModelChanged = false;

    try {
      ticket = ticket.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ticket id not exist');
    }
    try {
      ticket = ticket.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ticket name not exist for id: ${ticket.id}');
      isModelChanged = true;
    }

    try {
      ticket = ticket.copyWith(partyId: map['partyId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ticket partyId not exist for id: ${ticket.id}');
      isModelChanged = true;
    }
    try {
      ticket = ticket.copyWith(customerId: map['customerId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ticket customerId not exist for ticket id: ' + ticket.id);
      isModelChanged = true;
    }
    try {
      ticket = ticket.copyWith(transactionId: map['transactionId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'ticket transactionId not exist for ticket id: ' + ticket.id);
      isModelChanged = true;
    }
    try {
      ticket = ticket.copyWith(phone: map['phone'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ticket phone not exist for ticket id: ' + ticket.id);
      isModelChanged = true;
    }
    try {
      ticket = ticket.copyWith(email: map['email'] as String);
    } catch (e) {
      Logx.em(_TAG, 'ticket email not exist for ticket id: ' + ticket.id);
      isModelChanged = true;
    }
    try {
      ticket = ticket.copyWith(entryCount: map['entryCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'ticket entryCount not exist for ticket id: ' + ticket.id);
      isModelChanged = true;
    }
    try {
      ticket =
          ticket.copyWith(entriesRemaining: map['entriesRemaining'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'ticket entriesRemaining not exist for ticket id: ' + ticket.id);
      isModelChanged = true;
    }
    try {
      ticket = ticket.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'ticket createdAt not exist for ticket id: ' + ticket.id);
      isModelChanged = true;
    }
    try {
      ticket = ticket.copyWith(isPaid: map['isPaid'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'ticket isPaid not exist for ticket id: ' + ticket.id);
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
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
    bool isModelChanged = false;

    try {
      uiPhoto = uiPhoto.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'uiPhoto id not exist');
    }
    try {
      uiPhoto = uiPhoto.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'uiPhoto name not exist for id: ' + uiPhoto.id);
      isModelChanged = true;
    }
    try {
      uiPhoto =
          uiPhoto.copyWith(imageUrls: List<String>.from(map['imageUrls']));
    } catch (e) {
      Logx.em(_TAG, 'uiPhoto imageUrls not exist for id: ' + uiPhoto.id);
      List<String> temp = [];
      uiPhoto = uiPhoto.copyWith(imageUrls: temp);
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
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
    bool isModelChanged = false;

    try {
      user = user.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user id not exist');
    }
    try {
      user = user.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user name not exist for id: ${user.id}');
      isModelChanged = true;
    }
    try {
      user = user.copyWith(surname: map['surname'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user surname not exist for id: ${user.id}');
      isModelChanged = true;
    }
    try {
      user = user.copyWith(phoneNumber: map['phoneNumber'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user phoneNumber not exist for id: ${user.id}');
      isModelChanged = true;
    }
    try {
      user = user.copyWith(birthYear: map['birthYear'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user birthYear not exist for id: ${user.id}');
      isModelChanged = true;
    }
    try {
      user = user.copyWith(email: map['email'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user email not exist for id: ${user.id}');
      isModelChanged = true;
    }
    try {
      user = user.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user imageUrl not exist for user id: ' + user.id);
      isModelChanged = true;
    }
    try {
      user = user.copyWith(gender: map['gender'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user gender not exist for user id: ' + user.id);
      isModelChanged = true;
    }

    try {
      user = user.copyWith(clearanceLevel: map['clearanceLevel'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user clearanceLevel not exist for user id: ' + user.id);
      isModelChanged = true;
    }
    try {
      user = user.copyWith(challengeLevel: map['challengeLevel'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user challengeLevel not exist for user id: ' + user.id);
      isModelChanged = true;
    }

    try {
      user = user.copyWith(fcmToken: map['fcmToken'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user fcmToken not exist for user id: ' + user.id);
      isModelChanged = true;
    }
    try {
      user = user.copyWith(blocServiceId: map['blocServiceId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user blocServiceId not exist for user id: ' + user.id);
      isModelChanged = true;
    }

    try {
      user = user.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user createdAt not exist for user id: ' + user.id);
      isModelChanged = true;
    }
    try {
      user = user.copyWith(lastSeenAt: map['lastSeenAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user lastSeenAt not exist for user id: ' + user.id);
      isModelChanged = true;
    }

    try {
      user = user.copyWith(isBanned: map['isBanned'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'user isBanned not exist for id: ${user.id}');
      isModelChanged = true;
    }
    try {
      user = user.copyWith(isAppUser: map['isAppUser'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'user isAppUser not exist for id: ${user.id}');
      isModelChanged = true;
    }
    try {
      user = user.copyWith(appVersion: map['appVersion'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user appVersion not exist for id: ${user.id}');
      isModelChanged = true;
    }
    try {
      user = user.copyWith(isIos: map['isIos'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'user isIos not exist for id: ${user.id}');
      isModelChanged = true;
    }
    try {
      user = user.copyWith(isAppReviewed: map['isAppReviewed'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'user isAppReviewed not exist for id: ${user.id}');
      isModelChanged = true;
    }
    try {
      user = user.copyWith(lastReviewTime: map['lastReviewTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user lastReviewTime not exist for id: ${user.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating user ${user.id}');
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
      Logx.em(_TAG, 'name not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(surname: user.surname);
    } catch (e) {
      Logx.em(_TAG, 'user surname not exist for id: ${user.id}');
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
      Logx.em(_TAG, 'user clearanceLevel not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(challengeLevel: user.challengeLevel);
    } catch (e) {
      Logx.em(_TAG, 'user challengeLevel not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(phoneNumber: user.phoneNumber);
    } catch (e) {
      Logx.em(_TAG, 'user phoneNumber not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(birthYear: user.birthYear);
    } catch (e) {
      Logx.em(_TAG, 'user birthYear not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(fcmToken: user.fcmToken);
    } catch (e) {
      Logx.em(_TAG, 'user fcmToken not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(blocServiceId: user.blocServiceId);
    } catch (e) {
      Logx.em(_TAG, 'user blocServiceId not exist for id: ${user.id}');
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
      Logx.em(_TAG, 'user isAppUser not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(appVersion: user.appVersion);
    } catch (e) {
      Logx.em(_TAG, 'user appVersion not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(isIos: user.isIos);
    } catch (e) {
      Logx.em(_TAG, 'user isIos not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(isAppReviewed: user.isAppReviewed);
    } catch (e) {
      Logx.em(_TAG, 'user isAppReviewed not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(lastReviewTime: user.lastReviewTime);
    } catch (e) {
      Logx.em(_TAG, 'user lastReviewTime not exist for id: ${user.id}');
    }

    return freshUser;
  }

  /** user lounge **/
  static UserLounge freshUserLoungeMap(Map<String, dynamic> map, bool shouldUpdate) {
    UserLounge userLounge = Dummy.getDummyUserLounge();
    bool isModelChanged = false;

    try {
      userLounge = userLounge.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'userLounge id not exist');
    }
    try {
      userLounge = userLounge.copyWith(userId: map['userId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'userLounge userId not exist for id: ${userLounge.id}');
      isModelChanged = true;
    }
    try {
      userLounge = userLounge.copyWith(userFcmToken: map['userFcmToken'] as String);
    } catch (e) {
      Logx.em(_TAG, 'userLounge userFcmToken not exist for id: ${userLounge.id}');
      isModelChanged = true;
    }
    try {
      userLounge = userLounge.copyWith(loungeId: map['loungeId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'userLounge loungeId not exist for id: ${userLounge.id}');
      isModelChanged = true;
    }
    try {
      userLounge = userLounge.copyWith(lastAccessedTime: map['lastAccessedTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'userLounge lastAccessedTime not exist for id: ${userLounge.id}');
      isModelChanged = true;
    }
    try {
      userLounge = userLounge.copyWith(isAccepted: map['isAccepted'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'userLounge isAccepted not exist for id: ${userLounge.id}');
      isModelChanged = true;
    }
    try {
      userLounge = userLounge.copyWith(isBanned: map['isBanned'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'userLounge isBanned not exist for id: ${userLounge.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating userLounge ${userLounge.id}');
      FirestoreHelper.pushUserLounge(userLounge);
    }

    return userLounge;
  }

  static UserLounge freshUserLounge(UserLounge userLounge) {
    UserLounge freshUserLounge = Dummy.getDummyUserLounge();

    try {
      freshUserLounge = freshUserLounge.copyWith(id: userLounge.id);
    } catch (e) {
      Logx.em(_TAG, 'userLounge id not exist');
    }
    try {
      freshUserLounge = freshUserLounge.copyWith(userId: userLounge.userId);
    } catch (e) {
      Logx.em(_TAG, 'userLounge userId exist for id: ${userLounge.id}');
    }
    try {
      freshUserLounge = freshUserLounge.copyWith(userFcmToken: userLounge.userFcmToken);
    } catch (e) {
      Logx.em(_TAG, 'userLounge userFcmToken exist for id: ${userLounge.id}');
    }
    try {
      freshUserLounge = freshUserLounge.copyWith(loungeId: userLounge.loungeId);
    } catch (e) {
      Logx.em(_TAG, 'userLounge userLounge not exist for id: ${userLounge.id}');
    }
    try {
      freshUserLounge = freshUserLounge.copyWith(lastAccessedTime: userLounge.lastAccessedTime);
    } catch (e) {
      Logx.em(_TAG, 'userLounge lastAccessedTime not exist for id: ${userLounge.id}');
    }
    try {
      freshUserLounge = freshUserLounge.copyWith(isAccepted: userLounge.isAccepted);
    } catch (e) {
      Logx.em(_TAG, 'userLounge isAccepted not exist for id: ${userLounge.id}');
    }
    try {
      freshUserLounge = freshUserLounge.copyWith(isBanned: userLounge.isBanned);
    } catch (e) {
      Logx.em(_TAG, 'userLounge isBanned not exist for id: ${userLounge.id}');
    }

    return freshUserLounge;
  }
}