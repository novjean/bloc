import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/promoter.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../widgets/footer.dart';
import '../../widgets/ui/app_bar_title.dart';

class OrganizerScreen extends StatefulWidget {

  @override
  State<OrganizerScreen> createState() => _OrganizerScreenState();
}

class _OrganizerScreenState extends State<OrganizerScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title: 'organizer'),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
          onPressed: () {
            GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
          },
        ),
      ),
      backgroundColor: Constants.background,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context){
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     mainAxisSize: MainAxisSize.min,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       Flexible(
        //         flex: 1,
        //         child: Padding(
        //           padding: const EdgeInsets.only(left: 10, right: 15.0),
        //           child: Text(
        //             mUser.name.toLowerCase(),
        //             maxLines: 3,
        //             style: const TextStyle(
        //                 fontWeight: FontWeight.bold,
        //                 fontSize: 24,
        //                 color: Constants.primary),
        //           ),
        //         ),
        //       ),
        //       Flexible(
        //         flex: 1,
        //         child: mUser.imageUrl.isNotEmpty
        //             ? ProfileWidget(
        //           isEdit: false,
        //           imagePath: mUser.imageUrl,
        //           showEditIcon: false,
        //           onClicked: () {},
        //         )
        //             : ClipOval(
        //           child: Container(
        //             width: 128.0,
        //             height: 128.0,
        //             color: Constants.primary,
        //             // Optional background color for the circle
        //             child: Image.asset(
        //               mUser.gender == 'female'
        //                   ? 'assets/profile_photos/12.png'
        //                   : 'assets/profile_photos/1.png',
        //               // Replace with your asset image path
        //               fit: BoxFit.cover,
        //             ),
        //           ),
        //         ),
        //       ),
        //       Flexible(
        //         flex: 1,
        //         child: Padding(
        //           padding: const EdgeInsets.only(left: 15.0, right: 10),
        //           child: Text(
        //             mUser.surname.toLowerCase(),
        //             maxLines: 3,
        //             style: const TextStyle(
        //                 fontWeight: FontWeight.bold,
        //                 fontSize: 24,
        //                 color: Constants.primary),
        //           ),
        //
        //           // buildLastName(mUser),
        //         ),
        //       )
        //     ],
        //   ),
        // ),
        Footer()
      ],
    );
  }
}