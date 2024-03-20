import 'package:bloc/db/entity/job_applicant.dart';
import 'package:bloc/widgets/job_applicant/manage_job_applicant_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/job.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/loading_widget.dart';

class ManageJobApplicantsScreen extends StatefulWidget {
  static const String _TAG = 'ManageJobApplicantsScreen';

  String serviceId;

  ManageJobApplicantsScreen({Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  State<ManageJobApplicantsScreen> createState() => _ManageJobApplicantsScreenState();
}

class _ManageJobApplicantsScreenState extends State<ManageJobApplicantsScreen> {
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
          mJobs.add(job);
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
        titleSpacing: 0,
        title: AppBarTitle(title:'manage job applicants'),
      ),
      body: _isJobsLoading ? const LoadingWidget() : _buildJobApplicants(context),
    );
  }

  _buildJobApplicants(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getJobApplicants(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                List<JobApplicant> jobApplicants = [];
                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot document = snapshot.data!.docs[i];
                  Map<String, dynamic> map = document.data()! as Map<
                      String,
                      dynamic>;
                  final JobApplicant jobApplicant = Fresh.freshJobApplicantMap(map, false);
                  jobApplicants.add(jobApplicant);
                }
                return _displayJobApplicants(context, jobApplicants);
              }
          }
        });
  }

  _displayJobApplicants(BuildContext context, List<JobApplicant> jobApplicants) {
    return SizedBox(
      height: mq.height,
      child: ListView.builder(
          itemCount: jobApplicants.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            JobApplicant jobApplicant = jobApplicants[index];
            Job sJob = Dummy.getDummyJob();

            for(Job job in mJobs){
              if(jobApplicant.jobId == job.id){
                sJob = job;
                break;
              }
            }

            return GestureDetector(
                child: ManageJobApplicantItem(
                  jobApplicant: jobApplicant,
                  job: sJob,
                ),
                onTap: () {
                  JobApplicant job = jobApplicants[index];

                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //       builder: (ctx) => JobAddEditScreen(
                  //         job: job,
                  //         task: 'edit',
                  //       )),
                  // );
                });
          }),
    );
  }
}
