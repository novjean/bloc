import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:bloc/widgets/ui/textfield_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import '../../../db/entity/lounge.dart';
import '../../../db/entity/user.dart' as blocUser;

import '../../../db/entity/user.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/dark_button_widget.dart';
import '../../../widgets/ui/toaster.dart';

class LoungeAddEditScreen extends StatefulWidget {
  Lounge lounge;
  String task;

  LoungeAddEditScreen(
      {Key? key, required this.lounge, required this.task})
      : super(key: key);

  @override
  State<LoungeAddEditScreen> createState() =>
      _LoungeAddEditScreenState();
}

class _LoungeAddEditScreenState extends State<LoungeAddEditScreen> {
  static const String _TAG = 'LoungeAddEditScreen';

  List<String> loungeTypes = ['artist', 'community'];
  late String sType;

  List<User> mUsers = [];
  var isUsersLoading = true;

  List<User> sAdmins = [];
  List<String> sAdminIds = [];
  List<String> sAdminNames = [];

  @override
  void initState() {
    sType = widget.lounge.type;

    sAdminIds = widget.lounge.admins;

    FirestoreHelper.pullUsersGreaterThanLevel(Constants.MANAGER_LEVEL).then((res) {
      if(res.docs.isNotEmpty){
        for(int i=0;i<res.docs.length; i++){
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final User user = Fresh.freshUserMap(data, false);
          mUsers.add(user);

          if(sAdminIds.contains(user.id)){
            sAdmins.add(user);
            sAdminNames.add('${user.name} ${user.surname}');
          }

          setState(() {
            isUsersLoading = false;
          });
        }
      } else {
        setState(() {
          isUsersLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('lounge | ${widget.task}')),
      body: isUsersLoading? const LoadingWidget(): _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        TextFieldWidget(
            label: 'name \*',
            text: widget.lounge.name,
            onChanged: (name) {
              widget.lounge = widget.lounge.copyWith(name: name);
            }),
        const SizedBox(height: 24),

        Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'type *',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            FormField<String>(
              builder: (FormFieldState<String> state) {
                return InputDecorator(
                  key: const ValueKey('lounge_type'),
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      errorStyle: TextStyle(
                          color: Theme.of(context).errorColor, fontSize: 16.0),
                      hintText: 'please select lounge type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        // width: 0.0 produces a thin "hairline" border
                        borderSide: BorderSide(width: 0.0),
                      )),
                  isEmpty: sType == '',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: sType,
                      isDense: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          sType = newValue!;
                          widget.lounge =
                              widget.lounge.copyWith(type: sType);
                          state.didChange(newValue);
                        });
                      },
                      items: loungeTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
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
                    'admins *',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            MultiSelectDialogField(
              items: mUsers
                  .map((e) => MultiSelectItem(e,
                  '${e.name.toLowerCase()} ${e.surname.toLowerCase()}'))
                  .toList(),
              initialValue: sAdmins.map((e) => e).toList(),
              listType: MultiSelectListType.CHIP,
              buttonIcon: Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade700,
              ),
              title: const Text('select admins'),
              buttonText: const Text(
                'select',
                style: TextStyle(color: Constants.darkPrimary),
              ),
              decoration: BoxDecoration(
                // color: Constants.background,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: Border.all(
                  // color: Constants.primary,
                  width: 0.0,
                ),
              ),
              searchable: true,
              onConfirm: (values) {
                sAdmins = values as List<User>;
                sAdminIds = [];
                sAdminNames = [];

                for (User user in sAdmins) {
                  sAdminIds.add(user.id);
                  sAdminNames.add('${user.name} ${user.surname}');
                }

                if (sAdminIds.isEmpty) {
                  Logx.i(_TAG, 'no admins selected');
                  widget.lounge =
                      widget.lounge.copyWith(admins: []);
                } else {
                  widget.lounge =
                      widget.lounge.copyWith(admins: sAdminIds);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ButtonWidget(
              height: 50,
              text: 'save',
              onClicked: () {
                Lounge freshLounge = Fresh.freshLounge(widget.lounge);
                FirestoreHelper.pushLounge(freshLounge);

                Toaster.shortToast('lounge saved');
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 36),
            DarkButtonWidget(
                height: 50,
                text: 'delete',
                onClicked: () {
                  FirestoreHelper.deleteLounge(widget.lounge.id);
                  Toaster.shortToast('lounge deleted');
                  Navigator.of(context).pop();
                }),
          ],
        ),
        const SizedBox(height: 48),
      ],
    );
  }


}
