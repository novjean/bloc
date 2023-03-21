
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/offer.dart';
import '../../../db/entity/product.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class AddProductOfferScreen extends StatefulWidget {
  Product product;

  AddProductOfferScreen({key, required this.product}):super(key: key);

  @override
  _AddProductOfferScreenState createState() => _AddProductOfferScreenState();
}

class _AddProductOfferScreenState extends State<AddProductOfferScreen> {
  bool isPhotoChanged = false;
  late String oldImageUrl;
  late String newImageUrl;

  String offerDescription = '';
  double offerPercent = 0;
  bool isCommunityOffer = true;
  bool isPrivateOffer = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('product | offer'),),
    body: _buildBody(context),
  );

  _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 24),
        TextFormField(
          key: const ValueKey('product_name'),
          initialValue: widget.product.name,
          enabled: false,
          autocorrect: false,
          textCapitalization: TextCapitalization.words,
          enableSuggestions: false,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'product name',
          ),
        ),

        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'offer %',
          text: '',
          onChanged: (textPercent) {
            offerPercent = StringUtils.getDouble(textPercent);
            },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'description',
          text: 'enter the offer description here for notification purpose',
          maxLines: 5,
          onChanged: (value) {
            offerDescription = value;
          },
        ),

        const SizedBox(height: 24),
        Row(
          children: <Widget>[ //SizedBox
            Text(
              'offer for private : ',
              style: TextStyle(fontSize: 17.0),
            ), //Text
            const SizedBox(width: 10), //SizedBox
            Checkbox(
              value: isPrivateOffer,
              onChanged: (value) {
                setState(() {
                  isPrivateOffer = value!;
                });
              },
            ), //Checkbox
          ], //<Widget>[]
        ),

        // const SizedBox(height: 24),
        TextFormField(
          key: const ValueKey('current_price'),
          initialValue: widget.product.price.toString(),
          enabled: false,
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: false,
          validator: (value) {
            if (value!.isEmpty) {
              return 'please enter a valid price for the product';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'current price',
          ),
        ),

        const SizedBox(height: 24),
        TextFormField(
          key: const ValueKey('offer_price'),
          initialValue: widget.product.price.toString(),
          autocorrect: false,
          enabled: false,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: false,
          validator: (value) {
            if (value!.isEmpty) {
              return 'please enter a valid price for the product';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'offer price',
          ),
          onChanged: (value) {
            double? newPrice = double.tryParse(value);
            widget.product = widget.product.copyWith(price: newPrice);
          },
        ),

        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            Text(
              'offer for community : ',
              style: TextStyle(fontSize: 17.0),
            ), //Text
            SizedBox(width: 10), //SizedBox
            Checkbox(
              value: isCommunityOffer,
              onChanged: (value) {
                setState(() {
                  isCommunityOffer = value!;
                });
              },
            ), //Checkbox
          ], //<Widget>[]
        ),
        TextFormField(
          key: const ValueKey('product_price_community'),
          initialValue: widget.product.priceCommunity.toString(),
          autocorrect: false,
          enabled: false,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: false,
          validator: (value) {
            if (value!.isEmpty) {
              return 'please enter a valid community price for the product';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'community price',
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          key: const ValueKey('offer_price_community'),
          initialValue: widget.product.priceCommunity.toString(),
          autocorrect: false,
          enabled: false,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: false,
          validator: (value) {
            if (value!.isEmpty) {
              return 'please enter a valid community price for the product';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'offer community price',
          ),
        ),
        const SizedBox(height: 24),

        ButtonWidget(
          text: 'save',
          onClicked: () {
            String offerId = StringUtils.getRandomString(20);
            int creationMilliSec =
                Timestamp.now().millisecondsSinceEpoch;

            double newPriceCommunity = widget.product.priceCommunity;
            if(isCommunityOffer) {
              newPriceCommunity = widget.product.priceCommunity - (widget.product.priceCommunity * (offerPercent/100));
            }

            double newPricePrivate = widget.product.price;
            if(isPrivateOffer) {
              newPricePrivate = widget.product.price - (widget.product.price * (offerPercent/100));
            }

            // lets keep the end time to be irrelevant for now
            // trying to keep the logic to be manual for now
            // later on work on automation.
            Offer offer = Offer(
                id: offerId,
                blocServiceId: widget.product.serviceId,
                productId: widget.product.id,
                productName: widget.product.name,
                offerPercent: offerPercent,
                isCommunityOffer: isCommunityOffer,
                offerPriceCommunity: newPriceCommunity,
                isPrivateOffer: isPrivateOffer,
                offerPricePrivate: newPricePrivate,
                description: offerDescription,
                isActive: true,
                creationTime: creationMilliSec,
                endTime: creationMilliSec);
            FirestoreHelper.pushOffer(offer);

            widget.product.isOfferRunning = true;
            Product freshProduct = Fresh.freshProduct(widget.product);
            FirestoreHelper.pushProduct(freshProduct);

            // FirestoreHelper.setProductOfferRunning(widget.product.id, true);

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

