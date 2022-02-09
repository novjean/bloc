import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:flutter/material.dart';

import '../utils/const.dart';

class BlocSlideItem extends StatefulWidget {
  final BlocDao dao;
  final String img;
  final String title;
  final String address;
  final String rating;

  BlocSlideItem({
    Key? key,
    required this.dao,
    required this.img,
    required this.title,
    required this.address,
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
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //       builder: (ctx) => CityDetailScreen(dao: dao, city: city)),
                            // );
                          },
                          child: Hero(
                            // hero should be wired in with where we are animating to
                            tag: widget.img,
                            child: FadeInImage(
                              placeholder: AssetImage('assets/images/product-placeholder.png'),
                              image: widget.img != "url"
                                  ? NetworkImage(widget.img)
                                  : NetworkImage(
                                  "assets/images/product-placeholder.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ClipRRect(
                    //   borderRadius: BorderRadius.only(
                    //     topLeft: Radius.circular(10.0),
                    //     topRight: Radius.circular(10.0),
                    //   ),
                    //   child: Hero(
                    //     tag: widget.img,
                    //     child: FadeInImage(
                    //       placeholder: const AssetImage(
                    //           'assets/images/product-placeholder.png'),
                    //       image: widget.img != "url"
                    //           ? NetworkImage(widget.img)
                    //           : NetworkImage(
                    //               "assets/images/product-placeholder.png"),
                    //       fit: BoxFit.cover,
                    //     ),
                    //   ),
                    //   // Image.asset(
                    //   //   "${widget.img}",
                    //   //   fit: BoxFit.cover,
                    //   // ),
                    // ),
                  ),
                  Positioned(
                    top: 6.0,
                    right: 6.0,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0)),
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.star,
                              color: Constants.ratingBG,
                              size: 10,
                            ),
                            Text(
                              " ${widget.rating} ",
                              style: TextStyle(
                                fontSize: 10.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                    "${widget.title}",
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
                    "${widget.address}",
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
}
