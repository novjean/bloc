import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/lounge.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../widgets/profile_widget.dart';
import '../../widgets/ui/loading_widget.dart';

class LoungeDetailScreen extends StatefulWidget {
  String loungeId;

  LoungeDetailScreen({Key? key, required this.loungeId}) : super(key: key);

  @override
  State<LoungeDetailScreen> createState() => _LoungeDetailScreenState();
}

class _LoungeDetailScreenState extends State<LoungeDetailScreen> {
  static const String _TAG = 'LoungeDetailScreen';

  Lounge mLounge = Dummy.getDummyLounge();
  var isLoungeLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullLounge(widget.loungeId).then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          mLounge = Fresh.freshLoungeMap(data, false);
        }
        setState(() {
          isLoungeLoading = false;
        });
      } else {
        setState(() {
          isLoungeLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mLounge.name),
      ),
      backgroundColor: Constants.background,
      body: isLoungeLoading ? const LoadingWidget() : _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 75.0,
                backgroundImage: NetworkImage(mLounge.imageUrl),
              ),
              // ProfileWidget(
              //   imagePath: mLounge.imageUrl,
              //   onClicked: () async {},
              // ),
            ],
          ),
        ),

        // const SizedBox(height: 24),
        // NumbersWidget(),
        const Divider(color: Constants.darkPrimary),

      ],
    );
  }
}
