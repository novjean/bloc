import 'package:barcode_widget/barcode_widget.dart';
import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/widgets/ui/dark_button_widget.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../screens/parties/party_guest_add_edit_manage_screen.dart';
import '../../utils/date_time_utils.dart';
import '../ui/button_widget.dart';

class BoxOfficeItem extends StatefulWidget {
  final PartyGuest partyGuest;
  final Party party;
  final bool isClickable;

  const BoxOfficeItem(
      {Key? key,
      required this.partyGuest,
      required this.isClickable,
      required this.party})
      : super(key: key);

  @override
  State<BoxOfficeItem> createState() => _BoxOfficeItemState();
}

class _BoxOfficeItemState extends State<BoxOfficeItem> {
  @override
  Widget build(BuildContext context) {
    String title = widget.partyGuest.name.toLowerCase();
    int friendsCount = widget.partyGuest.guestsCount - 1;

    if (friendsCount > 0) {
      title += ' +' + friendsCount.toString();
    }

    return GestureDetector(
      onTap: () {
        // isClickable
        //     ? Navigator.of(context).push(
        //         MaterialPageRoute(builder: (ctx) => ArtistScreen(party: party)),
        //       )
        //     : print('party guest item no click');
      },
      child: Hero(
        tag: widget.partyGuest.id,
        child: Card(
          elevation: 1,
          color: Theme.of(context).primaryColorLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 3, left: 5.0),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      widget.party.eventName.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                widget.party.eventName.toLowerCase(),
                                style: const TextStyle(fontSize: 18),
                              ),
                            )
                          : const SizedBox(),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text(
                          widget.party.isTBA
                              ? 'tba'
                              : DateTimeUtils.getFormattedDate(
                                      widget.party.startTime) +
                                  ', ' +
                                  DateTimeUtils.getFormattedTime(
                                      widget.party.startTime),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text('status:\n' +
                                (widget.partyGuest.isApproved
                                    ? widget.partyGuest.guestsRemaining == 0
                                        ? 'completed'
                                        : widget.partyGuest.guestsRemaining
                                                .toString() +
                                            ' ' +
                                            widget.partyGuest.guestStatus
                                    : 'pending')),
                          ),
                          displayEntryEditButton(context),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      image: DecorationImage(
                        image: NetworkImage(widget.party.imageUrl),
                        fit: BoxFit.fitHeight,
                        // AssetImage(food['image']),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  displayEntryEditButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5, bottom: 5),
      child: widget.partyGuest.isApproved
          ? DarkButtonWidget(
              text: 'entry\ncode',
              onClicked: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      contentPadding: const EdgeInsets.all(16.0),
                      content: SizedBox(
                        height: 300,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.party.eventName +
                                        ' | ' +
                                        widget.party.name,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                                child: BarcodeWidget(
                              color: Theme.of(context).primaryColorDark,
                              barcode: Barcode.qrCode(),
                              // Barcode type and settings
                              data: widget.partyGuest.id,
                              // Content
                              width: 200,
                              height: 200,
                            )),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      widget.partyGuest.guestStatus +
                                          ' entry. ' +
                                          widget.partyGuest.guestsRemaining
                                              .toString() +
                                          ' guests remaining',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'valid until ' +
                                          DateTimeUtils.getFormattedTime(
                                              widget.party.guestListEndTime),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text("close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            )
          : ButtonWidget(
              text: 'edit\nrequest',
              onClicked: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => PartyGuestAddEditManagePage(
                          partyGuest: widget.partyGuest,
                          party: widget.party,
                          task: 'edit',
                        )));
              },
            ),
    );
  }
}
