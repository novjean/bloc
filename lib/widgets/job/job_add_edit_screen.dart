import 'package:bloc/helpers/fresh.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/genre.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';
import '../../../widgets/ui/toaster.dart';
import '../../db/entity/job.dart';

class JobAddEditScreen extends StatefulWidget {
  Job job;
  String task;

  JobAddEditScreen({key, required this.job, required this.task})
      : super(key: key);

  @override
  _JobAddEditScreenState createState() => _JobAddEditScreenState();
}

class _JobAddEditScreenState extends State<JobAddEditScreen> {
  static const String _TAG = 'JobAddEditScreen';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('${widget.task} job'),
    ),
    body: _buildBody(context),
  );

  _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        TextFieldWidget(
          label: 'title *',
          text: widget.job.title,
          onChanged: (text) => widget.job = widget.job.copyWith(title: text),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'description *',
          text: widget.job.description,
          maxLines: 5,
          onChanged: (text) => widget.job = widget.job.copyWith(description: text),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            const Text(
              'active : ',
              style: TextStyle(fontSize: 17.0),
            ),
            const SizedBox(width: 10),
            Checkbox(
              value: widget.job.isActive,
              onChanged: (value) {
                setState(() {
                  widget.job = widget.job.copyWith(isActive: value);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'save',
          onClicked: () {
            Job freshJob = Fresh.freshJob(widget.job);
            FirestoreHelper.pushJob(freshJob);

            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'delete',
          onClicked: () {
            FirestoreHelper.deleteJob(widget.job.id);
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
