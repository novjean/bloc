import 'package:flutter/src/widgets/framework.dart';

import '../main.dart';

class LoginUtils {
  BuildContext context;


  LoginUtils({required this.context});

  void showLoginDialog(BuildContext context) {
    if(kIsWeb){
      _showPhoneNumberDialog(context);
    } else {
      _showQuickLoginDialog(context);
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

}