import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bloc.dart';
import '../../db/entity/bloc_service.dart';
import '../../helpers/firestore_helper.dart';
import '../../screens/bloc/bloc_menu_screen.dart';

class BlocSlideItem extends StatefulWidget {
  final Bloc bloc;
  final String rating;

  BlocSlideItem({
    Key? key,
    required this.bloc,
    required this.rating,
  }) : super(key: key);

  @override
  _BlocSlideItemState createState() => _BlocSlideItemState();
}

class _BlocSlideItemState extends State<BlocSlideItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: MediaQuery.of(context).size.width,
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 3.0,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                    child: GridTile(
                      child: GestureDetector(
                        onTap: () {
                          FirestoreHelper.pullBlocService(widget.bloc.id)
                              .then((res) {
                            print(
                                "Successfully retrieved bloc services of bloc " +
                                    widget.bloc.name);

                            if (res.docs.isEmpty) {
                              print(
                                  'No bloc services is present here, should not be displaying this');
                            } else {
                              if (res.docs.length == 1) {
                                DocumentSnapshot document = res.docs[0];
                                Map<String, dynamic> data =
                                    document.data()! as Map<String, dynamic>;
                                final BlocService blocService =
                                    BlocService.fromMap(data);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (ctx) => BlocMenuScreen(
                                          blocService: blocService)),
                                );
                              } else {
                                print(
                                    'not allowing this operation for now, futre implementation maybe.');
                                // for (int i = 0; i < res.docs.length; i++){
                                //   DocumentSnapshot document = res.docs[i];
                                //   Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                //   final BlocService blocService = BlocService.fromMap(data);
                                //   Navigator.of(context).push(
                                //     MaterialPageRoute(
                                //         builder: (ctx) => BlocServiceDetailScreen(dao: widget.dao, blocService: blocService)),
                                //   );
                                // }
                              }
                            }
                          });
                        },
                        child: Hero(
                          // hero should be wired in with where we are animating to
                          tag: widget.bloc.id,
                          child: FadeInImage(
                            placeholderFit: BoxFit.cover,
                            placeholder: AssetImage(
                                'assets/images/product-placeholder.png'),
                            image: widget.bloc.imageUrl != "url"
                                ? NetworkImage(widget.bloc.imageUrl)
                                : NetworkImage(
                                    "assets/images/product-placeholder.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Positioned(
                //   top: 6.0,
                //   right: 6.0,
                //   child: Card(
                //     shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(4.0)),
                //     child: Padding(
                //       padding: EdgeInsets.all(2.0),
                //       child: Row(
                //         children: <Widget>[
                //           Icon(
                //             Icons.star,
                //             color: Constants.ratingBG,
                //             size: 10,
                //           ),
                //           Text(
                //             " ${widget.rating} ",
                //             style: TextStyle(
                //               fontSize: 10.0,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                Positioned(
                  top: 6.0,
                  left: 6.0,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0)),
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        " OPEN ",
                        style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 7.0),
            Padding(
              padding: EdgeInsets.only(left: 15.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "${widget.bloc.name}",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            SizedBox(height: 7.0),
            Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "${widget.bloc.addressLine1}, ${widget.bloc.addressLine2}",
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            SizedBox(height: 0.0),
          ],
        ),
      ),
    );
  }
}