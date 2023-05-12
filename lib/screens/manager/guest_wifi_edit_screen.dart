import 'package:bloc/db/entity/guest_wifi.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../widgets/ui/textfield_widget.dart';

class GuestWifiEditScreen extends StatefulWidget {
  String blocServiceId;
  String task;

  GuestWifiEditScreen({key, required this.blocServiceId, required this.task})
      : super(key: key);

  @override
  _GuestWifiEditScreenState createState() => _GuestWifiEditScreenState();
}

class _GuestWifiEditScreenState extends State<GuestWifiEditScreen> {

  bool _isGuestWifiLoading = true;
  late GuestWifi wifi;

  @override
  void initState() {
    super.initState();

    wifi = Dummy.getDummyGuestWifi(widget.blocServiceId);

    FirestoreHelper.pullGuestWifi(widget.blocServiceId).then((res) {
      print("successfully pulled in guest wifi ");

      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        final GuestWifi _wifi = GuestWifi.fromMap(data);

        setState(() {
          wifi = _wifi;
          _isGuestWifiLoading = false;
        });
      } else {
        print('no wifis found!');
        setState(() {
          _isGuestWifiLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('guest wifi | ' + widget.task),
    ),
    body: _buildBody(context),
  );

  _buildBody(BuildContext context) {
    return _isGuestWifiLoading
        ? const LoadingWidget()
        : ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [

        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'name',
          text: wifi.name,
          onChanged: (name) =>
          wifi = wifi.copyWith(name: name),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'password',
          text: wifi.password,
          onChanged: (password) =>
          wifi = wifi.copyWith(password: password),
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'save',
          onClicked: () {
            wifi.creationTime = Timestamp.now().millisecondsSinceEpoch;
            FirestoreHelper.pushGuestWifi(wifi);
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 24),

      ],
    );
  }
}
