import 'dart:io';

import 'package:bloc/db/entity/celebration.dart';
import 'package:bloc/db/entity/ui_photo.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../helpers/dummy.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../utils/logx.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/celebrations/celebration_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/loading_widget.dart';
import '../../user/celebration_add_edit_screen.dart';

class ManageCelebrationsScreen extends StatefulWidget {
  String blocServiceId;
  String serviceName;
  String userTitle;

  ManageCelebrationsScreen(
      {required this.blocServiceId,
      required this.serviceName,
      required this.userTitle});

  @override
  State<StatefulWidget> createState() => _ManageCelebrationsScreenState();
}

class _ManageCelebrationsScreenState extends State<ManageCelebrationsScreen> {
  static const String _TAG = 'ManageCelebrationsScreen';

  UiPhoto uiPhoto = Dummy.getDummyUiPhoto();
  bool isPhotosLoading = true;

  String newImageUrl = '';

  @override
  void initState() {
    uiPhoto.name = 'celebration';

    FirestoreHelper.pullUiPhoto(uiPhoto.name).then((res) {
      Logx.i(_TAG, 'successfully pulled in ui photos');

      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

        uiPhoto = Fresh.freshUiPhotoMap(data, false);
        setState(() {
          isPhotosLoading = false;
        });
      } else {
        setState(() {
          isPhotosLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          titleSpacing: 0,
          title: AppBarTitle(title: 'manage ${widget.serviceName}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showActionsDialog(context);
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
        const SizedBox(height: 5.0),
        _buildCelebrations(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  _buildCelebrations(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getCelebrationsByBlocId(widget.blocServiceId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          List<Celebration> celebrations = [];

          if (snapshot.data!.docs.isNotEmpty) {
            try {
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot document = snapshot.data!.docs[i];
                Map<String, dynamic> map =
                    document.data()! as Map<String, dynamic>;
                final Celebration celebration =
                    Fresh.freshCelebrationMap(map, false);
                celebrations.add(celebration);

                if (i == snapshot.data!.docs.length - 1) {
                  return _displayCelebrations(context, celebrations);
                }
              }
            } on Exception catch (e, s) {
              Logx.e(_TAG, e, s);
            } catch (e) {
              Logx.em(_TAG, 'error loading celebrations : $e');
            }
          }

          return const LoadingWidget();
        });
  }

  _displayCelebrations(BuildContext context, List<Celebration> celebrations) {
    return Expanded(
      child: ListView.builder(
          itemCount: celebrations.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            Celebration celebration = celebrations[index];

            return GestureDetector(
                child: CelebrationItem(
                  celebration: celebration,
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => CelebrationAddEditScreen(
                            celebration: celebration,
                            task: 'edit',
                          )));
                });
          }),
    );
  }

  showActionsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 250,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Text(
                          'actions',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
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
                              Text('${uiPhoto.imageUrls.length} photos : '),
                              const Spacer(),
                              ButtonWidget(
                                text: 'pick file',
                                onClicked: () async {
                                  final image = await ImagePicker().pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 95,
                                      maxHeight: 768,
                                      maxWidth: 1024);
                                  if (image == null) return;

                                  final directory =
                                      await getApplicationDocumentsDirectory();
                                  final name = basename(image.path);
                                  final imageFile =
                                      File('${directory.path}/$name');
                                  final newImage = await File(image.path)
                                      .copy(imageFile.path);

                                  newImageUrl =
                                      await FirestorageHelper.uploadFile(
                                          FirestorageHelper.UI_PHOTO_IMAGES,
                                          StringUtils.getRandomString(28),
                                          newImage);

                                  uiPhoto.imageUrls.add(newImageUrl);

                                  setState(() {
                                    uiPhoto = uiPhoto.copyWith(
                                        imageUrls: uiPhoto.imageUrls);
                                    FirestoreHelper.pushUiPhoto(uiPhoto);
                                  });
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: SizedBox.fromSize(
                                  size: Size(56, 56),
                                  child: ClipOval(
                                    child: Material(
                                      color: Colors.redAccent,
                                      child: InkWell(
                                        splashColor: Colors.red,
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('photos'),
                                                  content: photosListDialog(),
                                                );
                                              });
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(Icons.delete_forever),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  Widget photosListDialog() {
    return SingleChildScrollView(
      child: SizedBox(
        height: 300.0, // Change as per your requirement
        width: 300.0, // Change as per your requirement
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: uiPhoto.imageUrls.length,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(uiPhoto.imageUrls[index],
                        width: 110, height: 70, fit: BoxFit.fill),
                  ),
                ),
                SizedBox.fromSize(
                  size: const Size(50, 50),
                  child: ClipOval(
                    child: Material(
                      color: Colors.redAccent,
                      child: InkWell(
                        splashColor: Colors.red,
                        onTap: () {
                          FirestorageHelper.deleteFile(
                              uiPhoto.imageUrls[index]);
                          uiPhoto.imageUrls.removeAt(index);

                          uiPhoto =
                              uiPhoto.copyWith(imageUrls: uiPhoto.imageUrls);
                          FirestoreHelper.pushUiPhoto(uiPhoto);

                          Navigator.of(context).pop();
                          setState(() {});
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(Icons.delete_forever),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
