import 'package:bloc/db/entity/party_photo.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/widgets/ui/blurred_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/challenge_utils.dart';
import '../../utils/constants.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../../widgets/footer.dart';
import '../../widgets/photo/party_photo_item.dart';
import '../../widgets/store_badge_item.dart';
import '../../widgets/ui/loading_widget.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({Key? key}) : super(key: key);

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  static const String _TAG = 'PhotosScreen';

  bool showList = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      floatingActionButton: _showToggleViewButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      resizeToAvoidBottomInset: false,
      body: _buildPhotos(context),
    );
  }

  _buildPhotos(BuildContext context) {
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
                List<PartyPhoto> photos = [];

                try {
                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    DocumentSnapshot document = snapshot.data!.docs[i];
                    Map<String, dynamic> map =
                        document.data()! as Map<String, dynamic>;
                    final PartyPhoto photo =
                        Fresh.freshPartyPhotoMap(map, false);
                    photos.add(photo);
                  }

                  if (showList) {
                    return _showPhotosListView(photos);
                  } else {
                    return _showPhotosGridView(photos);
                  }
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

  _showPhotosGridView(List<PartyPhoto> photos) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        PartyPhoto photo = photos[index];

        if (kIsWeb) {
          return GestureDetector(
            onTap: () {
              _showDownloadAppDialog(context);
            },
            child: SizedBox(
                height: 200,
                child: BlurredImage(
                  imageUrl: photo.imageUrl,
                  blurLevel: 3,
                )),
          );
        } else {
          return GestureDetector(
            onTap: () {
              _showPhotoDialog(context, photo, index);
            },
            child: SizedBox(
              height: 200,
              child: FadeInImage(
                placeholder: const AssetImage('assets/icons/logo.png'),
                image: NetworkImage(photo.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      },
    );
  }

  _showPhotosListView(List<PartyPhoto> photos) {
    return ListView.builder(
      itemCount: photos.length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        PartyPhoto partyPhoto = photos[index];
        if (index == photos.length - 1) {
          return Column(
            children: [
              PartyPhotoItem(partyPhoto: partyPhoto, index: index,),
              const SizedBox(height: 15.0),
              kIsWeb ? const StoreBadgeItem() : const SizedBox(),
              const SizedBox(
                height: 10,
              ),
              Footer()
            ],
          );
        } else {
          return PartyPhotoItem(partyPhoto: partyPhoto, index: index,);
        }
      },
    );
  }

  _showToggleViewButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          showList = !showList;
        });
      },
      backgroundColor: Constants.primary,
      tooltip: 'toggle view',
      elevation: 5,
      splashColor: Colors.grey,
      child: Icon(
        showList ? Icons.grid_on_rounded : Icons.list_rounded,
        color: Colors.black,
        size: 29,
      ),
    );
  }

  _showPhotoDialog(BuildContext context, PartyPhoto partyPhoto, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: mq.height * 0.5,
            width: mq.width * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  child: Text(
                    '${partyPhoto.partyName}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                  child: Text(
                    '${DateTimeUtils.getFormattedDate2(partyPhoto.partyDate)}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Center(
                    child: SizedBox(
                  width: mq.width,
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/images/logo_3x2.png'),
                    image: NetworkImage(partyPhoto.imageUrl),
                    fit: BoxFit.contain,
                  ),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary), // Set your desired background color
              ),
              child: const Text(
                "💕 save to gallery",
                style: TextStyle(color: Constants.primary),
              ),
              onPressed: () {
                int fileNum = index+1;
                String fileName = '${partyPhoto.partyName} $fileNum';
                FileUtils.saveNetworkImage(partyPhoto.imageUrl, fileName);

                int count = partyPhoto.downloadCount + 1;
                partyPhoto = partyPhoto.copyWith(downloadCount: count);
                FirestoreHelper.pushPartyPhoto(partyPhoto);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDownloadAppDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'bloc app',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
            backgroundColor: Constants.lightPrimary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: const EdgeInsets.all(16.0),
            content: const Text(
                "ready, set, download delight! bloc app in hand, memories at hand. download our app in order to save photos to your gallery."),
            actions: [
              TextButton(
                child: const Text('close',
                    style: TextStyle(color: Constants.background)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Constants.darkPrimary), // Set your desired background color
                ),
                child: const Text('🤖 android',
                    style: TextStyle(color: Constants.primary)),
                onPressed: () async {
                  final uri = Uri.parse(ChallengeUtils.urlBlocPlayStore);
                  NetworkUtils.launchInBrowser(uri);
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Constants.darkPrimary), // Set your desired background color
                ),
                child:
                const Text('🍎 ios', style: TextStyle(color: Constants.primary)),
                onPressed: () async {
                  final uri = Uri.parse(ChallengeUtils.urlBlocAppStore);
                  NetworkUtils.launchInBrowser(uri);
                },
              ),
            ],
          );
        });
  }

}
