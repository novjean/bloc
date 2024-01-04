import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../utils/constants.dart';
import '../db/entity/bloc.dart';
import '../db/entity/bloc_service.dart';
import '../db/entity/user_bloc.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/dummy.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../utils/logx.dart';

class BlocItem extends StatefulWidget {
  final Bloc bloc;
  final double imageHeight;

  const BlocItem(
      {Key? key,
        required this.bloc,
        required this.imageHeight})
      : super(key: key);

  @override
  State<BlocItem> createState() => _BlocItemState();
}

class _BlocItemState extends State<BlocItem> {
  static const String _TAG = 'BlocItem';

  late BlocService mBlocService;
  bool isUserBloc = false;

  @override
  void initState() {
    FirestoreHelper.pullBlocServiceByBlocId(widget.bloc.id).then((res) {
      if (res.docs.isNotEmpty) {
        List<BlocService> blocServices = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final BlocService blocService = Fresh.freshBlocServiceMap(data, false);
          blocServices.add(blocService);
        }

        setState(() {
          mBlocService = blocServices.first;

          if(UserPreferences.getUserBlocs().contains(mBlocService.id)){
            isUserBloc = true;
          }
        });
      } else {
        Logx.em(_TAG, 'no bloc service found for bloc id ${widget.bloc.id}');
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        bool value = !isUserBloc;

        if(value){
          FirestoreHelper.pullUserBloc(UserPreferences.myUser.id, mBlocService.id).then((res) async {
            if(res.docs.isEmpty) {
              UserBloc userBloc = Dummy.getDummyUserBloc();
              userBloc = userBloc.copyWith(userId: UserPreferences.myUser.id,
                  blocServiceId: mBlocService.id);
              await FirestoreHelper.pushUserBloc(userBloc);

              List<String> blocIds = UserPreferences.getUserBlocs();

              if(!blocIds.contains(mBlocService.id)){
                blocIds.add(mBlocService.id);
                UserPreferences.setUserBlocs(blocIds);
              }
            } else {
              List<String> blocIds = UserPreferences.getUserBlocs();
              if(!blocIds.contains(mBlocService.id)){
                blocIds.add(mBlocService.id);
                UserPreferences.setUserBlocs(blocIds);
              } else {
                // the correct list of blocs is already present
              }
            }
          });
        } else {
          FirestoreHelper.pullUserBloc(UserPreferences.myUser.id, mBlocService.id).then((res) {
            if(res.docs.isNotEmpty){
              DocumentSnapshot document = res.docs[0];
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              UserBloc userBloc = Fresh.freshUserBlocMap(data, false);

              FirestoreHelper.deleteUserBloc(userBloc.id);
              Logx.d(_TAG, 'user bloc deleted');
            }
          });

          List<String> blocIds = UserPreferences.getUserBlocs();
          blocIds.remove(mBlocService.id);
          UserPreferences.setUserBlocs(blocIds);
        }

        setState(() {
          isUserBloc = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Hero(
          tag: widget.bloc.id,
          child: Card(
            elevation: 10,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: SizedBox(
              width: mq.width * 0.99,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: [
                      SizedBox(
                        height: widget.imageHeight,
                        width: mq.width,
                        child: isUserBloc ? FadeInImage(
                          placeholder: const AssetImage(
                              'assets/icons/logo.png'),
                          image: NetworkImage(widget.bloc.imageUrls.first, ),
                          fit: BoxFit.cover,) : ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          ),
                          child: FadeInImage(
                            placeholder: const AssetImage(
                                'assets/icons/logo.png'),
                            image: NetworkImage(widget.bloc.imageUrls.first, ),
                            fit: BoxFit.cover,),
                        ),
                      ),

                      Positioned(
                        top: 5.0,
                        right: 5.0,
                        child: Checkbox(
                          value: isUserBloc,
                          onChanged: (value) async {
                            if(value!){
                              FirestoreHelper.pullUserBloc(UserPreferences.myUser.id, mBlocService.id).then((res) async {
                                if(res.docs.isEmpty) {
                                  UserBloc userBloc = Dummy.getDummyUserBloc();
                                  userBloc = userBloc.copyWith(userId: UserPreferences.myUser.id,
                                      blocServiceId: mBlocService.id);
                                  await FirestoreHelper.pushUserBloc(userBloc);

                                  List<String> blocIds = UserPreferences.getUserBlocs();

                                  if(!blocIds.contains(mBlocService.id)){
                                    blocIds.add(mBlocService.id);
                                    UserPreferences.setUserBlocs(blocIds);
                                  }
                                } else {
                                  List<String> blocIds = UserPreferences.getUserBlocs();
                                  if(!blocIds.contains(mBlocService.id)){
                                    blocIds.add(mBlocService.id);
                                    UserPreferences.setUserBlocs(blocIds);
                                  } else {
                                    // the correct list of blocs is already present
                                  }
                                }
                              });
                            } else {
                              FirestoreHelper.pullUserBloc(UserPreferences.myUser.id, mBlocService.id).then((res) {
                                if(res.docs.isNotEmpty){
                                  DocumentSnapshot document = res.docs[0];
                                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                  UserBloc userBloc = Fresh.freshUserBlocMap(data, false);

                                  FirestoreHelper.deleteUserBloc(userBloc.id);
                                  Logx.d(_TAG, 'user bloc deleted');
                                }
                              });

                              List<String> blocIds = UserPreferences.getUserBlocs();
                              blocIds.remove(mBlocService.id);
                              UserPreferences.setUserBlocs(blocIds);
                            }

                            setState(() {
                              isUserBloc = value;
                            });
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 5.0,
                        left: 5,
                        child: Container(
                            width: mq.width,
                            child: Text(widget.bloc.name.toLowerCase(),
                                style: TextStyle(
                                    fontFamily: Constants.fontDefault,
                                    color: Colors.white,
                                    backgroundColor: Constants.darkPrimary
                                        .withOpacity(0.8),
                                    overflow: TextOverflow.ellipsis,

                                    fontSize: 26,
                                    fontWeight: FontWeight.bold))
                        ),
                      )

                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
