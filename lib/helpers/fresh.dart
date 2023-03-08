import 'package:bloc/helpers/firestore_helper.dart';

import '../db/entity/party.dart';
import '../db/entity/user.dart';
import '../db/shared_preferences/user_preferences.dart';
import 'dummy.dart';

class Fresh {
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

    return freshParty;
  }

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

    if(shouldPushUser && shouldUpdate){
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
