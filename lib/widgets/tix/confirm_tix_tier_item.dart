import 'package:bloc/db/entity/tix_tier_item.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../utils/logx.dart';

class ConfirmTixTierItem extends StatefulWidget {
  TixTier tixTier;
  bool isUser;

  ConfirmTixTierItem({Key? key, required this.tixTier, required this.isUser}) : super(key: key);

  @override
  State<ConfirmTixTierItem> createState() => _ConfirmTixTierItemState();
}

class _ConfirmTixTierItemState extends State<ConfirmTixTierItem> {
  static const String _TAG = 'ConfirmTixTierItem';

  int quantity = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: Hero(
          tag: widget.tixTier.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: '${widget.tixTier.tixTierName} ${widget.isUser? 'x ${widget.tixTier.tixTierCount}': ''} ',
                        style: const TextStyle(
                            fontFamily: Constants.fontDefault,
                            color: Colors.black,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    widget.isUser? const SizedBox(): Ink(
                      decoration: const ShapeDecoration(
                        color: Constants.primary,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            if (widget.tixTier.guestsRemaining > 0) {
                              int guestsRemaining = --widget.tixTier.guestsRemaining;
                              widget.tixTier = widget.tixTier.copyWith(guestsRemaining: guestsRemaining);

                              Logx.d(_TAG,
                                  'decrement tix count to ${widget.tixTier.guestsRemaining}');
                              FirestoreHelper.pushTixTier(widget.tixTier);
                            }
                          });
                        },
                      ),
                    ),
                    widget.isUser?const SizedBox(): Container(
                      // color: primaryColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 10),
                      child: Text(
                        widget.tixTier.guestsRemaining.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    widget.isUser? const SizedBox():Ink(
                      decoration: const ShapeDecoration(
                        color: Constants.primary,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            if (widget.tixTier.guestsRemaining < widget.tixTier.tixTierCount) {
                              int guestsRemaining = ++widget.tixTier.guestsRemaining;
                              widget.tixTier = widget.tixTier.copyWith(guestsRemaining: guestsRemaining);
                              Logx.i(_TAG,
                                  'increment tix count to ${widget.tixTier.guestsRemaining}');
                            } else {
                              Logx.ist(_TAG,
                                  'purchased only ${widget.tixTier.guestsRemaining} on this tier!');
                            }
                            FirestoreHelper.pushTixTier(widget.tixTier);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                subtitle: Text(widget.tixTier.tixTierDescription),
                trailing: Text('${StringUtils.rs} ${widget.tixTier.tixTierTotal.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}