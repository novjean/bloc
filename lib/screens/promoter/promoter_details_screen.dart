import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/promoter.dart';
import '../../db/entity/promoter_guest.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../widgets/promoter_guest_item.dart';
import '../../widgets/ui/app_bar_title.dart';
import '../../widgets/ui/sized_listview_block.dart';

class PromoterDetailsScreen extends StatefulWidget{
  Promoter promoter;

  PromoterDetailsScreen({Key? key, required this.promoter}) : super(key: key);

  @override
  State<PromoterDetailsScreen> createState() => _PromoterDetailsScreenState();
}

class _PromoterDetailsScreenState extends State<PromoterDetailsScreen> {
  static const String _TAG = 'PromoterDetailsScreen';

  late List<String> mOptions;
  String sOption = '';

  List<PromoterGuest> mPromoterGuests = [];
  var _isGuestsLoading = true;

  @override
  void initState() {
    mOptions = ['date', 'name'];
    sOption = mOptions.first;

    FirestoreHelper.pullPromoterGuests(widget.promoter.id).then((res) {
      if(res.docs.isNotEmpty){
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final PromoterGuest pg = Fresh.freshPromoterGuestMap(data, false);
          mPromoterGuests.add(pg);
        }
        setState(() {
          _isGuestsLoading = false;
        });
      } else {
        setState(() {
          _isGuestsLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AppBarTitle(title: widget.promoter.name),
          titleSpacing: 0,
        ),
        backgroundColor: Constants.background,
        body: _isGuestsLoading? const LoadingWidget(): _buildBody()
    );
  }

  _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          showOptions(context),
          const Divider(),
          switchOptions(context),
        ],
      ),
    );
  }

  showOptions(BuildContext context) {
    double containerHeight = mq.height / 20;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: MediaQuery.of(context).size.height / 15,
      child: ListView.builder(
          itemCount: mOptions.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: mOptions[index],
                  height: containerHeight,
                  width: MediaQuery.of(context).size.width / 3,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  setState(() {
                    sOption = mOptions[index];
                  });
                });
          }),
    );
  }

  showGuests(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          itemCount:  mPromoterGuests.length,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            PromoterGuest pg = mPromoterGuests[index];

            return GestureDetector(
                child: PromoterGuestItem(
                    promoterGuest: pg,
                    key: ValueKey(pg.id)),
                onTap: () {
                });
          }),);
  }

  switchOptions(BuildContext context) {
    if (sOption == mOptions[0]) {
      mPromoterGuests.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return showGuests(context);

    } else if (sOption == mOptions[1]) {
      mPromoterGuests.sort((a, b) => a.name.compareTo(b.name));
      return showGuests(context);
    } else {
      // unsupported
    }
  }

}