import 'package:flutter/material.dart';

import '../../db/entity/party.dart';

class ArtistScreen extends StatefulWidget{
  final Party party;


  ArtistScreen({required this.party, Key? key}) : super(key: key);

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.party.name),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _buildBody(context)
    );
  }

  _buildBody(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          width:  double.infinity,
          child: Hero(
            tag: widget.party.id,
            child: Image.network(
              widget.party.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          child: Text(widget.party.name.toLowerCase(),
              textAlign: TextAlign.start,
              softWrap: true,
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 26,
              )),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          child: Text(widget.party.description.toLowerCase(),
              textAlign: TextAlign.start,
              softWrap: true,
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 20,
              )),
        ),
      ],
    );
  }
}