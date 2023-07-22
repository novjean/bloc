import 'package:bloc/db/entity/quick_order.dart';
import 'package:bloc/db/shared_preferences/table_preferences.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/utils/logx.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/dark_button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:bloc/db/entity/user.dart' as blocUser;
import '../db/entity/cart_item.dart';
import '../db/entity/offer.dart';
import '../db/entity/product.dart';
import '../helpers/dummy.dart';
import '../helpers/firestore_helper.dart';
import '../providers/cart.dart';
import '../screens/bloc/product_detail_screen.dart';
import '../utils/constants.dart';
import '../utils/layout_utils.dart';
import '../utils/login_utils.dart';
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
      {Key? key,
      required this.serviceId,
      required this.product,
      required this.tableNumber,
      required this.isCommunity,
      required this.isOnOffer,
      required this.offer,
      required this.isCustomerSeated})
      : super(key: key);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  static const String _TAG = 'ProductItem';

  final TextEditingController _controller = TextEditingController();
  String completePhoneNumber = '';
  int maxPhoneNumberLength = 10;

  final formKey = GlobalKey<FormState>();
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  int quantity = 1;

  @override
  void dispose() {
    // _controller.dispose();
    // pinController.dispose();
    // focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final cart = Provider.of<Cart>(context, listen: false);

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
            color: Constants.lightPrimary,
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
                              fit: BoxFit.cover
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
                                flex: 4,
                                child: Text(
                                  widget.product.name.toLowerCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 1,
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
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            widget.product.type == 'Food'
                                ? Image.asset(
                              widget.product.isVeg
                                  ? 'assets/icons/ic_veg_food.png'
                                  : 'assets/icons/ic_non_veg_food.png',
                              width: 15,
                              height: 15,
                            )
                                : widget.product.priceBottle != 0
                                ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/icons/ic_bottle.png',
                                  width: 15,
                                  height: 15,
                                ),
                                Text(
                                    widget.product.priceBottle
                                        .toStringAsFixed(0),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))
                              ],
                            )
                                : const SizedBox(),
                          ],
                        ),
                        // const SizedBox(height: 5),
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
                                  const Text(' | '),
                                  Text(
                                      widget.product.priceHighest
                                          .toStringAsFixed(0),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent)),
                                  widget.isOnOffer
                                      ? Text(
                                          ' | ${widget.offer.offerPercent.toStringAsFixed(0)}% off',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        )
                                      : const SizedBox(),
                                ],
                              )
                            : widget.isOnOffer
                                ? Text(
                                    ' | ${widget.offer.offerPercent.toStringAsFixed(0)}% off',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  )
                                : const SizedBox(),
                        const SizedBox(height: 2),
                        Text(widget.product.description.toLowerCase(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).primaryColorDark)),

                        // widget.isCustomerSeated
                        //     ? showAddMinusButtons(cart)
                        //     : const SizedBox(),

                        Padding(
                          padding: const EdgeInsets.only(top:5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Ink(
                                decoration: ShapeDecoration(
                                  color: Theme.of(context).primaryColorLight,
                                  shape: const CircleBorder(
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.remove),
                                  splashRadius: 10.0,
                                  color: Colors.black,
                                  onPressed: () {
                                    setState(() {

                                      if (quantity > 1) {
                                        quantity--;
                                      }
                                    });
                                  },
                                ),
                              ),
                              Container(
                                // color: primaryColor,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2.0, horizontal: 10),
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20.0),
                                child: Ink(
                                  decoration: ShapeDecoration(
                                    color: Theme.of(context).primaryColorLight,
                                    shape: const CircleBorder(),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.add),
                                    splashRadius: 10.0,
                                    color: Colors.black87,
                                    onPressed: () {
                                      setState(() {
                                        quantity++;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              DarkButtonWidget(
                                text: 'order',
                                onClicked: () {
                                  handleOrderClicked(context, quantity);

                                  setState(() {
                                    quantity = 1;
                                  });
                                },
                              ),
                            ],
                          ),
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

    Logx.ist(_TAG, '${widget.product.name.toLowerCase()} is added to cart');
  }

  alertUserTable(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('select table'),
        content: const Text(
          'please select your table by clicking on the scan/table icon in the title section above before adding items',
        ),
        actions: [
          ElevatedButton(
            child: const Text('ok'),
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
          ),
        ],
      ),
    );
  }

  showAddMinusButtons(Cart cart) {
    Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              setState(() {
                if (widget.addCount > 1) {
                  widget.addCount--;
                  Logx.i(_TAG, 'decrement add count to ${widget.addCount}');
                } else {
                  Logx.i(_TAG, 'add count is at ${widget.addCount}');
                }
              });
            },
          ),
          Container(
              // color: primaryColor,
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
              ),
              child: ButtonWidget(
                text: widget.addCount == 1 ? 'add' : 'add ${widget.addCount}',
                onClicked: () {
                  //check if customer is seated
                  widget.isCustomerSeated
                      ? addProductToCart(cart)
                      : alertUserTable(context);
                },
              )),
          IconButton(
            icon: const Icon(Icons.add),
            color: Constants.primary,
            onPressed: () {
              setState(() {
                widget.addCount++;
              });
              Logx.i(_TAG, 'increment add count to ${widget.addCount}');
            },
          )
        ],
      ),
    );
  }

  void handleOrderClicked(BuildContext context, int quantity) {
    if (UserPreferences.isUserLoggedIn()) {
      if(TablePreferences.isUserQuickSeated()){
        blocUser.User user = UserPreferences.myUser;

        String tableName = TablePreferences.getQuickTableName();

        QuickOrder quickOrder = Dummy.getDummyQuickOrder();
        quickOrder = quickOrder.copyWith(
            custId: user.id,
            table: tableName,
            custPhone: user.phoneNumber,
            quantity: quantity,
            productId: widget.product.id);
        FirestoreHelper.pushQuickOrder(quickOrder);
      } else {
        LayoutUtils layoutUtils = LayoutUtils(context: context,
            blocServiceId: widget.serviceId);
        layoutUtils.showTableSelectBottomSheet();
      }
    } else {
      LoginUtils loginUtils = LoginUtils(context: context);
      loginUtils.showLoginDialog();
    }
  }
}
