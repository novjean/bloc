import 'package:bloc/db/entity/quick_order.dart';
import 'package:bloc/db/entity/quick_table.dart';
import 'package:bloc/db/shared_preferences/table_preferences.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/utils/logx.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/toaster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';

import 'package:bloc/db/entity/user.dart' as blocUser;
import '../db/entity/cart_item.dart';
import '../db/entity/offer.dart';
import '../db/entity/product.dart';
import '../db/entity/promoter_guest.dart';
import '../helpers/dummy.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../main.dart';
import '../providers/cart.dart';
import '../routes/route_constants.dart';
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
                                    fontSize: 19,
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
                                fontSize: 15,
                                color: Theme.of(context).primaryColorDark)),
                        const SizedBox(
                          height: 2,
                        ),

                        // widget.isCustomerSeated
                        //     ? showAddMinusButtons(cart)
                        //     : const SizedBox(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ButtonWidget(
                              text: 'order',
                              onClicked: () {
                                handleOrderClicked(context);
                              },
                            ),
                          ],
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/icons/ic_bottle.png',
                                            width: 15,
                                            height: 15,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 2.0),
                                            child: Text(
                                                widget.product.priceBottle
                                                    .toStringAsFixed(0),
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          )
                                        ],
                                      )
                                    : const SizedBox(),
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

  void handleOrderClicked(BuildContext context) {
    if (UserPreferences.isUserLoggedIn()) {
      if(TablePreferences.isUserQuickSeated()){
        blocUser.User user = UserPreferences.myUser;

        String tableName = TablePreferences.getQuickTable();


        QuickOrder quickOrder = Dummy.getDummyQuickOrder();
        quickOrder = quickOrder.copyWith(
            custId: user.id,
            table: tableName,
            custPhone: user.phoneNumber,
            productId: widget.product.id);
        FirestoreHelper.pushQuickOrder(quickOrder);
      } else {
        LayoutUtils layoutUtils = LayoutUtils(context: context,
            blocServiceId: widget.serviceId);
        layoutUtils.showTableSelectBottomSheet();
      }
    } else {
      // LoginUtils loginUt.showLoginDialog(context);
      
      if(kIsWeb){
        _showPhoneNumberDialog(context);
      } else {
        _showQuickLoginDialog(context);
      }
    }
  }

  void _showQuickLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctxDialog) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          backgroundColor: Constants.background,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: SizedBox(
            height: mq.height * 0.4,
            width: mq.width * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('please provide phone number 📱',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Constants.lightPrimary,
                        fontWeight: FontWeight.w500)),

                //for adding some space
                SizedBox(height: mq.height * .02),

                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 0, right: 20, left: 20),
                    child: IntlPhoneField(
                      style: const TextStyle(
                          color: Constants.primary, fontSize: 20),
                      decoration: const InputDecoration(
                          labelText: 'phone number',
                          labelStyle: TextStyle(color: Constants.primary),
                          hintStyle: TextStyle(color: Constants.primary),
                          counterStyle: TextStyle(color: Constants.primary),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Constants.primary),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Constants.primary, width: 0.0),
                          )),
                      controller: _controller,
                      initialCountryCode: 'IN',
                      dropdownTextStyle: const TextStyle(color: Constants.primary, fontSize: 20),
                      pickerDialogStyle: PickerDialogStyle(backgroundColor: Constants.primary),
                      onChanged: (phone) {
                        Logx.i(_TAG, phone.completeNumber);
                        completePhoneNumber = phone.completeNumber;

                        if (phone.number.length == maxPhoneNumberLength) {
                          _verifyPhone(completePhoneNumber);
                        }
                      },
                      onCountryChanged: (country) {
                        Logx.i(_TAG, 'country changed to: ${country.name}');
                        maxPhoneNumberLength = country.maxLength;
                      },
                    ),
                  ),
                ),

                SizedBox(height: mq.height * .02),

                Text('please enter otp sent to $completePhoneNumber ⏳',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Constants.lightPrimary,
                        fontWeight: FontWeight.w500)),

                //for adding some space
                SizedBox(height: mq.height * .02),

                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 0, right: 20, left: 20),
                    child: OTPVerifyWidget(completePhoneNumber, ctxDialog),
                  ),
                ),
              ],
            ),
          ),
          actions: [

          ],
        );
      },
    );
  }

  void _showPhoneNumberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          backgroundColor: Constants.background,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: SizedBox(
            height: mq.height * 0.2,
            width: mq.width * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('please provide phone number 📱',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Constants.lightPrimary,
                    fontWeight: FontWeight.w500)),

            SizedBox(height: mq.height * .02),

            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 0, right: 20, left: 20),
                child: IntlPhoneField(
                  style: const TextStyle(
                      color: Constants.primary, fontSize: 20),
                  decoration: const InputDecoration(
                      labelText: 'phone number',
                      labelStyle: TextStyle(color: Constants.primary),
                      hintStyle: TextStyle(color: Constants.primary),
                      counterStyle: TextStyle(color: Constants.primary),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Constants.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Constants.primary, width: 0.0),
                      )),
                  controller: _controller,
                  initialCountryCode: 'IN',
                  dropdownTextStyle: const TextStyle(color: Constants.primary, fontSize: 20),
                  pickerDialogStyle:
                  PickerDialogStyle(backgroundColor: Constants.primary),
                  onChanged: (phone) {
                    Logx.i(_TAG, phone.completeNumber);
                    completePhoneNumber = phone.completeNumber;

                    if (phone.number.length == maxPhoneNumberLength) {
                      _verifyPhone(completePhoneNumber);

                      if(kIsWeb){
                        Navigator.of(context).pop();
                        _showOtpDialog(context);
                      }
                    }
                  },
                  onCountryChanged: (country) {
                    Logx.i(_TAG, 'country changed to: ${country.name}');
                    maxPhoneNumberLength = country.maxLength;
                  },
                ),
              ),
            ),

            ],
            ),
          ),
          actions: [
            // mLounge.name.isNotEmpty? TextButton(
            //   child: const Text("request access"),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //     UserLounge userLounge = Dummy.getDummyUserLounge();
            //     userLounge = userLounge.copyWith(userId :UserPreferences.myUser.id,
            //         loungeId: mLounge.id, isAccepted: false);
            //     FirestoreHelper.pushUserLounge(userLounge);
            //     Toaster.longToast('request to join the vip lounge has been sent');
            //     Logx.i(_TAG, 'user requested to join the vip lounge');
            //     GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
            //   },
            // ): const SizedBox(),
            // TextButton(
            //   child: const Text("exit"),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //     GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
            //   },
            // ),
          ],
        );
      },
    );
  }

  _verifyPhone(String completePhoneNumber) async {
    if (kIsWeb) {
      await FirebaseAuth.instance
          .signInWithPhoneNumber(completePhoneNumber, null)
          .then((user) {
        Logx.i(_TAG,
            'signInWithPhoneNumber: user verification id ${user.verificationId}');

        Logx.ist(_TAG, 'otp code has been sent to $completePhoneNumber');

        UserPreferences.setVerificationId(user.verificationId);

        // setState(() {
        //   _verificationCode = user.verificationId;
        // });
      }).catchError((e, s) {
        Logx.e(_TAG, e, s);
      });
    } else {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: completePhoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            Logx.i(_TAG,
                'verifyPhoneNumber: $completePhoneNumber is verified. attempting sign in with credentials...');
          },
          verificationFailed: (FirebaseAuthException e) {
            Logx.i(_TAG, 'verificationFailed $e');
          },
          codeSent: (String verificationID, int? resendToken) {
            Logx.i(_TAG, 'verification id : $verificationID');
            Logx.ist(_TAG, 'otp code has been sent to $completePhoneNumber');

            UserPreferences.setVerificationId(verificationID);

            // if (mounted) {
            //   setState(() {
            //     _verificationCode = verificationID;
            //   });
            // }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // if (mounted) {
            //   setState(() {
            //     _verificationCode = verificationId;
            //   });
            // }
          },
          timeout: const Duration(seconds: 60));
    }
  }

  void _showOtpDialog(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext ctxDialog) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          backgroundColor: Constants.background,
          content: SizedBox(
            height: mq.height * 0.2,
            width: mq.width * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //pick profile picture label
                Text('please enter otp sent to $completePhoneNumber ⏳',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Constants.lightPrimary,
                        fontWeight: FontWeight.w500)),

                //for adding some space
                SizedBox(height: mq.height * .02),

                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 0, right: 20, left: 20),
                    child: OTPVerifyWidget(completePhoneNumber, ctxDialog),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // TextButton(
            //   child: const Text("exit"),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //     GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
            //   },
            // ),
          ],
        );
      },
    );
  }

  OTPVerifyWidget(String phone, BuildContext ctxDialog) {
    const focusedBorderColor = Color.fromRGBO(222, 193, 170, 1);
    const fillColor = Color.fromRGBO(38, 50, 56, 1.0);
    const borderColor = Color.fromRGBO(211, 167, 130, 1);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(222, 193, 170, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Pinput(
              length: 6,
              controller: pinController,
              focusNode: focusNode,
              listenForMultipleSmsOnAndroid: true,
              defaultPinTheme: defaultPinTheme,
              closeKeyboardWhenCompleted: true,
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (pin) async {
                debugPrint('onCompleted: $pin');

                String verificationCode = UserPreferences.getVerificationId();

                Toaster.shortToast('verifying $phone');
                try {
                  await FirebaseAuth.instance
                      .signInWithCredential(PhoneAuthProvider.credential(
                          verificationId: verificationCode, smsCode: pin))
                      .then((value) async {
                    if (value.user != null) {
                      Logx.i(_TAG, 'user is in firebase auth');

                      String? fcmToken = '';

                      if (!kIsWeb) {
                        fcmToken = await FirebaseMessaging.instance.getToken();
                      }

                      Logx.i(_TAG,
                          'checking for bloc registration by id ${value.user!.uid}');

                      FirestoreHelper.pullUser(value.user!.uid).then((res) {
                        if (res.docs.isEmpty) {
                          Logx.i(_TAG,
                              'checking for bloc registration by phone $completePhoneNumber');

                          int phoneNumber =
                              StringUtils.getInt(completePhoneNumber);
                          FirestoreHelper.pullUserByPhoneNumber(phoneNumber)
                              .then((res) {
                            if (res.docs.isNotEmpty) {
                              DocumentSnapshot document = res.docs[0];
                              Map<String, dynamic> data =
                                  document.data()! as Map<String, dynamic>;
                              blocUser.User user =
                                  Fresh.freshUserMap(data, true);

                              String oldUserDocId = user.id;
                              FirestoreHelper.deleteUser(oldUserDocId);

                              FirestoreHelper.pullPromoterGuestsByBlocUserId(
                                      user.id)
                                  .then((res) {
                                if (res.docs.isNotEmpty) {
                                  for (int i = 0; i < res.docs.length; i++) {
                                    DocumentSnapshot document = res.docs[i];
                                    Map<String, dynamic> data = document.data()!
                                        as Map<String, dynamic>;
                                    final PromoterGuest pg =
                                        Fresh.freshPromoterGuestMap(
                                            data, false);
                                    pg.copyWith(blocUserId: value.user!.uid);
                                    FirestoreHelper.pushPromoterGuest(pg);
                                  }
                                }
                              });

                              user = user.copyWith(
                                  id: value.user!.uid, fcmToken: fcmToken);
                              FirestoreHelper.pushUser(user);

                              UserPreferences.setUser(user);
                              Navigator.of(ctxDialog).pop();

                              LayoutUtils layoutUtils = LayoutUtils(context: context,
                                  blocServiceId: widget.serviceId);
                              layoutUtils.showTableSelectBottomSheet();

                              Logx.ist(_TAG, 'hey there, welcome to bloc! 🦖');
                            } else {
                              Logx.i(_TAG,
                                  'user is not already registered in bloc, registering...');

                              blocUser.User registeredUser = Dummy.getDummyUser();
                              registeredUser.copyWith(
                                  id: value.user!.uid,
                                  phoneNumber: StringUtils.getInt(
                                      value.user!.phoneNumber!),
                                  fcmToken: fcmToken!);

                              UserPreferences.setUser(registeredUser);
                              Navigator.of(ctxDialog).pop();

                              LayoutUtils layoutUtils = LayoutUtils(context: context,
                                  blocServiceId: widget.serviceId);
                              layoutUtils.showTableSelectBottomSheet();

                              Logx.ist(_TAG, 'hey there, welcome to bloc! 🦖');
                            }
                          });
                        } else {
                          Logx.i(_TAG,
                              'user is a bloc member. navigating to main...');

                          DocumentSnapshot document = res.docs[0];
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;

                          blocUser.User user;
                          if (kIsWeb) {
                            user = Fresh.freshUserMap(data, true);
                          } else {
                            user = Fresh.freshUserMap(data, false);
                            user.fcmToken = fcmToken!;
                            FirestoreHelper.pushUser(user);
                          }
                          UserPreferences.setUser(user);

                          Navigator.of(ctxDialog).pop();

                          LayoutUtils layoutUtils = LayoutUtils(context: context,
                              blocServiceId: widget.serviceId);
                          layoutUtils.showTableSelectBottomSheet();

                          Logx.ist(_TAG,
                              'hey ${user.name.toLowerCase()}, welcome back! 🦖');
                        }
                      });
                    }
                  });
                } catch (e) {
                  Logx.em(_TAG, 'otp error $e');

                  String exception = e.toString();
                  if (exception.contains('session-expired')) {
                    Logx.ist(_TAG,'session got expired, trying again');
                    // _verifyPhone(completePhoneNumber);
                    Navigator.pop(context);
                  } else {
                    Toaster.shortToast('invalid otp, please try again');
                  }
                  FocusScope.of(context).unfocus();
                }
              },
              onChanged: (value) {
                debugPrint('onChanged: $value');
              },
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    width: 22,
                    height: 1,
                    color: focusedBorderColor,
                  ),
                ],
              ),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              errorPinTheme: defaultPinTheme.copyBorderWith(
                border: Border.all(color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
