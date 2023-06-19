import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:pinput/pinput.dart';

import '../../db/entity/celebration.dart';
import '../../db/entity/product.dart';
import '../../db/entity/ui_photo.dart';
import '../../db/entity/user.dart' as blocUser;

import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/logx.dart';
import '../../utils/string_utils.dart';
import '../../widgets/ui/button_widget.dart';
import '../../widgets/ui/dark_textfield_widget.dart';
import '../../widgets/ui/toaster.dart';
import '../main_screen.dart';

class CelebrationAddEditScreen extends StatefulWidget {
  Celebration celebration;
  String task;

  CelebrationAddEditScreen(
      {Key? key, required this.celebration, required this.task})
      : super(key: key);

  @override
  State<CelebrationAddEditScreen> createState() =>
      _CelebrationAddEditScreenState();
}

class _CelebrationAddEditScreenState extends State<CelebrationAddEditScreen> {
  static const String _TAG = 'CelebrationAddEditScreen';

  final TextEditingController _controller = TextEditingController();

  DateTime sDateArrival = DateTime.now();
  TimeOfDay sArrivalTime = TimeOfDay.now();

  List<String> guestCounts = [];
  late String sGuestCount;

  List<String> durationHours = [];
  late String sDurationHours;

  List<String> ocassions = [
    'none',
    'birthday party',
    'charity gala',
    'college party',
    'corporate event',
    'family reunion',
    'wedding party',
    'other'
  ];
  late String sOcassion;

  final pinController = TextEditingController();
  final focusNode = FocusNode();
  bool isLoggedIn = false;
  String completePhoneNumber = '';
  String _verificationCode = '';

  late blocUser.User bloc_user;
  bool isEdit = false;

  List<Product> mBottles = [];
  bool isBottlesLoading = true;
  List<String> sBottleNames = [];
  List<Product> sBottles = [];
  List<String> sBottleIds = [];

  UiPhoto uiPhoto = Dummy.getDummyUiPhoto();
  bool isUiPhotosLoading = true;

  @override
  void initState() {
    if (!UserPreferences.isUserLoggedIn()) {
      bloc_user = Dummy.getDummyUser();
    } else {
      bloc_user = UserPreferences.myUser;
    }

    if (widget.task == 'edit') {
      isEdit = true;
    }

    uiPhoto.name = 'celebration';

    guestCounts = [
      '25',
      '50',
      '100',
      '150',
      '200',
      '250',
      '300',
      '400',
      '500',
      '750',
      '1000',
      '1500'
    ];

    for (int i = 1; i <= 12; i++) {
      durationHours.add(i.toString());
    }
    sDurationHours = widget.celebration.durationHours.toString();

    sGuestCount = widget.celebration.guestsCount.toString();
    sOcassion = widget.celebration.occasion;

    sBottleIds = widget.celebration.bottleProductIds;

    if (widget.celebration.arrivalTime.isEmpty) {
      sArrivalTime = TimeOfDay.now();
    } else {
      sArrivalTime =
          DateTimeUtils.convertStringToTime(widget.celebration.arrivalTime);
    }

    FirestoreHelper.pullProductsByBottle(Constants.blocServiceId).then((res) {
      Logx.i(_TAG, "successfully pulled in all bottles");

      if (res.docs.isNotEmpty) {
        List<Product> products = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Product product = Fresh.freshProductMap(data, false);
          products.add(product);
        }

        products.sort((a, b) => a.category.compareTo(b.category));

        mBottles = products;

        for (int i = 0; i < products.length; i++) {
          Product product = products[i];
          if (sBottleIds.contains(product.id)) {
            sBottles.add(product);
            sBottleNames.add(
                '${product.name.toLowerCase()} [${product.category.toLowerCase()}]');
          }
        }

        setState(() {
          isBottlesLoading = false;
        });
      } else {
        // no bottles found
        setState(() {
          isBottlesLoading = false;
        });
      }
    });

