import '../db/entity/party.dart';
import '../db/shared_preferences/user_preferences.dart';
import 'dummy.dart';

class Fresh {
  static Party freshParty(Party party) {
    String blocId;

    if(party.blocServiceId.isNotEmpty){
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

}