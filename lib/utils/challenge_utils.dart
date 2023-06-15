import 'package:bloc/db/entity/challenge.dart';

class ChallengeUtils {

  static const String partyInsta = 'party insta';
  static const String storyImage = 'story image';

  static const String urlBlocInsta = 'https://www.instagram.com/bloc.india/';
  static const String urlFreqInsta = 'https://www.instagram.com/freq.club/';

  static const String urlBlocPlayStore = 'https://play.google.com/store/apps/details?id=com.novatech.bloc';
  static const String urlBlocAppStore = 'https://apps.apple.com/in/app/bloc-community/id1672736309';

  static String challengeUrl(Challenge challenge) {
    switch (challenge.level) {
      case 1:
        {
          return ChallengeUtils.urlBlocInsta;
        }
      case 2:
        {
          return ChallengeUtils.urlFreqInsta;
        }
      case 3:{
        return ChallengeUtils.urlBlocAppStore;
      }
      case 4:{
        //share or invite your friends
        return partyInsta;
      }
      case 100:
        {
          return storyImage;
        }
      default:
        {
          return ChallengeUtils.urlBlocInsta;
        }
    }

  }

}