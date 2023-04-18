import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bloc.dart';
import '../../screens/bloc/bloc_menu_screen.dart';
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
        Logx.i(_TAG, "successfully pulled in bloc service for id " + widget.bloc.id);

        List<BlocService> blocServices = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final BlocService blocService = BlocService.fromMap(data);
          blocServices.add(blocService);
        }

        if(mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    List<String> imgList = [
      widget.bloc.imageUrl,
      'https://firebasestorage.googleapis.com/v0/b/bloc-novatech.appspot.com/o/bloc_service_image%2FUJIIia7TYiBwQ1lF3eO447zvM7gc.jpg?alt=media&token=fdda6b44-fae5-413f-b630-509bf7f3e0b6'
    ];


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
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width-10,
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: [
                          // Container(
                          //   height: 300,
                          //   width: MediaQuery.of(context).size.width,
                          //   decoration: BoxDecoration(
                          //     border: Border.all(
                          //         color: Theme.of(context).primaryColor),
                          //     borderRadius:
                          //         const BorderRadius.all(Radius.circular(10)),
                          //     image: DecorationImage(
                          //       image: NetworkImage(widget.bloc.imageUrl),
                          //       fit: BoxFit.fitWidth,
                          //     ),
                          //   ),
                          // ),

                          SizedBox(
                            height: 300,
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  initialPage: 0,
                                  enableInfiniteScroll: true,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 2),
                                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                ),
                                items: imgList
                                    .map((item) => Container(
                                  child: Center(
                                      child:
                                      Image.network(item, fit: BoxFit.fill, width:  MediaQuery.of(context).size.width)),
                                ))
                                    .toList(),
                              )),

                          Positioned(
                            bottom: 0.0,
                            right: 0.0,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 1.0, right: 5),
                              child: Text(
                                "click for menu",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 15, fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          )
                        ],
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

                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding:
                            EdgeInsets.only(top: 10, left: 15.0, right: 15.0),
                        child: Text(
                          widget.bloc.name,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).highlightColor,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding:
                            const EdgeInsets.only(top: 5, left: 15.0, right: 15.0),
                        child: Text(
                          "${widget.bloc.addressLine1.toLowerCase()}, ${widget.bloc.addressLine2.toLowerCase()}",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).highlightColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
