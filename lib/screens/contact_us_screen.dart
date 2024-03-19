import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../routes/route_constants.dart';
import '../utils/constants.dart';
import '../widgets/ui/app_bar_title.dart';
import '../widgets/ui/toaster.dart';

class ContactUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title: 'contact us',),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
          onPressed: () {
            if (kIsWeb) {
              GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
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
                  var url = Uri.parse("tel:+918830962982");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    Clipboard.setData(
                        const ClipboardData(text: '+918830962982'))
                        .then((value) {
                      Toaster.shortToast('phone number copied');
                    });
                  }
                },
                child: Text(
                  '\n+91 8830962982\n',
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