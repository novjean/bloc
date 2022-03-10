import 'package:flutter/material.dart';

class CoverPhoto extends StatelessWidget {
  String title;
  String imageUrl;

  CoverPhoto(this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 5.5;
    double width = MediaQuery.of(context).size.width;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      elevation: 3.0,
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: height,
                width: width,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                  child: FadeInImage(
                    placeholder: const AssetImage(
                        'assets/images/product-placeholder.png'),
                    image: imageUrl != "url"
                        ? NetworkImage(imageUrl)
                        : NetworkImage("assets/images/product-placeholder.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: height,
                width: width,
                child: Center(
                    child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
