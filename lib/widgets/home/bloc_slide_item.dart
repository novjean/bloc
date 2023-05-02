import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bloc.dart';
import '../../screens/bloc/bloc_menu_screen.dart';
import '../../screens/user/reservation_add_edit_screen.dart';
import '../../utils/logx.dart';

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
            "successfully pulled in bloc service for id " + widget.bloc.id);

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
        Logx.em(_TAG, 'no bloc service found for id ' + widget.bloc.id);
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
                elevation: 1,
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0)),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        flex: 4,
                        child: SizedBox(
                            height: 400,
                            child: CarouselSlider(
                              options: CarouselOptions(
                                initialPage: 0,
                                enableInfiniteScroll: true,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 2),
                                autoPlayAnimationDuration:
                                    const Duration(milliseconds: 800),
                                enlargeCenterPage: true,
                                scrollDirection: Axis.horizontal,
                                // aspectRatio: 2.0,
                              ),
                              items: widget.bloc.imageUrls
                                  .map((item) => Container(
                                        child: Center(
                                            child: Image.network(item,
                                                fit: BoxFit.fitWidth,
                                                height: 400,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width)),
                                      ))
                                  .toList(),
                            )),
                      ),

                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (ctx) => BlocMenuScreen(
                                                blocService: mBlocService)),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.menu_book,
                                      size: 24.0,
                                    ),
                                    label: const Text('menu'), // <-- Text
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () {
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
                                  icon: const Icon(
                                    Icons.table_restaurant,
                                    size: 24.0,
                                  ),
                                  label: const Text('reserve'), // <-- Text
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // CachedNetworkImage(
                      //   imageUrl: widget.bloc.imageUrl,
                      //   imageBuilder: (context, imageProvider) => Container(
                      //     decoration: BoxDecoration(
                      //       image: DecorationImage(
                      //           image: imageProvider,
                      //           fit: BoxFit.fitWidth,
                      //           colorFilter:
                      //           ColorFilter.mode(Colors.red, BlendMode.colorBurn)),
                      //     ),
                      //   ),
                      //   placeholder: (context, url) => CircularProgressIndicator(),
                      //   errorWidget: (context, url, error) {
                      //     print(error.toString());
                      //     return Icon(Icons.error);},
                      // ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
