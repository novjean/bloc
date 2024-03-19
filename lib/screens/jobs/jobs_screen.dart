import 'dart:io';

import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/job.dart';
import '../../db/entity/organizer.dart';
import '../../db/entity/party.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestorage_helper.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../utils/number_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/footer.dart';
import '../../widgets/job/job_banner.dart';
import '../../widgets/organizer/organizer_party_banner.dart';
import '../../widgets/profile_widget.dart';
import '../../widgets/ui/app_bar_title.dart';

class JobsScreen extends StatefulWidget {
  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  static const String _TAG = 'JobsScreen';

  List<Job> mJobs = [];
  var _isJobsLoading = true;


  @override
  void initState() {
    FirestoreHelper.pullJobs().then((res) {
      if(res.docs.isNotEmpty){
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Job job = Fresh.freshJobMap(data, false);
          if(job.isActive){
            mJobs.add(job);
          }
        }

        setState(() {
          _isJobsLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title: 'jobs'),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Constants.lightPrimary),
          onPressed: () {
            GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
          },
        ),
      ),
      backgroundColor: Constants.background,
      body: _isJobsLoading ? const LoadingWidget() : _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // const SizedBox(height: 15),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     mainAxisSize: MainAxisSize.min,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       // Padding(
        //       //   padding: const EdgeInsets.only(left: 10, right: 10.0),
        //       //   child: Text(
        //       //     mOrganizer.name,
        //       //     maxLines: 3,
        //       //     style: const TextStyle(
        //       //         fontWeight: FontWeight.bold,
        //       //         fontSize: 24,
        //       //         color: Constants.primary),
        //       //   ),
        //       // ),
        //       Padding(
        //         padding: const EdgeInsets.only(left: 10.0, right: 10),
        //         child: ProfileWidget(
        //           isEdit: false,
        //           imagePath: mOrganizer.imageUrl,
        //           showEditIcon: false,
        //           onClicked: () {
        //             //nothing to do here
        //           },
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        const SizedBox(
          height: 15,
        ),
        _displayJobs(context),
        Footer(
          showAll: false,
        )
      ],
    );
  }

  _displayJobs(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        key: UniqueKey(),
        itemCount: mJobs.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          Job job = mJobs[index];

          return JobBanner(
            job: job,
          );
        },
      ),
    );
  }
}
