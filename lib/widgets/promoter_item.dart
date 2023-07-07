import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

import '../../db/entity/challenge.dart';
import '../../db/entity/party.dart';
import '../../main.dart';
import '../../screens/parties/party_guest_add_edit_manage_screen.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../db/entity/promoter.dart';

class PromoterItem extends StatefulWidget {
  Promoter promoter;

  PromoterItem({Key? key, required this.promoter })
      : super(key: key);

  @override
  State<PromoterItem> createState() => _PromoterItemState();
}

class _PromoterItemState extends State<PromoterItem> {
  static const String _TAG = 'PromoterItem';

  @override
  Widget build(BuildContext context) {


    return GestureDetector(
      onTap: () {
        if(UserPreferences.myUser.clearanceLevel>=Constants.MANAGER_LEVEL){
          // Navigator.of(context).push(MaterialPageRoute(
          //     builder: (ctx) => PartyGuestAddEditManageScreen(
          //       partyGuest: widget.partyGuest,
          //       party: widget.party,
          //       task: 'manage',
          //     )));
        }
      },
      child: Hero(
        tag: widget.promoter.id,
        child: Card(
          elevation: 1,
          color: Theme.of(context).primaryColorLight,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: SizedBox(
            height: mq.height * 0.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.only(left: 5.0, right: 5, top: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.promoter.name,
                              style: const TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      // widget.partyGuest.guestsRemaining != 0
                      //     ? Padding(
                      //   padding: const EdgeInsets.only(left: 5.0),
                      //   child: Text(
                      //     '${widget.partyGuest.guestsRemaining} guests remaining',
                      //     style: const TextStyle(fontSize: 18),
                      //   ),
                      // )
                      //     : Padding(
                      //   padding: const EdgeInsets.only(left: 5.0),
                      //   child: Text(
                      //     '${widget.partyGuest.guestsCount} guests entered',
                      //     style: const TextStyle(fontSize: 18),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 5.0),
                      //   child: Text(
                      //     '+${widget.partyGuest.phone}',
                      //     style: const TextStyle(fontSize: 18),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 5.0, vertical: 2),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.start,
                      //     children: [
                      //       !widget.partyGuest.isApproved
                      //           ? showApproveButton(context)
                      //           : showUnapproveButton(context),
                      //       showEditOrTicketButton(context),
                      //       const Spacer(),
                      //       widget.partyGuest.shouldBanUser
                      //           ? displayFreeUserButton(context)
                      //           : displayBanUserButton(context),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
