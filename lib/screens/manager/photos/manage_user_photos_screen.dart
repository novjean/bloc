
import 'package:bloc/db/entity/user_photo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/party_photo.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../widgets/manager/manage_user_photo_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/loading_widget.dart';
import 'party_photo_add_edit_screen.dart';

class ManageUserPhotosScreen extends StatefulWidget {
  ManageUserPhotosScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ManageUserPhotosScreenState();
}

class _ManageUserPhotosScreenState extends State<ManageUserPhotosScreen> {
  static const String _TAG = 'ManageUserPhotosScreen';

  List<UserPhoto> mUserPhotos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: 'manage user photos'),
        titleSpacing: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showActionsDialog(context);
        },
        backgroundColor: Constants.primary,
        tooltip: 'actions',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.science,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 2.0),
        _loadUserPhotos(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  _loadUserPhotos(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getUserPhotos(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                mUserPhotos = [];

                try {
                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    DocumentSnapshot document = snapshot.data!.docs[i];
                    Map<String, dynamic> map =
                    document.data()! as Map<String, dynamic>;
                    final UserPhoto userPhoto =
                    Fresh.freshUserPhotoMap(map, false);

                    mUserPhotos.add(userPhoto);
                  }

                  return _showUserPhotos(context);
                } on Exception catch (e, s) {
                  Logx.e(_TAG, e, s);
                } catch (e) {
                  Logx.em(_TAG, 'error loading user photos : $e');
                }
              }
          }
          return const LoadingWidget();
        });
  }

  _showUserPhotos(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          itemCount: mUserPhotos.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageUserPhotoItem(
                  userPhoto: mUserPhotos[index],
                ),
                onDoubleTap: () {
                  UserPhoto userPhoto = mUserPhotos[index];
                  FirestoreHelper.deleteUserPhoto(userPhoto.id);

                  Logx.ist(_TAG, 'user photo tag is deleted');
                },
                onTap: () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //       builder: (ctx) => PartyPhotoAddEditScreen(
                  //         partyPhoto: mUserPhotos[index],
                  //         task: 'edit',
                  //       )),
                  // );
                });
          }),
    );
  }

  _showActionsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: _actionsList(ctx),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _actionsList(BuildContext ctx) {
    return SizedBox(
      height: mq.height * 0.5,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'actions',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: mq.height * 0.45,
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('check connection'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () async {
                                  Navigator.of(ctx).pop();

                                  for(UserPhoto userPhoto in mUserPhotos){
                                    await FirestoreHelper.pullPartyPhoto(userPhoto.partyPhotoId).then((res) {
                                      if(res.docs.isNotEmpty){
                                        DocumentSnapshot document = res.docs[0];
                                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                        PartyPhoto partyPhoto = Fresh.freshPartyPhotoMap(data, false);

                                        if(partyPhoto.tags.contains(userPhoto.userId)){
                                          Logx.d(_TAG, 'name ${partyPhoto.partyName} : views ${partyPhoto.views} : tags ${partyPhoto.tags.length} ');
                                        } else {
                                          if(userPhoto.isConfirmed){
                                            partyPhoto.tags.add(userPhoto.userId);
                                            FirestoreHelper.pushPartyPhoto(partyPhoto);
                                            Logx.ist(_TAG, 'tag fixed on ${partyPhoto.partyName} : ${partyPhoto.views}');
                                          }
                                        }
                                      }
                                    });
                                  }
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.add_photo_alternate_rounded,
                                      color: Constants.darkPrimary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
