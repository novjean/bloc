import 'package:bloc/db/entity/user.dart';
import 'package:bloc/main.dart';
import 'package:bloc/screens/user/book_table_screen.dart';
import 'package:bloc/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db/entity/bloc.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/token_monitor.dart';
import '../widgets/home/new_bloc_slide_item.dart';
import '../widgets/search_card.dart';
import '../widgets/ui/button_widget.dart';
import 'experimental/trending.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Bloc> mBlocs;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();

    FirestoreHelper.pullBlocs().then((res) {
      print("Successfully pulled in blocs.");

      if (res.docs.isNotEmpty) {
        // found blocs
        List<Bloc> blocs = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Bloc bloc = Bloc.fromMap(data);
          blocs.add(bloc);

          setState(() {
            mBlocs = blocs;
            _isLoading = false;
          });
        }
      } else {
        print('no blocs found!!!');
        //todo: need to re-attempt or check internet connection
      }
    });
  }

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
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
          children: <Widget>[
            // buildSearchBar(context),
            const SizedBox(height: 10.0),
            _isLoading
                ? Center(child: Text('Loading blocs...'))
                : _displayBlocs(context),
            // SizedBox(height: 20.0),
            // buildBookTableRow(context),
            // buildRestaurantRow('Trending Restaurants', context),
            // SizedBox(height: 10.0),
            // buildSuperstarsTitleRow('Superstars', context),
            // SizedBox(height: 10.0),
            // buildSuperstarsList(context),
            !kIsWeb ? TokenMonitor((token) {
              if (token != null) {
                User user = UserPreferences.myUser;
                if (user.id.isNotEmpty) {
                  if (UserPreferences.myUser.fcmToken.isEmpty ||
                      UserPreferences.myUser.fcmToken != token) {
                    UserPreferences.setUserFcmToken(token);
                    FirestoreHelper.updateUserFcmToken(
                        UserPreferences.myUser.id, token);
                  } else {
                    print('fcm token has not changed: ' + token);
                  }
                }
              }
              return const Spacer();
            }) : const SizedBox(height: 0),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  _displayBlocs(context) {
    return SizedBox(
      height: 400,
      child: ListView.builder(
          itemCount: mBlocs.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            Bloc bloc = mBlocs[index];

            return GestureDetector(
              child:
                  // BlocSlideItem(
                  //   bloc: bloc,
                  //   rating: '5',
                  // )
                  NewBlocSlideItem(
                bloc: bloc,
              ),
            );
          }),
    );
  }

  /** Optional **/
  buildSuperstarsTitleRow(String category, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "$category",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          // FlatButton(
          //   child: Text(
          //     "See all",
          //     style: TextStyle(
          //       color: Theme.of(context).accentColor,
          //     ),
          //   ),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (BuildContext context) {
          //todo: need to navigate to show list of users or friends
          //           return Categories();
          //         },
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  buildSuperstarsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getUsers(Constants.MANAGER_LEVEL),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('loading users...');
          return SizedBox();
        }

        List<User> _users = [];
        for (int i = 0; i < snapshot.data!.docs.length; i++) {
          DocumentSnapshot document = snapshot.data!.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final User user = User.fromMap(data);
          if (user.imageUrl.isNotEmpty) {
            _users.add(user);
          }

          if (i == snapshot.data!.docs.length - 1) {
            return _displaySuperstarsList(context, _users);
          }
        }
        return Text('Loading users...');
      },
    );
  }

  _displaySuperstarsList(BuildContext context, List<User> users) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
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

  /** Non functional **/
  buildBookTableRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // NumbersWidget(),
        ButtonWidget(
            text: 'Book A Table',
            onClicked: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => BookTableScreen(
                          blocs: mBlocs,
                        )),
              );
            }),
      ],
    );
  }

  /** Unimplemented **/
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
        ElevatedButton(
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

  buildSearchBar(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(10, 5, 10, 0), child: SearchCard());
  }
}
