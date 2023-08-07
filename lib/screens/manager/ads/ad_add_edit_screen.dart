import 'package:bloc/helpers/fresh.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/ad.dart';
import '../../../helpers/firestore_helper.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('ad | ${widget.task}'),
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
          label: 'title \*',
          text: widget.ad.title,
          onChanged: (title) => widget.ad = widget.ad.copyWith(title: title),
        ),
        const SizedBox(height: 24),
        // ios default 140
        // ios extended 260
        // android default 80
        TextFieldWidget(
          label: 'message \*',
          text: widget.ad.message,
          maxLines: 5,
          maxLength: 260,
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
          onClicked: () {
            Ad freshAd = Fresh.freshAd(widget.ad);
            FirestoreHelper.pushAd(freshAd);

            Navigator.of(context).pop();
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
