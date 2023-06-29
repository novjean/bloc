import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../widgets/ui/app_bar_title.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title: 't&c',),
        titleSpacing: 0,
      ),
      backgroundColor: Constants.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'terms and conditions',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22
                ),
              ),
              Text(
                '\nWelcome to our app that provides food and tickets for events! Please read these terms and conditions carefully before using our app. By using our app, you agree to be bound by these terms and conditions.\n'.toLowerCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'Use of Our App'.toLowerCase(),
                style: TextStyle(

                    color: Theme.of(context).primaryColor,
                    fontSize: 22
                ),
              ),
              Text(
                '\nOur app allows you to purchase food and tickets for events. You may only use our app for lawful purposes and in accordance with these terms and conditions.\n'.toLowerCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'Registration'.toLowerCase(),
                style: TextStyle(

                    color: Theme.of(context).primaryColor,
                    fontSize: 22
                ),
              ),
              Text(
                '\nIn order to use our app, you may be required to register an account with us. You agree to provide accurate and complete information when registering an account. You are solely responsible for maintaining the confidentiality of your account information.\n'.toLowerCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'Purchases'.toLowerCase(),
                style: TextStyle(

                    color: Theme.of(context).primaryColor,
                    fontSize: 22
                ),
              ),
              Text(
                '\nAll purchases made through our app are subject to our refund and cancellation policy. You agree to pay all fees and charges associated with your purchases.\n'.toLowerCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'Content'.toLowerCase(),
                style: TextStyle(

                    color: Theme.of(context).primaryColor,
                    fontSize: 22
                ),
              ),
              Text(
                '\nAll content on our app, including text, graphics, images, and other materials, is owned by us or our licensors and is protected by copyright and other intellectual property laws. You may not use any content from our app without our express written permission.\n'.toLowerCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'Third-Party Links'.toLowerCase(),
                style: TextStyle(

                    color: Theme.of(context).primaryColor,
                    fontSize: 22
                ),
              ),
              Text(
                '\nOur app may contain links to third-party websites or resources. We are not responsible for the content or accuracy of any third-party websites or resources.\n'.toLowerCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'Limitation of Liability'.toLowerCase(),
                style: TextStyle(

                    color: Theme.of(context).primaryColor,
                    fontSize: 22
                ),
              ),
              Text(
                '\nTo the maximum extent permitted by law, we are not liable for any damages or losses arising out of or in connection with your use of our app, including but not limited to direct, indirect, incidental, consequential, special, or punitive damages.\n'.toLowerCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'Indemnification'.toLowerCase(),
                style: TextStyle(

                    color: Theme.of(context).primaryColor,
                    fontSize: 22
                ),
              ),
              Text(
                '\nYou agree to indemnify, defend, and hold us harmless from any claims, liabilities, damages, and expenses (including reasonable attorneys\' fees) arising out of or in connection with your use of our app or your breach of these terms and conditions.\n'.toLowerCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'Termination'.toLowerCase(),
                style: TextStyle(

                    color: Theme.of(context).primaryColor,
                    fontSize: 22
                ),
              ),
              Text(
                '\nWe reserve the right to terminate your access to our app at any time for any reason.\n'.toLowerCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'Governing Law'.toLowerCase(),
                style: TextStyle(

                    color: Theme.of(context).primaryColor,
                    fontSize: 22
                ),
              ),
              Text(
                '\nThese terms and conditions are governed by and construed in accordance with the laws of India. Any dispute arising out of or in connection with these terms and conditions shall be subject to the exclusive jurisdiction of the courts of Pune.\n'.toLowerCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'Changes to These Terms and Conditions'.toLowerCase(),
                style: TextStyle(

                    color: Theme.of(context).primaryColor,
                    fontSize: 22
                ),
              ),
              Text(
                '\nWe reserve the right to change these terms and conditions at any time without notice. Your continued use of our app after such changes will constitute your acceptance of the revised terms and conditions.\n'.toLowerCase(),
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