    FirestoreHelper.pullUiPhoto(uiPhoto.name).then((res) {
      Logx.i(_TAG, 'successfully pulled in ui photos');

      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

        uiPhoto = Fresh.freshUiPhotoMap(data, false);
        setState(() {
          isUiPhotosLoading = false;
        });
      } else {
        setState(() {
          isUiPhotosLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('bloc | celebration')),
      backgroundColor: Constants.background,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return isUiPhotosLoading
        ? const LoadingWidget()
        : ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 15),
              SizedBox(
                  height: 200,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 2),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 1000),
                      enlargeCenterPage: false,
                      scrollDirection: Axis.horizontal,
                      aspectRatio: 2.0,
                    ),
                    items: uiPhoto.imageUrls
                        .map((item) => Container(
                              child: Center(
                                  child: Image.network(item,
                                      fit: BoxFit.fitWidth,
                                      width:
                                          MediaQuery.of(context).size.width)),
                            ))
                        .toList(),
                  )),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: DarkTextFieldWidget(
                    label: 'name *',
                    text: widget.celebration.name,
                    onChanged: (name) {
                      bloc_user = bloc_user.copyWith(name: name);

                      widget.celebration =
                          widget.celebration.copyWith(name: name);
                    }),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: DarkTextFieldWidget(
                    label: 'surname *',
                    text: widget.celebration.surname,
                    onChanged: (text) {
                      bloc_user = bloc_user.copyWith(surname: text);

                      widget.celebration =
                          widget.celebration.copyWith(surname: text);
                    }),
              ),
              !UserPreferences.isUserLoggedIn()
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'phone number *',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          IntlPhoneField(
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 18),
                            decoration: InputDecoration(
                                labelText: '',
                                labelStyle: TextStyle(
                                    color: Theme.of(context).primaryColor),
                                hintStyle: TextStyle(
                                    color: Theme.of(context).primaryColor),
                                counterStyle: TextStyle(
                                    color: Theme.of(context).primaryColor),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  // width: 0.0 produces a thin "hairline" border
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 0.0),
                                )),
                            controller: _controller,
                            initialCountryCode: 'IN',
                            dropdownTextStyle: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 18),
                            pickerDialogStyle: PickerDialogStyle(
                                backgroundColor:
                                    Theme.of(context).primaryColor),
                            onChanged: (phone) {
                              Logx.i(_TAG, phone.completeNumber);
                              completePhoneNumber = phone.completeNumber;
                            },
                            onCountryChanged: (country) {
                              Logx.i(
                                  _TAG, 'country changed to: ${country.name}');
                            },
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              !UserPreferences.isUserLoggedIn()
                  ? const SizedBox(height: 12)
                  : const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'date *',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    dateContainer(context),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'expected time of arrival',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    timeContainer(context),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'expected number of guests *',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          key: const ValueKey('guest_count'),
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              errorStyle: TextStyle(
                                  color: Theme.of(context).errorColor,
                                  fontSize: 16.0),
                              hintText: 'please select guests count',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 0.0),
                              )),
                          isEmpty: sGuestCount == '',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight),
                              dropdownColor: Theme.of(context).backgroundColor,
                              value: sGuestCount,
                              isDense: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  sGuestCount = newValue!;
                                  widget.celebration = widget.celebration
                                      .copyWith(
                                          guestsCount: int.parse(sGuestCount));
                                  state.didChange(newValue);
                                });
                              },
                              items: guestCounts.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'booking duration in hours',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          key: const ValueKey('duration_hours'),
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              errorStyle: TextStyle(
                                  color: Theme.of(context).errorColor,
                                  fontSize: 16.0),
                              hintText: 'please select booking duration hours',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 0.0),
                              )),
                          isEmpty: sDurationHours == '',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight),
                              dropdownColor: Theme.of(context).backgroundColor,
                              value: sDurationHours,
                              isDense: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  sDurationHours = newValue!;
                                  widget.celebration = widget.celebration
                                      .copyWith(
                                          durationHours:
                                              int.parse(sDurationHours));
                                  state.didChange(newValue);
                                });
                              },
                              items: durationHours.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'occasion',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          key: const ValueKey('occasion'),
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              errorStyle: TextStyle(
                                  color: Theme.of(context).errorColor,
                                  fontSize: 16.0),
                              hintText: 'please select occasion',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 0.0),
                              )),
                          isEmpty: sOcassion == '',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight),
                              dropdownColor: Theme.of(context).backgroundColor,
                              value: sOcassion,
                              isDense: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  sOcassion = newValue!;
                                  widget.celebration = widget.celebration
                                      .copyWith(occasion: sOcassion);
                                  state.didChange(newValue);
                                });
                              },
                              items: ocassions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'reserve bottles',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    MultiSelectDialogField(
                      items: mBottles
                          .map((e) => MultiSelectItem(e,
                              '${e.name.toLowerCase()} [${e.category.toLowerCase()}]'))
                          .toList(),
                      listType: MultiSelectListType.CHIP,
                      initialValue: sBottles.map((e) => e).toList(),
                      buttonIcon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey.shade700,
                      ),
                      title: const Text('select your spirits 🥂'),
                      buttonText: const Text(
                        'select',
                        style: TextStyle(color: Constants.lightPrimary),
                      ),
                      decoration: BoxDecoration(
                        color: Constants.background,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        border: Border.all(
                          color: Constants.primary,
                          width: 0.0,
                        ),
                      ),
                      searchable: true,
                      onConfirm: (values) {
                        sBottles = values as List<Product>;
                        sBottleIds = [];
                        sBottleNames = [];

                        for (Product product in sBottles) {
                          sBottleIds.add(product.id);
                          sBottleNames.add(product.name);
                        }

                        if (sBottleIds.isEmpty) {
                          Logx.i(_TAG, 'no bottles selected');
                          widget.celebration =
                              widget.celebration.copyWith(bottleNames: []);
                          widget.celebration =
                              widget.celebration.copyWith(bottleProductIds: []);
                        } else {
                          widget.celebration = widget.celebration
                              .copyWith(bottleNames: sBottleNames);
                          widget.celebration = widget.celebration
                              .copyWith(bottleProductIds: sBottleIds);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: DarkTextFieldWidget(
                  label: 'additional requests',
                  text: widget.celebration.specialRequest,
                  onChanged: (text) => widget.celebration =
                      widget.celebration.copyWith(specialRequest: text),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10, bottom: 5),
                      child: DelayedDisplay(
                        delay: const Duration(seconds: 1),
                        child: Text(
                          "* required",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: isEdit
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ButtonWidget(
                            text: 'save',
                            onClicked: () {
                              Celebration freshCelebration =
                                  Fresh.freshCelebration(widget.celebration);
                              FirestoreHelper.pushCelebration(freshCelebration);
                              Toaster.shortToast('celebration changes saved');
                              Navigator.of(context).pop();
                            },
                          ),
                          const SizedBox(height: 15),
                          ButtonWidget(
                              text: 'delete',
                              onClicked: () {
                                FirestoreHelper.deleteCelebration(
                                    widget.celebration.id);
                                Toaster.shortToast('celebration deleted');
                                Navigator.of(context).pop();
                              }),
                        ],
                      )
                    : ButtonWidget(
                        height: 50,
                        text: 'confirm',
                        onClicked: () {
                          if (UserPreferences.isUserLoggedIn()) {
                            showConfirmationDialog(context, false);
                          } else {
                            _verifyPhone();
                          }
                        },
                      ),
              ),
              const SizedBox(height: 24),
            ],
          );
  }

  void _verifyPhone() async {
    Logx.i(_TAG, '_verifyPhone: registering ' + completePhoneNumber.toString());

    if (kIsWeb) {
      await FirebaseAuth.instance
          .signInWithPhoneNumber('${completePhoneNumber}', null)
          .then((firebaseUser) {
        Logx.i(
            _TAG,
            'signInWithPhoneNumber: user verification id ' +
                firebaseUser.verificationId);

        showOTPDialog(context);

        setState(() {
          _verificationCode = firebaseUser.verificationId;
        });
      }).catchError((e, s) {
        Logx.e(_TAG, e, s);
      });
    } else {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '${completePhoneNumber}',
          verificationCompleted: (PhoneAuthCredential credential) async {
            Logx.i(_TAG,
                'verifyPhoneNumber: ${completePhoneNumber} is verified. attempting sign in with credentials...');
          },
          verificationFailed: (FirebaseAuthException e) {
            Logx.em(_TAG, 'verificationFailed ' + e.toString());
          },
          codeSent: (String verificationID, int? resendToken) {
            Logx.i(_TAG, 'verification id : ' + verificationID);

            if (mounted) {
              showOTPDialog(context);

              setState(() {
                _verificationCode = verificationID;
              });
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            if (mounted) {
              setState(() {
                _verificationCode = verificationId;
              });
            }
          },
          timeout: const Duration(seconds: 60));
    }
  }

  showOTPDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'phone number verification',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: FractionallySizedBox(
                        widthFactor: 1,
                        child: OTPVerifyWidget(
                          completePhoneNumber,
                        )),
                  ),
                ),
                Center(
                    child: Text(
                  'enter the six digit code you received on \n${completePhoneNumber}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10, top: 2, bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DelayedDisplay(
                        delay: const Duration(seconds: 7),
                        child: Text('didn\'t receive code. ',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 16,
                            )),
                      ),
                      InkWell(
                        onTap: () {
                          Toaster.longToast('refreshing');
                          _verifyPhone();
                        },
                        child: DelayedDisplay(
                          delay: const Duration(seconds: 10),
                          child: Text(
                            'resend?',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  OTPVerifyWidget(String phone) {
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
      key: GlobalKey<FormState>(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            // Specify direction if desired
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

                Toaster.shortToast('verifying ${completePhoneNumber}');
                try {
                  await FirebaseAuth.instance
                      .signInWithCredential(PhoneAuthProvider.credential(
                          verificationId: _verificationCode, smsCode: pin))
                      .then((value) async {
                    if (value.user != null) {
                      Logx.i(_TAG,
                          'user in firebase auth. checking bloc registration: id: ${value.user!.uid}');

                      FirestoreHelper.pullUser(value.user!.uid).then((res) {
                        Logx.i(_TAG,
                            "successfully retrieved bloc user for id ${value.user!.uid}");

                        if (res.docs.isEmpty) {
                          Logx.i(_TAG,
                              'user is not already registered in bloc, registering...');

                          bloc_user.id = value.user!.uid;
                          bloc_user.phoneNumber =
                              StringUtils.getInt(value.user!.phoneNumber!);

                          FirestoreHelper.pushUser(bloc_user);
                          Logx.i(_TAG, 'registered user ${bloc_user.id}');

                          UserPreferences.setUser(bloc_user);
                          widget.celebration = widget.celebration
                              .copyWith(customerId: bloc_user.id);
                          widget.celebration = widget.celebration.copyWith(
                              phone: int.tryParse(completePhoneNumber));

                          showConfirmationDialog(context, true);
                        } else {
                          Logx.i(_TAG, 'user is a bloc member, logging in...');

                          DocumentSnapshot document = res.docs[0];
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;

                          blocUser.User user = Fresh.freshUserMap(data, true);

                          //update user details
                          user = user.copyWith(name: bloc_user.name);
                          int time = Timestamp.now().millisecondsSinceEpoch;
                          user = user.copyWith(lastSeenAt: time);
                          FirestoreHelper.pushUser(user);

                          UserPreferences.setUser(user);
                          bloc_user = user;

                          widget.celebration = widget.celebration
                              .copyWith(customerId: bloc_user.id);
                          widget.celebration = widget.celebration.copyWith(
                              phone: int.tryParse(completePhoneNumber));

                          showConfirmationDialog(context, false);
                        }
                      });
                    }
                  });
                } catch (e) {
                  Logx.em(_TAG, 'otp error ' + e.toString());

                  String exception = e.toString();
                  if (exception.contains('session-expired')) {
                    Toaster.shortToast('session got expired, trying again');
                    _verifyPhone();
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

  showConfirmationDialog(BuildContext context, bool isNewUser) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 250,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        'celebration confirmation ',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  width: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                            'thank you for choosing us to host your celebration '
                            'on the ${DateTimeUtils.getFormattedDate2(widget.celebration.arrivalDate)}'
                            ', your booking will be reviewed and approved soon. '
                            '\n\nyour celebration confirmation status shall be found at the box office. '
                            'also, our team may reach out to you for any further information. thank you.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: const Text("confirm"),
              onPressed: () {
                if (isNewUser) {
                  Celebration freshCelebration =
                      Fresh.freshCelebration(widget.celebration);
                  FirestoreHelper.pushCelebration(freshCelebration);
                } else {
                  Celebration freshCelebration =
                      Fresh.freshCelebration(widget.celebration);
                  FirestoreHelper.pushCelebration(freshCelebration);
                }

                Navigator.of(ctx).pop();

                UserPreferences.setUser(bloc_user);
                GoRouter.of(context)
                    .pushNamed(RouteConstants.homeRouteName);
              },
            ),
          ],
        );
      },
    );
  }

  Widget dateContainer(BuildContext context) {
    sDateArrival = DateTimeUtils.getDate(widget.celebration.arrivalDate);
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      padding: const EdgeInsets.only(left: 10, top: 5, right: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              DateTimeUtils.getFormattedDateType(
                      sDateArrival.millisecondsSinceEpoch, 0)
                  .toLowerCase(),
              style: const TextStyle(
                color: Constants.lightPrimary,
                fontSize: 18,
              )),
          const SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              shadowColor: Theme.of(context).primaryColor,
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0)),
              minimumSize: const Size(50, 50), //////// HERE
            ),
            onPressed: () {
              _selectDate(context, sDateArrival);
            },
            child: const Text('pick date'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime initDate) async {
    final DateTime? _sDate = await showDatePicker(
        context: context,
        initialDate: initDate,
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2101));
    if (_sDate != null) {
      setState(() {
        sDateArrival = DateTime(_sDate.year, _sDate.month, _sDate.day);
        widget.celebration = widget.celebration
            .copyWith(arrivalDate: sDateArrival.millisecondsSinceEpoch);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    setState(() {
      sArrivalTime = pickedTime!;
      widget.celebration = widget.celebration.copyWith(
          arrivalTime: DateTimeUtils.convertTimeToString(sArrivalTime));
    });
  }

  Widget timeContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      padding: const EdgeInsets.only(left: 10, top: 5, right: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(sArrivalTime.format(context),
              style: const TextStyle(
                color: Constants.lightPrimary,
                fontSize: 18,
              )),
          const SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              shadowColor: Theme.of(context).primaryColor,
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0)),
              minimumSize: const Size(50, 50), //////// HERE
            ),
            onPressed: () {
              _selectTime(context);
            },
            child: const Text('pick time'),
          ),
        ],
      ),
    );
  }
}
