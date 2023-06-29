import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/dark_button_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bloc.dart';
import '../../main.dart';
import '../../screens/bloc/bloc_menu_screen.dart';
import '../../screens/user/celebration_add_edit_screen.dart';
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
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (ctx) => BlocMenuScreen(blocService: mBlocService)),
        );
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
                    fit: StackFit.expand,
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          initialPage: 0,
                          enableInfiniteScroll: true,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                          enlargeCenterPage: false,
                          scrollDirection: Axis.vertical,
                          // aspectRatio: 2.0,
                        ),
                        items: widget.bloc.imageUrls
                            .map((item) => Center(
                            child: Image.network(item,
                                fit: BoxFit.cover,
                                height: mq.height * 0.33,
                                width: mq.width)))
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
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (ctx) => BlocMenuScreen(
                                        blocService: mBlocService)),
                              );
                          },
                          fontSize: 24,
                        )
                      ),
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
                                    builder: (ctx) =>
                                        ReservationAddEditScreen(
                                            reservation:
                                                Dummy.getDummyReservation(
                                                    mBlocService.id),
                                            task: 'add')),
                              );
                            },
                            fontSize: 24,
                          )
                      )
                    ],
                  ),



                  // Column(
                  //   mainAxisSize: MainAxisSize.min,
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: <Widget>[
                  //     SizedBox(
                  //         // height: mq.height * 0.33,
                  //         width: mq.width,
                  //         child: CarouselSlider(
                  //           options: CarouselOptions(
                  //             initialPage: 0,
                  //             enableInfiniteScroll: true,
                  //             autoPlay: true,
                  //             autoPlayInterval: const Duration(seconds: 2),
                  //             autoPlayAnimationDuration:
                  //                 const Duration(milliseconds: 800),
                  //             enlargeCenterPage: false,
                  //             scrollDirection: Axis.vertical,
                  //             // aspectRatio: 2.0,
                  //           ),
                  //           items: widget.bloc.imageUrls
                  //               .map((item) => Center(
                  //                   child: Image.network(item,
                  //                       fit: BoxFit.cover,
                  //                       width: mq.width)))
                  //               .toList(),
                  //         ),
                  //     ),
                  //
                  //     // Flexible(
                  //     //   flex: 1,
                  //     //   child: Center(
                  //     //     child: Padding(
                  //     //       padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  //     //       child: Row(
                  //     //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     //         crossAxisAlignment: CrossAxisAlignment.center,
                  //     //         children: [
                  //     //           SizedBox(
                  //     //             height: 50,
                  //     //             child: ElevatedButton.icon(
                  //     //               onPressed: () {
                  //     //                 Navigator.of(context).push(
                  //     //                   MaterialPageRoute(
                  //     //                       builder: (ctx) =>
                  //     //                           CelebrationAddEditScreen(
                  //     //                               celebration:
                  //     //                               Dummy.getDummyCelebration(
                  //     //                                   mBlocService.id),
                  //     //                               task: 'add')),
                  //     //                 );
                  //     //               },
                  //     //               icon: const Icon(
                  //     //                 Icons.groups_outlined,
                  //     //                 size: 24.0,
                  //     //               ),
                  //     //               label: const Text('celebrate'), // <-- Text
                  //     //             ),
                  //     //           ),
                  //     //           SizedBox(
                  //     //             height: 50,
                  //     //             child: ElevatedButton.icon(
                  //     //               onPressed: () {
                  //     //                 Navigator.of(context).push(
                  //     //                   MaterialPageRoute(
                  //     //                       builder: (ctx) => BlocMenuScreen(
                  //     //                           blocService: mBlocService)),
                  //     //                 );
                  //     //               },
                  //     //               icon: const Icon(
                  //     //                 Icons.menu_book,
                  //     //                 size: 24.0,
                  //     //               ),
                  //     //               label: const Text('menu'), // <-- Text
                  //     //             ),
                  //     //           ),
                  //     //           Padding(
                  //     //             padding: const EdgeInsets.only(left: 10.0),
                  //     //             child: SizedBox(
                  //     //               height: 50,
                  //     //               child: ElevatedButton.icon(
                  //     //                 onPressed: () {
                  //     //                   Navigator.of(context).push(
                  //     //                     MaterialPageRoute(
                  //     //                         builder: (ctx) =>
                  //     //                             ReservationAddEditScreen(
                  //     //                                 reservation:
                  //     //                                     Dummy.getDummyReservation(
                  //     //                                         mBlocService.id),
                  //     //                                 task: 'add')),
                  //     //                   );
                  //     //                 },
                  //     //                 icon: const Icon(
                  //     //                   Icons.table_restaurant,
                  //     //                   size: 24.0,
                  //     //                 ),
                  //     //                 label: const Text('reserve'), // <-- Text
                  //     //               ),
                  //     //             ),
                  //     //           ),
                  //     //         ],
                  //     //       ),
                  //     //     ),
                  //     //   ),
                  //     // ),
                  //
                  //   ],
                  // ),
                ),
              ),
            ),
    );
  }

  showMenuButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.background,
          foregroundColor: Constants.primary,
          shadowColor: Colors.white10,
          elevation: 3,
          minimumSize: const Size.fromHeight(60),
        ),
        onPressed: () {

        },
        icon: const Icon(
          Icons.app_registration,
          size: 24.0,
        ),
        label: const Text(
          'guest list',
          style: TextStyle(fontSize: 20, color: Constants.primary),
        ),
      ),
    );
  }

  showReserveButton(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.background,
            foregroundColor: Constants.primary,
            shadowColor: Colors.white10,
            elevation: 3,
            minimumSize: const Size.fromHeight(60),
          ),
          onPressed: () {

          },
          icon: const Icon(
            Icons.app_registration,
            size: 24.0,
          ),
          label: const Text(
            'reserve',
            style: TextStyle(fontSize: 20, color: Constants.primary),
          ),
        ),
      ),
    );

  }
}
