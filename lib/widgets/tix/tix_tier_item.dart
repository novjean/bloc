import 'package:flutter/material.dart';

import '../../db/entity/party_tix_tier.dart';
import '../../utils/constants.dart';

class TixTierItem extends StatefulWidget{
  static const String _TAG = 'TixTierItem';

  PartyTixTier tixTier;

  TixTierItem({Key? key, required this.tixTier}) : super(key: key);

  @override
  State<TixTierItem> createState() => _TixTierItemState();
}

class _TixTierItemState extends State<TixTierItem> {
  int quantity = 0;

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                      text: widget.tixTier.tierName,
                      style: const TextStyle(
                          fontFamily: Constants.fontDefault,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  subtitle:Text(widget.tixTier.tierDescription),
                  trailing: !widget.tixTier.isSoldOut ? DropdownButton<int>(
                    value: quantity,
                    items: List<DropdownMenuItem<int>>.generate(10, (int index) {
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text((index).toString()),
                      );
                    }),
                    onChanged: (newValue) {
                      setState(() {
                        quantity = newValue!;
                      });
                    },
                  ): Text('sold')

                )),
          ),
        ),
      ),
    );
  }
}