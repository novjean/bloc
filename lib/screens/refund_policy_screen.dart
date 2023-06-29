import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../widgets/ui/app_bar_title.dart';

class RefundPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title: 'refund policy',),
        titleSpacing: 0,      ),
      backgroundColor: Constants.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Refund Policy'.toLowerCase(),
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 22
                ),
              ),
              Text(
                '\nBloc has a Refund Policy in respect of all event listed on the platform, wherein users may cancel their enrollment and obtain a refund\n'
                    '\nTo initiate a Refund, the customer can contact us at novjean@bloc.bar\n '
                    '\nRefund can only be initiated within 72 hours from the time of making the payment. Refund Policy is available only to users within India. Under normal situations, the refund shall be processed within 15 working days.\n'
                    '\nTickets purchased on bloc are subject to a per ticket non-refundable internet handling fee and a non-refundable per order processing fee.'.toLowerCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                '\nbloc may, at its sole discretion, reject requests for availing Refunds from users requesting serial or repeated refunds, or Users who have violated or are suspected of violation of the Terms of Use, Disclaimer Policy or any other terms and conditions of use of the app/website. This Refund Policy is a part of and incorporated within, the Terms of Use. As a condition of registering with bloc.bar and using the services offered through this app/website, you expressly acknowledge that you have read and understood this Refund Policy and you agree to be bound by its terms and conditions. If at any time you disagree with this Refund Policy or any part of it, your sole remedy is to cease use of all bloc services and terminate your account. However, any transactions occurring prior to the date of such termination shall be governed and controlled in full by the terms of this Refund Policy.\n'.toLowerCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
