import 'package:bloc/helpers/fresh.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/ad.dart';
import '../../../db/entity/config.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class ConfigAddEditScreen extends StatefulWidget {
  Config config;
  String task;

  ConfigAddEditScreen({key, required this.config, required this.task})
      : super(key: key);

  @override
  _ConfigAddEditScreenState createState() => _ConfigAddEditScreenState();
}

class _ConfigAddEditScreenState extends State<ConfigAddEditScreen> {
  static const String _TAG = 'ConfigAddEditScreen';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('config | ${widget.task}'),
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
          label: 'title *',
          text: widget.config.name,
          onChanged: (text) => widget.config = widget.config.copyWith(name: text),
        ),
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            const Text(
              'value : ',
              style: TextStyle(fontSize: 17.0),
            ), //Text
            const SizedBox(width: 10), //SizedBox
            Checkbox(
              value: widget.config.value,
              onChanged: (value) {
                setState(() {
                  widget.config = widget.config.copyWith(value: value);
                });
              },
            ), //Checkbox
          ], //<Widget>[]
        ),

        const SizedBox(height: 24),
        ButtonWidget(
          text: 'save',
          onClicked: () {
            Config freshConfig = Fresh.freshConfig(widget.config);
            FirestoreHelper.pushConfig(freshConfig);

            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'delete',
          onClicked: () {
            FirestoreHelper.deleteConfig(widget.config.id);

            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
