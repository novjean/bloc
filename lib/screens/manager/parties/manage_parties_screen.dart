import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/widgets/manager/manage_genre_item.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/genre.dart';
import '../../../db/entity/manager_service.dart';
import '../../../db/entity/party.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../widgets/manager/manage_party_item.dart';
import '../../../widgets/ui/sized_listview_block.dart';
import 'genre_add_edit_screen.dart';
import 'party_add_edit_screen.dart';

class ManagePartiesScreen extends StatefulWidget {
  String serviceId;
  ManagerService managerService;

  ManagePartiesScreen(
      {Key? key, required this.serviceId, required this.managerService})
      : super(key: key);

  @override
  State<ManagePartiesScreen> createState() => _ManagePartiesScreenState();
}

class _ManagePartiesScreenState extends State<ManagePartiesScreen> {
  static const String _TAG = 'ManagePartiesScreen';

  late List<String> mOptions;
  String sOption = '';

  List<Party> mParties = [];
  var _isPartiesLoading = true;
  List<Party> mEvents = [];
  List<Party> mArtists = [];

  List<Party> searchList = [];
  bool isSearching = false;

  @override
  void initState() {
    mOptions = ['event', 'artist', 'genre'];
    sOption = mOptions.first;

    FirestoreHelper.pullParties(widget.serviceId).then((res) {
      if(res.docs.isNotEmpty){
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, false);
          mParties.add(party);

          if(party.type == 'event'){
            mEvents.add(party);
          } else {
            mArtists.add(party);
          }
        }

        setState(() {
          _isPartiesLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          titleSpacing: 0,
          title: AppBarTitle(
            title: 'manage parties',
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddOptionsDialog(context);
        },
        backgroundColor: Constants.primary,
        tooltip: 'add party',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _isPartiesLoading? const LoadingWidget(): _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        _showOptions(context),
        const Divider(),
        sOption == 'event' || sOption == 'artist'
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: TextField(
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'search by name',
                      hintStyle: TextStyle(color: Constants.primary)),
                  autofocus: false,
                  style:
                      const TextStyle(fontSize: 17, color: Constants.primary),
                  onChanged: (val) {
                    if (val.trim().isNotEmpty) {
                      isSearching = true;
                    } else {
                      isSearching = false;
                    }

                    searchList.clear();

                    for (var i in mParties) {
                      if (i.name.toLowerCase().contains(val.toLowerCase())) {
                        searchList.add(i);
                      }
                    }
                    setState(() {});
                  },
                ),
              )
            : const SizedBox(),
        const Divider(),
        sOption == 'event' || sOption == 'artist'
            ? _showPartiesList(context)
            : _buildGenres(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  _showOptions(BuildContext context) {
    double containerHeight = mq.height * 0.2;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: mq.height / 15,
      child: ListView.builder(
          itemCount: mOptions.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: mOptions[index],
                  height: containerHeight,
                  width: mq.width / 3,
                  color: Constants.primary,
                ),
                onTap: () {
                  setState(() {
                    sOption = mOptions[index];
                  });
                });
          }),
    );
  }

  _showPartiesList(BuildContext context) {
    List<Party> parties = isSearching ? searchList : (sOption == 'event'? mEvents: mArtists);

    return Expanded(
      child: ListView.builder(
          itemCount: parties.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManagePartyItem(
                  party: parties[index],
                ),
                onTap: () {
                  Party sParty = parties[index];
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) =>
                          PartyAddEditScreen(party: sParty, task: 'edit')));
                });
          }),
    );
  }

  _buildGenres(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getGenres(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          List<Genre> genres = [];

          if (!snapshot.hasData) {
            return const Center(child: Text('no genres found!'));
          }

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            final Genre genre = Fresh.freshGenreMap(map, false);
            genres.add(genre);
          }
          return _displayGenres(context, genres);
        });
  }

  _displayGenres(BuildContext context, List<Genre> genres) {
    return Expanded(
      child: ListView.builder(
          itemCount: genres.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageGenreItem(
                  genre: genres[index],
                ),
                onTap: () {
                  Genre genre = genres[index];
                  Logx.i(_TAG, '${genre.name} is selected');

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) =>
                          GenreAddEditScreen(genre: genre, task: 'edit')));
                });
          }),
    );
  }

  showAddOptionsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 250,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'add options',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    width: 300,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('event | artist'),
                              ButtonWidget(
                                  text: 'add',
                                  onClicked: () {
                                    Navigator.of(ctx).pop();

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (ctx) => PartyAddEditScreen(
                                                party: Dummy.getDummyParty(
                                                    widget.serviceId),
                                                task: 'add',
                                              )),
                                    );
                                  }),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('genre'),
                              ButtonWidget(
                                  text: 'add',
                                  onClicked: () {
                                    Navigator.of(ctx).pop();

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (ctx) => GenreAddEditScreen(
                                                genre: Dummy.getDummyGenre(),
                                                task: 'add',
                                              )),
                                    );
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
