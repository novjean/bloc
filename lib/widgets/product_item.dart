import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/toaster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/entity/cart_item.dart';
import '../db/entity/offer.dart';
import '../db/entity/product.dart';
import '../providers/cart.dart';
import '../screens/bloc/product_detail_screen.dart';
import '../utils/string_utils.dart';

class ProductItem extends StatefulWidget {
  final Product product;
  final String serviceId;
  final int tableNumber;
  final bool isCommunity;
  final bool isOnOffer;
  final Offer offer;
  final bool isCustomerSeated;
  int addCount = 1;

  ProductItem(
      {Key? key, required this.serviceId,
      required this.product,
      required this.tableNumber,
      required this.isCommunity,
      required this.isOnOffer,
      required this.offer,
      required this.isCustomerSeated}) : super(key: key);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);

    Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      margin: const EdgeInsets.only(bottom: 1.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => ProductDetailScreen(product: widget.product)),
          );
        },
        child: Hero(
          tag: widget.product.id,
          child: Card(
            color: Theme.of(context).primaryColorLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                widget.product.imageUrl.isNotEmpty
                    ? Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(widget.product.imageUrl),
                              fit: BoxFit.fitHeight
                              // AssetImage(food['image']),
                              ),
                        ),
                      )
                    : const SizedBox(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 1, bottom: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  widget.product.name.toLowerCase(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                flex: 4,
                              ),
                              Flexible(
                                child: widget.isOnOffer
                                    ? Text(
                                        widget.isCommunity
                                            ? widget.offer.offerPriceCommunity
                                                .toStringAsFixed(0)
                                            : widget.offer.offerPricePrivate
                                                .toStringAsFixed(0),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500))
                                    : Text(
                                        widget.isCommunity
                                            ? widget.product.priceCommunity
                                                .toStringAsFixed(0)
                                            : widget.product.price
                                                .toStringAsFixed(0),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                flex: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        widget.isCommunity
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //\u20B9
                                  Text(
                                      widget.product.priceLowest
                                          .toStringAsFixed(0),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                  Text(' | '),
                                  Text(
                                      widget.product.priceHighest
                                          .toStringAsFixed(0),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent)),
                                  widget.isOnOffer
                                      ? Text(
                                          ' | ' +
                                              widget.offer.offerPercent
                                                  .toStringAsFixed(0) +
                                              '% off',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        )
                                      : const SizedBox(height: 0),
                                ],
                              )
                            : widget.isOnOffer
                                ? Text(
                                    ' | ' +
                                        widget.offer.offerPercent
                                            .toStringAsFixed(0) +
                                        '% off',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  )
                                : const SizedBox(height: 0),
                        const SizedBox(height: 2),
                        Text(
                            StringUtils.firstFewWords(
                                widget.product.description.toLowerCase(), 20)
                                + (StringUtils.getWordCount(widget.product.description) > 20 ? ' ...' : ''),
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColorDark)),
                        const SizedBox(height: 2,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Spacer(),
                            widget.isCustomerSeated
                                ? IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        if (widget.addCount > 1) {
                                          widget.addCount--;
                                          print('decrement add count to ' +
                                              widget.addCount.toString());
                                        } else {
                                          print('add count is at ' +
                                              widget.addCount.toString());
                                        }
                                      });
                                    },
                                  )
                                : SizedBox(),
                            widget.isCustomerSeated
                                ? Container(
                                    // color: primaryColor,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 0.0,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                      horizontal: 0.0,
                                    ),
                                    child: ButtonWidget(
                                      text: widget.addCount == 1
                                          ? 'add'
                                          : 'add ' + widget.addCount.toString(),
                                      onClicked: () {
                                        //check if customer is seated
                                        widget.isCustomerSeated
                                            ? addProductToCart(cart)
                                            : alertUserTable(context);
                                      },
                                    ))
                                : const SizedBox(),
                            widget.isCustomerSeated
                                ? IconButton(
                                    icon: const Icon(Icons.add),
                                    color: primaryColor,
                                    onPressed: () {
                                      setState(() {
                                        widget.addCount++;
                                      });
                                      print('increment add count to ' +
                                          widget.addCount.toString());
                                    },
                                  )
                                : const SizedBox(),
                            const SizedBox(width: 10),
                            widget.product.type == 'Food'
                                ? Image.asset(widget.product.isVeg
                                ? 'assets/icons/ic_veg_food.png'
                                : 'assets/icons/ic_non_veg_food.png',
                              width: 15, height: 15,)
                                : const SizedBox(width: 0),
                          ],
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  addProductToCart(Cart cart) {
    // add it to the cart
    String cartId = StringUtils.getRandomString(20);
    //todo: this needs to increment
    int cartNumber = 0;
    final user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;
    int timestamp = Timestamp.now().millisecondsSinceEpoch;
    CartItem cartItem = CartItem(
        cartId: cartId,
        serviceId: widget.serviceId,
        billId: '',
        tableNumber: widget.tableNumber,
        cartNumber: cartNumber,
        userId: userId,
        productId: widget.product.id,
        productName: widget.product.name,
        productPrice: double.parse(widget.isCommunity
            ? widget.product.priceCommunity.toString()
            : widget.product.price.toString()),
        isCommunity: widget.isCommunity,
        quantity: widget.addCount,
        createdAt: timestamp,
        isCompleted: false,
        isBilled: false);

    cart.addItem(
        cartId,
        widget.serviceId,
        cartItem.billId,
        widget.tableNumber,
        cartNumber,
        cartItem.userId,
        cartItem.productId,
        cartItem.productName,
        cartItem.productPrice,
        widget.isCommunity,
        cartItem.quantity,
        cartItem.createdAt,
        cartItem.isCompleted,
        cartItem.isBilled);

    setState(() {
      widget.addCount = 1;
    });

    Toaster.shortToast(widget.product.name.toLowerCase() + ' is added to cart');
  }

  alertUserTable(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('select table'),
        content: Text(
          'please select your table by clicking on the scan/table icon in the title section above before adding items',
        ),
        actions: [
          ElevatedButton(
            child: Text('ok'),
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
          ),
        ],
      ),
    );
  }
}
