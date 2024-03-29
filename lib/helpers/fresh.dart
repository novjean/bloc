import 'package:bloc/db/entity/history_music.dart';
import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/db/entity/ui_photo.dart';

import '../db/entity/ad.dart';
import '../db/entity/ad_campaign.dart';
import '../db/entity/advert.dart';
import '../db/entity/bloc.dart';
import '../db/entity/bloc_service.dart';
import '../db/entity/captain_service.dart';
import '../db/entity/category.dart';
import '../db/entity/celebration.dart';
import '../db/entity/challenge.dart';
import '../db/entity/challenge_action.dart';
import '../db/entity/city.dart';
import '../db/entity/config.dart';
import '../db/entity/friend.dart';
import '../db/entity/friend_notification.dart';
import '../db/entity/lounge_chat.dart';
import '../db/entity/genre.dart';
import '../db/entity/lounge.dart';
import '../db/entity/notification_test.dart';
import '../db/entity/organizer.dart';
import '../db/entity/party.dart';
import '../db/entity/party_interest.dart';
import '../db/entity/party_photo.dart';
import '../db/entity/support_chat.dart';
import '../db/entity/tix.dart';
import '../db/entity/party_tix_tier.dart';
import '../db/entity/product.dart';
import '../db/entity/promoter.dart';
import '../db/entity/promoter_guest.dart';
import '../db/entity/quick_order.dart';
import '../db/entity/quick_table.dart';
import '../db/entity/reservation.dart';
import '../db/entity/tix_backup.dart';
import '../db/entity/tix_tier_item.dart';
import '../db/entity/user.dart';
import '../db/entity/user_bloc.dart';
import '../db/entity/user_lounge.dart';
import '../db/entity/user_organizer.dart';
import '../db/entity/user_photo.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../utils/constants.dart';
import '../utils/logx.dart';
import '../utils/number_utils.dart';
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
      adCampaign = adCampaign.copyWith(clickCount: map['clickCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign clickCount not exist for ad campaign id: ${adCampaign.id}');
      isModelChanged = true;
    }
    try {
      adCampaign = adCampaign.copyWith(views: map['views'] as int);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign views not exist for ad campaign id: ${adCampaign.id}');
      isModelChanged = true;
    }
    try {
      adCampaign = adCampaign.copyWith(isActive: map['isActive'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign isActive not exist for ad campaign id: ${adCampaign.id}');
      isModelChanged = true;
    }
    try {
      adCampaign = adCampaign.copyWith(isStorySize: map['isStorySize'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign isStorySize not exist for id: ${adCampaign.id}');
      isModelChanged = true;
    }
    try {
      adCampaign = adCampaign.copyWith(isPartyAd: map['isPartyAd'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign isPartyAd not exist for id: ${adCampaign.id}');
      isModelChanged = true;
    }
    try {
      adCampaign = adCampaign.copyWith(partyId: map['partyId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign partyId not exist for id: ${adCampaign.id}');
      isModelChanged = true;
    }

    try {
      adCampaign = adCampaign.copyWith(isPurchased: map['isPurchased'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign isPurchased not exist for id: ${adCampaign.id}');
      isModelChanged = true;
    }
    try {
      adCampaign = adCampaign.copyWith(advertId: map['advertId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign advertId not exist for id: ${adCampaign.id}');
      isModelChanged = true;
    }

    try {
      adCampaign = adCampaign.copyWith(startTime: map['startTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign startTime not exist for id: ${adCampaign.id}');
      isModelChanged = true;
    }
    try {
      adCampaign = adCampaign.copyWith(endTime: map['endTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign endTime not exist for id: ${adCampaign.id}');
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
      Logx.em(_TAG, 'adCampaign linkUrl not exist for id: ${adCampaign.id}');
    }
    try {
      fresh = fresh.copyWith(clickCount: adCampaign.clickCount);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign clickCount not exist for id: ${adCampaign.id}');
    }
    try {
      fresh = fresh.copyWith(views: adCampaign.views);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign views not exist for id: ${adCampaign.id}');
    }
    try {
      fresh = fresh.copyWith(isActive: adCampaign.isActive);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign isActive not exist for id: ${adCampaign.id}');
    }
    try {
      fresh = fresh.copyWith(isStorySize: adCampaign.isStorySize);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign isStorySize not exist for id: ${adCampaign.id}');
    }

    try {
      fresh = fresh.copyWith(isPartyAd: adCampaign.isPartyAd);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign isPartyAd not exist for id: ${adCampaign.id}');
    }
    try {
      fresh = fresh.copyWith(partyId: adCampaign.partyId);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign partyId not exist for id: ${adCampaign.id}');
    }

    try {
      fresh = fresh.copyWith(isPurchased: adCampaign.isPurchased);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign isPurchased not exist for id: ${adCampaign.id}');
    }
    try {
      fresh = fresh.copyWith(advertId: adCampaign.advertId);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign advertId not exist for id: ${adCampaign.id}');
    }

    try {
      fresh = fresh.copyWith(startTime: adCampaign.startTime);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign startTime not exist for id: ${adCampaign.id}');
    }
    try {
      fresh = fresh.copyWith(endTime: adCampaign.endTime);
    } catch (e) {
      Logx.em(_TAG, 'adCampaign endTime not exist for id: ${adCampaign.id}');
    }

    return fresh;
  }

  /** advert **/
  static Advert freshAdvertMap(Map<String, dynamic> map, bool shouldUpdate) {
    Advert advert = Dummy.getDummyAdvert();

    bool isModelChanged = false;

    try {
      advert = advert.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'advert id not exist');
    }
    try {
      advert = advert.copyWith(title: map['title'] as String);
    } catch (e) {
      Logx.em(_TAG, 'advert title not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(userId: map['userId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'advert userId not exist for id: ${advert.id}');
      isModelChanged = true;
    }

    try {
      advert = advert.copyWith(userName: map['userName'] as String);
    } catch (e) {
      Logx.em(_TAG, 'advert userName not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(userPhone: map['userPhone'] as String);
    } catch (e) {
      Logx.em(_TAG, 'advert userPhone not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(userEmail: map['userEmail'] as String);
    } catch (e) {
      Logx.em(_TAG, 'advert userEmail not exist for id: ${advert.id}');
      isModelChanged = true;
    }

    try {
      advert = advert.copyWith(imageUrls: List<String>.from(map['imageUrls']));
    } catch (e) {
      Logx.em(_TAG, 'advert imageUrls not exist for id: ${advert.id}');
      advert = advert.copyWith(imageUrls: []);
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(linkUrl: map['linkUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'advert linkUrl not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(clickCount: map['clickCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'advert clickCount not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(views: map['views'] as int);
    } catch (e) {
      Logx.em(_TAG, 'advert views not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(isActive: map['isActive'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'advert isActive not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(isPaused: map['isPaused'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'advert isPaused not exist for id: ${advert.id}');
      isModelChanged = true;
    }

    try {
      advert = advert.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'advert createdAt not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(startTime: map['startTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'advert startTime not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(endTime: map['endTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'advert endTime not exist for id: ${advert.id}');
      isModelChanged = true;
    }

    try {
      advert = advert.copyWith(isSuccess: map['isSuccess'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'advert isSuccess not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(isCompleted: map['isCompleted'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'advert isCompleted not exist for id: ${advert.id}');
      isModelChanged = true;
    }

    try {
      advert = advert.copyWith(merchantTransactionId: map['merchantTransactionId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'advert merchantTransactionId not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(transactionId: map['transactionId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'advert transactionId not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(transactionResponseCode: map['transactionResponseCode'] as String);
    } catch (e) {
      Logx.em(_TAG, 'advert transactionResponseCode not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(result: map['result'] as String);
    } catch (e) {
      Logx.em(_TAG, 'advert result not exist  for id: ${advert.id}');
      isModelChanged = true;
    }

    try {
      advert = advert.copyWith(igst: map['igst'] as double);
    } catch (e) {
      Logx.em(_TAG, 'advert igst not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(subTotal: map['subTotal'] as double);
    } catch (e) {
      Logx.em(_TAG, 'advert subTotal not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(bookingFee: map['bookingFee'] as double);
    } catch (e) {
      Logx.em(_TAG, 'advert bookingFee not exist for id: ${advert.id}');
      isModelChanged = true;
    }
    try {
      advert = advert.copyWith(total: map['total'] as double);
    } catch (e) {
      Logx.em(_TAG, 'advert total not exist for id: ${advert.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating advert ${advert.id}');
      FirestoreHelper.pushAdvert(advert);
    }

    return advert;
  }

  static Advert freshAdvert(Advert advert) {
    Advert fresh = Dummy.getDummyAdvert();

    try {
      fresh = fresh.copyWith(id: advert.id);
    } catch (e) {
      Logx.em(_TAG, 'advert id not exist');
    }
    try {
      fresh = fresh.copyWith(title: advert.title);
    } catch (e) {
      Logx.em(_TAG, 'advert title not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(userId: advert.userId);
    } catch (e) {
      Logx.em(_TAG, 'advert userId not exist for id: ${advert.id}');
    }

    try {
      fresh = fresh.copyWith(userName: advert.userName);
    } catch (e) {
      Logx.em(_TAG, 'advert userName not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(userPhone: advert.userPhone);
    } catch (e) {
      Logx.em(_TAG, 'advert userPhone not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(userEmail: advert.userEmail);
    } catch (e) {
      Logx.em(_TAG, 'advert userEmail not exist for id: ${advert.id}');
    }

    try {
      fresh = fresh.copyWith(imageUrls: advert.imageUrls);
    } catch (e) {
      Logx.em(_TAG, 'advert imageUrls not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(linkUrl: advert.linkUrl);
    } catch (e) {
      Logx.em(_TAG, 'advert linkUrl not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(clickCount: advert.clickCount);
    } catch (e) {
      Logx.em(_TAG, 'advert clickCount not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(views: advert.views);
    } catch (e) {
      Logx.em(_TAG, 'advert views not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(isActive: advert.isActive);
    } catch (e) {
      Logx.em(_TAG, 'advert isActive not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(isPaused: advert.isPaused);
    } catch (e) {
      Logx.em(_TAG, 'advert isPaused not exist for id: ${advert.id}');
    }

    try {
      fresh = fresh.copyWith(createdAt: advert.createdAt);
    } catch (e) {
      Logx.em(_TAG, 'advert createdAt not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(startTime: advert.startTime);
    } catch (e) {
      Logx.em(_TAG, 'advert startTime not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(endTime: advert.endTime);
    } catch (e) {
      Logx.em(_TAG, 'advert endTime not exist for id: ${advert.id}');
    }

    try {
      fresh = fresh.copyWith(isSuccess: advert.isSuccess);
    } catch (e) {
      Logx.em(_TAG, 'advert isSuccess not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(isCompleted: advert.isCompleted);
    } catch (e) {
      Logx.em(_TAG, 'advert isCompleted not exist for id: ${advert.id}');
    }

    try {
      fresh = fresh.copyWith(merchantTransactionId: advert.merchantTransactionId);
    } catch (e) {
      Logx.em(_TAG, 'advert merchantTransactionId not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(transactionId: advert.transactionId);
    } catch (e) {
      Logx.em(_TAG, 'advert transactionId not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(transactionResponseCode: advert.transactionResponseCode);
    } catch (e) {
      Logx.em(_TAG, 'advert transactionResponseCode not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(result: advert.result);
    } catch (e) {
      Logx.em(_TAG, 'advert result not exist for id: ${advert.id}');
    }

    try {
      fresh = fresh.copyWith(igst: advert.igst);
    } catch (e) {
      Logx.em(_TAG, 'advert igst not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(subTotal: advert.subTotal);
    } catch (e) {
      Logx.em(_TAG, 'advert subTotal not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(bookingFee: advert.bookingFee);
    } catch (e) {
      Logx.em(_TAG, 'advert bookingFee not exist for id: ${advert.id}');
    }
    try {
      fresh = fresh.copyWith(total: advert.total);
    } catch (e) {
      Logx.em(_TAG, 'advert total not exist for id: ${advert.id}');
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
      Logx.em(_TAG, 'bloc createdAt not exist for id: ${bloc.id}');
      isModelChanged = true;
    }
    try {
      bloc = bloc.copyWith(isActive: map['isActive'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'bloc isActive not exist for id: ${bloc.id}');
      isModelChanged = true;
    }
    try {
      bloc = bloc.copyWith(imageUrls: List<String>.from(map['imageUrls']));
    } catch (e) {
      Logx.em(_TAG, 'bloc imageUrls not exist for id: ${bloc.id}');
      List<String> temp = [];
      bloc = bloc.copyWith(imageUrls: temp);
      isModelChanged = true;
    }

    try {
      bloc = bloc.copyWith(latitude: map['latitude'] as double);
    } catch (e) {
      Logx.em(_TAG, 'bloc latitude not exist for id: ${bloc.id}');
      isModelChanged = true;
    }
    try {
      bloc = bloc.copyWith(longitude: map['longitude'] as double);
    } catch (e) {
      Logx.em(_TAG, 'bloc longitude not exist for id: ${bloc.id}');
      isModelChanged = true;
    }
    try {
      bloc = bloc.copyWith(mapImageUrl: map['mapImageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc mapImageUrl not exist for id: ${bloc.id}');
      isModelChanged = true;
    }

    try {
      bloc = bloc.copyWith(orderPriority: map['orderPriority'] as int);
    } catch (e) {
      Logx.em(_TAG, 'bloc orderPriority not exist for id: ${bloc.id}');
      isModelChanged = true;
    }
    try {
      bloc = bloc.copyWith(powerBloc: map['powerBloc'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'bloc powerBloc not exist for id: ${bloc.id}');
      isModelChanged = true;
    }
    try {
      bloc = bloc.copyWith(superPowerBloc: map['superPowerBloc'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'bloc superPowerBloc not exist for id: ${bloc.id}');
      isModelChanged = true;
    }
    try {
      bloc = bloc.copyWith(creationDate: map['creationDate'] as int);
    } catch (e) {
      Logx.em(_TAG, 'bloc creationDate not exist for id: ${bloc.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.ADMIN_LEVEL) {
      Logx.em(_TAG, 'updating bloc ${bloc.id}');
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
      Logx.em(_TAG, 'bloc name not exist for id: ${bloc.id}');
    }
    try {
      freshBloc = freshBloc.copyWith(cityId: bloc.cityId);
    } catch (e) {
      Logx.em(_TAG, 'bloc cityId not exist for id: ${bloc.id}');
    }
    try {
      freshBloc = freshBloc.copyWith(addressLine1: bloc.addressLine1);
    } catch (e) {
      Logx.em(_TAG, 'bloc addressLine1 not exist for id: ${bloc.id}');
    }
    try {
      freshBloc = freshBloc.copyWith(addressLine2: bloc.addressLine2);
    } catch (e) {
      Logx.em(_TAG, 'bloc addressLine2 not exist for id: ${bloc.id}');
    }
    try {
      freshBloc = freshBloc.copyWith(pinCode: bloc.pinCode);
    } catch (e) {
      Logx.em(_TAG, 'bloc pinCode not exist for id: ${bloc.id}');
    }
    try {
      freshBloc = freshBloc.copyWith(ownerId: bloc.ownerId);
    } catch (e) {
      Logx.em(_TAG, 'bloc ownerId not exist for bloc id: ${bloc.id}');
    }
    try {
      freshBloc = freshBloc.copyWith(createdAt: bloc.createdAt);
    } catch (e) {
      Logx.em(_TAG, 'bloc createdAt not exist for bloc id: ${bloc.id}');
    }
    try {
      freshBloc = freshBloc.copyWith(isActive: bloc.isActive);
    } catch (e) {
      Logx.em(_TAG, 'bloc isActive not exist for bloc id: ${bloc.id}');
    }
    try {
      freshBloc = freshBloc.copyWith(imageUrls: bloc.imageUrls);
    } catch (e) {
      Logx.em(_TAG, 'bloc imageUrls not exist for id: ${bloc.id}');
    }

    try {
      freshBloc = freshBloc.copyWith(latitude: bloc.latitude);
    } catch (e) {
      Logx.em(_TAG, 'bloc latitude not exist for id: ${bloc.id}');
    }
    try {
      freshBloc = freshBloc.copyWith(longitude: bloc.longitude);
    } catch (e) {
      Logx.em(_TAG, 'bloc longitude not exist for id: ${bloc.id}');
    }
    try {
      freshBloc = freshBloc.copyWith(mapImageUrl: bloc.mapImageUrl);
    } catch (e) {
      Logx.em(_TAG, 'bloc mapImageUrl not exist for id: ${bloc.id}');
    }

    try {
      freshBloc = freshBloc.copyWith(orderPriority: bloc.orderPriority);
    } catch (e) {
      Logx.em(_TAG, 'bloc orderPriority not exist for id: ${bloc.id}');
    }
    try {
      freshBloc = freshBloc.copyWith(powerBloc: bloc.powerBloc);
    } catch (e) {
      Logx.em(_TAG, 'bloc powerBloc not exist for id: ${bloc.id}');
    }
    try {
      freshBloc = freshBloc.copyWith(superPowerBloc: bloc.superPowerBloc);
    } catch (e) {
      Logx.em(_TAG, 'bloc superPowerBloc not exist for id: ${bloc.id}');
    }
    try {
      freshBloc = freshBloc.copyWith(creationDate: bloc.creationDate);
    } catch (e) {
      Logx.em(_TAG, 'bloc creationDate not exist for id: ${bloc.id}');
    }

    return freshBloc;
  }

  /** bloc service **/
  static BlocService freshBlocServiceMap(Map<String, dynamic> map, bool shouldUpdate) {
    BlocService blocService = Dummy.getDummyBlocService('');

    bool isModelChanged = false;

    try {
      blocService = blocService.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc service id not exist');
    }
    try {
      blocService = blocService.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc service name not exist for id: ${blocService.id}');
      isModelChanged = true;
    }

    try {
      blocService = blocService.copyWith(blocId: map['blocId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc service blocId not exist for id: ${blocService.id}');
      isModelChanged = true;
    }
    try {
      blocService = blocService.copyWith(type: map['type'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc service type not exist for id: ${blocService.id}');
      isModelChanged = true;
    }
    try {
      blocService = blocService.copyWith(primaryPhone: map['primaryPhone'] as double);
    } catch (e) {
      Logx.em(_TAG, 'bloc service primaryPhone not exist for id: ${blocService.id}');
      isModelChanged = true;
    }
    try {
      blocService = blocService.copyWith(secondaryPhone: map['secondaryPhone'] as double);
    } catch (e) {
      Logx.em(_TAG, 'bloc service secondaryPhone not exist for id: ${blocService.id}');
      isModelChanged = true;
    }
    try {
      blocService = blocService.copyWith(emailId: map['emailId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc service emailId not exist for id: ${blocService.id}');
      isModelChanged = true;
    }
    try {
      blocService = blocService.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc service imageUrl not exist for id: ${blocService.id}');
      isModelChanged = true;
    }
    try {
      blocService = blocService.copyWith(ownerId: map['ownerId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc service ownerId not exist for id: ${blocService.id}');
      isModelChanged = true;
    }
    try {
      blocService = blocService.copyWith(createdAt: map['createdAt'] as String);
    } catch (e) {
      Logx.em(_TAG, 'bloc service createdAt not exist for id: ${blocService.id}');
      isModelChanged = true;
    }

    if (isModelChanged &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.ADMIN_LEVEL) {
      Logx.em(_TAG, 'updating bloc service ${blocService.id}');
      FirestoreHelper.pushBlocService(blocService);
    }

    return blocService;
  }

  static BlocService freshBlocService(BlocService blocService) {
    BlocService fresh = Dummy.getDummyBlocService('');

    try {
      fresh = fresh.copyWith(id: blocService.id);
    } catch (e) {
      Logx.em(_TAG, 'bloc service id not exist');
    }
    try {
      fresh = fresh.copyWith(name: blocService.name);
    } catch (e) {
      Logx.em(_TAG, 'bloc service name not exist for id: ${blocService.id}');
    }

    try {
      fresh = fresh.copyWith(blocId: blocService.blocId);
    } catch (e) {
      Logx.em(_TAG, 'bloc service blocId not exist for id: ${blocService.id}');
    }
    try {
      fresh = fresh.copyWith(type: blocService.type);
    } catch (e) {
      Logx.em(_TAG, 'bloc service type not exist for id: ${blocService.id}');
    }
    try {
      fresh = fresh.copyWith(primaryPhone: blocService.primaryPhone);
    } catch (e) {
      Logx.em(_TAG, 'bloc service primaryPhone not exist for id: ${blocService.id}');
    }
    try {
      fresh = fresh.copyWith(secondaryPhone: blocService.secondaryPhone);
    } catch (e) {
      Logx.em(_TAG, 'bloc service secondaryPhone not exist for id: ${blocService.id}');
    }
    try {
      fresh = fresh.copyWith(emailId: blocService.emailId);
    } catch (e) {
      Logx.em(_TAG, 'bloc service emailId not exist for id: ${blocService.id}');
    }
    try {
      fresh = fresh.copyWith(imageUrl: blocService.imageUrl);
    } catch (e) {
      Logx.em(_TAG, 'bloc service imageUrl not exist for id: ${blocService.id}');
    }
    try {
      fresh = fresh.copyWith(ownerId: blocService.ownerId);
    } catch (e) {
      Logx.em(_TAG, 'bloc service ownerId not exist for id: ${blocService.id}');
    }
    try {
      fresh = fresh.copyWith(createdAt: blocService.createdAt);
    } catch (e) {
      Logx.em(_TAG, 'bloc service createdAt not exist for id: ${blocService.id}');
    }

    return fresh;
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
      Logx.em(_TAG, 'category name not exist for category id: ${category.id}');
      isModelChanged = true;
    }
    try {
      category = category.copyWith(type: map['type'] as String);
    } catch (e) {
      Logx.em(_TAG, 'category type not exist for category id: ${category.id}');
      isModelChanged = true;
    }
    try {
      category = category.copyWith(serviceId: map['serviceId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'category serviceId not exist for category id: ${category.id}');
      isModelChanged = true;
    }
    try {
      category = category.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'category imageUrl not exist for id: ${category.id}');
      isModelChanged = true;
    }
    try {
      category = category.copyWith(ownerId: map['ownerId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'category ownerId not exist for id: ${category.id}');
      isModelChanged = true;
    }
    try {
      category = category.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'category createdAt not exist for id: ${category.id}');
      isModelChanged = true;
    }
    try {
      category = category.copyWith(sequence: map['sequence'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'category sequence not exist for id: ${category.id}');
      isModelChanged = true;
    }
    try {
      category = category.copyWith(description: map['description'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'category description not exist for category id: ${category.id}');
      isModelChanged = true;
    }
    try {
      category = category.copyWith(blocIds: List<String>.from(map['blocIds']));
    } catch (e) {
      Logx.em(
          _TAG, 'category blocIds not exist for category id: ${category.id}');
      List<String> existingBlocIds = [category.serviceId];
      category = category.copyWith(blocIds: existingBlocIds);
      isModelChanged = true;
    }

    if (isModelChanged &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating category ${category.id}');
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
      Logx.em(_TAG, 'category name not exist for category id: ${category.id}');
    }
    try {
      freshCategory = freshCategory.copyWith(type: category.type);
    } catch (e) {
      Logx.em(_TAG, 'category type not exist for category id: ${category.id}');
    }
    try {
      freshCategory = freshCategory.copyWith(serviceId: category.serviceId);
    } catch (e) {
      Logx.em(
          _TAG, 'category serviceId not exist for category id: ${category.id}');
    }
    try {
      freshCategory = freshCategory.copyWith(imageUrl: category.imageUrl);
    } catch (e) {
      Logx.em(
          _TAG, 'category imageUrl not exist for category id: ${category.id}');
    }
    try {
      freshCategory = freshCategory.copyWith(ownerId: category.ownerId);
    } catch (e) {
      Logx.em(
          _TAG, 'category ownerId not exist for category id: ${category.id}');
    }
    try {
      freshCategory = freshCategory.copyWith(createdAt: category.createdAt);
    } catch (e) {
      Logx.em(
          _TAG, 'category createdAt not exist for category id: ${category.id}');
    }
    try {
      freshCategory = freshCategory.copyWith(sequence: category.sequence);
    } catch (e) {
      Logx.em(
          _TAG, 'category sequence not exist for category id: ${category.id}');
    }
    try {
      freshCategory = freshCategory.copyWith(description: category.description);
    } catch (e) {
      Logx.em(_TAG,
          'category description not exist for category id: ${category.id}');
    }
    try {
      freshCategory = freshCategory.copyWith(blocIds: category.blocIds);
    } catch (e) {
      Logx.em(
          _TAG, 'category blocIds not exist for category id: ${category.id}');
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
      Logx.em(_TAG, 'celebration name not exist for id: ${celebration.id}');
      isModelChanged = true;
    }
    try {
      celebration = celebration.copyWith(surname: map['surname'] as String);
    } catch (e) {
      Logx.em(_TAG, 'celebration surname not exist for id: ${celebration.id}');
      isModelChanged = true;
    }
    try {
      celebration =
          celebration.copyWith(blocServiceId: map['blocServiceId'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'celebration blocServiceId not exist for id: ${celebration.id}');
      isModelChanged = true;
    }
    try {
      celebration =
          celebration.copyWith(customerId: map['customerId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration customerId not exist for id: ${celebration.id}');
      isModelChanged = true;
    }
    try {
      celebration = celebration.copyWith(phone: map['phone'] as int);
    } catch (e) {
      Logx.em(_TAG, 'celebration phone not exist for id: ${celebration.id}');
      isModelChanged = true;
    }

    try {
      celebration =
          celebration.copyWith(guestsCount: map['guestsCount'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration guestsCount not exist for id: ${celebration.id}');
      isModelChanged = true;
    }
    try {
      celebration = celebration.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration createdAt not exist for id: ${celebration.id}');
      isModelChanged = true;
    }
    try {
      celebration =
          celebration.copyWith(arrivalDate: map['arrivalDate'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration arrivalDate not exist for id: ${celebration.id}');
      isModelChanged = true;
    }
    try {
      celebration =
          celebration.copyWith(arrivalTime: map['arrivalTime'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration arrivalTime not exist for id: ${celebration.id}');
      isModelChanged = true;
    }
    try {
      celebration =
          celebration.copyWith(durationHours: map['durationHours'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'celebration durationHours not exist for id: ${celebration.id}');
      isModelChanged = true;
    }

    try {
      celebration = celebration.copyWith(
          bottleProductIds: List<String>.from(map['bottleProductIds']));
    } catch (e) {
      Logx.em(_TAG,
          'celebration bottleProductIds not exist for id: ${celebration.id}');
      isModelChanged = true;
    }
    try {
      celebration = celebration.copyWith(
          bottleNames: List<String>.from(map['bottleNames']));
    } catch (e) {
      Logx.em(
          _TAG, 'celebration bottleNames not exist for id: ${celebration.id}');
      isModelChanged = true;
    }
    try {
      celebration =
          celebration.copyWith(specialRequest: map['specialRequest'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'celebration specialRequest not exist for id: ${celebration.id}');
      isModelChanged = true;
    }
    try {
      celebration = celebration.copyWith(occasion: map['occasion'] as String);
    } catch (e) {
      Logx.em(_TAG, 'reservation occasion not exist for id: ${celebration.id}');
      isModelChanged = true;
    }
    try {
      celebration = celebration.copyWith(isApproved: map['isApproved'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration isApproved not exist for id: ${celebration.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating celebration ${celebration.id}');
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
      Logx.em(_TAG, 'celebration name not exist for id: ${celebration.id}');
    }
    try {
      fresh = fresh.copyWith(surname: celebration.surname);
    } catch (e) {
      Logx.em(_TAG, 'celebration surname not exist for id: ${celebration.id}');
    }
    try {
      fresh = fresh.copyWith(blocServiceId: celebration.blocServiceId);
    } catch (e) {
      Logx.em(_TAG,
          'celebration blocServiceId not exist for id: ${celebration.id}');
    }
    try {
      fresh = fresh.copyWith(customerId: celebration.customerId);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration customerId not exist for id: ${celebration.id}');
    }
    try {
      fresh = fresh.copyWith(phone: celebration.phone);
    } catch (e) {
      Logx.em(_TAG, 'celebration phone not exist for id: ${celebration.id}');
    }

    try {
      fresh = fresh.copyWith(guestsCount: celebration.guestsCount);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration guestsCount not exist for id: ${celebration.id}');
    }
    try {
      fresh = fresh.copyWith(createdAt: celebration.createdAt);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration createdAt not exist for id: ${celebration.id}');
    }
    try {
      fresh = fresh.copyWith(arrivalDate: celebration.arrivalDate);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration arrivalDate not exist for id: ${celebration.id}');
    }
    try {
      fresh = fresh.copyWith(arrivalTime: celebration.arrivalTime);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration arrivalTime not exist for id: ${celebration.id}');
    }
    try {
      fresh = fresh.copyWith(durationHours: celebration.durationHours);
    } catch (e) {
      Logx.em(_TAG,
          'celebration durationHours not exist for id: ${celebration.id}');
    }

    try {
      fresh = fresh.copyWith(bottleProductIds: celebration.bottleProductIds);
    } catch (e) {
      Logx.em(_TAG,
          'celebration bottleProductIds not exist for id: ${celebration.id}');
    }
    try {
      fresh = fresh.copyWith(bottleNames: celebration.bottleNames);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration bottleNames not exist for id: ${celebration.id}');
    }
    try {
      fresh = fresh.copyWith(specialRequest: celebration.specialRequest);
    } catch (e) {
      Logx.em(_TAG,
          'celebration specialRequest not exist for id: ${celebration.id}');
    }
    try {
      fresh = fresh.copyWith(occasion: celebration.occasion);
    } catch (e) {
      Logx.em(_TAG, 'celebration occasion not exist for id: ${celebration.id}');
    }

    try {
      fresh = fresh.copyWith(isApproved: celebration.isApproved);
    } catch (e) {
      Logx.em(
          _TAG, 'celebration isApproved not exist for id: ${celebration.id}');
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
      Logx.em(_TAG, 'challenge level not exist for id: ${challenge.id}');
      isModelChanged = true;
    }
    try {
      challenge = challenge.copyWith(title: map['title'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge title not exist for id: ${challenge.id}');
      isModelChanged = true;
    }
    try {
      challenge = challenge.copyWith(description: map['description'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge description not exist for id: ${challenge.id}');
      isModelChanged = true;
    }
    try {
      challenge = challenge.copyWith(points: map['points'] as int);
    } catch (e) {
      Logx.em(_TAG, 'challenge points not exist for id: ${challenge.id}');
      isModelChanged = true;
    }
    try {
      challenge = challenge.copyWith(clickCount: map['clickCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'challenge clickCount not exist for id: ${challenge.id}');
      isModelChanged = true;
    }
    try {
      challenge = challenge.copyWith(dialogTitle: map['dialogTitle'] as String);
    } catch (e) {
      Logx.em(_TAG, 'challenge dialogTitle not exist for id: ${challenge.id}');
      isModelChanged = true;
    }
    try {
      challenge = challenge.copyWith(
          dialogAcceptText: map['dialogAcceptText'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'challenge dialogAcceptText not exist for id: ${challenge.id}');
      isModelChanged = true;
    }
    try {
      challenge = challenge.copyWith(
          dialogAccept2Text: map['dialogAccept2Text'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'challenge dialogAccept2Text not exist for id: ${challenge.id}');
      isModelChanged = true;
    }

    if (isModelChanged &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating challenge ${challenge.id}');
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
          _TAG, 'challenge level not exist for challenge id: ${challenge.id}');
    }
    try {
      freshChallenge = freshChallenge.copyWith(title: challenge.title);
    } catch (e) {
      Logx.em(
          _TAG, 'challenge title not exist for challenge id: ${challenge.id}');
    }
    try {
      freshChallenge =
          freshChallenge.copyWith(description: challenge.description);
    } catch (e) {
      Logx.em(_TAG,
          'challenge description not exist for challenge id: ${challenge.id}');
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

    try {
      chat = chat.copyWith(views: map['views'] as int);
    } catch (e) {
      Logx.em(_TAG, 'chat views not exist for id: ${chat.id}');
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

    try {
      freshChat = freshChat.copyWith(views: chat.views);
    } catch (e) {
      Logx.em(
          _TAG, 'chat views not exist for id: ${chat.id}');
    }

    return freshChat;
  }

  /** city **/
  static City freshCityMap(String id, Map<String, dynamic> map, bool shouldUpdate) {
    City city = Dummy.getDummyCity();

    bool isModelChanged = false;

    try {
      city = city.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'city id not exist');
      city = city.copyWith(id: id);
    }
    try {
      city = city.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'city name not exist for id: ${city.id}');
      isModelChanged = true;
    }
    try {
      city = city.copyWith(ownerId: map['ownerId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'city ownerId not exist for id: ${city.id}');
      isModelChanged = true;
    }
    try {
      city = city.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'city imageUrl not exist for id: ${city.id}');
      isModelChanged = true;
    }

    if (isModelChanged &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel == Constants.ADMIN_LEVEL) {
      Logx.i(_TAG, 'updating config ${city.id}');
      FirestoreHelper.pushCity(city);
    }

    return city;
  }

  static City freshCity(City city) {
    City fresh = Dummy.getDummyCity();

    try {
      fresh = fresh.copyWith(id: city.id);
    } catch (e) {
      Logx.em(_TAG, 'city id not exist');
    }
    try {
      fresh = fresh.copyWith(name: city.name);
    } catch (e) {
      Logx.em(_TAG, 'city name not exist for id: ${city.id}');
    }
    try {
      fresh = fresh.copyWith(ownerId: city.ownerId);
    } catch (e) {
      Logx.em(_TAG, 'city ownerId not exist for id: ${city.id}');
    }
    try {
      fresh = fresh.copyWith(imageUrl: city.imageUrl);
    } catch (e) {
      Logx.em(_TAG, 'city imageUrl not exist for id: ${city.id}');
    }

    return fresh;
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

  /** friend **/
  static Friend freshFriendMap(Map<String, dynamic> map, bool shouldUpdate) {
    Friend friend = Dummy.getDummyFriend();

    bool isModelChanged = false;

    try {
      friend = friend.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'friend id not exist');
    }
    try {
      friend = friend.copyWith(userId: map['userId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'friend userId not exist for id: ${friend.id}');
      isModelChanged = true;
    }
    try {
      friend = friend.copyWith(friendUserId: map['friendUserId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'friend friendUserId not exist for id: ${friend.id}');
      isModelChanged = true;
    }
    try {
      friend = friend.copyWith(isFollowing: map['isFollowing'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'friend isFollowing not exist for id: ${friend.id}');
      isModelChanged = true;
    }
    try {
      friend = friend.copyWith(friendshipDate: map['friendshipDate'] as int);
    } catch (e) {
      Logx.em(_TAG, 'friend friendshipDate not exist for id: ${friend.id}');
      isModelChanged = true;
    }

    if (isModelChanged &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating friend ${friend.id}');
      FirestoreHelper.pushFriend(friend);
    }

    return friend;
  }

  static Friend freshFriend(Friend friend) {
    Friend freshFriend = Dummy.getDummyFriend();

    try {
      freshFriend = freshFriend.copyWith(id: friend.id);
    } catch (e) {
      Logx.em(_TAG, 'friend id not exist');
    }
    try {
      freshFriend = freshFriend.copyWith(userId: friend.userId);
    } catch (e) {
      Logx.em(_TAG, 'friend userId not exist for id: ${friend.id}');
    }
    try {
      freshFriend = freshFriend.copyWith(friendUserId: friend.friendUserId);
    } catch (e) {
      Logx.em(_TAG, 'friend friendUserId not exist for id: ${friend.id}');
    }
    try {
      freshFriend = freshFriend.copyWith(isFollowing: friend.isFollowing);
    } catch (e) {
      Logx.em(_TAG, 'friend isFollowing not exist for id: ${friend.id}');
    }
    try {
      freshFriend = freshFriend.copyWith(friendshipDate: friend.friendshipDate);
    } catch (e) {
      Logx.em(_TAG, 'friend friendshipDate not exist for id: ${friend.id}');
    }

    return freshFriend;
  }

  /** friend notification **/
  static FriendNotification freshFriendNotificationMap(Map<String, dynamic> map, bool shouldUpdate) {
    FriendNotification friendNotification = Dummy.getDummyFriendNotification();

    bool isModelChanged = false;

    try {
      friendNotification = friendNotification.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'friendNotification id not exist');
    }
    try {
      friendNotification = friendNotification.copyWith(title: map['title'] as String);
    } catch (e) {
      Logx.em(_TAG, 'friendNotification title not exist for id: ${friendNotification.id}');
      isModelChanged = true;
    }
    try {
      friendNotification = friendNotification.copyWith(message: map['message'] as String);
    } catch (e) {
      Logx.em(_TAG, 'friendNotification message not exist for id: ${friendNotification.id}');
      isModelChanged = true;
    }
    try {
      friendNotification = friendNotification.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'friendNotification imageUrl not exist for id: ${friendNotification.id}');
      isModelChanged = true;
    }
    try {
      friendNotification = friendNotification.copyWith(topic: map['topic'] as String);
    } catch (e) {
      Logx.em(_TAG, 'friendNotification topic not exist for id: ${friendNotification.id}');
      isModelChanged = true;
    }
    try {
      friendNotification = friendNotification.copyWith(time: map['time'] as int);
    } catch (e) {
      Logx.em(_TAG, 'friendNotification time not exist for id: ${friendNotification.id}');
      isModelChanged = true;
    }

    if (isModelChanged &&
        shouldUpdate) {
      Logx.i(_TAG, 'updating friend notification ${friendNotification.id}');
      FirestoreHelper.pushFriendNotification(friendNotification);
    }

    return friendNotification;
  }

  static FriendNotification freshFriendNotification(FriendNotification friendNotification) {
    FriendNotification fresh = Dummy.getDummyFriendNotification();

    try {
      fresh = fresh.copyWith(id: friendNotification.id);
    } catch (e) {
      Logx.em(_TAG, 'friendNotification id not exist');
    }
    try {
      fresh = fresh.copyWith(title: friendNotification.title);
    } catch (e) {
      Logx.em(_TAG, 'friendNotification title not exist for id: ${friendNotification.id}');
    }
    try {
      fresh = fresh.copyWith(message: friendNotification.message);
    } catch (e) {
      Logx.em(_TAG, 'friendNotification message not exist for id: ${friendNotification.id}');
    }
    try {
      fresh = fresh.copyWith(imageUrl: friendNotification.imageUrl);
    } catch (e) {
      Logx.em(_TAG, 'friendNotification imageUrl not exist for id: ${friendNotification.id}');
    }
    try {
      fresh = fresh.copyWith(topic: friendNotification.topic);
    } catch (e) {
      Logx.em(_TAG, 'friendNotification topic not exist for id: ${friendNotification.id}');
    }
    try {
      fresh = fresh.copyWith(time: friendNotification.time);
    } catch (e) {
      Logx.em(_TAG, 'friendNotification time not exist for id: ${friendNotification.id}');
    }

    return fresh;
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
      Logx.em(_TAG, 'genre name not exist for id: ${genre.id}');
      isModelChanged = true;
    }

    if (isModelChanged &&
        shouldUpdate &&
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      Logx.i(_TAG, 'updating genre ${genre.id}');
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
      Logx.em(_TAG, 'genre name not exist for id: ${genre.id}');
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

  /** organizer **/
  static Organizer freshOrganizer(Organizer organizer) {
    Organizer fresh = Dummy.getDummyOrganizer();

    try {
      fresh = fresh.copyWith(id: organizer.id);
    } catch (e) {
      Logx.em(_TAG, 'organizer id not exist');
    }
    try {
      fresh = fresh.copyWith(name: organizer.name);
    } catch (e) {
      Logx.em(_TAG,
          'organizer name not exist for id: ${organizer.id}');
    }
    try {
      fresh = fresh.copyWith(phoneNumber: organizer.phoneNumber);
    } catch (e) {
      Logx.em(_TAG, 'organizer phoneNumber not exist for id: ${organizer.id}');
    }
    try {
      fresh = fresh.copyWith(ownerId: organizer.ownerId);
    } catch (e) {
      Logx.em(_TAG, 'organizer ownerId not exist for id: ${organizer.id}');
    }
    try {
      fresh = fresh.copyWith(imageUrl: organizer.imageUrl);
    } catch (e) {
      Logx.em(_TAG, 'organizer imageUrl not exist for id: ${organizer.id}');
    }
    try {
      fresh = fresh.copyWith(followersCount: organizer.followersCount);
    } catch (e) {
      Logx.em(_TAG, 'organizer followersCount not exist for id: ${organizer.id}');
    }
    try {
      fresh = fresh.copyWith(createdAt: organizer.createdAt);
    } catch (e) {
      Logx.em(_TAG, 'organizer createdAt not exist for id: ${organizer.id}');
    }

    return fresh;
  }

  static Organizer freshOrganizerMap(Map<String, dynamic> map, bool shouldUpdate) {
    Organizer fresh = Dummy.getDummyOrganizer();
    bool isModelChanged = false;

    try {
      fresh = fresh.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'organizer id not exist');
    }
    try {
      fresh = fresh.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'organizer name not exist for id: ${fresh.id}');
      isModelChanged = true;
    }
    try {
      fresh = fresh.copyWith(phoneNumber: map['phoneNumber'] as int);
    } catch (e) {
      Logx.em(_TAG, 'organizer phoneNumber not exist for id: ${fresh.id}');
      isModelChanged = true;
    }
    try {
      fresh = fresh.copyWith(ownerId: map['ownerId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'organizer ownerId not exist for id: ${fresh.id}');
      isModelChanged = true;
    }
    try {
      fresh = fresh.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'organizer imageUrl not exist for id: ${fresh.id}');
      isModelChanged = true;
    }
    try {
      fresh = fresh.copyWith(followersCount: map['followersCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'organizer followersCount not exist for id: ${fresh.id}');
      isModelChanged = true;
    }
    try {
      fresh = fresh.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'organizer createdAt not exist for id: ${fresh.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating organizer ${fresh.id}');
      FirestoreHelper.pushOrganizer(fresh);
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
      Logx.em(_TAG, 'party type not exist for id: ${party.id}');
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
      Logx.em(_TAG, 'party instagramUrl not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(ticketUrl: map['ticketUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party ticketUrl not exist for id: ${party.id}');
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
      Logx.em(_TAG, 'party createdAt not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(startTime: map['startTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'party startTime not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(endTime: map['endTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'party endTime not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(ownerId: map['ownerId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'party ownerId not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(isTBA: map['isTBA'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'party isTBA not exist for id: ${party.id}');
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
      Logx.em(_TAG, 'party guestListCount not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(isEmailRequired: map['isEmailRequired'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'party isEmailRequired not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(guestListEndTime: map['guestListEndTime'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'party guestListEndTime not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(guestListRules: map['guestListRules'] as String);
      if (party.guestListRules.isEmpty) {
        party = party.copyWith(guestListRules: Constants.guestListRules);
        isModelChanged = true;
      }
    } catch (e) {
      Logx.em(_TAG, 'party guestListRules not exist for id: ${party.id}');
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
      party = party.copyWith(isTix: map['isTix'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'party isTix not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(bookingFeePercent: map['bookingFeePercent'] as double);
    } catch (e) {
      Logx.em(
          _TAG, 'party bookingFeePercent not exist for id: ${party.id}');
      isModelChanged = true;
    }

    try {
      party = party.copyWith(isTicketsDisabled: map['isTicketsDisabled'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'party isTicketsDisabled not exist for id: ${party.id}');
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

    try {
      party =
          party.copyWith(isAdCampaignRunning: map['isAdCampaignRunning'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'party isAdCampaignRunning not exist for id: ${party.id}');
      isModelChanged = true;
    }

    try {
      party = party.copyWith(organizerIds: List<String>.from(map['organizerIds']));
    } catch (e) {
      Logx.em(_TAG, 'party organizerIds not exist for id: ${party.id}');
      isModelChanged = true;
    }
    try {
      party = party.copyWith(isPayoutComplete: map['isPayoutComplete'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'party isPayoutComplete not exist for id: ${party.id}');
      isModelChanged = true;
    }

    if(isModelChanged){
      if (shouldUpdate) {
        Logx.i(_TAG, 'updating party ${party.id}');
        FirestoreHelper.pushParty(party);
      } else if(UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL){
        if(NumberUtils.getRandomNumber(0, 10) == 9){
          Logx.i(_TAG, 'updating party ${party.id} by luck');
          FirestoreHelper.pushParty(party);
        }
      }
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
      Logx.em(_TAG, 'party eventName not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(description: party.description);
    } catch (e) {
      Logx.em(_TAG, 'party description not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(blocServiceId: party.blocServiceId);
    } catch (e) {
      Logx.em(_TAG, 'party blocServiceId not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(type: party.type);
    } catch (e) {
      Logx.em(_TAG, 'party type not exist for id: ${party.id}');
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
      Logx.em(_TAG, 'party ticketUrl not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(listenUrl: party.listenUrl);
    } catch (e) {
      Logx.em(_TAG, 'party listenUrl not exist for id: ${party.id}');
    }

    try {
      freshParty = freshParty.copyWith(createdAt: party.createdAt);
    } catch (e) {
      Logx.em(_TAG, 'party createdAt not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(startTime: party.startTime);
    } catch (e) {
      Logx.em(_TAG, 'party startTime not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(endTime: party.endTime);
    } catch (e) {
      Logx.em(_TAG, 'party endTime not exist for id: ${party.id}');
    }

    try {
      freshParty = freshParty.copyWith(ownerId: party.ownerId);
    } catch (e) {
      Logx.em(_TAG, 'party ownerId not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(isTBA: party.isTBA);
    } catch (e) {
      Logx.em(_TAG, 'party isTBA not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(isActive: party.isActive);
    } catch (e) {
      Logx.em(_TAG, 'party isActive not exist for id: ${party.id}');
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
          _TAG, 'party guestListEndTime not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(isEmailRequired: party.isEmailRequired);
    } catch (e) {
      Logx.em(
          _TAG, 'party isEmailRequired not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(guestListRules: party.guestListRules);
    } catch (e) {
      Logx.em(_TAG, 'party guestListRules not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(clubRules: party.clubRules);
    } catch (e) {
      Logx.em(_TAG, 'party clubRules not exist for id: ${party.id}');
    }

    try {
      freshParty = freshParty.copyWith(isTix: party.isTix);
    } catch (e) {
      Logx.em(_TAG, 'party isTix not exist for id: ${party.id}');
    }
    try {
      freshParty =
          freshParty.copyWith(bookingFeePercent: party.bookingFeePercent);
    } catch (e) {
      Logx.em(
          _TAG, 'party bookingFeePercent not exist for id: ${party.id}');
    }

    try {
      freshParty = freshParty.copyWith(isTicketsDisabled: party.isTicketsDisabled);
    } catch (e) {
      Logx.em(_TAG, 'party isTicketsDisabled not exist for id: ${party.id}');
    }

    try {
      freshParty =
          freshParty.copyWith(isChallengeActive: party.isChallengeActive);
    } catch (e) {
      Logx.em(
          _TAG, 'party isChallengeActive not exist for id: ${party.id}');
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
      Logx.em(_TAG, 'party genre not exist for id: ${party.id}');
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

    try {
      freshParty = freshParty.copyWith(isAdCampaignRunning: party.isAdCampaignRunning);
    } catch (e) {
      Logx.em(_TAG, 'party isAdCampaignRunning not exist for id: ${party.id}');
    }

    try {
      freshParty = freshParty.copyWith(organizerIds: party.organizerIds);
    } catch (e) {
      Logx.em(_TAG, 'party organizerIds not exist for id: ${party.id}');
    }
    try {
      freshParty = freshParty.copyWith(isPayoutComplete: party.isPayoutComplete);
    } catch (e) {
      Logx.em(_TAG, 'party isPayoutComplete not exist for id: ${party.id}');
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
          'party guest surname not exist for party guest id: ${partyGuest.id}');
    }
    try {
      freshGuest = freshGuest.copyWith(partyId: partyGuest.partyId);
    } catch (e) {
      Logx.em(_TAG,
          'party guest partyId not exist for party guest id: ${partyGuest.id}');
    }
    try {
      freshGuest = freshGuest.copyWith(guestId: partyGuest.guestId);
    } catch (e) {
      Logx.em(_TAG,
          'party guest guestId not exist for party guest id: ${partyGuest.id}');
    }
    try {
      freshGuest = freshGuest.copyWith(phone: partyGuest.phone);
    } catch (e) {
      Logx.em(_TAG,
          'party guest phone not exist for party guest id: ${partyGuest.id}');
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
          'party guest guestsRemaining not exist for party guest id: ${partyGuest.id}');
    }
    try {
      freshGuest = freshGuest.copyWith(createdAt: partyGuest.createdAt);
    } catch (e) {
      Logx.em(
          _TAG,
          'party guest createdAt not exist for party guest id: ${partyGuest.id}');
    }
    try {
      freshGuest = freshGuest.copyWith(isApproved: partyGuest.isApproved);
    } catch (e) {
      Logx.em(
          _TAG,
          'party guest isApproved not exist for party guest id: ${partyGuest.id}');
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
      Logx.em(_TAG, 'partyGuest partyId not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }
    try {
      partyGuest = partyGuest.copyWith(guestId: map['guestId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest guestId not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }
    try {
      partyGuest = partyGuest.copyWith(name: map['name'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest name not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }
    try {
      partyGuest = partyGuest.copyWith(surname: map['surname'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest surname not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }
    try {
      partyGuest = partyGuest.copyWith(phone: map['phone'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest phone not exist for id: ${partyGuest.id}');
      isModelChanged = true;
    }
    try {
      partyGuest = partyGuest.copyWith(email: map['email'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyGuest email not exist for id: ${partyGuest.id}');
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

  /** party interest **/
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
      fresh = fresh.copyWith(tags: partyPhoto.tags);
    } catch (e) {
      Logx.em(_TAG,
          'party photo tags not exist for id: ${partyPhoto.id}');
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
      fresh = fresh.copyWith(downloaders: partyPhoto.downloaders);
    } catch (e) {
      Logx.em(_TAG,
          'party photo downloaders not exist for id: ${partyPhoto.id}');
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
    try {
      fresh = fresh.copyWith(isFreePhoto: partyPhoto.isFreePhoto);
    } catch (e) {
      Logx.em(_TAG,
          'party photo isFreePhoto not exist for id: ${partyPhoto.id}');
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
      partyPhoto = partyPhoto.copyWith(tags: List<String>.from(map['tags']));
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto tags not exist for id: ${partyPhoto.id}');
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
      partyPhoto = partyPhoto.copyWith(downloaders: List<String>.from(map['downloaders']));
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto downloaders not exist for id: ${partyPhoto.id}');
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
    try {
      partyPhoto = partyPhoto.copyWith(isFreePhoto: map['isFreePhoto'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'partyPhoto isFreePhoto not exist for id: ${partyPhoto.id}');
      isModelChanged = true;
    }

    if(isModelChanged){
      if (shouldUpdate) {
        Logx.i(_TAG, 'updating party photo ${partyPhoto.id}');
        FirestoreHelper.pushPartyPhoto(partyPhoto);
      } else if(UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL){
        if(NumberUtils.getRandomNumber(0, 10) == 9){
          Logx.i(_TAG, 'updating party photo ${partyPhoto.id} by luck');
          FirestoreHelper.pushPartyPhoto(partyPhoto);
        }
      }
    }


    return partyPhoto;
  }

  /** party tix tier **/
  static PartyTixTier freshPartyTixTier(PartyTixTier partyTixTier) {
    PartyTixTier fresh = Dummy.getDummyPartyTixTier(partyTixTier.partyId, 0);

    try {
      fresh = fresh.copyWith(id: partyTixTier.id);
    } catch (e) {
      Logx.em(_TAG, 'tix tier id not exist');
    }
    try {
      fresh = fresh.copyWith(partyId: partyTixTier.partyId);
    } catch (e) {
      Logx.em(_TAG,
          'tix tier partyId not exist for id: ${partyTixTier.id}');
    }

    try {
      fresh = fresh.copyWith(tierLevel: partyTixTier.tierLevel);
    } catch (e) {
      Logx.em(_TAG,
          'tix tier tierLevel not exist for id: ${partyTixTier.id}');
    }
    try {
      fresh = fresh.copyWith(tierName: partyTixTier.tierName);
    } catch (e) {
      Logx.em(_TAG,
          'tix tier tierName not exist for id: ${partyTixTier.id}');
    }
    try {
      fresh = fresh.copyWith(tierDescription: partyTixTier.tierDescription);
    } catch (e) {
      Logx.em(_TAG,
          'tix tier tierDescription not exist for id: ${partyTixTier.id}');
    }
    try {
      fresh = fresh.copyWith(tierPrice: partyTixTier.tierPrice);
    } catch (e) {
      Logx.em(_TAG,
          'tix tier tierPrice not exist for id: ${partyTixTier.id}');
    }

    try {
      fresh = fresh.copyWith(soldCount: partyTixTier.soldCount);
    } catch (e) {
      Logx.em(_TAG,
          'tix tier soldCount not exist for id: ${partyTixTier.id}');
    }
    try {
      fresh = fresh.copyWith(totalTix: partyTixTier.totalTix);
    } catch (e) {
      Logx.em(_TAG,
          'tix tier totalTix not exist for id: ${partyTixTier.id}');
    }
    try {
      fresh = fresh.copyWith(isSoldOut: partyTixTier.isSoldOut);
    } catch (e) {
      Logx.em(_TAG,
          'tix tier isSoldOut not exist for id: ${partyTixTier.id}');
    }
    try {
      fresh = fresh.copyWith(endTime: partyTixTier.endTime);
    } catch (e) {
      Logx.em(_TAG,
          'tix tier endTime not exist for id: ${partyTixTier.id}');
    }

    return fresh;
  }

  static PartyTixTier freshPartyTixTierMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    PartyTixTier partyTixTier = Dummy.getDummyPartyTixTier('', 0);
    bool isModelChanged = false;

    try {
      partyTixTier = partyTixTier.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyTixTier id not exist');
    }
    try {
      partyTixTier = partyTixTier.copyWith(partyId: map['partyId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyTixTier partyId not exist for id: ${partyTixTier.id}');
      isModelChanged = true;
    }

    try {
      partyTixTier = partyTixTier.copyWith(tierLevel: map['tierLevel'] as int);
    } catch (e) {
      Logx.em(_TAG, 'partyTixTier tierLevel not exist for id: ${partyTixTier.id}');
      isModelChanged = true;
    }
    try {
      partyTixTier = partyTixTier.copyWith(tierName: map['tierName'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyTixTier tierName not exist for id: ${partyTixTier.id}');
      isModelChanged = true;
    }
    try {
      partyTixTier = partyTixTier.copyWith(tierDescription: map['tierDescription'] as String);
    } catch (e) {
      Logx.em(_TAG, 'partyTixTier tierDescription not exist for id: ${partyTixTier.id}');
      isModelChanged = true;
    }
    try {
      partyTixTier = partyTixTier.copyWith(tierPrice: map['tierPrice'] as double);
    } catch (e) {
      Logx.em(_TAG, 'partyTixTier tierPrice not exist for id: ${partyTixTier.id}');
      isModelChanged = true;
    }

    try {
      partyTixTier = partyTixTier.copyWith(soldCount: map['soldCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'partyTixTier soldCount not exist for id: ${partyTixTier.id}');
      isModelChanged = true;
    }
    try {
      partyTixTier = partyTixTier.copyWith(totalTix: map['totalTix'] as int);
    } catch (e) {
      Logx.em(_TAG, 'partyTixTier totalTix not exist for id: ${partyTixTier.id}');
      isModelChanged = true;
    }

    try {
      partyTixTier = partyTixTier.copyWith(isSoldOut: map['isSoldOut'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'partyTixTier isSoldOut not exist for id: ${partyTixTier.id}');
      isModelChanged = true;
    }
    try {
      partyTixTier = partyTixTier.copyWith(endTime: map['endTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'partyTixTier endTime not exist for id: ${partyTixTier.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating party tix tier ${partyTixTier.id}');
      FirestoreHelper.pushPartyTixTier(partyTixTier);
    }
    return partyTixTier;
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
        Logx.i(_TAG, 'product price not exist for product id: ${product.id}');
        isModelChanged = true;
      }
    }
    try {
      product = product.copyWith(priceHighest: map['priceHighest'] as double);
    } catch (e) {
      intPrice = map['priceHighest'] as int;
      product = product.copyWith(priceHighest: intPrice.toDouble());
      Logx.em(
          _TAG, 'product priceHighest not exist for product id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product = product.copyWith(priceLowest: map['priceLowest'] as double);
    } catch (e) {
      intPrice = map['priceLowest'] as int;
      product = product.copyWith(priceLowest: intPrice.toDouble());
      Logx.em(
          _TAG, 'product priceLowest not exist for product id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product =
          product.copyWith(priceCommunity: map['priceCommunity'] as double);
    } catch (e) {
      intPrice = map['priceCommunity'] as int;
      product = product.copyWith(priceCommunity: intPrice.toDouble());
      Logx.em(_TAG,
          'product priceCommunity not exist for product id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product = product.copyWith(type: map['type'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product type not exist for product id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product = product.copyWith(category: map['category'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product category not exist for product id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product = product.copyWith(description: map['description'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'product description not exist for product id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product = product.copyWith(serviceId: map['serviceId'] as String);
    } catch (e) {
      Logx.em(
          _TAG, 'product serviceId not exist for product id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product = product.copyWith(imageUrl: map['imageUrl'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product imageUrl not exist for product id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product = product.copyWith(ownerId: map['ownerId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'product ownerId not exist for product id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product = product.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'product createdAt not exist for product id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product = product.copyWith(isAvailable: map['isAvailable'] as bool);
    } catch (e) {
      Logx.em(
          _TAG, 'product isAvailable not exist for product id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product =
          product.copyWith(priceHighestTime: map['priceHighestTime'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'product priceHighestTime not exist for product id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product =
          product.copyWith(priceLowestTime: map['priceLowestTime'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'product priceLowestTime not exist for product id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product = product.copyWith(isOfferRunning: map['isOfferRunning'] as bool);
    } catch (e) {
      Logx.em(_TAG,
          'product isOfferRunning not exist for product id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product = product.copyWith(isVeg: map['isVeg'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'product isVeg not exist for product id: ${product.id}');
      isModelChanged = true;
    }
    try {
      product = product.copyWith(blocIds: List<String>.from(map['blocIds']));
    } catch (e) {
      Logx.em(_TAG, 'product blocIds not exist for product id: ${product.id}');
      List<String> existingBlocIds = [product.serviceId];
      product = product.copyWith(blocIds: existingBlocIds);
      isModelChanged = true;
    }
    try {
      product = product.copyWith(priceBottle: map['priceBottle'] as int);
    } catch (e) {
      Logx.em(
          _TAG, 'product priceBottle not exist for product id: ${product.id}');
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
      Logx.em(_TAG, 'product name not exist for id: ${product.id}');
    }
    try {
      freshProduct = freshProduct.copyWith(type: product.type);
    } catch (e) {
      Logx.em(_TAG, 'product type not exist for id: ${product.id}');
    }
    try {
      freshProduct = freshProduct.copyWith(category: product.category);
    } catch (e) {
      Logx.em(_TAG, 'product category not exist for id: ${product.id}');
    }
    try {
      freshProduct = freshProduct.copyWith(description: product.description);
    } catch (e) {
      Logx.em(
          _TAG, 'product description not exist for id: ${product.id}');
    }
    try {
      freshProduct = freshProduct.copyWith(price: product.price);
    } catch (e) {
      Logx.em(_TAG, 'product price not exist for id: ${product.id}');
    }
    try {
      freshProduct = freshProduct.copyWith(serviceId: product.serviceId);
    } catch (e) {
      Logx.em(
          _TAG, 'product serviceId not exist for id: ${product.id}');
    }
    try {
      freshProduct = freshProduct.copyWith(imageUrl: product.imageUrl);
    } catch (e) {
      Logx.em(_TAG, 'product imageUrl not exist for id: ${product.id}');
    }
    try {
      freshProduct = freshProduct.copyWith(ownerId: product.ownerId);
    } catch (e) {
      Logx.em(_TAG, 'product ownerId not exist for id: ${product.id}');
    }
    try {
      freshProduct = freshProduct.copyWith(createdAt: product.createdAt);
    } catch (e) {
      Logx.em(
          _TAG, 'product createdAt not exist for id: ${product.id}');
    }
    try {
      freshProduct = freshProduct.copyWith(isAvailable: product.isAvailable);
    } catch (e) {
      Logx.em(
          _TAG, 'product isAvailable not exist for id: ${product.id}');
    }
    try {
      freshProduct = freshProduct.copyWith(priceHighest: product.priceHighest);
    } catch (e) {
      Logx.em(
          _TAG, 'product priceHighest not exist for id: ${product.id}');
    }
    try {
      freshProduct = freshProduct.copyWith(priceLowest: product.priceLowest);
    } catch (e) {
      Logx.em(
          _TAG, 'product priceLowest not exist for id: ${product.id}');
    }
    try {
      freshProduct =
          freshProduct.copyWith(priceHighestTime: product.priceHighestTime);
    } catch (e) {
      Logx.em(_TAG,
          'product priceHighestTime not exist for id: ${product.id}');
    }
    try {
      freshProduct =
          freshProduct.copyWith(priceLowestTime: product.priceLowestTime);
    } catch (e) {
      Logx.em(_TAG,
          'product priceLowestTime not exist for id: ${product.id}');
    }
    try {
      freshProduct =
          freshProduct.copyWith(priceCommunity: product.priceCommunity);
    } catch (e) {
      Logx.em(_TAG,
          'product priceCommunity not exist for id: ${product.id}');
    }
    try {
      freshProduct =
          freshProduct.copyWith(isOfferRunning: product.isOfferRunning);
    } catch (e) {
      Logx.em(_TAG,
          'product isOfferRunning not exist for id: ${product.id}');
    }
    try {
      freshProduct = freshProduct.copyWith(isVeg: product.isVeg);
    } catch (e) {
      Logx.em(_TAG, 'product isVeg not exist for id: ${product.id}');
    }
    try {
      freshProduct = freshProduct.copyWith(blocIds: product.blocIds);
    } catch (e) {
      Logx.em(_TAG, 'product blocIds not exist for id: ${product.id}');
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
    try {
      promoter = promoter.copyWith(ownerId: map['ownerId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'promoter ownerId not exist for id: ${promoter.id}');
      isModelChanged = true;
    }
    try {
      promoter = promoter.copyWith(
          helperIds: List<String>.from(map['helperIds']));
    } catch (e) {
      Logx.em(_TAG, 'promoter helperIds not exist for id: ${promoter.id}');
      isModelChanged = true;
    }
    try {
      promoter = promoter.copyWith(creationDate: map['creationDate'] as int);
    } catch (e) {
      Logx.em(_TAG, 'promoter creationDate not exist for id: ${promoter.id}');
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
    try {
      fresh = fresh.copyWith(ownerId: promoter.ownerId);
    } catch (e) {
      Logx.em(_TAG, 'promoter ownerId not exist for id: ${promoter.id}');
    }
    try {
      fresh = fresh.copyWith(helperIds: promoter.helperIds);
    } catch (e) {
      Logx.em(_TAG, 'promoter helperIds not exist for id: ${promoter.id}');
    }
    try {
      fresh = fresh.copyWith(creationDate: promoter.creationDate);
    } catch (e) {
      Logx.em(_TAG, 'promoter creationDate not exist for id: ${promoter.id}');
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
    bool isModelChanged = false;

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
          'reservation blocServiceId not exist for id: ${reservation.id}');
      isModelChanged = true;
    }
    try {
      reservation =
          reservation.copyWith(customerId: map['customerId'] as String);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation customerId not exist for id: ${reservation.id}');
      isModelChanged = true;
    }
    try {
      reservation = reservation.copyWith(phone: map['phone'] as int);
    } catch (e) {
      Logx.em(_TAG,
          'reservation phone not exist for reservation id: ${reservation.id}');
      isModelChanged = true;
    }
    try {
      reservation =
          reservation.copyWith(guestsCount: map['guestsCount'] as int);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation guestsCount not exist for reservation id: ${reservation.id}');
      isModelChanged = true;
    }
    try {
      reservation = reservation.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation createdAt not exist for reservation id: ${reservation.id}');
      isModelChanged = true;
    }
    try {
      reservation =
          reservation.copyWith(arrivalDate: map['arrivalDate'] as int);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation arrivalDate not exist for id: ${reservation.id}');
      isModelChanged = true;
    }
    try {
      reservation =
          reservation.copyWith(arrivalTime: map['arrivalTime'] as String);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation arrivalTime not exist for id: ${reservation.id}');
      isModelChanged = true;
    }

    try {
      reservation = reservation.copyWith(
          bottleProductIds: List<String>.from(map['bottleProductIds']));
    } catch (e) {
      Logx.em(_TAG,
          'reservation bottleProductIds not exist for id: ${reservation.id}');
      isModelChanged = true;
    }
    try {
      reservation = reservation.copyWith(
          bottleNames: List<String>.from(map['bottleNames']));
    } catch (e) {
      Logx.em(
          _TAG, 'reservation bottleNames not exist for id: ${reservation.id}');
      isModelChanged = true;
    }
    try {
      reservation =
          reservation.copyWith(specialRequest: map['specialRequest'] as String);
    } catch (e) {
      Logx.em(_TAG,
          'reservation specialRequest not exist for id: ${reservation.id}');
      isModelChanged = true;
    }
    try {
      reservation = reservation.copyWith(occasion: map['occasion'] as String);
    } catch (e) {
      Logx.em(_TAG, 'reservation occasion not exist for id: ${reservation.id}');
      isModelChanged = true;
    }
    try {
      reservation = reservation.copyWith(isApproved: map['isApproved'] as bool);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation isApproved not exist for reservation id: ${reservation.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating reservation ${reservation.id}');
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
          'reservation name not exist for reservation id: ${reservation.id}');
    }
    try {
      freshReservation =
          freshReservation.copyWith(blocServiceId: reservation.blocServiceId);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation blocServiceId not exist for reservation id: ${reservation.id}');
    }
    try {
      freshReservation =
          freshReservation.copyWith(customerId: reservation.customerId);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation customerId not exist for reservation id: ${reservation.id}');
    }
    try {
      freshReservation = freshReservation.copyWith(phone: reservation.phone);
    } catch (e) {
      Logx.em(_TAG,
          'reservation phone not exist for reservation id: ${reservation.id}');
    }
    try {
      freshReservation =
          freshReservation.copyWith(guestsCount: reservation.guestsCount);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation guestsCount not exist for reservation id: ${reservation.id}');
    }
    try {
      freshReservation =
          freshReservation.copyWith(createdAt: reservation.createdAt);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation createdAt not exist for reservation id: ${reservation.id}');
    }
    try {
      freshReservation =
          freshReservation.copyWith(arrivalDate: reservation.arrivalDate);
    } catch (e) {
      Logx.em(
          _TAG,
          'reservation arrivalDate not exist for reservation id: ${reservation.id}');
    }
    try {
      freshReservation =
          freshReservation.copyWith(arrivalTime: reservation.arrivalTime);
    } catch (e) {
      Logx.em(
          _TAG, 'reservation arrivalTime not exist for id: ${reservation.id}');
    }

    try {
      freshReservation = freshReservation.copyWith(
          bottleProductIds: reservation.bottleProductIds);
    } catch (e) {
      Logx.em(_TAG,
          'reservation bottleProductIds not exist for id: ${reservation.id}');
    }
    try {
      freshReservation =
          freshReservation.copyWith(bottleNames: reservation.bottleNames);
    } catch (e) {
      Logx.em(
          _TAG, 'reservation bottleNames not exist for id: ${reservation.id}');
    }
    try {
      freshReservation =
          freshReservation.copyWith(specialRequest: reservation.specialRequest);
    } catch (e) {
      Logx.em(_TAG,
          'reservation specialRequest not exist for id: ${reservation.id}');
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
      Logx.em(_TAG, 'uiPhoto name not exist for id: ${uiPhoto.id}');
      isModelChanged = true;
    }
    try {
      uiPhoto =
          uiPhoto.copyWith(imageUrls: List<String>.from(map['imageUrls']));
    } catch (e) {
      Logx.em(_TAG, 'uiPhoto imageUrls not exist for id: ${uiPhoto.id}');
      List<String> temp = [];
      uiPhoto = uiPhoto.copyWith(imageUrls: temp);
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating uiPhoto ${uiPhoto.id}');
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
      Logx.em(_TAG, 'uiPhoto name not exist for id: ${uiPhoto.id}');
    }
    try {
      freshUiPhoto = freshUiPhoto.copyWith(imageUrls: uiPhoto.imageUrls);
    } catch (e) {
      Logx.em(_TAG, 'uiPhoto imageUrls not exist for id: ${uiPhoto.id}');
    }

    return freshUiPhoto;
  }

  /** support chat **/
  static SupportChat freshSupportChatMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    SupportChat chat = Dummy.getDummySupportChat();
    bool isModelChanged = false;

    try {
      chat = chat.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'chat id not exist');
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
      chat = chat.copyWith(isResponse: map['isResponse'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'chat isResponse not exist for id: ${chat.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating support chat ${chat.id}');
      FirestoreHelper.pushSupportChat(chat);
    }

    return chat;
  }

  static SupportChat freshSupportChat(SupportChat chat) {
    SupportChat freshChat = Dummy.getDummySupportChat();

    try {
      freshChat = freshChat.copyWith(id: chat.id);
    } catch (e) {
      Logx.em(_TAG, 'chat id not exist');
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
      freshChat = freshChat.copyWith(isResponse: chat.isResponse);
    } catch (e) {
      Logx.em(
          _TAG, 'chat isResponse not exist for id: ${chat.id}');
    }

    return freshChat;
  }

  /** tix **/
  static Tix freshTix(Tix tix) {
    Tix fresh = Dummy.getDummyTix();

    try {
      fresh = fresh.copyWith(id: tix.id);
    } catch (e) {
      Logx.em(_TAG, 'tix id not exist');
    }
    try {
      fresh = fresh.copyWith(partyId: tix.partyId);
    } catch (e) {
      Logx.em(_TAG,
          'tix partyId not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(userId: tix.userId);
    } catch (e) {
      Logx.em(_TAG,
          'tix userId not exist for id: ${tix.id}');
    }

    try {
      fresh = fresh.copyWith(userName: tix.userName);
    } catch (e) {
      Logx.em(_TAG,
          'tix userName not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(userPhone: tix.userPhone);
    } catch (e) {
      Logx.em(_TAG,
          'tix userPhone not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(userEmail: tix.userEmail);
    } catch (e) {
      Logx.em(_TAG,
          'tix userEmail not exist for id: ${tix.id}');
    }

    try {
      fresh = fresh.copyWith(igst: tix.igst);
    } catch (e) {
      Logx.em(_TAG,
          'tix igst not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(subTotal: tix.subTotal);
    } catch (e) {
      Logx.em(_TAG,
          'tix subTotal not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(bookingFee: tix.bookingFee);
    } catch (e) {
      Logx.em(_TAG, 'tix bookingFee not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(total: tix.total);
    } catch (e) {
      Logx.em(_TAG,
          'tix total not exist for id: ${tix.id}');
    }

    try {
      fresh = fresh.copyWith(merchantTransactionId: tix.merchantTransactionId);
    } catch (e) {
      Logx.em(_TAG,
          'tix merchantTransactionId not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(transactionId: tix.transactionId);
    } catch (e) {
      Logx.em(_TAG,
          'tix transactionId not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(transactionResponseCode: tix.transactionResponseCode);
    } catch (e) {
      Logx.em(_TAG,
          'tix transactionResponseCode not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(result: tix.result);
    } catch (e) {
      Logx.em(_TAG,
          'tix result not exist for id: ${tix.id}');
    }

    try {
      fresh = fresh.copyWith(creationTime: tix.creationTime);
    } catch (e) {
      Logx.em(_TAG,
          'tix creationTime not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(isSuccess: tix.isSuccess);
    } catch (e) {
      Logx.em(_TAG, 'tix isSuccess not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(isCompleted: tix.isCompleted);
    } catch (e) {
      Logx.em(_TAG,
          'tix isCompleted not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(isArrived: tix.isArrived);
    } catch (e) {
      Logx.em(_TAG,
          'tix isArrived not exist for id: ${tix.id}');
    }

    try {
      fresh = fresh.copyWith(tixTierIds: tix.tixTierIds);
    } catch (e) {
      Logx.em(_TAG,
          'tix tixTierItemIds not exist for id: ${tix.id}');
    }

    return fresh;
  }

  static Tix freshTixMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    Tix tix = Dummy.getDummyTix();
    bool isModelChanged = false;

    try {
      tix = tix.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix id not exist');
    }
    try {
      tix = tix.copyWith(partyId: map['partyId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix partyId not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(userId: map['userId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix userId not exist for id: ${tix.id}');
      isModelChanged = true;
    }

    try {
      tix = tix.copyWith(userName: map['userName'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix userName not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(userPhone: map['userPhone'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix userPhone not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(userEmail: map['userEmail'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix userEmail not exist for id: ${tix.id}');
      isModelChanged = true;
    }

    try {
      tix = tix.copyWith(igst: map['igst'] as double);
    } catch (e) {
      Logx.em(_TAG, 'tix igst not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(subTotal: map['subTotal'] as double);
    } catch (e) {
      Logx.em(_TAG, 'tix subTotal not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(bookingFee: map['bookingFee'] as double);
    } catch (e) {
      Logx.em(_TAG, 'tix bookingFee not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(total: map['total'] as double);
    } catch (e) {
      Logx.em(_TAG, 'tix total not exist for id: ${tix.id}');
      isModelChanged = true;
    }

    try {
      tix = tix.copyWith(merchantTransactionId: map['merchantTransactionId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix merchantTransactionId not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(transactionId: map['transactionId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix transactionId not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(transactionResponseCode: map['transactionResponseCode'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix transactionResponseCode not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(result: map['result'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix result not exist for id: ${tix.id}');
      isModelChanged = true;
    }

    try {
      tix = tix.copyWith(creationTime: map['creationTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'tix creationTime not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(isSuccess: map['isSuccess'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'tix isSuccess not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(isCompleted: map['isCompleted'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'tix isCompleted not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(isArrived: map['isArrived'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'tix isArrived not exist for id: ${tix.id}');
      isModelChanged = true;
    }

    try {
      tix =
          tix.copyWith(tixTierIds: List<String>.from(map['tixTierIds']));
    } catch (e) {
      Logx.em(_TAG, 'tix tixTierIds not exist for id: ${tix.id}');
      List<String> temp = [];
      tix = tix.copyWith(tixTierIds: temp);
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate && UserPreferences.myUser.clearanceLevel>=Constants.ADMIN_LEVEL) {
      Logx.i(_TAG, 'updating tix ${tix.id}');
      FirestoreHelper.pushTix(tix);
    }
    return tix;
  }

  /** tix backup **/
  static TixBackup freshTixBackup(TixBackup tix) {
    TixBackup fresh = Dummy.getDummyTixBackup();

    try {
      fresh = fresh.copyWith(id: tix.id);
    } catch (e) {
      Logx.em(_TAG, 'tix backup id not exist');
    }
    try {
      fresh = fresh.copyWith(partyId: tix.partyId);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup partyId not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(userId: tix.userId);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup userId not exist for id: ${tix.id}');
    }

    try {
      fresh = fresh.copyWith(userName: tix.userName);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup userName not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(userPhone: tix.userPhone);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup userPhone not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(userEmail: tix.userEmail);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup userEmail not exist for id: ${tix.id}');
    }

    try {
      fresh = fresh.copyWith(igst: tix.igst);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup igst not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(subTotal: tix.subTotal);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup subTotal not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(bookingFee: tix.bookingFee);
    } catch (e) {
      Logx.em(_TAG, 'tix backup bookingFee not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(total: tix.total);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup total not exist for id: ${tix.id}');
    }

    try {
      fresh = fresh.copyWith(merchantTransactionId: tix.merchantTransactionId);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup merchantTransactionId not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(transactionId: tix.transactionId);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup transactionId not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(transactionResponseCode: tix.transactionResponseCode);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup transactionResponseCode not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(result: tix.result);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup result not exist for id: ${tix.id}');
    }

    try {
      fresh = fresh.copyWith(creationTime: tix.creationTime);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup creationTime not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(isSuccess: tix.isSuccess);
    } catch (e) {
      Logx.em(_TAG, 'tix backup isSuccess not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(isCompleted: tix.isCompleted);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup isCompleted not exist for id: ${tix.id}');
    }
    try {
      fresh = fresh.copyWith(isArrived: tix.isArrived);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup isArrived not exist for id: ${tix.id}');
    }

    try {
      fresh = fresh.copyWith(tixTierIds: tix.tixTierIds);
    } catch (e) {
      Logx.em(_TAG,
          'tix backup tixTierItemIds not exist for id: ${tix.id}');
    }

    return fresh;
  }

  static TixBackup freshTixBackupMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    TixBackup tix = Dummy.getDummyTixBackup();
    bool isModelChanged = false;

    try {
      tix = tix.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix backup id not exist');
    }
    try {
      tix = tix.copyWith(partyId: map['partyId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix backup partyId not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(userId: map['userId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix backup userId not exist for id: ${tix.id}');
      isModelChanged = true;
    }

    try {
      tix = tix.copyWith(userName: map['userName'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix backup userName not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(userPhone: map['userPhone'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix backup userPhone not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(userEmail: map['userEmail'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix backup userEmail not exist for id: ${tix.id}');
      isModelChanged = true;
    }

    try {
      tix = tix.copyWith(igst: map['igst'] as double);
    } catch (e) {
      Logx.em(_TAG, 'tix backup igst not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(subTotal: map['subTotal'] as double);
    } catch (e) {
      Logx.em(_TAG, 'tix backup subTotal not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(bookingFee: map['bookingFee'] as double);
    } catch (e) {
      Logx.em(_TAG, 'tix backup bookingFee not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(total: map['total'] as double);
    } catch (e) {
      Logx.em(_TAG, 'tix backup total not exist for id: ${tix.id}');
      isModelChanged = true;
    }

    try {
      tix = tix.copyWith(merchantTransactionId: map['merchantTransactionId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix backup merchantTransactionId not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(transactionId: map['transactionId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix backup transactionId not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(transactionResponseCode: map['transactionResponseCode'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix backup transactionResponseCode not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(result: map['result'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tix backup result not exist for id: ${tix.id}');
      isModelChanged = true;
    }

    try {
      tix = tix.copyWith(creationTime: map['creationTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'tix backup creationTime not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(isSuccess: map['isSuccess'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'tix backup isSuccess not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(isCompleted: map['isCompleted'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'tix backup isCompleted not exist for id: ${tix.id}');
      isModelChanged = true;
    }
    try {
      tix = tix.copyWith(isArrived: map['isArrived'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'tix backup isArrived not exist for id: ${tix.id}');
      isModelChanged = true;
    }

    try {
      tix =
          tix.copyWith(tixTierIds: List<String>.from(map['tixTierIds']));
    } catch (e) {
      Logx.em(_TAG, 'tix backup tixTierIds not exist for id: ${tix.id}');
      List<String> temp = [];
      tix = tix.copyWith(tixTierIds: temp);
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate && UserPreferences.myUser.clearanceLevel>=Constants.ADMIN_LEVEL) {
      Logx.i(_TAG, 'updating tix backup ${tix.id}');
      FirestoreHelper.pushTixBackup(tix);
    }
    return tix;
  }

  /** tix tier **/
  static TixTier freshTixTier(TixTier tixTier) {
    TixTier fresh = Dummy.getDummyTixTier();

    try {
      fresh = fresh.copyWith(id: tixTier.id);
    } catch (e) {
      Logx.em(_TAG, 'tixTier id not exist');
    }
    try {
      fresh = fresh.copyWith(tixId: tixTier.tixId);
    } catch (e) {
      Logx.em(_TAG,
          'tixTier tixId not exist for id: ${tixTier.id}');
    }

    try {
      fresh = fresh.copyWith(partyTixTierId: tixTier.partyTixTierId);
    } catch (e) {
      Logx.em(_TAG,
          'tixTier partyTixTierId not exist for id: ${tixTier.id}');
    }
    try {
      fresh = fresh.copyWith(tixTierName: tixTier.tixTierName);
    } catch (e) {
      Logx.em(_TAG,
          'tixTier tixTierName not exist for id: ${tixTier.id}');
    }
    try {
      fresh = fresh.copyWith(tixTierDescription: tixTier.tixTierDescription);
    } catch (e) {
      Logx.em(_TAG,
          'tixTier tixTierDescription not exist for id: ${tixTier.id}');
    }
    try {
      fresh = fresh.copyWith(tixTierPrice: tixTier.tixTierPrice);
    } catch (e) {
      Logx.em(_TAG,
          'tixTier tixTierPrice not exist for id: ${tixTier.id}');
    }
    try {
      fresh = fresh.copyWith(tixTierCount: tixTier.tixTierCount);
    } catch (e) {
      Logx.em(_TAG,
          'tixTier tixTierCount not exist for id: ${tixTier.id}');
    }
    try {
      fresh = fresh.copyWith(guestsRemaining: tixTier.guestsRemaining);
    } catch (e) {
      Logx.em(_TAG,
          'tixTier guestsRemaining not exist for id: ${tixTier.id}');
    }

    try {
      fresh = fresh.copyWith(tixTierTotal: tixTier.tixTierTotal);
    } catch (e) {
      Logx.em(_TAG,
          'tixTier tixTierTotal not exist for id: ${tixTier.id}');
    }

    return fresh;
  }

  static TixTier freshTixTierMap(
      Map<String, dynamic> map, bool shouldUpdate) {
    TixTier tixTier = Dummy.getDummyTixTier();
    bool isModelChanged = false;

    try {
      tixTier = tixTier.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tixTier id not exist');
    }
    try {
      tixTier = tixTier.copyWith(tixId: map['tixId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tixTier tixId not exist for id: ${tixTier.id}');
      isModelChanged = true;
    }

    try {
      tixTier = tixTier.copyWith(partyTixTierId: map['partyTixTierId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tixTier partyTixTierId not exist for id: ${tixTier.id}');
      isModelChanged = true;
    }
    try {
      tixTier = tixTier.copyWith(tixTierName: map['tixTierName'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tixTier tixTierName not exist for id: ${tixTier.id}');
      isModelChanged = true;
    }
    try {
      tixTier = tixTier.copyWith(tixTierDescription: map['tixTierDescription'] as String);
    } catch (e) {
      Logx.em(_TAG, 'tixTier tixTierDescription not exist for id: ${tixTier.id}');
      isModelChanged = true;
    }
    try {
      tixTier = tixTier.copyWith(tixTierPrice: map['tixTierPrice'] as double);
    } catch (e) {
      Logx.em(_TAG, 'tixTier tixTierPrice not exist for id: ${tixTier.id}');
      isModelChanged = true;
    }
    try {
      tixTier = tixTier.copyWith(tixTierCount: map['tixTierCount'] as int);
    } catch (e) {
      Logx.em(_TAG, 'tixTier tixTierCount not exist for id: ${tixTier.id}');
      isModelChanged = true;
    }
    try {
      tixTier = tixTier.copyWith(guestsRemaining: map['guestsRemaining'] as int);
    } catch (e) {
      Logx.em(_TAG, 'tixTier guestsRemaining not exist for id: ${tixTier.id}');
      isModelChanged = true;
    }

    try {
      tixTier = tixTier.copyWith(tixTierTotal: map['tixTierTotal'] as double);
    } catch (e) {
      Logx.em(_TAG, 'tixTier tixTierTotal not exist for id: ${tixTier.id}');
      isModelChanged = true;
    }


    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating tix tier ${tixTier.id}');
      FirestoreHelper.pushTixTier(tixTier);
    }
    return tixTier;
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
      user = user.copyWith(username: map['username'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user username not exist for id: ${user.id}');
      isModelChanged = true;
    }
    try {
      user = user.copyWith(instagramLink: map['instagramLink'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user instagramLink not exist for id: ${user.id}');
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
      Logx.em(_TAG, 'user imageUrl not exist for id: ${user.id}');
      isModelChanged = true;
    }
    try {
      user = user.copyWith(gender: map['gender'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user gender not exist for id: ${user.id}');
      isModelChanged = true;
    }

    try {
      user = user.copyWith(clearanceLevel: map['clearanceLevel'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user clearanceLevel not exist for id: ${user.id}');
      isModelChanged = true;
    }
    try {
      user = user.copyWith(challengeLevel: map['challengeLevel'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user challengeLevel not exist for id: ${user.id}');
      isModelChanged = true;
    }

    try {
      user = user.copyWith(fcmToken: map['fcmToken'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user fcmToken not exist for id: ${user.id}');
      isModelChanged = true;
    }

    try {
      user = user.copyWith(createdAt: map['createdAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user createdAt not exist for id: ${user.id}');
      isModelChanged = true;
    }
    try {
      user = user.copyWith(lastSeenAt: map['lastSeenAt'] as int);
    } catch (e) {
      Logx.em(_TAG, 'user lastSeenAt not exist for id: ${user.id}');
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

    try {
      user = user.copyWith(blocServiceId: map['blocServiceId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'user blocServiceId not exist for id: ${user.id}');
      isModelChanged = true;
    }

    if(isModelChanged){
      if (shouldUpdate) {
        Logx.i(_TAG, 'updating user ${user.id}');
        FirestoreHelper.pushUser(user);
      } else if(UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL){
        int luck = NumberUtils.getRandomNumber(0, 10);
        if(luck == 9){
          Logx.i(_TAG, 'updating user ${user.id} by luck');
          FirestoreHelper.pushUser(user);
        }
      }
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
      freshUser = freshUser.copyWith(username: user.username);
    } catch (e) {
      Logx.em(_TAG, 'user username not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(instagramLink: user.instagramLink);
    } catch (e) {
      Logx.em(_TAG, 'user instagramLink not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(gender: user.gender);
    } catch (e) {
      Logx.em(_TAG, 'user gender not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(email: user.email);
    } catch (e) {
      Logx.em(_TAG, 'user email not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(imageUrl: user.imageUrl);
    } catch (e) {
      Logx.em(_TAG, 'user imageUrl not exist for id: ${user.id}');
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
      Logx.em(_TAG, 'user createdAt not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(lastSeenAt: user.lastSeenAt);
    } catch (e) {
      Logx.em(_TAG, 'user lastSeenAt not exist for id: ${user.id}');
    }
    try {
      freshUser = freshUser.copyWith(isBanned: user.isBanned);
    } catch (e) {
      Logx.em(_TAG, 'user isBanned not exist for id: ${user.id}');
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

    try {
      freshUser = freshUser.copyWith(blocServiceId: user.blocServiceId);
    } catch (e) {
      Logx.em(_TAG, 'user blocServiceId not exist for id: ${user.id}');
    }

    return freshUser;
  }

  /** user bloc **/
  static UserBloc freshUserBlocMap(Map<String, dynamic> map, bool shouldUpdate) {
    UserBloc userBloc = Dummy.getDummyUserBloc();
    bool isModelChanged = false;

    try {
      userBloc = userBloc.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'userBloc id not exist');
    }
    try {
      userBloc = userBloc.copyWith(userId: map['userId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'userBloc userId not exist for id: ${userBloc.id}');
      isModelChanged = true;
    }
    try {
      userBloc = userBloc.copyWith(blocServiceId: map['blocServiceId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'userBloc blocServiceId not exist for id: ${userBloc.id}');
      isModelChanged = true;
    }
    try {
      userBloc = userBloc.copyWith(createdTime: map['createdTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'userBloc createdTime not exist for id: ${userBloc.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating userPhoto ${userBloc.id}');
      FirestoreHelper.pushUserBloc(userBloc);
    }

    return userBloc;
  }

  static UserBloc freshUserBloc(UserBloc userBloc) {
    UserBloc fresh = Dummy.getDummyUserBloc();

    try {
      fresh = fresh.copyWith(id: userBloc.id);
    } catch (e) {
      Logx.em(_TAG, 'userBloc id not exist');
    }
    try {
      fresh = fresh.copyWith(userId: userBloc.userId);
    } catch (e) {
      Logx.em(_TAG, 'userBloc userId exist for id: ${userBloc.id}');
    }
    try {
      fresh = fresh.copyWith(blocServiceId: userBloc.blocServiceId);
    } catch (e) {
      Logx.em(_TAG, 'userBloc blocServiceId exist for id: ${userBloc.id}');
    }
    try {
      fresh = fresh.copyWith(createdTime: userBloc.createdTime);
    } catch (e) {
      Logx.em(_TAG, 'userBloc createdTime exist for id: ${userBloc.id}');
    }

    return fresh;
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

  /** user organizer **/
  static UserOrganizer freshUserOrganizerMap(Map<String, dynamic> map, bool shouldUpdate) {
    UserOrganizer userOrganizer = Dummy.getDummyUserOrganizer();
    bool isModelChanged = false;

    try {
      userOrganizer = userOrganizer.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'userOrganizer id not exist');
    }
    try {
      userOrganizer = userOrganizer.copyWith(userId: map['userId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'userPhoto userId not exist for id: ${userOrganizer.id}');
      isModelChanged = true;
    }
    try {
      userOrganizer = userOrganizer.copyWith(organizerId: map['organizerId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'userPhoto organizerId not exist for id: ${userOrganizer.id}');
      isModelChanged = true;
    }
    try {
      userOrganizer = userOrganizer.copyWith(creationTime: map['creationTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'userOrganizer creationTime not exist for id: ${userOrganizer.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating userOrganizer ${userOrganizer.id}');
      FirestoreHelper.pushUserOrganizer(userOrganizer);
    }

    return userOrganizer;
  }

  static UserOrganizer freshUserOrganizer(UserOrganizer userOrganizer) {
    UserOrganizer fresh = Dummy.getDummyUserOrganizer();

    try {
      fresh = fresh.copyWith(id: userOrganizer.id);
    } catch (e) {
      Logx.em(_TAG, 'userOrganizer id not exist');
    }
    try {
      fresh = fresh.copyWith(userId: userOrganizer.userId);
    } catch (e) {
      Logx.em(_TAG, 'userOrganizer userId exist for id: ${userOrganizer.id}');
    }
    try {
      fresh = fresh.copyWith(organizerId: userOrganizer.organizerId);
    } catch (e) {
      Logx.em(_TAG, 'userOrganizer organizerId exist for id: ${userOrganizer.id}');
    }
    try {
      fresh = fresh.copyWith(creationTime: userOrganizer.creationTime);
    } catch (e) {
      Logx.em(_TAG, 'userOrganizer creationTime not exist for id: ${userOrganizer.id}');
    }

    return fresh;
  }

  /** user photo **/
  static UserPhoto freshUserPhotoMap(Map<String, dynamic> map, bool shouldUpdate) {
    UserPhoto userPhoto = Dummy.getDummyUserPhoto();
    bool isModelChanged = false;

    try {
      userPhoto = userPhoto.copyWith(id: map['id'] as String);
    } catch (e) {
      Logx.em(_TAG, 'userPhoto id not exist');
    }
    try {
      userPhoto = userPhoto.copyWith(userId: map['userId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'userPhoto userId not exist for id: ${userPhoto.id}');
      isModelChanged = true;
    }
    try {
      userPhoto = userPhoto.copyWith(partyPhotoId: map['partyPhotoId'] as String);
    } catch (e) {
      Logx.em(_TAG, 'userPhoto partyPhotoId not exist for id: ${userPhoto.id}');
      isModelChanged = true;
    }
    try {
      userPhoto = userPhoto.copyWith(isConfirmed: map['isConfirmed'] as bool);
    } catch (e) {
      Logx.em(_TAG, 'userPhoto isConfirmed not exist for id: ${userPhoto.id}');
      isModelChanged = true;
    }
    try {
      userPhoto = userPhoto.copyWith(tagTime: map['tagTime'] as int);
    } catch (e) {
      Logx.em(_TAG, 'userPhoto tagTime not exist for id: ${userPhoto.id}');
      isModelChanged = true;
    }

    if (isModelChanged && shouldUpdate) {
      Logx.i(_TAG, 'updating userPhoto ${userPhoto.id}');
      FirestoreHelper.pushUserPhoto(userPhoto);
    }

    return userPhoto;
  }

  static UserPhoto freshUserPhoto(UserPhoto userPhoto) {
    UserPhoto fresh = Dummy.getDummyUserPhoto();

    try {
      fresh = fresh.copyWith(id: userPhoto.id);
    } catch (e) {
      Logx.em(_TAG, 'userPhoto id not exist');
    }
    try {
      fresh = fresh.copyWith(userId: userPhoto.userId);
    } catch (e) {
      Logx.em(_TAG, 'userPhoto userId exist for id: ${userPhoto.id}');
    }
    try {
      fresh = fresh.copyWith(partyPhotoId: userPhoto.partyPhotoId);
    } catch (e) {
      Logx.em(_TAG, 'userPhoto partyPhotoId exist for id: ${userPhoto.id}');
    }
    try {
      fresh = fresh.copyWith(isConfirmed: userPhoto.isConfirmed);
    } catch (e) {
      Logx.em(_TAG, 'userPhoto isConfirmed not exist for id: ${userPhoto.id}');
    }
    try {
      fresh = fresh.copyWith(tagTime: userPhoto.tagTime);
    } catch (e) {
      Logx.em(_TAG, 'userPhoto tagTime not exist for id: ${userPhoto.id}');
    }

    return fresh;
  }
}