import 'package:bloc/db/entity/party_photo.dart';
import 'package:bloc/widgets/ui/blurred_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
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
                    Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
                    final PartyPhoto photo = Fresh.freshPartyPhotoMap(map, false);
                    photos.add(photo);
                  }

                  if(showList){
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

        if(kIsWeb){
          return GestureDetector(
            child: SizedBox(
                height: 200,
                child: BlurredImage(imageUrl: photo.imageUrl, blurLevel: 3,)
            ),
          );
        } else {
          return GestureDetector(
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
        if(index == photos.length-1){
          return Column(
            children: [
              PartyPhotoItem(partyPhoto: partyPhoto),
              const SizedBox(height: 15.0),
              kIsWeb ? const StoreBadgeItem() : const SizedBox(),
              const SizedBox(height: 10,),
              Footer()
            ],
          );
        } else {
          return PartyPhotoItem(partyPhoto: partyPhoto);
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
}
