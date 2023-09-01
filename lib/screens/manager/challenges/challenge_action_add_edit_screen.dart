import 'package:bloc/db/entity/challenge_action.dart';
import 'package:bloc/helpers/fresh.dart';
import 'package:flutter/material.dart';

import '../../../helpers/firestore_helper.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/dark_button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class ChallengeActionAddEditScreen extends StatefulWidget {
  ChallengeAction challengeAction;
  String task;

  ChallengeActionAddEditScreen({key, required this.challengeAction, required this.task})
      : super(key: key);

  @override
  _ChallengeActionAddEditScreenState createState() => _ChallengeActionAddEditScreenState();
}

class _ChallengeActionAddEditScreenState extends State<ChallengeActionAddEditScreen> {
  static const String _TAG = 'ChallengeActionAddEditScreen';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: AppBarTitle(title:'manage challenge action'),
      titleSpacing: 0,
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
          key: const ValueKey('challenge_action_button_count'),
          initialValue: widget.challengeAction.buttonCount.toString(),
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: false,
          validator: (value) {
            if (value!.isEmpty) {
              return 'please enter a valid button count for the challenge action';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'button count *',
          ),
          onChanged: (value) {
            int? intValue = int.tryParse(value);
            widget.challengeAction = widget.challengeAction.copyWith(buttonCount: intValue);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'button title *',
          text: widget.challengeAction.buttonTitle,
          onChanged: (title) => widget.challengeAction = widget.challengeAction.copyWith(buttonTitle: title),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'action *',
          hintText: 'http:// ....',
          text: widget.challengeAction.action,
          onChanged: (text) => widget.challengeAction = widget.challengeAction.copyWith(action: text),
        ),

        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'action type *',
          hintText: 'url, instagram_url',
          text: widget.challengeAction.actionType,
          onChanged: (text) => widget.challengeAction = widget.challengeAction.copyWith(actionType: text),
        ),

        const SizedBox(height: 24),
        ButtonWidget(
          text: 'save',
          onClicked: () {
            ChallengeAction fresh = Fresh.freshChallengeAction(widget.challengeAction);
            FirestoreHelper.pushChallengeAction(fresh);

            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 36),
        DarkButtonWidget(
          text: 'delete',
          onClicked: () {
            FirestoreHelper.deleteChallengeAction(widget.challengeAction.id);

            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
