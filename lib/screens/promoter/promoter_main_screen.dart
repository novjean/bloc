import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/promoter.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/promoter_item.dart';
import '../../widgets/ui/app_bar_title.dart';

class PromoterMainScreen extends StatelessWidget {
  static const String _TAG = 'PromoterMainScreen';

  const PromoterMainScreen({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AppBarTitle(title: 'promoter'),
          titleSpacing: 0,
        ),
        backgroundColor: Constants.background,
        body: StreamBuilder<QuerySnapshot>(
            stream: FirestoreHelper.getPromoters(),
            builder: (ctx, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const LoadingWidget();
                case ConnectionState.active:
                case ConnectionState.done:
                  {
                    List<Promoter> promoters = [];

                    try {
                      for (int i = 0; i < snapshot.data!.docs.length; i++) {
                        DocumentSnapshot document = snapshot.data!.docs[i];
                        Map<String, dynamic> map =
                            document.data()! as Map<String, dynamic>;
                        final Promoter promoter =
                            Fresh.freshPromoterMap(map, false);
                        promoters.add(promoter);
                      }
                      return ListView.builder(
                          itemCount: promoters.length,
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemBuilder: (ctx, index) {
                            Promoter promoter = promoters[index];

                            return GestureDetector(
                                child: PromoterItem(
                                    promoter: promoter,
                                    key: ValueKey(promoter.id)),
                                onTap: () {
                                  // if(UserPreferences.isUserLoggedIn()){
                                  //   GoRouter.of(context).pushNamed(
                                  //       RouteConstants.loungeRouteName,
                                  //       params: {
                                  //         'id': lounge.id,
                                  //       });
                                  // } else {
                                  //   if(!kIsWeb){
                                  //     Toaster.shortToast('please log in to access community');
                                  //   } else {
                                  //     Toaster.shortToast('log in to the bloc app to access community');
                                  //   }
                                  // }
                                });
                          });
                    } on Exception catch (e, s) {
                      Logx.e(_TAG, e, s);
                    } catch (e) {
                      Logx.em(_TAG, 'error loading promoters : $e');
                    }
                  }
              }
              return const LoadingWidget();
            }));
  }
}
