import 'package:bloc/db/entity/offer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/dao/bloc_dao.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/ui/listview_block.dart';

class ManageOffersScreen extends StatelessWidget {
  String serviceId;
  BlocDao dao;

  ManageOffersScreen({
    required this.serviceId,
    required this.dao,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Inventory | Offers'),
        ),
      body: _buildOffers(context),
    );
  }

  _buildOffers(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getOffers(serviceId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Offer> _offers = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            final Offer _offer = Offer.fromMap(map);
            _offers.add(_offer);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayOffers(context, _offers);
            }
          }
          return Center(child: Text('loading offers...'));
        });
  }

  _displayOffers(BuildContext context, List<Offer> _offers) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: _offers.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ListViewBlock(
                  title: _offers[index].productName + ' | ' + _offers[index].offerPercent.toString() + '%' ,
                ),
                onTap: () {
                  Offer _sOffer = _offers[index];

                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('End Offer | ' + _sOffer.productName),
                      content: Text(
                        'Do you want to end the offer for the item?',
                      ),
                      actions: [
                        FlatButton(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.of(ctx).pop(false);
                          },
                        ),
                        FlatButton(
                          child: Text('Yes'),
                          onPressed: () {
                            _sOffer.isActive = false;
                            FirestoreHelper.deleteOffer(_sOffer.id);

                            Navigator.of(ctx).pop(true);
                          },
                        ),
                      ],
                    ),
                  );
                });
          }),
    );
  }


}