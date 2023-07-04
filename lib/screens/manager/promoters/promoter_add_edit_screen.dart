import 'dart:io';

import 'package:bloc/db/entity/ad_campaign.dart';
import 'package:bloc/helpers/fresh.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../../../db/entity/promoter.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class PromoterAddEditScreen extends StatefulWidget {
  Promoter promoter;
  String task;

  PromoterAddEditScreen({key, required this.promoter, required this.task})
      : super(key: key);

  @override
  _PromoterAddEditScreenState createState() => _PromoterAddEditScreenState();
}

class _PromoterAddEditScreenState extends State<PromoterAddEditScreen> {
  static const String _TAG = 'PromoterAddEditScreen';

  List<String> mTypes = ['brand', 'individual'];
  List<String> sTypes = ['brand'];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      titleSpacing: 0,
      title: AppBarTitle(title:'${widget.task} promoter'),
    ),
    body: _buildBody(context),
  );

  _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        TextFieldWidget(
          label: 'name *',
          text: widget.promoter.name,
          onChanged: (text) => widget.promoter = widget.promoter.copyWith(name: text),
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
                    'type *',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            MultiSelectDialogField(
              items: mTypes
                  .map((e) => MultiSelectItem(
                  e, e))
                  .toList(),
              initialValue: sTypes.map((e) => e).toList(),
              listType: MultiSelectListType.CHIP,
              buttonIcon: Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade700,
              ),
              title: const Text('pick a type'),
              buttonText: const Text(
                'select',
                style: TextStyle(color: Constants.darkPrimary),
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: Border.all(
                  // color: Constants.primary,
                  width: 0.0,
                ),
              ),
              searchable: true,
              onConfirm: (values) {
                sTypes = values as List<String>;
                widget.promoter.type = sTypes.first;
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'save',
          onClicked: () {
            Promoter freshPromoter = Fresh.freshPromoter(widget.promoter);
            FirestoreHelper.pushPromoter(freshPromoter);
            Logx.ist(_TAG, 'promoter is saved');
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'delete',
          onClicked: () {
            FirestoreHelper.deletePromoter(widget.promoter.id);

            Logx.ist(_TAG, 'promoter deleted');
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
