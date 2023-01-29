import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../db/entity/bloc.dart';
import '../../screens/bloc/bloc_menu_screen.dart';

class NewBlocSlideItem extends StatefulWidget {
  final Bloc bloc;

  int addCount = 1;

  NewBlocSlideItem({required this.bloc});

  @override
  State<NewBlocSlideItem> createState() => _NewBlocSlideItemState();
}

class _NewBlocSlideItemState extends State<NewBlocSlideItem> {
  late BlocService mBlocService;

  var _isBlocServiceLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullBlocService(widget.bloc.id).then((res) {
      print("Successfully retrieved bloc services...");

      if (res.docs.isNotEmpty) {
        List<BlocService> blocServices = [];

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final BlocService blocService = BlocService.fromMap(data);
          blocServices.add(blocService);
        }

        setState(() {
          mBlocService = blocServices.first;
          _isBlocServiceLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var logger = Logger();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (ctx) =>
                  BlocMenuScreen(blocService: mBlocService)),
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
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          image: DecorationImage(
                            image: NetworkImage(widget.bloc.imageUrl),
                            fit: BoxFit.fitWidth,
                            // AssetImage(food['image']),
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

                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding:
                            EdgeInsets.only(top: 10, left: 15.0, right: 15.0),
                        child: Text(
                          "${widget.bloc.name}",
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).highlightColor,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      // Container(
                      //   width: MediaQuery.of(context).size.width,
                      //   padding: EdgeInsets.only(
                      //       top: 0, left: 15.0, right: 15.0, bottom: 5),
                      //   child: Text(
                      //     "${widget.bloc.addressLine1}, ${widget.bloc.addressLine2}",
                      //     style: TextStyle(
                      //       fontSize: 16.0,
                      //       fontWeight: FontWeight.w500,
                      //       color: Theme.of(context).highlightColor,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}