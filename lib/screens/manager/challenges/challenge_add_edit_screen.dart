import 'package:bloc/helpers/fresh.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/challenge.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class ChallengeAddEditScreen extends StatefulWidget {
  Challenge challenge;
  String task;

  ChallengeAddEditScreen({key, required this.challenge, required this.task})
      : super(key: key);

  @override
  _ChallengeAddEditScreenState createState() => _ChallengeAddEditScreenState();
}

class _ChallengeAddEditScreenState extends State<ChallengeAddEditScreen> {
  static const String _TAG = 'ChallengeAddEditScreen';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('challenge | ' + widget.task),
    ),
    body: _buildBody(context),
  );

  _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        TextFormField(
          key: const ValueKey('challenge_level'),
          initialValue: widget.challenge.level.toString(),
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: false,
          validator: (value) {
            if (value!.isEmpty) {
              return 'please enter a valid level for the challenge';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'level \*',
          ),
          onChanged: (value) {
            int? intValue = int.tryParse(value);
            widget.challenge = widget.challenge.copyWith(level: intValue);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'title \*',
          text: widget.challenge.title,
          onChanged: (title) => widget.challenge = widget.challenge.copyWith(title: title),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'dialog title \*',
          text: widget.challenge.dialogTitle,
          onChanged: (text) => widget.challenge = widget.challenge.copyWith(dialogTitle: text),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'description \*',
          text: widget.challenge.description,
          maxLines: 5,
          onChanged: (description) =>
          widget.challenge = widget.challenge.copyWith(description: description),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'dialog accept text \*',
          text: widget.challenge.dialogAcceptText,
          onChanged: (text) => widget.challenge = widget.challenge.copyWith(dialogAcceptText: text),
        ),
        const SizedBox(height: 24),
        TextFormField(
          key: const ValueKey('challenge_points'),
          initialValue: widget.challenge.points.toString(),
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: false,
          validator: (value) {
            if (value!.isEmpty) {
              return 'please enter a valid points for the challenge';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'points \*',
          ),
          onChanged: (value) {
            int? intPoints = int.tryParse(value);
            widget.challenge = widget.challenge.copyWith(points: intPoints);
          },
        ),

        const SizedBox(height: 24),
        ButtonWidget(
          text: 'save',
          onClicked: () {
            Challenge freshChallenge = Fresh.freshChallenge(widget.challenge);
            FirestoreHelper.pushChallenge(freshChallenge);

            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'delete',
          onClicked: () {
            FirestoreHelper.deleteChallenge(widget.challenge.id);

            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
