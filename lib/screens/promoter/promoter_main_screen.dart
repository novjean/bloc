import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/screens/promoter/promoter_details_screen.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/promoter.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/promoter_item.dart';
import '../../widgets/ui/app_bar_title.dart';
import '../../widgets/ui/sized_listview_block.dart';
import '../manager/promoters/promoter_add_edit_screen.dart';

class PromoterMainScreen extends StatefulWidget {
  static const String _TAG = 'PromoterMainScreen';

  const PromoterMainScreen({key}) : super(key: key);

  @override
  State<PromoterMainScreen> createState() => _PromoterMainScreenState();
}

class _PromoterMainScreenState extends State<PromoterMainScreen> {
  static const String _TAG = 'PromoterMainScreen';

  late List<String> mOptions;
  String sOption = '';

  List<Promoter> mPromoters = [];
  List<Promoter> mBrandPromoters = [];
  List<Promoter> mIndividualPromoters = [];

  var _isPromotersLoading = true;

  @override
  void initState() {
    mOptions = ['brand', 'individual'];
    sOption = mOptions.first;

    FirestoreHelper.pullPromoters().then((res) {
      if(res.docs.isNotEmpty){
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Promoter promoter = Fresh.freshPromoterMap(data, false);
          if(promoter.type == 'brand'){
            mBrandPromoters.add(promoter);
          } else {
            mIndividualPromoters.add(promoter);
          }
          mPromoters.add(promoter);
        }
        setState(() {
          _isPromotersLoading = false;
        });
      } else {
        setState(() {
          _isPromotersLoading = false;
        });
      }
    });

    super.initState();
  }

  switchPromoterOptions(BuildContext context) {
    if (sOption == 'brand') {
      return showPromoters(context);
    } else if (sOption == 'individual') {
      return showPromoters(context);
    } else {
      // unsupported
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AppBarTitle(title: 'promoter'),
          titleSpacing: 0,
        ),
        backgroundColor: Constants.background,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (ctx) => PromoterAddEditScreen(
                    promoter: Dummy.getDummyPromoter(),
                    task: 'add',
                  )),
            );
          },
          backgroundColor: Theme.of(context).primaryColor,
          tooltip: 'add promoter',
          elevation: 5,
          splashColor: Colors.grey,
          child: Icon(
            Icons.add,
            color: Theme.of(context).primaryColorDark,
            size: 29,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: _isPromotersLoading? const LoadingWidget(): _buildBody()
    );
  }

  _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          showPromoterOptions(context),
          const Divider(),
          showPromoters(context)
        ],
      ),
    );
  }

  showPromoters(BuildContext context) {
    List<Promoter> promoters=[];
    if(sOption == 'brand'){
      promoters = mBrandPromoters;
    } else {
      promoters = mIndividualPromoters;
    }
    return Expanded(
      child: ListView.builder(
        itemCount:  promoters.length,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (ctx, index) {
          Promoter promoter = promoters[index];

          return GestureDetector(
              child: PromoterItem(
                  promoter: promoter,
                  key: ValueKey(promoter.id)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (ctx) => PromoterDetailsScreen(
                        promoter: promoter,
                      )),
                );
              });
        }),);
  }

  showPromoterOptions(BuildContext context) {
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
                    Logx.i(_TAG, '$sOption at box office is selected');
                  });
                });
          }),
    );
  }


}
