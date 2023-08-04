import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/party_photo.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../utils/logx.dart';
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
      appBar: AppBar(title: const Text('manage photos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) =>
                    PartyPhotoAddEditScreen(partyPhoto: Dummy.getDummyPartyPhoto(),task: 'add',)),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'add photos',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
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
        const SizedBox(height: 5.0),
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

                try {
                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    DocumentSnapshot document = snapshot.data!.docs[i];
                    Map<String, dynamic> map =
                        document.data()! as Map<String, dynamic>;
                    final PartyPhoto photo =
                        Fresh.freshPartyPhotoMap(map, false);
                    mPartyPhotos.add(photo);
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
}
