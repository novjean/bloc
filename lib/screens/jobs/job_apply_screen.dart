import 'package:bloc/db/entity/job_applicant.dart';
import 'package:flutter/material.dart';

import '../../../helpers/firestore_helper.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../widgets/footer.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/dark_textfield_widget.dart';
import '../../db/entity/job.dart';

class JobApplyScreen extends StatefulWidget {
  Job job;
  JobApplicant jobApplicant;
  final String task;

  JobApplyScreen(
      {Key? key, required this.job,
        required this.jobApplicant,
        required this.task})
      : super(key: key);

  @override
  State<JobApplyScreen> createState() => _JobApplyScreenState();
}

class _JobApplyScreenState extends State<JobApplyScreen> {
  static const String _TAG = 'JobApplyScreen';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Constants.background,
            title: AppBarTitle(
              title: widget.job.title,
            ),
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Constants.lightPrimary,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          backgroundColor: Constants.background,
          body: _buildBody(context)),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          width: double.infinity,
          child: DarkTextFieldWidget(
            label: 'full name *',
            text: widget.jobApplicant.name,
            onChanged: (text) =>
            widget.jobApplicant = widget.jobApplicant.copyWith(name: text),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          width: double.infinity,
          child: DarkTextFieldWidget(
            label: 'phone number *',
            text: widget.jobApplicant.phoneNumber,
            maxLines: 1,
            onChanged: (text) => widget.jobApplicant = widget.jobApplicant.copyWith(phoneNumber: text),
          ),
        ),
        const SizedBox(height: 10),
        // todo: implement resume file upload

        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ButtonWidget(
              height: 50,
              text: 'send application',
              onClicked: () {
                FirestoreHelper.pushJobApplicant(widget.jobApplicant);
                Logx.ist(_TAG, 'application sent successfully');
                Navigator.of(context).pop();
              }),
        ),

        const SizedBox(height: 32.0),
        Spacer(),
        Footer(),
      ],
    );
  }
}
