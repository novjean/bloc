import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db/entity/bloc.dart';
import '../db/entity/bloc_service.dart';
import '../helpers/firestore_helper.dart';
import '../screens/bloc/bloc_detail_screen.dart';
import '../screens/bloc/bloc_service_detail_screen.dart';

class BlocSlideItem extends StatefulWidget {
  final BlocDao dao;
  final Bloc bloc;
  final String rating;

  BlocSlideItem({
    Key? key,
    required this.dao,
    required this.bloc,
    required this.rating,
  }) : super(key: key);

  @override
  _BlocSlideItemState createState() => _BlocSlideItemState();
}

class _BlocSlideItemState extends State<BlocSlideItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Container(
        height: MediaQuery.of(context).size.height / 2.9,
        width: MediaQuery.of(context).size.width / 1.2,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          elevation: 3.0,
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height / 3.7,
                    width: MediaQuery.of(context).size.width,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: GridTile(
                        child: GestureDetector(
                          onTap: () {
                            // return _loadBloc(context, widget.bloc.id);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (ctx) => BlocDetailScreen(dao: widget.dao, bloc: widget.bloc)),
                            );
                          },
                          child: Hero(
                            // hero should be wired in with where we are animating to
                            tag: widget.bloc.id,
                            child: FadeInImage(
                              placeholder: AssetImage('assets/images/product-placeholder.png'),
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
                padding: EdgeInsets.only(left: 15.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "${widget.bloc.addressLine1}, ${widget.bloc.addressLine2}",
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }

  // _loadBloc(BuildContext context, String blocId) {
  //   return StreamBuilder<QuerySnapshot>(
  //       stream: FirestoreHelper.getBloc(blocId),
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(
  //             child: CircularProgressIndicator(),
  //           );
  //         }
  //
  //         List<BlocService> _blocServices = [];
  //
  //         for (int i = 0; i < snapshot.data!.docs.length; i++) {
  //           DocumentSnapshot document = snapshot.data!.docs[i];
  //           Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
  //           final BlocService _blocService = BlocService.fromMap(data);
  //           // BlocRepository.insertServiceTable(dao, serviceTable);
  //           _blocServices.add(_blocService);
  //
  //           if (i == snapshot.data!.docs.length - 1) {
  //             Navigator.of(context).push(
  //               MaterialPageRoute(
  //                   builder: (ctx) => BlocServiceDetailScreen(dao: widget.dao, service: _blocService)),
  //             );
  //             // return _displayUsers(context, _users);
  //           }
  //         }
  //         return Text('Pulling bloc services...');
  //       }
  //   );
  // }
}
