import 'dart:io';

import 'package:bloc/db/entity/job_applicant.dart';
import 'package:bloc/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../helpers/firestore_helper.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../widgets/footer.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/dark_textfield_widget.dart';
import '../../db/entity/job.dart';
import '../../helpers/firestorage_helper.dart';
import '../../utils/string_utils.dart';

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

  String? pickedFileName = '';
  String? pickedFileType = '';

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
                if(widget.task == 'add' && widget.jobApplicant.resumeUrl.isNotEmpty){
                  FirestorageHelper.deleteFile(widget.jobApplicant.resumeUrl);
                }
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
          child: Text(widget.job.description, style: TextStyle(color: Constants.lightPrimary),),
        ),
        const SizedBox(height: 15),
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
        const SizedBox(height: 15),
        // todo: implement resume file upload
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text('resumé / work history',
                textAlign: TextAlign.left,
                style: TextStyle(color: Constants.lightPrimary, fontSize: 16,
                    fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: Constants.lightPrimary,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(9))),
            padding: const EdgeInsets.only(left: 10, top: 5, right: 5, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    pickedFileName == '' ?'pdf/doc/docx file': pickedFileName!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Constants.lightPrimary
                    )),
                const SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Constants.primary,
                    shadowColor: Constants.shadowColor,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    minimumSize: const Size(50, 50),
                  ),
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                        allowedExtensions: ['pdf', 'doc', 'docx'],
                    );

                    if (result != null) {
                      Logx.ist(_TAG, 'uploading file...');

                      if(kIsWeb){
                        if (result != null && result.files.isNotEmpty) {
                          final fileBytes = result.files.first.bytes;
                          final fileName = result.files.first.name;
                          pickedFileType = result.files.single.extension;

                          String resumeUrl = await FirestorageHelper.uploadDocFileWeb(FirestorageHelper.JOB_RESUMES,
                              StringUtils.getRandomString(28), fileBytes!, fileName, pickedFileType!);

                          setState(() {
                            if(widget.jobApplicant.resumeUrl.isNotEmpty){
                              String oldResumeUrl = widget.jobApplicant.resumeUrl;
                              FirestorageHelper.deleteFile(oldResumeUrl);
                            }
                            pickedFileName = result.files.single.name;
                            widget.jobApplicant = widget.jobApplicant.copyWith(resumeUrl: resumeUrl);
                          });
                        }
                      } else {
                        File file = File(result.files.single.path!);
                        pickedFileType = result.files.single.extension;

                        String resumeUrl = await FirestorageHelper.uploadDocFile(
                            FirestorageHelper.JOB_RESUMES,
                            StringUtils.getRandomString(28),
                            file, pickedFileType!);

                        setState(() {
                          if(widget.jobApplicant.resumeUrl.isNotEmpty){
                            String oldResumeUrl = widget.jobApplicant.resumeUrl;
                            FirestorageHelper.deleteFile(oldResumeUrl);
                          }
                          pickedFileName = result.files.single.name;
                          widget.jobApplicant = widget.jobApplicant.copyWith(resumeUrl: resumeUrl);
                        });
                      }
                    } else {
                      // User canceled the picker
                    }
                  },
                  child: Text('pick file', style: TextStyle(color: Constants.darkPrimary),),
                ),
              ],
            ),
          ),
        ),

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
        const Spacer(),
        Footer(),
      ],
    );
  }
}
