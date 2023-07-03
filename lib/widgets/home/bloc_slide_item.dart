import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/bloc.dart';
import '../../main.dart';
import '../../routes/route_constants.dart';
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
    FirestoreHelper.pullBlocService(widget.bloc.id).then((res) {
      if (res.docs.isNotEmpty) {
        Logx.i(_TAG,
            "successfully pulled in bloc service for id ${widget.bloc.id}");

        List<BlocService> blocServices = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final BlocService blocService = BlocService.fromMap(data);
          blocServices.add(blocService);
        }

        if (mounted) {
          setState(() {
            mBlocService = blocServices.first;
            _isBlocServiceLoading = false;
          });
        } else {
          Logx.em(_TAG, 'state is not mounted');
        }
      } else {
        Logx.em(_TAG, 'no bloc service found for id ${widget.bloc.id}');
        setState(() {
          _isBlocServiceLoading = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).pushNamed(RouteConstants.menuRouteName, params: {
          'id': mBlocService.blocId,
        });
      },
      child: _isBlocServiceLoading
          ? const SizedBox()
          : Hero(
              tag: widget.bloc.id,
              child: Card(
                elevation: 3,
                color: Constants.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: SizedBox(
                  width: mq.width * 0.99,
                  child: Stack(
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
                            .map((item) => Image.network(item,
                                fit: BoxFit.cover,
                                width: mq.width))
                            .toList(),
                      ),
                      Positioned(
                          bottom: 0.0,
                          left: 20,
                          child: IconButtonWidget(
                            icon: Icons.restaurant_menu_sharp,
                            text: 'menu',
                            height: 60,
                            onClicked: () {
                              GoRouter.of(context).pushNamed(
                                  RouteConstants.menuRouteName,
                                  params: {
                                    'id': mBlocService.blocId,
                                  });
                            },
                            fontSize: 24,
                          )),
                      Positioned(
                          bottom: 0.0,
                          right: 20,
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
                          ))
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
