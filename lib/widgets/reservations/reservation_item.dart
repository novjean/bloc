import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../db/entity/bloc_service.dart';
import '../../db/entity/reservation.dart';
import '../../helpers/fresh.dart';
import '../../screens/user/reservation_add_edit_screen.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';

class ReservationItem extends StatefulWidget {
  Reservation reservation;
  final bool isPromoter;

  ReservationItem(
      {Key? key,
        required this.reservation,
        required this.isPromoter,})
      : super(key: key);

  @override
  State<ReservationItem> createState() => _ReservationItemState();
}

class _ReservationItemState extends State<ReservationItem> {
  static const String _TAG = 'ReservationItem';

  bool testMode = false;

  late BlocService mBlocService;
  bool _isBlocServiceLoading = true;

  @override
  void initState() {
    super.initState();

    FirestoreHelper.pullBlocServiceById(widget.reservation.blocServiceId).then(
        (res) {
          if(res.docs.isNotEmpty){
            DocumentSnapshot document = res.docs[0];
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

            setState(() {
              mBlocService = Fresh.freshBlocServiceMap(data, false);
              _isBlocServiceLoading = false;
            });
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {


    String title = widget.reservation.name.toLowerCase();
    int guestsCount = widget.reservation.guestsCount -1;
    if(guestsCount > 0){
      title += ' +$guestsCount';
    }

    return Hero(
      tag: widget.reservation.id,
      child: Card(
        elevation: 1,
        color: Constants.lightPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        child: Container(
          padding: const EdgeInsets.only(top: 1, bottom: 0, left: 5, right: 5),
          width: MediaQuery.of(context).size.width,
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  _isBlocServiceLoading ? const SizedBox() : SizedBox(
                    height: 50,
                    width: 50,
                    child: FadeInImage(
                      placeholder: AssetImage('assets/icons/logo.png'),
                      image: NetworkImage(mBlocService.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_isBlocServiceLoading ? '' : '${mBlocService.name}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateTimeUtils.getFormattedDate(widget.reservation.arrivalDate),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'reach by: ${widget.reservation.arrivalTime}',
                    style: const TextStyle(fontSize: 16),
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _showBuyTicketButton(context),
                  widget.reservation.isApproved
                      ? _showApprovedButton(context)
                      : _showPendingButton(context),
                  _showEditReservationButton(context)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showApprovedButton(BuildContext context) {
    return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          height: 60,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.lightPrimary,
              foregroundColor: Constants.primary,
              shadowColor: Colors.white30,
              minimumSize: const Size.fromHeight(60),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              ),
              elevation: 3,
            ),
            label: const Text(
              'approved',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Constants.darkPrimary),
            ),
            icon: const Icon(
              Icons.thumb_up_off_alt_sharp,
              size: 24.0,
              color: Constants.darkPrimary,
            ),
            onPressed: () {
              Logx.ilt(_TAG,
                  'congratulations, your reservation has been accepted. see you soon! 🍾');
            },
          ),
        ));
  }


  _showBuyTicketButton(BuildContext context) {
    return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          height: 60,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.darkPrimary,
              foregroundColor: Constants.primary,
              shadowColor: Colors.white30,
              minimumSize: const Size.fromHeight(60),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              ),
              elevation: 3,
            ),
            label: const Text(
              'call us',
              style: TextStyle(fontSize: 14),
            ),
            icon: const Icon(
              Icons.phone,
              size: 24.0,
            ),
            onPressed: () {
              _handlePropertyCall();
            },
          ),
        ));
  }

  _showEditReservationButton(BuildContext context) {
    return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          height: 60,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.darkPrimary,
              foregroundColor: Constants.primary,
              shadowColor: Colors.white30,
              minimumSize: const Size.fromHeight(60),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              ),
              elevation: 3,
            ),
            label: const Text(
              'edit',
              style: TextStyle(fontSize: 14),
            ),
            icon: const Icon(
              Icons.mode_edit_outline_outlined,
              size: 24.0,
            ),
            onPressed: () {
              if(!widget.reservation.isApproved) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => ReservationAddEditScreen(
                      reservation: widget.reservation,
                      task: 'edit',
                    )));
              } else {
                _showReservationNoEditDialog(context);
              }
            },
          ),
        ));
  }

  _showReservationNoEditDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(19.0))),
          title: const Text(
            'reservation is confirmed',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          content: Text(
              'Your reservation is confirmed! Need changes? Swing by the club or give us a call. 🎉📞'.toLowerCase()),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Constants.darkPrimary),
              ),
              child: const Text("☎️ call", style: TextStyle(color: Constants.primary)),
              onPressed: () {
                _handlePropertyCall();
              },
            ),
          ],
        );
      },
    );
  }


  _showPendingButton(BuildContext context) {
    String text = "your reservation is pending, which means it's waiting for approval by our team. please give us some time or feel free to call us!";

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        height: 60,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.lightPrimary,
            foregroundColor: Constants.primary,
            shadowColor: Colors.white30,
            minimumSize: const Size.fromHeight(60),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            elevation: 3,
          ),
          label: const Text(
            'pending',
            style: TextStyle(fontSize: 14, color: Constants.darkPrimary),
          ),
          icon: const Icon(
            Icons.pending,
            size: 24.0,
            color: Constants.darkPrimary,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    '⏳ reservation is pending'.toLowerCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, color: Colors.black),
                  ),
                  backgroundColor: Constants.lightPrimary,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  contentPadding: const EdgeInsets.all(16.0),
                  content: Text(text),
                  actions: [
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Constants.darkPrimary),
                      ),
                      child: const Text("👍 okay" , style: TextStyle(color: Constants.primary),),
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _handlePropertyCall() {
    NetworkUtils.makePhoneCall('tel:+91${mBlocService.primaryPhone.toInt()}');
  }


}
