import 'package:bloc/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';

class PartyBoxOfficeBanner extends StatelessWidget {
  final Party party;

  const PartyBoxOfficeBanner(
      {Key? key,
        required this.party,
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: party.id,
      child: Card(
        elevation: 1,
        color: Theme.of(context).primaryColorLight,
        child: SizedBox(
          height: 200,
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
                      padding: const EdgeInsets.only(top: 3, left: 5.0, right: 0.0),
                      child: Text(
                        party.name.toLowerCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    party.eventName.isNotEmpty
                        ? Padding(
                      padding: const EdgeInsets.only(left: 5.0, top: 10),
                      child: Text(
                        party.eventName.toLowerCase(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    )
                        : const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        party.isTBA
                            ? 'tba'
                            : DateTimeUtils.getFormattedDate(party.startTime),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        party.isTBA
                            ? ''
                            : DateTimeUtils.getFormattedTime(party.startTime),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),

                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text('end time: ${DateTimeUtils.getFormattedTime(party.guestListEndTime)}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),

                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                    image: DecorationImage(
                      image: NetworkImage(party.imageUrl),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
