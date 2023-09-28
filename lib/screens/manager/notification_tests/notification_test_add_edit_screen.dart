import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bloc/helpers/firestorage_helper.dart';
import 'package:bloc/helpers/fresh.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../db/entity/ad.dart';
import '../../../db/entity/notification_test.dart';
import '../../../db/entity/party.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../services/notification_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/profile_widget.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/dark_button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class NotificationTestAddEditScreen extends StatefulWidget {
  NotificationTest test;
  String task;

  NotificationTestAddEditScreen({key, required this.test, required this.task})
      : super(key: key);

  @override
  _NotificationTestAddEditScreenState createState() =>
      _NotificationTestAddEditScreenState();
}

class _NotificationTestAddEditScreenState
    extends State<NotificationTestAddEditScreen> {
  static const String _TAG = 'NotificationTestAddEditScreen';
  bool testMode = false;

  List<Party> mParties = [];
  List<Party> sParties = [];
  var _isPartiesLoading = true;

  String imagePath = '';
  bool isPartyPhoto = false;

  @override
  void initState() {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;
    FirestoreHelper.pullPartiesByEndTime(timeNow, true).then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, false);
          mParties.add(party);
        }
        setState(() {
          _isPartiesLoading = false;
        });
      } else {
        Logx.i(_TAG, 'no parties found!');
        setState(() {
          _isPartiesLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: AppBarTitle(
            title: '${widget.task} test notification',
          ),
          titleSpacing: 0,
        ),
        body: _isPartiesLoading ? const LoadingWidget() : _buildBody(context),
      );

  _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        ProfileWidget(
          imagePath: imagePath.isEmpty ? widget.test.imageUrl : imagePath,
          isEdit: true,
          onClicked: () async {
            final image = await ImagePicker().pickImage(
                source: ImageSource.gallery, imageQuality: 95, maxWidth: 768);
            if (image == null) return;

            final directory = await getApplicationDocumentsDirectory();
            final name = basename(image.path);
            final imageFile = File('${directory.path}/$name');
            final newImage = await File(image.path).copy(imageFile.path);

            if (!isPartyPhoto) {
              String oldImageUrl = widget.test.imageUrl;

              if (oldImageUrl.isNotEmpty &&
                  oldImageUrl.contains('notification_test_image')) {
                FirestorageHelper.deleteFile(oldImageUrl);
              }
            } else {
              isPartyPhoto = false;
            }

            String newImageUrl = await FirestorageHelper.uploadFile(
                FirestorageHelper.NOTIFICATION_TEST_IMAGES,
                StringUtils.getRandomString(28),
                newImage);
            widget.test = widget.test.copyWith(imageUrl: newImageUrl);

            setState(() {
              imagePath = imageFile.path;
            });
          },
        ),
        const SizedBox(
          height: 24,
        ),
        TextFieldWidget(
          label: 'title *',
          text: widget.test.title,
          onChanged: (text) => widget.test = widget.test.copyWith(title: text),
        ),
        const SizedBox(height: 24),
        Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'party',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            MultiSelectDialogField(
              items: mParties
                  .map((e) => MultiSelectItem(e, '${e.name} ${e.chapter}'))
                  .toList(),
              initialValue: sParties.map((e) => e).toList(),
              listType: MultiSelectListType.CHIP,
              buttonIcon: Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade700,
              ),
              title: const Text('pick a party'),
              buttonText: const Text(
                'select',
                style: TextStyle(color: Constants.darkPrimary),
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: Border.all(
                  width: 0.0,
                ),
              ),
              searchable: true,
              onConfirm: (values) {
                sParties = values as List<Party>;

                if (sParties.isNotEmpty) {
                  Party party = sParties.first;

                  setState(() {
                    isPartyPhoto = true;
                    widget.test = widget.test.copyWith(
                      title: party.name,
                      body: party.description,
                      imageUrl: party.imageUrl,
                    );
                  });
                } else {
                  setState(() {
                    isPartyPhoto = false;
                    widget.test =
                        widget.test.copyWith(title: '', body: '', imageUrl: '');
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'body *',
          text: widget.test.body,
          maxLines: 8,
          onChanged: (text) => widget.test = widget.test.copyWith(body: text),
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: '💾 save',
          onClicked: () async {
            NotificationTest test = Fresh.freshNotificationTest(widget.test);

            if (!testMode) {
              FirestoreHelper.pushNotificationTest(test);
              Navigator.of(context).pop();
            } else {
              if (widget.test.imageUrl.isEmpty) {
                await NotificationService.showNotification(
                    title: widget.test.title,
                    body: widget.test.body,
                    actionButtons: [
                      NotificationActionButton(
                          key: 'DISMISS',
                          label: 'Dismiss',
                          actionType: ActionType.DismissAction,
                          isDangerousOption: true)
                    ]);
              } else {
                Map<String, dynamic> objectMap = widget.test.toMap();
                String jsonString = jsonEncode(objectMap);

                await NotificationService.showNotification(
                  title: widget.test.title,
                  body: widget.test.body,
                  bigPicture: widget.test.imageUrl,
                  largeIcon: widget.test.imageUrl,
                  notificationLayout: NotificationLayout.BigPicture,
                  payload: {
                    "navigate": "true",
                    "type": "notification_test",
                    "data": jsonString,
                  },
                );
              }
            }
          },
        ),
        const SizedBox(height: 24),
        DarkButtonWidget(
          text: 'delete',
          onClicked: () {
            if (widget.test.imageUrl.isNotEmpty &&
                widget.test.imageUrl.contains('notification_test_image')) {
              FirestorageHelper.deleteFile(widget.test.imageUrl);
            }

            FirestoreHelper.deleteNotificationTest(widget.test.id);
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
