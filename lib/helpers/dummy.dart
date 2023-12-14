import 'package:bloc/db/entity/category.dart';
import 'package:bloc/db/entity/challenge.dart';
import 'package:bloc/db/entity/guest_wifi.dart';
import 'package:bloc/db/entity/history_music.dart';
import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/db/entity/reservation.dart';
import 'package:bloc/db/entity/service_table.dart';
import 'package:bloc/db/entity/ticket.dart';
import 'package:bloc/db/entity/ui_photo.dart';
import 'package:bloc/db/entity/user_level.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../db/entity/ad.dart';
import '../db/entity/ad_campaign.dart';
import '../db/entity/bloc.dart';
import '../db/entity/bloc_service.dart';
import '../db/entity/captain_service.dart';
import '../db/entity/celebration.dart';
import '../db/entity/challenge_action.dart';
import '../db/entity/config.dart';
import '../db/entity/friend.dart';
import '../db/entity/friend_notification.dart';
import '../db/entity/lounge_chat.dart';
import '../db/entity/genre.dart';
import '../db/entity/lounge.dart';
import '../db/entity/notification_test.dart';
import '../db/entity/offer.dart';
import '../db/entity/party.dart';
import '../db/entity/party_interest.dart';
import '../db/entity/party_photo.dart';
import '../db/entity/tix.dart';
import '../db/entity/party_tix_tier.dart';
import '../db/entity/product.dart';
import '../db/entity/promoter.dart';
import '../db/entity/promoter_guest.dart';
import '../db/entity/quick_order.dart';
import '../db/entity/quick_table.dart';
import '../db/entity/seat.dart';
import '../db/entity/tix_tier_item.dart';
import '../db/entity/user.dart';
import '../db/entity/user_lounge.dart';
import '../db/entity/user_photo.dart';
import '../db/shared_preferences/user_preferences.dart';
import 'firestore_helper.dart';

class Dummy {
  static Ad getDummyAd(String blocServiceId) {
    Ad dummyAd = Ad(
        id: StringUtils.getRandomString(28),
        title: '',
        message: '',
        imageUrl: '',
        partyName: '',
        partyChapter: '',
        blocId: blocServiceId,
        createdAt: Timestamp.now().millisecondsSinceEpoch,
        isActive: true,
        hits: 0,
        reach: 0);

    return dummyAd;
  }

  static AdCampaign getDummyAdCampaign() {
    AdCampaign dummy = AdCampaign(
        id: StringUtils.getRandomString(28),
        name: '',
        imageUrls: [],
        clickCount: 0,
        linkUrl: '',
        isActive: false,
        isStorySize: false,
        isPartyAd: false,
        partyId: '',
      endTime: Timestamp.now().millisecondsSinceEpoch
    );

    return dummy;
  }

  static Bloc getDummyBloc(String cityId) {
    int time = Timestamp.now().millisecondsSinceEpoch;

    Bloc dummyBloc = Bloc(
        id: StringUtils.getRandomString(28),
        createdAt: time.toString(),
        name: '',
        ownerId: UserPreferences.myUser.id,
        addressLine1: '',
        addressLine2: '',
        cityId: cityId,
        isActive: false,
        pinCode: '',
        imageUrls: []);

    return dummyBloc;
  }

