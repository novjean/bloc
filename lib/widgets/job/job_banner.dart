import 'package:bloc/main.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bloc.dart';
import '../../db/entity/bloc_service.dart';
import '../../db/entity/job.dart';
import '../../db/entity/party.dart';
import '../../db/entity/party_interest.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../screens/jobs/job_apply_screen.dart';
import '../../screens/manager/organizers/organizer_party_add_edit_screen.dart';
import '../../screens/organizer/organizer_party_sales_screen.dart';
import '../../screens/organizer/organizer_party_tickets_screen.dart';

class JobBanner extends StatefulWidget {
  Job job;

  JobBanner({Key? key, required this.job}) : super(key: key);

  @override
  State<JobBanner> createState() => _JobBannerState();
}

class _JobBannerState extends State<JobBanner> {
  static const String _TAG = 'JobBanner';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: widget.job.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            child: SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text('${widget.job.title.toLowerCase()} ',
                      style: const TextStyle(
                          color: Colors.black,
                          fontFamily: Constants.fontDefault,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 19,
                          fontWeight: FontWeight.bold),)


                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      DateTimeUtils.getFormattedDate2(widget.job.postingDate),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      widget.job.description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 16),
                      ),
                  ),
                  const Spacer(),

                  _displayJobApplyRow()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _displayJobApplyRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.background,
                  foregroundColor: Constants.primary,
                  shadowColor: Colors.white30,
                  minimumSize: const Size.fromHeight(60),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  elevation: 3,
                ),
                label: const Text(
                  'apply now',
                  style: TextStyle(fontSize: 18),
                ),
                icon: const Icon(
                  Icons.work,
                  size: 24.0,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) =>
                          JobApplyScreen(
                              job: widget.job,
                            jobApplicant: Dummy.getDummyJobApplicant(),
                            task: 'add',
                          )));
                },
              ),
            )),
        // Expanded(
        //     child: Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 5),
        //       height: 60,
        //       child: ElevatedButton.icon(
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Constants.background,
        //           foregroundColor: Constants.primary,
        //           shadowColor: Colors.white30,
        //           minimumSize: const Size.fromHeight(60),
        //           shape: const RoundedRectangleBorder(
        //             borderRadius: BorderRadius.only(
        //                 topLeft: Radius.circular(10),
        //                 topRight: Radius.circular(10)),
        //           ),
        //           elevation: 3,
        //         ),
        //         label: const Text(
        //           'sales',
        //           style: TextStyle(fontSize: 18),
        //         ),
        //         icon: const Icon(
        //           Icons.money,
        //           size: 24.0,
        //         ),
        //         onPressed: () {
        //           Navigator.of(context).push(MaterialPageRoute(
        //               builder: (ctx) =>
        //                   OrganizerPartySalesScreen(party: widget.job)));
        //         },
        //       ),
        //     )),
      ],
    );
  }
}
