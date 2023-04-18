import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('bloc | contact us'),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'address'.toLowerCase(),
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 22
                ),
              ),
              Text(
                '\nPyramid Complex, 81/82, above FREQ, Koregaon Park Annexe, Mundhwa, Pune, Maharashtra 411036\n'.toLowerCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'phone number'.toLowerCase(),
                style: TextStyle(

                    color: Theme.of(context).primaryColor,
                    fontSize: 22
                ),
              ),
              InkWell(
                onTap: () async {
                  var url = Uri.parse("tel:+917700004328");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Text(
                  '\n+91 7700004328\n',
                  style: TextStyle(
                      fontSize: 14, color: Theme.of(context).primaryColor),
                ),
              ),

              Text(
                'email address'.toLowerCase(),
                style: TextStyle(

                    color: Theme.of(context).primaryColor,
                    fontSize: 22
                ),
              ),
              Text(
                '\nnovjean@bloc.bar\n'.toLowerCase(),
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