import 'package:bloc/helpers/dummy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/dao/bloc_dao.dart';
import '../../../db/entity/manager_service.dart';
import '../../../db/entity/party.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/ui/listview_block.dart';
import 'party_add_edit_screen.dart';

class ManagePartiesScreen extends StatefulWidget {
  String serviceId;
  ManagerService managerService;

  ManagePartiesScreen(
      {required this.serviceId,
      required this.managerService});

  @override
  State<ManagePartiesScreen> createState() => _ManagePartiesScreenState();
}

class _ManagePartiesScreenState extends State<ManagePartiesScreen> {
  String _selectedType = 'Alcohol';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage | Parties'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => PartyAddEditScreen(
                      party: Dummy.getDummyParty(widget.serviceId),
                      task: 'Add',
                    )),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Add Party',
        elevation: 5,
        splashColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 2.0),
        _buildParties(context),
        const SizedBox(height: 2.0),
      ],
    );
  }

  _buildParties(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getParties(widget.serviceId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Party> _parties = [];

          if (!snapshot.hasData) {
            return Center(child: Text('No products found!'));
          }

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            final Party _party = Party.fromMap(map);
            _parties.add(_party);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayPartiesList(context, _parties);
            }
          }
          return Center(child: Text('loading products...'));
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
                  print(_sParty.name + ' is selected');

                  PartyAddEditScreen(party: _sParty, task: 'Edit');
                });
          }),
    );
  }
}
