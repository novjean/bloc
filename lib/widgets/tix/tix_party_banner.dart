import 'package:barcode_widget/barcode_widget.dart';
import 'package:bloc/main.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/tix.dart';

class TixPartyBanner extends StatefulWidget {
  static const String _TAG = 'PartyBanner';

  int tixsCount;
  Tix tix;
  Party party;
  final bool shouldShowButton;

  TixPartyBanner(
      {Key? key,
        required this.tix,
        required this.tixsCount,
        required this.party,
        required this.shouldShowButton})
      : super(key: key);

  @override
  State<TixPartyBanner> createState() => _TixPartyBannerState();
}

class _TixPartyBannerState extends State<TixPartyBanner> {
  static const String _TAG = 'TixPartyBanner';

  int merchantTransacationId = 0;

  @override
  void initState() {

    if(widget.tix.merchantTransactionId.isNotEmpty){
      merchantTransacationId = StringUtils.getInt(widget.tix.merchantTransactionId);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
      child: ClipRRect(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        child: Hero(
          tag: widget.party.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            child: SizedBox(
              height: 200,
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
                          padding: const EdgeInsets.only(left: 5.0, top: 5),
                          child: Text(
                            '${widget.tix.userName}',
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(left: 5.0, top: 5),
                        //   child: Text(
                        //     '+${widget.tix.userPhone}',
                        //     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: RichText(
                            maxLines: 1,
                            text: TextSpan(
                                text:
                                '${widget.party.name.toLowerCase()} ',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: Constants.fontDefault,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: widget.party.chapter == 'I'
                                          ? ' '
                                          : '${widget.party.chapter} ',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontFamily:
                                          Constants.fontDefault,
                                          fontSize: 17,
                                          fontWeight: FontWeight.normal,
                                          fontStyle: FontStyle.italic)),
                                ]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0, top: 0),
                          child: Text(
                            '${widget.tixsCount} tickets',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(
                            widget.party.isTBA
                                ? 'tba'
                                : '🎊 ${DateTimeUtils.getFormattedDate(widget.party.startTime)}, ${DateTimeUtils.getFormattedTime(widget.party.startTime)}' ,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        // Padding(
                        //   padding: const EdgeInsets.only(left: 5.0),
                        //   child: Text('🚪${DateTimeUtils.getFormattedDate(widget.party.endTime)}, ${DateTimeUtils.getFormattedTime(widget.party.endTime)}',
                        //     style: const TextStyle(fontSize: 17),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:[
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0, top: 5),
                          child: Text(
                            '#${widget.tix.merchantTransactionId}' ,
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(
                            merchantTransacationId>0?('${DateTimeUtils.getFormattedDate(merchantTransacationId)}, ${DateTimeUtils.getFormattedTime2(merchantTransacationId)}') :
                            'payment failure' ,
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Container(
                        padding: EdgeInsets.only(top:10, left: 10, right: 5),
                          height: 150,
                          child: BarcodeWidget(
                            color: Constants.darkPrimary,
                            barcode: Barcode.qrCode(),
                            // Barcode type and settings
                            data: widget.tix.id,
                            // Content
                            width: mq.width * 0.35,
                            height: mq.width * 0.35,
                          )
                      ),
              ]
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
