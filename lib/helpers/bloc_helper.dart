import '../db/entity/user_bloc.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../utils/constants.dart';
import '../utils/logx.dart';
import 'dummy.dart';
import 'firestore_helper.dart';

class BlocHelper {
  static const String _TAG = 'BlocHelper';

  static void setDefaultBlocs(String userId) {
    Logx.i(_TAG, 'setDefaultBlocs: $userId');

    UserBloc userBlocBloc = Dummy.getDummyUserBloc();
    userBlocBloc = userBlocBloc.copyWith(userId: userId, blocServiceId: Constants.blocServiceId);

    if(UserPreferences.getUserBlocs().contains(Constants.blocServiceId)){
      FirestoreHelper.pushUserBloc(userBlocBloc);
    }

    UserBloc userBlocFreq = Dummy.getDummyUserBloc();
    userBlocFreq = userBlocFreq.copyWith(userId: userId, blocServiceId: Constants.freqServiceId);

    if(UserPreferences.getUserBlocs().contains(Constants.freqServiceId)){
      FirestoreHelper.pushUserBloc(userBlocFreq);
    }

    List<String> blocIds = [Constants.blocServiceId, Constants.freqServiceId];
    UserPreferences.setUserBlocs(blocIds);

    Logx.d(_TAG, '${UserPreferences.myUser.name} ${UserPreferences.myUser.surname} is part of bloc and freq');
  }

}