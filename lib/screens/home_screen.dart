import 'package:bloc/db/entity/user.dart';
import 'package:bloc/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db/bloc_repository.dart';
import '../db/dao/bloc_dao.dart';
import '../db/entity/bloc.dart';
import '../helpers/firestore_helper.dart';
import '../widgets/search_card.dart';
import '../widgets/bloc_slide_item.dart';
import 'experimental/categories.dart';
import 'experimental/trending.dart';

class HomeScreen extends StatelessWidget {
  BlocDao dao;

  HomeScreen({key, required this.dao}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
          child: ListView(
            children: <Widget>[
              // buildSearchBar(context),
              SizedBox(height: 20.0),
              buildBlocRow(context),
              // SizedBox(height: 20.0),
              // buildRestaurantRow('Trending Restaurants', context),
              // SizedBox(height: 10.0),
              // buildCategoryRow('Category', context),
              SizedBox(height: 20.0),
              buildCategoryRow('Superstars', context),
              SizedBox(height: 10.0),
              buildSuperstarsList(context),
              SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  buildBlocRow(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getBlocs(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Bloc> blocs = [];

        for(int i=0; i<snapshot.data!.docs.length; i++){
          DocumentSnapshot document = snapshot.data!.docs[i];
          Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
          final Bloc bloc = Bloc.fromMap(map);
          BlocRepository.insertBloc(dao, bloc);

          if(bloc.isActive){
            blocs.add(bloc);
          }

          if(i==snapshot.data!.docs.length-1){
            return buildBlocList(context, blocs);
          }
        }
        return Text('Loading blocs...');

        // int count = snapshot.data!.docs.length;

        // for (DocumentSnapshot document in snapshot.data!.docs) {
        //   Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        //   final Bloc bloc = Bloc.fromMap(data);
        //   BlocRepository.insertBloc(dao, bloc);
        //
        //   if(bloc.isActive){
        //     blocs.add(bloc);
        //   }
        //
        //   if (--count == 0) return buildBlocList(context, blocs);
        // }
      },
    );
  }

  buildRestaurantRow(String restaurant, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "$restaurant",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        FlatButton(
          child: Text(
            "See all (9)",
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return Trending();
                },
              ),
            );
          },
        ),
      ],
    );
  }

  buildCategoryRow(String category, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "$category",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        FlatButton(
          child: Text(
            "See all",
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return Categories();
                },
              ),
            );
          },
        ),
      ],
    );
  }

  buildSearchBar(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(10, 5, 10, 0), child: SearchCard());
  }

  buildBlocList(BuildContext context, List blocs) {
    return Container(
      height: MediaQuery.of(context).size.height / 2.4,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        primary: false,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: blocs == null ? 0 : blocs.length,
        itemBuilder: (BuildContext context, int index) {
          Bloc bloc = blocs[index];

          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: BlocSlideItem(
              dao: dao,
              bloc: bloc,
              rating: "3",
            ),
          );
        },
      ),
    );
  }

  buildSuperstarsList(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getUsers(Constants.MANAGER_LEVEL),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('loading superstars...');
          return SizedBox();
        }

        // if (snapshot.data!.docs.length > 0) {
        //   BlocRepository.clearCategories(widget.dao);
        // }

        List<User> _users = [];
        for (int i = 0; i < snapshot.data!.docs.length; i++) {
          DocumentSnapshot document = snapshot.data!.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final User user = User.fromMap(data);
          // BlocRepository.insertCategory(widget.dao, cat);
          _users.add(user);

          if (i == snapshot.data!.docs.length - 1) {
            return _displaySuperstarsList(context, _users);
          }
        }
        return Text('Loading categories...');
      },
    );
  }

  _displaySuperstarsList(BuildContext context, List<User> users) {
    return Container(
      height: 50.0,
      child: ListView.builder(
        primary: false,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          String img = users[index].imageUrl;

          return Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                img,
              ),
              radius: 25.0,
            ),
          );
        },
      ),
    );
  }
}
