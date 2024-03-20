import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/job.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../jobs/job_add_edit_screen.dart';
import '../../../widgets/job/manage_job_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/loading_widget.dart';

class ManageJobsScreen extends StatelessWidget {
  static const String _TAG = 'ManageJobsScreen';

  String serviceId;

  ManageJobsScreen({Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AppBarTitle(title:'manage jobs'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => JobAddEditScreen(
                  job: Dummy.getDummyJob(),
                  task: 'add',
                )),
          );
        },
        backgroundColor: Constants.primary,
        tooltip: 'add job',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildJobs(context),
    );
  }

  _buildJobs(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getJobs(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                List<Job> jobs = [];
                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot document = snapshot.data!.docs[i];
                  Map<String, dynamic> map = document.data()! as Map<
                      String,
                      dynamic>;
                  final Job job = Fresh.freshJobMap(map, false);
                  jobs.add(job);
                }
                return _displayJobs(context, jobs);
              }
          }
        });
  }

  _displayJobs(BuildContext context, List<Job> jobs) {
    return SizedBox(
      height: mq.height,
      child: ListView.builder(
          itemCount: jobs.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageJobItem(
                  job: jobs[index],
                ),
                onTap: () {
                  Job job = jobs[index];

                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => JobAddEditScreen(
                          job: job,
                          task: 'edit',
                        )),
                  );
                });
          }),
    );
  }
}
