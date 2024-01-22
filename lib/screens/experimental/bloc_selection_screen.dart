import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/bloc.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/bloc_item.dart';
import '../../widgets/ui/app_bar_title.dart';

class BlocSelectionScreen extends StatefulWidget {
  const BlocSelectionScreen({super.key});

  @override
  _BlocSelectionScreenState createState() => _BlocSelectionScreenState();
}

class _BlocSelectionScreenState extends State<BlocSelectionScreen> {
  static const String _TAG = 'BlocSelectionScreen';

  List<Bloc> mBlocs = [];
  var _isBlocsLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullBlocs().then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Bloc bloc = Fresh.freshBlocMap(data, false);
          mBlocs.add(bloc);
        }

        setState(() {
          _isBlocsLoading = false;
        });
      } else {
        Logx.em(_TAG, 'no blocs could be found!');
      }
    }).catchError((err) {
      Logx.em(_TAG, 'error loading blocs $err');
      setState(() {
        _isBlocsLoading = false;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
          backgroundColor: Constants.background,
          appBar: AppBar(
            elevation: 0.0,
            title: AppBarTitle(title: 'blocs'),
            backgroundColor: Colors.black,
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
              onPressed: () {
                _handleDone();
              },
            ),
          ),
          body: _isBlocsLoading
              ? const LoadingWidget()
              : ListView(
                  children: [
                    SizedBox(
                      height: mq.height * 0.8, // Adjust the height as needed
                      child: ListView.builder(
                          itemCount: mBlocs.length,
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return BlocItem(
                              bloc: mBlocs[index],
                              imageHeight: 250,
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.primary,
                          foregroundColor: Constants.darkPrimary,
                          shadowColor: Colors.white30,
                          elevation: 3,
                          minimumSize: const Size.fromHeight(50),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        onPressed: () {
                          _handleDone();
                        },
                        label: const Text(
                          'done',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        icon: const Icon(
                          Icons.done_all_sharp,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ],
                )),
    );
  }

  void _handleDone() {
    if (UserPreferences.getUserBlocs().isNotEmpty) {
      GoRouter.of(context).pushReplacementNamed(RouteConstants.landingRouteName);
    } else {
      Logx.elt(_TAG, 'please select at least one bloc.');
    }
  }
}
