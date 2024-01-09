import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bloc.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../screens/user/reservation_add_edit_screen.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../ui/icon_button_widget.dart';

class BlocSlideItem extends StatefulWidget {
  final Bloc bloc;

  int addCount = 1;

  BlocSlideItem({Key? key, required this.bloc}) : super(key: key);

  @override
  State<BlocSlideItem> createState() => _BlocSlideItemState();
}

class _BlocSlideItemState extends State<BlocSlideItem> {
  static const String _TAG = 'BlocSlideItem';

  late BlocService mBlocService;
  var _isBlocServiceLoading = true;

  @override
  void initState() {
    super.initState();
    FirestoreHelper.pullBlocServiceByBlocId(widget.bloc.id).then((res) {
      if (res.docs.isNotEmpty) {
        List<BlocService> blocServices = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final BlocService blocService = Fresh.freshBlocServiceMap(data, false);
          blocServices.add(blocService);
        }
        setState(() {
          mBlocService = blocServices.first;
          if(UserPreferences.getUserBlocs().contains(mBlocService.id)){
            _isBlocServiceLoading = false;
          } else {
            // true will result in not showing
            _isBlocServiceLoading = true;
          }
        });
      } else {
        Logx.em(_TAG, 'no bloc service found for bloc id ${widget.bloc.id}');
        setState(() {
          _isBlocServiceLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
            tag: widget.bloc.id,
            child: Card(
              elevation: 3,
              color: Constants.background,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: SizedBox(
                width: mq.width * 0.99,
                child: _isBlocServiceLoading ?
                Center(child: Text(widget.bloc.name, textAlign: TextAlign.center, style: TextStyle(color: Constants.primary),),):
                Stack(
                  fit: StackFit.passthrough,
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 4),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 750),
                        enlargeCenterPage: false,
                        scrollDirection: Axis.vertical,
                        // aspectRatio: 1.0,
                      ),
                      items: widget.bloc.imageUrls
                          .map((item) => kIsWeb? Image.network(item,
                              fit: BoxFit.cover,
                              width: mq.width) :
                      CachedNetworkImage(
                        imageUrl: item,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) =>
                            const FadeInImage(
                              placeholder: AssetImage('assets/images/logo.png'),
                              image: AssetImage('assets/images/logo.png'),
                              fit: BoxFit.cover,
                            ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      )
                      ).toList(),
                    ),
                    Positioned(
                        bottom: 0.0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SizedBox(
                            width: 250,
                            child: IconButtonWidget(
                              icon: Icons.table_restaurant_rounded,
                              text: 'reserve',
                              height: 60,
                              onClicked: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (ctx) => ReservationAddEditScreen(
                                          reservation: Dummy.getDummyReservation(
                                              mBlocService.id),
                                          task: 'add')),
                                );
                              },
                              fontSize: 24,
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            ),
          );
  }
}