  static BlocService getDummyBlocService(String blocId) {
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

  static CaptainService getDummyCaptainService() {
    CaptainService dummy = CaptainService(
        id: StringUtils.getRandomString(28),
        name: '',
        sequence: 0,
        isActive: false);
    return dummy;
  }

  static Category getDummyCategory(String serviceId) {
    Category dummyCategory = Category(
        id: StringUtils.getRandomString(28),
        name: '',
        description: '',
        imageUrl: '',
        createdAt: Timestamp.now().millisecondsSinceEpoch,
        ownerId: UserPreferences.myUser.id,
        sequence: -1,
        serviceId: serviceId,
        type: 'Alcohol',
        blocIds: []);
    return dummyCategory;
  }

  static Celebration getDummyCelebration(String blocServiceId) {
    Celebration dummy = Celebration(
      id: StringUtils.getRandomString(28),
      blocServiceId: blocServiceId,
      customerId: UserPreferences.myUser.id,
      name: UserPreferences.isUserLoggedIn() ? UserPreferences.myUser.name : '',
      surname: UserPreferences.isUserLoggedIn()
          ? UserPreferences.myUser.surname
          : '',
      phone: UserPreferences.isUserLoggedIn()
          ? UserPreferences.myUser.phoneNumber
          : 0,
      guestsCount: 25,
      createdAt: Timestamp.now().millisecondsSinceEpoch,
      arrivalDate: Timestamp.now().millisecondsSinceEpoch,
      arrivalTime: '',
      durationHours: 1,
      bottleProductIds: [],
      bottleNames: [],
      specialRequest: '',
      occasion: 'none',
      isApproved: false,
    );
    return dummy;
  }

  static Challenge getDummyChallenge() {
    Challenge dummyChallenge = Challenge(
        id: StringUtils.getRandomString(28),
        level: 0,
        title: '',
        description: '',
        points: 0,
        clickCount: 0,
        dialogTitle: '',
        dialogAcceptText: '',
        dialogAccept2Text: '');
    return dummyChallenge;
  }

  static ChallengeAction getDummyChallengeAction(String challengeId) {
    ChallengeAction dummy = ChallengeAction(
        id: StringUtils.getRandomString(28),
        action: '',
        actionType: 'url',
        buttonCount: 1,
        buttonTitle: '',
        challengeId: challengeId);
    return dummy;
  }

  static Config getDummyConfig(String blocServiceId) {
    Config dummyConfig = Config(
        id: StringUtils.getRandomString(28),
        name: '',
        blocServiceId: blocServiceId,
        value: true);
    return dummyConfig;
  }

  static LoungeChat getDummyLoungeChat() {
    LoungeChat dummyChat = LoungeChat(
        id: StringUtils.getRandomString(28),
        loungeId: '',
        loungeName: '',
        userId: UserPreferences.myUser.id,
        userName: UserPreferences.myUser.name,
        userImage: UserPreferences.myUser.imageUrl,
        message: '',
        imageUrl: '',
        type: 'text',
        time: Timestamp.now().millisecondsSinceEpoch,
        vote: 0,
        upVoters: [],
        downVoters: []);
    return dummyChat;
  }

  static Friend getDummyFriend() {
    Friend dummyFriend = Friend(
      id: StringUtils.getRandomString(28),
      userId: '',
      friendUserId: '',
      isFollowing: true,
      friendshipDate: Timestamp.now().millisecondsSinceEpoch
    );
    return dummyFriend;
  }

  static FriendNotification getDummyFriendNotification() {
    FriendNotification dummy = FriendNotification(
        id: StringUtils.getRandomString(28),
        title: '',
        message: '',
        topic: '',
        imageUrl: '',
        time: Timestamp.now().millisecondsSinceEpoch
    );
    return dummy;
  }

  static Genre getDummyGenre() {
    Genre dummyGenre = Genre(
      id: StringUtils.getRandomString(28),
      name: '',
    );
    return dummyGenre;
  }

  static GuestWifi getDummyGuestWifi(String blocServiceId) {
    GuestWifi dummyWifi = GuestWifi(
        id: StringUtils.getRandomString(28),
        name: '',
        password: '',
        blocServiceId: blocServiceId,
        creationTime: Timestamp.now().millisecondsSinceEpoch);
    return dummyWifi;
  }

  static HistoryMusic getDummyHistoryMusic() {
    HistoryMusic dummy = HistoryMusic(
        id: StringUtils.getRandomString(28), userId: '', genre: '', count: 0);
    return dummy;
  }

  static Lounge getDummyLounge() {
    Lounge dummy = Lounge(
        id: StringUtils.getRandomString(28),
        name: '',
        description: '',
        rules: Constants.loungeRules,
        type: 'community',
        admins: [],
        members: [],
        exitedUserIds: [],
        imageUrl: '',
        creationTime: Timestamp.now().millisecondsSinceEpoch,
        lastChat: '',
        lastChatTime: Timestamp.now().millisecondsSinceEpoch,
        isActive: true,
        isVip: false);
    return dummy;
  }

  static NotificationTest getDummyNotificationTest() {
    NotificationTest dummy = NotificationTest(
        id: StringUtils.getRandomString(28), title: '', body: '', imageUrl: '');
    return dummy;
  }

  static Offer getDummyOffer() {
    Offer productOffer = Offer(
        blocServiceId: '',
        creationTime: 0,
        description: '',
        endTime: 0,
        id: StringUtils.getRandomString(28),
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

  static Party getDummyParty(String blocId) {
    Party dummyParty = Party(
        id: StringUtils.getRandomString(28),
        createdAt: Timestamp.now().millisecondsSinceEpoch,
        imageUrls: [],
        imageUrl: '',
        isSquare: true,
        storyImageUrl: '',
        showStoryImageUrl: false,
        name: '',
        ownerId: UserPreferences.myUser.id,
        isActive: false,
        isTBA: true,
        description: '',
        blocServiceId: '',
        endTime: Timestamp.now().millisecondsSinceEpoch,
        instagramUrl: Constants.blocInstaHandle,
        startTime: Timestamp.now().millisecondsSinceEpoch,
        ticketUrl: '',
        listenUrl: '',
        eventName: '',
        isGuestListActive: false,
        isGuestListFull: false,
        guestListCount: 2,
        isGuestsCountRestricted: true,
        guestListEndTime: Timestamp.now().millisecondsSinceEpoch,
        isEmailRequired: false,
        clubRules: Constants.clubRules,
        guestListRules: Constants.guestListRules,
        type: 'artist',
        isTix: false,
        tixSoldCount: 0,
        tixSalesTotal: 0,
        isBigAct: true,
        genre: '',
        isChallengeActive: false,
        overrideChallengeNum: 0,
        chapter: '',
        artistIds: [],
        loungeId: '',
        isTicketsDisabled: false,
        views: 0,
        shareCount: 0,
        isAdCampaignRunning: false
    );

    return dummyParty;
  }

  static PartyGuest getDummyPartyGuest(bool isLoggedInUser) {
    PartyGuest dummyGuest = PartyGuest(
        id: StringUtils.getRandomString(28),
        partyId: '',
        guestId: isLoggedInUser ? UserPreferences.myUser.id : '',
        name: isLoggedInUser ? UserPreferences.myUser.name : '',
        surname: isLoggedInUser ? UserPreferences.myUser.surname : '',
        phone: isLoggedInUser
            ? UserPreferences.myUser.phoneNumber.toString()
            : '0',
        email: isLoggedInUser ? UserPreferences.myUser.email : '',
        guestsCount: 2,
        guestsRemaining: 2,
        createdAt: Timestamp.now().millisecondsSinceEpoch,
        isApproved: false,
        guestStatus: isLoggedInUser ? 'couple' : 'promoter',
        isChallengeClicked: false,
        isVip: false,
        shouldBanUser: false,
        promoterId: '',
        guestNames: [],
        gender: isLoggedInUser ? UserPreferences.myUser.gender : 'male');
    return dummyGuest;
  }

  static PartyInterest getDummyPartyInterest() {
    PartyInterest partyInterest = PartyInterest(
        id: StringUtils.getRandomString(28),
        partyId: '',
        userIds: [],
        initCount: 10);
    return partyInterest;
  }

  static PartyPhoto getDummyPartyPhoto() {
    int now = Timestamp.now().millisecondsSinceEpoch;
    int endTime = now + (DateTimeUtils.millisecondsWeek * 4);

    PartyPhoto partyPhoto = PartyPhoto(
        id: StringUtils.getRandomString(28),
        blocServiceId: Constants.blocServiceId,
        partyName: '',
        loungeId: '',
        imageUrl: '',
        imageThumbUrl: '',
        createdAt: now,
        partyDate: now,
        endTime: endTime,
        likers: [],
        initLikes: 0,
        downloadCount: 0,
        downloaders: [],
        views: 0,
        tags: [],
      isFreePhoto: false
    );
    return partyPhoto;
  }

  static PartyTixTier getDummyPartyTixTier(String partyId, int endTime) {
    PartyTixTier partyTixTier = PartyTixTier(
        id: StringUtils.getRandomString(28),
        partyId: partyId,
        tierLevel: 1,
        tierName: '',
        tierDescription: 'entry for 1 person.',
        tierPrice: 0,
        soldCount: 0,
        totalTix: 0,
        isSoldOut: false,
      endTime: endTime
    );
    return partyTixTier;
  }

  static Product getDummyProduct(String blocServiceId, String userId) {
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
        isVeg: true,
        blocIds: [],
        priceBottle: 0);

    return dummyProduct;
  }

  static Promoter getDummyPromoter() {
    Promoter dummy =
        Promoter(id: StringUtils.getRandomString(28), name: '', type: 'brand');

    return dummy;
  }

  static PromoterGuest getDummyPromoterGuest() {
    PromoterGuest dummy = PromoterGuest(
        id: StringUtils.getRandomString(28),
        name: '',
        phone: '',
        promoterId: Constants.blocPromoterId,
        blocUserId: '',
        partyGuestId: '',
        createdAt: Timestamp.now().millisecondsSinceEpoch,
        hasAttended: false);

    return dummy;
  }

  static QuickOrder getDummyQuickOrder() {
    QuickOrder dummy = QuickOrder(
        id: StringUtils.getRandomString(28),
        custId: '',
        custPhone: 0,
        productId: '',
        quantity: 1,
        table: '',
        createdAt: Timestamp.now().millisecondsSinceEpoch,
        status: 'ordered');

    return dummy;
  }

  static QuickTable getDummyQuickTable() {
    QuickTable dummy = QuickTable(
      id: StringUtils.getRandomString(28),
      phone: 0,
      tableName: '',
      createdAt: Timestamp.now().millisecondsSinceEpoch,
    );

    return dummy;
  }

  static Reservation getDummyReservation(String blocServiceId) {
    Reservation dummyReservation = Reservation(
        id: StringUtils.getRandomString(28),
        blocServiceId: blocServiceId,
        customerId: UserPreferences.myUser.id,
        name:
            UserPreferences.isUserLoggedIn() ? UserPreferences.myUser.name : '',
        phone: UserPreferences.isUserLoggedIn()
            ? UserPreferences.myUser.phoneNumber
            : 0,
        guestsCount: 1,
        createdAt: Timestamp.now().millisecondsSinceEpoch,
        arrivalDate: Timestamp.now().millisecondsSinceEpoch,
        arrivalTime: '',
        bottleProductIds: [],
        bottleNames: [],
        specialRequest: '',
        occasion: 'none',
        isApproved: false);
    return dummyReservation;
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

  static ServiceTable getDummyTable(String blocServiceId) {
    ServiceTable dummyTable = ServiceTable(
        id: StringUtils.getRandomString(28),
        captainId: '',
        capacity: 0,
        isActive: false,
        isOccupied: false,
        serviceId: blocServiceId,
        tableNumber: -1,
        type: FirestoreHelper.TABLE_PRIVATE_TYPE_ID);
    return dummyTable;
  }

  static Tix getDummyTix() {
    Tix tix = Tix(
        id: StringUtils.getRandomString(9),
        partyId: '',
        userId: UserPreferences.myUser.id,
        userName: '${UserPreferences.myUser.name} ${UserPreferences.myUser.surname}',
        userEmail: UserPreferences.myUser.email,
        userPhone: UserPreferences.myUser.phoneNumber.toString(),
        igst: 0,
        subTotal: 0,
        bookingFee: 0,
        total: 0,
        merchantTransactionId: '',
        transactionId: '',
        transactionResponseCode:'',
        creationTime: Timestamp.now().millisecondsSinceEpoch,
        isSuccess: false,
        isCompleted: false,
        isArrived: false,
        tixTierIds: []);
    return tix;
  }

  static TixTier getDummyTixTier() {
    TixTier tixTierItem = TixTier(
      id: StringUtils.getRandomString(28),
      tixId: '',
      partyTixTierId: '',
      tixTierName: '',
      tixTierDescription: '',
      tixTierPrice: 0,
      tixTierCount: 0,
      tixTierTotal: 0,
      guestsRemaining: 0
    );
    return tixTierItem;
  }

  static UiPhoto getDummyUiPhoto() {
    UiPhoto uiPhoto =
        UiPhoto(id: StringUtils.getRandomString(28), name: '', imageUrls: []);
    return uiPhoto;
  }

  static User getDummyUser() {
    int millis = Timestamp.now().millisecondsSinceEpoch;

    User dummyUser = User(
        id: StringUtils.getRandomString(28),
        blocServiceId: '',
        clearanceLevel: 1,
        challengeLevel: 1,
        email: '',
        fcmToken: '',
        imageUrl: '',
        name: '',
        surname: '',
        username: '',
        instagramHandle: '',
        gender: 'male',
        birthYear: 2023,
        phoneNumber: 0,
        isBanned: false,
        isAppUser: false,
        appVersion: Constants.appVersion,
        isAppReviewed: false,
        lastReviewTime: 0,
        isIos: false,
        createdAt: millis,
        lastSeenAt: millis);
    return dummyUser;
  }

  static UserLevel getDummyUserLevel() {
    UserLevel dummyUserLevel =
        const UserLevel(id: '84ub8bC0m3NQH9KfWCkD', name: 'customer', level: 1);

    return dummyUserLevel;
  }

  static UserLounge getDummyUserLounge() {
    UserLounge dummyUserLounge = UserLounge(
        id: StringUtils.getRandomString(28),
        userId: '',
        userFcmToken: '',
        loungeId: '',
        lastAccessedTime: Timestamp.now().millisecondsSinceEpoch,
        isAccepted: true,
        isBanned: false);
    return dummyUserLounge;
  }

  static UserPhoto getDummyUserPhoto() {
    UserPhoto dummy = UserPhoto(
      id: StringUtils.getRandomString(28),
      userId: '',
      partyPhotoId: '',
      isConfirmed: false,
      tagTime: Timestamp.now().millisecondsSinceEpoch,
    );

    return dummy;
  }
}
