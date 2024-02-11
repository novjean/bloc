
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../utils/logx.dart';

class TixConfirmationScreen extends StatefulWidget {
  String tixId;

  TixConfirmationScreen({required this.tixId});

  @override
  _TixConfirmationScreenState createState() => _TixConfirmationScreenState();
}

class _TixConfirmationScreenState extends State<TixConfirmationScreen> {
  static const String _TAG = 'TixConfirmationScreen';

  @override
  void initState() {
    Logx.d(_TAG, 'initState');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
              backgroundColor: Constants.background,
              title: AppBarTitle(title: 'confirmation'),
              titleSpacing: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary,),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
          ),
          body: const LoadingWidget()
      ),
    );
  }
}