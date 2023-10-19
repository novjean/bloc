import 'package:bloc/db/entity/tix_tier_item.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class BuyTixTierItem extends StatefulWidget {
  TixTier tixTier;

  BuyTixTierItem({Key? key, required this.tixTier}) : super(key: key);

  @override
  State<BuyTixTierItem> createState() => _BuyTixTierItemState();
}

class _BuyTixTierItemState extends State<BuyTixTierItem> {
  static const String _TAG = 'BuyTixTierItem';

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
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.tixTier.tixTierPrice.toStringAsFixed(2)),
                    Text(widget.tixTier.tixTierCount.toString()),
                  ],
                ),
                trailing: Text(widget.tixTier.tixTierTotal.toStringAsFixed(2)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
