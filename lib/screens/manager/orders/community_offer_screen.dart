import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/product.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:bloc/widgets/ui/center_text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/offer.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/number_utils.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class CommunityOfferScreen extends StatefulWidget {
  CartItem cartItem;

  CommunityOfferScreen({key, required this.cartItem}) : super(key: key);

  @override
  _CommunityOfferScreenState createState() => _CommunityOfferScreenState();
}

class _CommunityOfferScreenState extends State<CommunityOfferScreen> {
  late Product? _product;
  late double _priceDifference;
  late double _oldPriceCommunity;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    FirestoreHelper.pullProduct(widget.cartItem.productId).then((res) {
      print("Successfully retrieved product");
      for (int i = 0; i < res.docs.length; i++) {
        DocumentSnapshot document = res.docs[i];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        final Product product = Product.fromMap(data);

        if (i == res.docs.length - 1) {
          setProduct(product);
        }
      }
    });
  }

  void setProduct(Product? product) {
    setState(() {
      _product = product;
      _priceDifference = _product!.priceCommunity - _product!.price;
      _oldPriceCommunity = _product!.priceCommunity;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Community | Offer'),
        ),
        body: _isLoading
            ? CenterTextWidget(text: 'Loading product...')
            : _buildBody(context),
      );

  _buildBody(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 32),
      physics: BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        TextFieldWidget(
          label: 'Product Name',
          text: _product!.name,
          onChanged: (name) => _product = _product,
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Community Price',
          text: _product!.priceCommunity.toStringAsFixed(2),
          onChanged: (value) {
            double? newPrice = double.tryParse(value);
            _product = _product!.copyWith(priceCommunity: newPrice);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Price Difference',
          text: _priceDifference.toStringAsFixed(2),
          onChanged: (value) {},
        ),
        const SizedBox(height: 24),
        // TextFieldWidget(
        //   label: 'Offer %',
        //   text: _offerPercentage.toStringAsFixed(2),
        //   onChanged: (value) {
        //     double? offerPercentage = double.tryParse(value);
        //     // double curPrice = _product!.priceCommunity;
        //     // double discount = curPrice * (offerPercentage!/100);
        //     // double newPrice = curPrice - discount;
        //     // _product = _product!.copyWith(priceCommunity: newPrice);
        //   },
        // ),
        // const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Lowest Price',
          text: _product!.priceLowest.toStringAsFixed(2),
          onChanged: (value) {
            double? newPrice = double.tryParse(value);
            _product = _product!.copyWith(priceLowest: newPrice);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Highest Price',
          text: _product!.priceHighest.toStringAsFixed(2),
          onChanged: (value) {
            double? newPrice = double.tryParse(value);
            _product = _product!.copyWith(priceHighest: newPrice);
          },
        ),
        const SizedBox(height: 24),

        ButtonWidget(
          text: 'Save',
          onClicked: () {
            // check if a price change has been taken place
            if (_product!.priceCommunity >= _oldPriceCommunity) {
              //the price has not changed or gone up
              // todo: notify users that the price is expected to go up, so buy quick
              FirestoreHelper.updateProduct(_product!);
              Navigator.of(context).pop();
            } else {
              double discountPercent = 100 -
                  NumberUtils.getPercentage(
                      _product!.priceCommunity, _oldPriceCommunity);

              // todo: we will need to ask for the time or pull it in from one of the fields

              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: Text("Offer Confirm"),
                    content: Text(discountPercent.toStringAsFixed(0) +
                        "% discount has been offered. Is this correct?"),
                    actions: [
                      TextButton(
                        child: Text("Yes"),
                        onPressed: () async {
                          // we should not change the price directly, instead use offer object
                          // FirestoreHelper.updateProduct(_product!);

                          //now we need to notify from here
                          String offerId = StringUtils.getRandomString(20);
                          int creationMilliSec =
                              Timestamp.now().millisecondsSinceEpoch;

                          DateTime initialDate = DateTime.now();
                          DateTime? pickedDay = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            lastDate: DateTime(2025),
                            firstDate: initialDate,
                          );

                          TimeOfDay initialTime = TimeOfDay.now();
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: initialTime,
                          );

                          DateTime endDT = DateTime(
                              pickedDay!.year,
                              pickedDay.month,
                              pickedDay.day,
                              pickedTime!.hour,
                              pickedTime.minute);

                          Offer offer = Offer(
                              id: offerId,
                              blocId: _product!.serviceId,
                              productId: _product!.id,
                              productName: _product!.name,
                              isCommunityOffer: true,
                              isPrivateOffer: false,
                              offerPercent: discountPercent,
                              offerPriceCommunity: _product!.priceCommunity,
                              offerPricePrivate: _product!.price,
                              isActive: true,
                              description: 'Community offer, from us to you!', // need to figure out a good logic for this
                              creationTime: creationMilliSec,
                              endTime: endDT.millisecondsSinceEpoch);
                          FirestoreHelper.insertOffer(offer);

                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      )
                    ],
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }
}
