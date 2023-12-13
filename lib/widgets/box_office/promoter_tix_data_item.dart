import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/db/entity/tix.dart';
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
import '../../screens/parties/box_office_guest_confirm_screen.dart';
import '../../screens/parties/party_guest_add_edit_manage_screen.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../ui/toaster.dart';

class PromoterTixDataItem extends StatefulWidget {
  Tix tix;
  final Party party;
  final bool isClickable;

  PromoterTixDataItem(
      {Key? key,
        required this.tix,
        required this.isClickable,
        required this.party,})
      : super(key: key);

  @override
  State<PromoterTixDataItem> createState() => _PromoterTixDataItemState();
}

class _PromoterTixDataItemState extends State<PromoterTixDataItem> {
  static const String _TAG = 'PromoterTixDataItem';

  @override
  Widget build(BuildContext context) {
    String title =
        widget.tix.userName.toLowerCase();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (ctx) => BoxOfficeGuestConfirmScreen(
                partyGuestId: widget.tix.id,
              )),
        );
      },
      child: Hero(
        tag: widget.tix.id,
        child: Card(
          elevation: 1,
          color: Constants.lightPrimary,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
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
                            fontSize: 20.0,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    Text(
                      '+${widget.tix.userPhone}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
