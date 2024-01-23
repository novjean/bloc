import 'dart:io';

import 'package:bloc/helpers/firestorage_helper.dart';
import 'package:bloc/helpers/fresh.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../db/entity/organizer.dart';
import '../../../db/entity/user.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/logx.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/profile_widget.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/dark_button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class OrganizerAddEditScreen extends StatefulWidget {
  Organizer organizer;
  String task;

  OrganizerAddEditScreen({key, required this.organizer, required this.task})
      : super(key: key);

  @override
  _OrganizerAddEditScreenState createState() => _OrganizerAddEditScreenState();
}

class _OrganizerAddEditScreenState extends State<OrganizerAddEditScreen> {
  static const String _TAG = 'OrganizerAddEditScreen';

  String imagePath = '';

  List<User> mUsers = [];
  List<User> mFcmUsers = [];
  bool isUsersLoading = true;
  List<String> sUserNames = [];
  List<User> sUsers = [];
  List<String> sUserIds = [];

  @override
  void initState() {
    sUserIds = [widget.organizer.ownerId];
    FirestoreHelper.pullUsersApp().then((res) {
      if(res.docs.isNotEmpty){
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final User user = Fresh.freshUserMap(data, false);
          mUsers.add(user);

          if (sUserIds.contains(user.id)) {
            sUsers.add(user);
            sUserNames.add('${user.name} ${user.surname}');
          }
        }

        setState(() {
          isUsersLoading = false;
        });
      } else {
        Logx.est(_TAG, 'no app users, time to close up shop!');
        setState(() {
          isUsersLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: AppBarTitle(
        title: '${widget.task} organizer',
      ),
      titleSpacing: 0,
    ),
    body: _buildBody(context),
  );

  _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        ProfileWidget(
          imagePath: imagePath.isEmpty ? widget.organizer.imageUrl : imagePath,
          isEdit: true,
          onClicked: () async {
            final image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                imageQuality: 98,
                maxWidth: 480);
            if (image == null) return;

            final directory = await getApplicationDocumentsDirectory();
            final name = basename(image.path);
            final imageFile = File('${directory.path}/$name');
            final newImage = await File(image.path).copy(imageFile.path);

            String oldImageUrl = widget.organizer.imageUrl;

            if(oldImageUrl.isNotEmpty && oldImageUrl.contains('organizer_image')){
              FirestorageHelper.deleteFile(oldImageUrl);
            }

            String newImageUrl = await FirestorageHelper.uploadFile(
                FirestorageHelper.ORGANIZER_IMAGES,
                StringUtils.getRandomString(28),
                newImage);
            widget.organizer = widget.organizer.copyWith(imageUrl: newImageUrl);

            setState(() {
              imagePath = imageFile.path;
            });
          },
        ),

        const SizedBox(height: 24,),
        TextFieldWidget(
          label: 'name *',
          text: widget.organizer.name,
          onChanged: (text) => widget.organizer = widget.organizer.copyWith(name: text),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'phone number *',
          text: widget.organizer.phoneNumber.toString(),
          onChanged: (text) {
            int number = int.parse(text);
            widget.organizer = widget.organizer.copyWith(phoneNumber: number);
          },
        ),
        const SizedBox(height: 24),

        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'owner',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            MultiSelectDialogField(
              items: mUsers
                  .map((e) => MultiSelectItem(e,
                  '${e.name.toLowerCase()} ${e.surname.toLowerCase()}'))
                  .toList(),
              initialValue: sUsers.map((e) => e).toList(),
              listType: MultiSelectListType.CHIP,
              buttonIcon: Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade700,
              ),
              title: const Text('app members'),
              buttonText: const Text(
                'select',
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: Border.all(
                  width: 0.0,
                ),
              ),
              searchable: true,
              onConfirm: (values) {
                sUsers = values;
                sUserIds = [];
                sUserNames = [];

                for (User user in sUsers) {
                  sUserIds.add(user.id);
                  sUserNames.add(user.name);
                }

                if (sUserIds.isEmpty) {
                  Logx.i(_TAG, 'no users selected');
                  widget.organizer = widget.organizer.copyWith(ownerId: '');
                } else {
                  widget.organizer = widget.organizer.copyWith(ownerId : sUserIds.first);
                }
              },
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10, bottom: 5),
                  child: DelayedDisplay(
                    delay: const Duration(seconds: 1),
                    child: Text(
                      "* required",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),
        ButtonWidget(
          text: '💾 save',
          onClicked: () async {
            Organizer freshOrganizer = Fresh.freshOrganizer(widget.organizer);
            FirestoreHelper.pushOrganizer(freshOrganizer);
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 24),
        DarkButtonWidget(
          text: 'delete',
          onClicked: () {
            if(widget.organizer.imageUrl.isNotEmpty && widget.organizer.imageUrl.contains('organizer_image')){
              FirestorageHelper.deleteFile(widget.organizer.imageUrl);
            }
            FirestoreHelper.deleteOrganizer(widget.organizer.id);
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
