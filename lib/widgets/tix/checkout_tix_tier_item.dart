import 'package:bloc/db/entity/tix_tier_item.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class CheckoutTixTierItem extends StatefulWidget {
  TixTier tixTier;

  CheckoutTixTierItem({Key? key, required this.tixTier}) : super(key: key);

  @override
  State<CheckoutTixTierItem> createState() => _CheckoutTixTierItemState();
}

class _CheckoutTixTierItemState extends State<CheckoutTixTierItem> {
  static const String _TAG = 'CheckoutTixTierItem';

  int quantity = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
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
                // leading: FadeInImage(
                //   placeholder: const AssetImage(
                //       'assets/icons/logo.png'),
                //   image: NetworkImage(tixTier.imageUrl),
                //   fit: BoxFit.cover,),
                title: RichText(
                  text: TextSpan(
                    text: widget.tixTier.tixTierName,
                    style: const TextStyle(
                        fontFamily: Constants.fontDefault,
                        color: Colors.black,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                subtitle: RichText(
                  maxLines: 1,
                  text: TextSpan(
                      text:
                      '${widget.tixTier.tixTierPrice.toStringAsFixed(2)} x ',
                      style: const TextStyle(
                          color: Colors.black,
                          fontFamily: Constants.fontDefault,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                      children: <TextSpan>[
                        TextSpan(text:widget.tixTier.tixTierCount.toString(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontFamily:
                                Constants.fontDefault,
                                fontSize: 14,
                                fontWeight: FontWeight.normal)),
                      ]),
                ),
                trailing: Text('${StringUtils.rs} ${widget.tixTier.tixTierTotal.toStringAsFixed(2)}',),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
