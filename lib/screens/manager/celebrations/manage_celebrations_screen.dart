import 'package:bloc/db/entity/celebration.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../helpers/fresh.dart';
import '../../../utils/logx.dart';
import '../../../widgets/celebrations/celebration_item.dart';
import '../../../widgets/ui/loading_widget.dart';
import '../../user/celebration_add_edit_screen.dart';

class ManageCelebrationsScreen extends StatefulWidget {
  String blocServiceId;
  String serviceName;
  String userTitle;

  ManageCelebrationsScreen({
    required this.blocServiceId,
    required this.serviceName,
    required this.userTitle});

  @override
  State<StatefulWidget> createState() => _ManageCelebrationsScreenState();
}

class _ManageCelebrationsScreenState extends State<ManageCelebrationsScreen> {
  static const String _TAG = 'ManageCelebrationsScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('manage | ${widget.serviceName}')),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     //todo: implement new booking
      //     // Navigator.of(context).push(
      //     //   MaterialPageRoute(
      //     //       builder: (ctx) =>
      //     //           NewServiceTableScreen(serviceId: widget.blocServiceId)),
      //     // );
      //   },
      //   backgroundColor: Theme
      //       .of(context)
      //       .primaryColor,
      //   tooltip: 'new celebration',
      //   elevation: 5,
      //   splashColor: Colors.grey,
      //   child: const Icon(
      //     Icons.add,
      //     color: Colors.black,
      //     size: 29,
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        // const SizedBox(height: 2.0),
        // _displayOptions(context),
        // const Divider(),
        const SizedBox(height: 5.0),
        _buildCelebrations(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  _buildCelebrations(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getCelebrationsByBlocId(widget.blocServiceId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          List<Celebration> celebrations = [];

          if (snapshot.data!.docs.isNotEmpty) {
            try {
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot document = snapshot.data!.docs[i];
                Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
                final Celebration celebration = Fresh.freshCelebrationMap(map, false);
                celebrations.add(celebration);

                if (i == snapshot.data!.docs.length - 1) {
                  return _displayCelebrations(context, celebrations);
                }
              }
            } on Exception catch (e, s) {
              Logx.e(_TAG, e, s);
            } catch (e) {
              Logx.em(_TAG, 'error loading celebrations : $e');
            }
          }

          return const LoadingWidget();
        });
  }

  _displayCelebrations(BuildContext context, List<Celebration> celebrations) {
    return Expanded(
      child: ListView.builder(
          itemCount: celebrations.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            Celebration celebration = celebrations[index];

            return GestureDetector(
                child: CelebrationItem(
                  celebration: celebration,
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => CelebrationAddEditScreen(
                        celebration: celebration,
                        task: 'edit',
                      )));
                });
          }),
    );
  }

}