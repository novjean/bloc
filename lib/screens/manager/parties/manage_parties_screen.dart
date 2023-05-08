import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/manager_service.dart';
import '../../../db/entity/party.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../utils/logx.dart';
import '../../../widgets/ui/listview_block.dart';
import '../../../widgets/ui/sized_listview_block.dart';
import 'party_add_edit_screen.dart';

class ManagePartiesScreen extends StatefulWidget {
  String serviceId;
  ManagerService managerService;

  ManagePartiesScreen({Key? key, required this.serviceId, required this.managerService}) : super(key: key);

  @override
  State<ManagePartiesScreen> createState() => _ManagePartiesScreenState();
}

class _ManagePartiesScreenState extends State<ManagePartiesScreen> {
  static const String _TAG = 'ManagePartiesScreen';

  late List<String> mOptions;
  String sOption = '';

  @override
  void initState() {
    mOptions = ['event', 'artist'];
    sOption = mOptions.first;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('manage | parties'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => PartyAddEditScreen(
                      party: Dummy.getDummyParty(widget.serviceId),
                      task: 'add',
                    )),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
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
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        displayBoxOfficeOptions(context),
        const Divider(),
        _buildParties(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  displayBoxOfficeOptions(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height / 20;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: MediaQuery.of(context).size.height / 15,
      child: ListView.builder(
          itemCount: mOptions.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: mOptions[index],
                  height: containerHeight,
                  width: MediaQuery.of(context).size.width / 3,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  setState(() {
                    sOption = mOptions[index];
                    Logx.i(_TAG, '$sOption at box office is selected');
                  });
                });
          }),
    );
  }

  _buildParties(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getPartyByType(widget.serviceId, sOption),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          List<Party> _parties = [];

          if (!snapshot.hasData) {
            return const Center(child: Text('no parties found!'));
          }

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            final Party _party = Fresh.freshPartyMap(map, false);
            _parties.add(_party);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayPartiesList(context, _parties);
            }
          }
          return Center(child: Text('loading parties...'));
        });
  }

  _displayPartiesList(BuildContext context, List<Party> _parties) {
    return Expanded(
      child: ListView.builder(
          itemCount: _parties.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ListViewBlock(
                  title: _parties[index].name,
                ),
                // ManagePartyItem(
                //   serviceId: widget.serviceId,
                //   product: _parties[index],
                // ),
                onTap: () {
                  Party _sParty = _parties[index];
                  print('${_sParty.name} is selected');

                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => PartyAddEditScreen(party: _sParty, task: 'edit')));
                });
          }),
    );
  }
}
