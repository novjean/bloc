import 'package:bloc/db/entity/party_tix.dart';
import 'package:bloc/helpers/fresh.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:flutter/material.dart';

import '../../../helpers/firestore_helper.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/dark_button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class PartyTixTierAddEditScreen extends StatefulWidget {
  PartyTixTier tixTier;
  String task;

  PartyTixTierAddEditScreen({key, required this.tixTier, required this.task})
      : super(key: key);

  @override
  _PartyTixTierAddEditScreenState createState() => _PartyTixTierAddEditScreenState();
}

class _PartyTixTierAddEditScreenState extends State<PartyTixTierAddEditScreen> {
  static const String _TAG = 'PartyTixTierAddEditScreen';
  bool testMode = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: AppBarTitle(
        title: '${widget.task} tix tier',
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
        TextFieldWidget(
          label: 'level *',
          text: widget.tixTier.tierLevel.toString(),
          maxLines: 1,
          onChanged: (value) {
            int? num = int.tryParse(value);
            widget.tixTier =
                widget.tixTier.copyWith(tierLevel: num);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'name *',
          text: widget.tixTier.tierName,
          onChanged: (text) => widget.tixTier = widget.tixTier.copyWith(tierName: text),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'price *',
          text: widget.tixTier.tierPrice.toString(),
          maxLines: 1,
          onChanged: (value) {
            double? num = double.tryParse(value);
            widget.tixTier =
                widget.tixTier.copyWith(tierPrice: num);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'sold count',
          text: widget.tixTier.soldCount.toString(),
          maxLines: 1,
          onChanged: (value) {
            int? num = int.tryParse(value);
            widget.tixTier =
                widget.tixTier.copyWith(soldCount: num);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'total tix',
          text: widget.tixTier.totalTix.toString(),
          maxLines: 1,
          onChanged: (value) {
            int? num = int.tryParse(value);
            widget.tixTier =
                widget.tixTier.copyWith(totalTix: num);
          },
        ),

        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            const Text(
              'sold out : ',
              style: TextStyle(fontSize: 17.0),
            ), //Text
            const SizedBox(width: 10), //SizedBox
            Checkbox(
              value: widget.tixTier.isSoldOut,
              onChanged: (value) {
                setState(() {
                  widget.tixTier = widget.tixTier.copyWith(isSoldOut: value);
                });
              },
            ), //Checkbox
          ], //<Widget>[]
        ),

        const SizedBox(height: 24),
        ButtonWidget(
          text: '💾 save',
          onClicked: () async {
            PartyTixTier freshTixTier = Fresh.freshPartyTixTier(widget.tixTier);

            FirestoreHelper.pushPartyTixTier(freshTixTier);
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 24),
        DarkButtonWidget(
          text: 'delete',
          onClicked: () {
            FirestoreHelper.deletePartyTixTier(widget.tixTier.id);
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
