import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../widgets/ui/app_bar_title.dart';

class DeliveryPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title:'delivery policy'),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Constants.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: ListView(
          children: [
            Text(
              'Delivery Policy'.toLowerCase(),
              style: const TextStyle(
                  color: Constants.primary,
                  fontSize: 22
              ),
            ),
            const Text("\nAt bloc, we are dedicated to providing a convenient and eco-friendly experience when you purchase online tickets. Our commitment to the environment is a key reason why we do not offer physical tickets. On this page, you'll find comprehensive details about how we deliver your online tickets, including delivery methods, estimated delivery times, and how to track your order.",
                style: TextStyle(
                  color: Constants.primary,
                )),
            Text(
              '\nTicket Delivery Methods'.toLowerCase(),
              style: const TextStyle(
                  color: Constants.primary,
                  fontSize: 22
              ),
            ),
            Text("\nE-Tickets: Receive your tickets as electronic files that you can easily access and store on your device. No physical delivery required; simply show your e-ticket on your mobile device at the event".toLowerCase(),
                style: const TextStyle(
                  color: Constants.primary,
                )),
            Text("\nMobile App Tickets: Download our mobile app and access your tickets seamlessly, ready for scanning at the event. Ideal for a contactless and environmentally conscious ticketing experience.".toLowerCase(),
                style: const TextStyle(
                  color: Constants.primary,
                )),

            Text(
              '\nEstimated Delivery Times and Factors Affecting Them'.toLowerCase(),
              style: const TextStyle(
                  color: Constants.primary,
                  fontSize: 22
              ),
            ),
            Text("\nOur estimated delivery times are to be instantaneously as the payment confirmation is retrieved and verified by our team. Please be aware that these times may vary due to factors beyond our control, including:"
                "\nTicket Type: The type of ticket you've selected (e-ticket or mobile app ticket) affects the delivery method and time."
                "\nEvent Date and Location: Different events and venues may have unique ticket delivery timelines.".toLowerCase(),
                style: const TextStyle(
                  color: Constants.primary,
                )),

            Text(
              '\nTicket Order Tracking'.toLowerCase(),
              style: const TextStyle(
                  color: Constants.primary,
                  fontSize: 22
              ),
            ),
            Text("\nWe provide several options to help you stay updated on the status of your ticket order:"
                "\nOrder Confirmation: Once you've successfully purchased your tickets, you will receive an order confirmation email with details of your purchase."
                "\nMobile App Access: If you've opted for mobile app tickets, you can access your tickets at any time through our mobile app. Just log in and navigate to your event to view and download your tickets.".toLowerCase(),
                style: const TextStyle(
                  color: Constants.primary,
                )),
          ],
        )
      ),
    );
  }
}