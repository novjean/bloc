import 'package:bloc/services/payu/payu_test_credentials.dart';

class PayUParams {
  // static Map createPayUPaymentParams() {
  //   // var siParams = {
  //   //   PayUSIParamsKeys.isFreeTrial: true,
  //   //   PayUSIParamsKeys.billingAmount: '1',              //Required
  //   //   PayUSIParamsKeys.billingInterval: 1,              //Required
  //   //   PayUSIParamsKeys.paymentStartDate: '2023-04-20',  //Required
  //   //   PayUSIParamsKeys.paymentEndDate: '2023-04-30',    //Required
  //   //   PayUSIParamsKeys.billingCycle:                    //Required
  //   //   'daily', //Can be any of 'daily','weekly','yearly','adhoc','once','monthly'
  //   //   PayUSIParamsKeys.remarks: 'Test SI transaction',
  //   //   PayUSIParamsKeys.billingCurrency: 'INR',
  //   //   PayUSIParamsKeys.billingLimit: 'ON', //ON, BEFORE, AFTER
  //   //   PayUSIParamsKeys.billingRule: 'MAX', //MAX, EXACT
  //   // };
  //   //
  //   // var additionalParam = {
  //   //   PayUAdditionalParamKeys.udf1: "udf1",
  //   //   PayUAdditionalParamKeys.udf2: "udf2",
  //   //   PayUAdditionalParamKeys.udf3: "udf3",
  //   //   PayUAdditionalParamKeys.udf4: "udf4",
  //   //   PayUAdditionalParamKeys.udf5: "udf5",
  //   //   PayUAdditionalParamKeys.merchantAccessKey:
  //   //   PayUTestCredentials.merchantAccessKey,
  //   //   PayUAdditionalParamKeys.sourceId:PayUTestCredentials.sodexoSourceId,
  //   // };
  //
  //
  //   var spitPaymentDetails =
  //   {
  //     "type": "absolute",
  //     "splitInfo": {
  //       PayUTestCredentials.merchantKey: {
  //         "aggregatorSubTxnId": "1234567540099887766650092", //unique for each transaction
  //         "aggregatorSubAmt": "1"
  //       },
  //       /* "qOoYIv": {
  //         "aggregatorSubTxnId": "12345678",
  //         "aggregatorSubAmt": "40"
  //      },*/
  //     }
  //   };
  //
  //
  //   // var payUPaymentParams = {
  //   //   PayUPaymentParamKey.key: PayUTestCredentials.merchantKey,
  //   //   PayUPaymentParamKey.amount: "1",
  //   //   PayUPaymentParamKey.productInfo: "Info",
  //   //   PayUPaymentParamKey.firstName: "Abc",
  //   //   PayUPaymentParamKey.email: "test@gmail.com",
  //   //   PayUPaymentParamKey.phone: "9999999999",
  //   //   PayUPaymentParamKey.ios_surl: PayUTestCredentials.iosSurl,
  //   //   PayUPaymentParamKey.ios_furl: PayUTestCredentials.iosFurl,
  //   //   PayUPaymentParamKey.android_surl: PayUTestCredentials.androidSurl,
  //   //   PayUPaymentParamKey.android_furl: PayUTestCredentials.androidFurl,
  //   //   PayUPaymentParamKey.environment: "0", //0 => Production 1 => Test
  //   //   PayUPaymentParamKey.userCredential: null, //TODO: Pass user credential to fetch saved cards => A:B - Optional
  //   //   PayUPaymentParamKey.transactionId:
  //   //   DateTime.now().millisecondsSinceEpoch.toString(),
  //   //   PayUPaymentParamKey.additionalParam: additionalParam,
  //   //   PayUPaymentParamKey.enableNativeOTP: true,
  //   //   // PayUPaymentParamKey.splitPaymentDetails:json.encode(spitPaymentDetails),
  //   //   PayUPaymentParamKey.userToken:"", //TODO: Pass a unique token to fetch offers. - Optional
  //   // };
  //
  //   // return payUPaymentParams;
  // }

  // static Map createPayUConfigParams() {
  //   var paymentModesOrder = [
  //     {"Wallets": "PHONEPE"},
  //     {"UPI": "TEZ"},
  //     {"Wallets": ""},
  //     {"EMI": ""},
  //     {"NetBanking": ""},
  //   ];
  //
  //   var cartDetails = [
  //     {"GST": "5%"},
  //     {"Delivery Date": "25 Dec"},
  //     {"Status": "In Progress"}
  //   ];
  //   var enforcePaymentList = [
  //     {"payment_type": "CARD", "enforce_ibiboCode": "UTIBENCC"},
  //   ];
  //
  //   // var customNotes = [
  //   //   {
  //   //     "custom_note": "Its Common custom note for testing purpose",
  //   //     "custom_note_category": [PayUPaymentTypeKeys.emi,PayUPaymentTypeKeys.card]
  //   //   },
  //   //   {
  //   //     "custom_note": "Payment options custom note",
  //   //     "custom_note_category": null
  //   //   }
  //   // ];
  //
  //   // var payUCheckoutProConfig = {
  //   //   PayUCheckoutProConfigKeys.primaryColor: "#4994EC",
  //   //   PayUCheckoutProConfigKeys.secondaryColor: "#FFFFFF",
  //   //   PayUCheckoutProConfigKeys.merchantName: "PayU",
  //   //   PayUCheckoutProConfigKeys.merchantLogo: "logo",
  //   //   PayUCheckoutProConfigKeys.showExitConfirmationOnCheckoutScreen: true,
  //   //   PayUCheckoutProConfigKeys.showExitConfirmationOnPaymentScreen: true,
  //   //   PayUCheckoutProConfigKeys.cartDetails: cartDetails,
  //   //   PayUCheckoutProConfigKeys.paymentModesOrder: paymentModesOrder,
  //   //   PayUCheckoutProConfigKeys.merchantResponseTimeout: 30000,
  //   //   PayUCheckoutProConfigKeys.customNotes: customNotes,
  //   //   PayUCheckoutProConfigKeys.autoSelectOtp: true,
  //   //   // PayUCheckoutProConfigKeys.enforcePaymentList: enforcePaymentList,
  //   //   PayUCheckoutProConfigKeys.waitingTime: 30000,
  //   //   PayUCheckoutProConfigKeys.autoApprove: true,
  //   //   PayUCheckoutProConfigKeys.merchantSMSPermission: true,
  //   //   PayUCheckoutProConfigKeys.showCbToolbar: true,
  //   // };
  //   // return payUCheckoutProConfig;
  // }
}