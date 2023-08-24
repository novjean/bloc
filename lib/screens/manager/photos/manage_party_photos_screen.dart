import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../../../db/entity/party_photo.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../utils/file_utils.dart';
import '../../../utils/logx.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/ui/loading_widget.dart';
import 'manage_party_photo_item.dart';
import 'party_photo_add_edit_screen.dart';

class ManagePartyPhotosScreen extends StatefulWidget {
  String blocServiceId;

  ManagePartyPhotosScreen({super.key, required this.blocServiceId});

  @override
  State<StatefulWidget> createState() => _ManagePartyPhotosScreenState();
}

class _ManagePartyPhotosScreenState extends State<ManagePartyPhotosScreen> {
  static const String _TAG = 'ManagePartyPhotosScreen';

  List<PartyPhoto> mPartyPhotos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('manage photos'),
        titleSpacing: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showActionsDialog(context);
        },
        backgroundColor: Theme.of(context).primaryColor,
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
        // const SizedBox(height: 2.0),
        // _displayOptions(context),
        // const Divider(),
        const SizedBox(height: 2.0),
        _loadPhotos(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  _loadPhotos(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getPartyPhotos(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                mPartyPhotos = [];

                int now = Timestamp.now().millisecondsSinceEpoch;

                try {
                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    DocumentSnapshot document = snapshot.data!.docs[i];
                    Map<String, dynamic> map =
                        document.data()! as Map<String, dynamic>;
                    final PartyPhoto photo =
                        Fresh.freshPartyPhotoMap(map, false);

                    if(now> photo.endTime){
                      FirestoreHelper.deletePartyPhoto(photo.id);
                    } else {
                      mPartyPhotos.add(photo);
                    }
                  }

                  return _showPhotos(context);
                } on Exception catch (e, s) {
                  Logx.e(_TAG, e, s);
                } catch (e) {
                  Logx.em(_TAG, 'error loading photos : $e');
                }
              }
          }
          return const LoadingWidget();
        });
  }

  _showPhotos(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          itemCount: mPartyPhotos.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManagePartyPhotoItem(
                  partyPhoto: mPartyPhotos[index],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) =>
                            PartyPhotoAddEditScreen(partyPhoto: mPartyPhotos[index],task: 'edit',)),
                  );
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
                        const Text('add photos'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () {
                                  Navigator.of(ctx).pop();

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (ctx) =>
                                            PartyPhotoAddEditScreen(partyPhoto: Dummy.getDummyPartyPhoto(),task: 'add',)),
                                  );
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.add_photo_alternate_rounded,color: Constants.darkPrimary,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 30,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('update all thumbnails'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () async {
                                  Navigator.of(ctx).pop();

                                  int count = 0;
                                  for(PartyPhoto partyPhoto in mPartyPhotos){
                                    if(partyPhoto.imageThumbUrl.isEmpty){
                                      final Uri url = Uri.parse(partyPhoto.imageUrl);
                                      final response = await http.get(url);

                                      final tempDir = await getTemporaryDirectory();
                                      final imageFile = File('${tempDir.path}/${partyPhoto.id}.png');
                                      await imageFile.writeAsBytes(response.bodyBytes);

                                      final newThumbImage = await FileUtils.getImageCompressed(imageFile.path, 280, 210, 95);
                                      String imageThumbUrl = await FirestorageHelper.uploadFile(
                                          FirestorageHelper.PARTY_PHOTO_THUMB_IMAGES,
                                          StringUtils.getRandomString(28),
                                          newThumbImage);

                                      partyPhoto = partyPhoto.copyWith(
                                          imageThumbUrl: imageThumbUrl);
                                      FirestoreHelper.pushPartyPhoto(partyPhoto);
                                      count++;

                                      Logx.ist(_TAG, 'pushed $count new photo with thumbnails!');
                                    }
                                  }
                                  },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.photo_size_select_large_sharp, color: Colors.blue,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
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
