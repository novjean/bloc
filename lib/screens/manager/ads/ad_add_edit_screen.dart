import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bloc/helpers/fresh.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import '../../../db/entity/ad.dart';
import '../../../db/entity/party.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../services/notification_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class AdAddEditScreen extends StatefulWidget {
  Ad ad;
  String task;

  AdAddEditScreen({key, required this.ad, required this.task})
      : super(key: key);

  @override
  _AdAddEditScreenState createState() => _AdAddEditScreenState();
}

class _AdAddEditScreenState extends State<AdAddEditScreen> {
  static const String _TAG = 'AdAddEditScreen';

  List<Party> mParties = [];
  List<Party> sParties = [];
  var _isPartiesLoading = true;

  bool testMode = false;

  @override
  void initState() {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;
    FirestoreHelper.pullPartiesByEndTime(timeNow, true).then((res) {
      if (res.docs.isNotEmpty) {
        List<Party> parties = [];

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, false);
          mParties.add(party);

          setState(() {
            mParties = parties;
            _isPartiesLoading = false;
          });
        }
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
          title: AppBarTitle(title: '${widget.task} ad',),
          titleSpacing: 0,
        ),
        body: _isPartiesLoading ? const LoadingWidget(): _buildBody(context),
      );

  _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        TextFieldWidget(
          label: 'title *',
          text: widget.ad.title,
          onChanged: (title) => widget.ad = widget.ad.copyWith(title: title),
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
                    'party image',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            MultiSelectDialogField(
              items: mParties
                  .map((e) => MultiSelectItem(
                  e, '${e.name} ${e.chapter}'))
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

                setState(() {
                  widget.ad = widget.ad.copyWith(imageUrl: sParties.first.imageUrl);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        // ios default 140
        // ios extended 260
        // android default 80
        TextFieldWidget(
          label: 'message *',
          text: widget.ad.message,
          maxLines: 6,
          onChanged: (message) =>
              widget.ad = widget.ad.copyWith(message: message),
        ),
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            const Text(
              'active : ',
              style: TextStyle(fontSize: 17.0),
            ), //Text
            const SizedBox(width: 10), //SizedBox
            Checkbox(
              value: widget.ad.isActive,
              onChanged: (value) {
                setState(() {
                  widget.ad = widget.ad.copyWith(isActive: value);
                });
              },
            ), //Checkbox
          ], //<Widget>[]
        ),

        const SizedBox(height: 24),
        ButtonWidget(
          text: 'save',
          onClicked: () async {
            Ad freshAd = Fresh.freshAd(widget.ad);

            if(!testMode){
              FirestoreHelper.pushAd(freshAd);
              Navigator.of(context).pop();
            } else {
              if(widget.ad.imageUrl.isEmpty){
                await NotificationService.showNotification(
                    title: widget.ad.title,
                    body: widget.ad.message,
                    actionButtons: [
                      // NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
                      // NotificationActionButton(
                      //     key: 'REPLY',
                      //     label: 'Reply Message',
                      //     requireInputText: true,
                      //     actionType: ActionType.SilentAction
                      // ),
                      NotificationActionButton(
                          key: 'DISMISS',
                          label: 'Dismiss',
                          actionType: ActionType.DismissAction,
                          isDangerousOption: true)
                    ]
                );
              } else {
                await NotificationService.showNotification(
                    title: widget.ad.title,
                    body: widget.ad.message,
                    bigPicture: widget.ad.imageUrl,
                    notificationLayout: NotificationLayout.BigPicture,
                    actionButtons: [
                      NotificationActionButton(
                          key: 'DISMISS',
                          label: 'Dismiss',
                          actionType: ActionType.DismissAction,
                          isDangerousOption: true)
                    ]
                );
              }
            }

          },
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'delete',
          onClicked: () {
            FirestoreHelper.deleteAd(widget.ad.id);

            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
