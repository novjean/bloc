
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/advert.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/advert/advert_banner.dart';
import '../../widgets/footer.dart';
import '../../widgets/ui/app_bar_title.dart';
import 'advert_add_edit_screen.dart';

class AdvertScreen extends StatefulWidget {
  @override
  State<AdvertScreen> createState() => _AdvertScreenState();
}

class _AdvertScreenState extends State<AdvertScreen> {
  static const String _TAG = 'AdvertScreen';

  List<Advert> mAdverts = [];

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title: 'advertisements'),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Constants.lightPrimary),
          onPressed: () {
            GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>
                    AdvertAddEditScreen(
                      advert: Dummy.getDummyAdvert(),
                      task: 'add',
                    )),
          );
        },
        backgroundColor: Constants.primary,
        tooltip: 'new advertisement',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.ads_click,
          color: Constants.darkPrimary,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      backgroundColor: Constants.background,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        const SizedBox(
          height: 15,
        ),
        _loadAdverts(context),
        Footer(
          showAll: false,
        )
      ],
    );
  }

  _loadAdverts(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getAdvertsByUser(UserPreferences.myUser.id),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:
            {
              Logx.d(_TAG, 'load adverts user is done');

              try {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isNotEmpty) {
                    mAdverts.clear();

                    for (int i = 0; i < snapshot.data!.docs.length; i++) {
                      DocumentSnapshot document = snapshot.data!.docs[i];
                      Map<String, dynamic> map =
                      document.data()! as Map<String, dynamic>;
                      final Advert advert = Fresh.freshAdvertMap(map, false);
                      mAdverts.add(advert);
                    }
                  }
                }

                if (mAdverts.isNotEmpty) {
                  return _displayAdverts(context);
                } else {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'you have no advertisements yet!',
                            style: TextStyle(color: Constants.primary),
                          ),
                          const SizedBox(height: 10,),
                          ButtonWidget(text: 'create ad', onClicked: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AdvertAddEditScreen(
                                        advert: Dummy.getDummyAdvert(),
                                        task: 'add',
                                      )),
                            );
                          },)
                        ],
                      ),
                    ),
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: [
                    //
                    //     const SizedBox(height: 36,),
                    //     ButtonWidget(
                    //       text: 'add event',
                    //       onClicked: () {
                    //       Logx.ist(_TAG, 'adding your event');
                    //     },)
                    // ]
                    // ),
                  );
                }
              } catch (e) {
                return const Center(
                  child: Text('no hosted events found!'),
                );
              }
            }
        }
      },
    );
  }

  _displayAdverts(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        key: UniqueKey(),
        itemCount: mAdverts.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          Advert advert = mAdverts[index];

          return AdvertBanner(
            advert: advert,
          );
        },
      ),
    );
  }
}
