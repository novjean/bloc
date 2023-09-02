import 'package:bloc/db/entity/challenge_action.dart';
import 'package:bloc/helpers/fresh.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/challenge.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/constants.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/dark_button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';
import 'challenge_action_add_edit_screen.dart';

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
          title: AppBarTitle(title: '${widget.task} challenge'),
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
          onChanged: (title) =>
              widget.challenge = widget.challenge.copyWith(title: title),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'dialog title \*',
          text: widget.challenge.dialogTitle,
          onChanged: (text) =>
              widget.challenge = widget.challenge.copyWith(dialogTitle: text),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'description \*',
          text: widget.challenge.description,
          maxLines: 5,
          onChanged: (description) => widget.challenge =
              widget.challenge.copyWith(description: description),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'dialog accept text \*',
          text: widget.challenge.dialogAcceptText,
          onChanged: (text) => widget.challenge =
              widget.challenge.copyWith(dialogAcceptText: text),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'dialog accept text 2 \*',
          text: widget.challenge.dialogAccept2Text,
          onChanged: (text) => widget.challenge =
              widget.challenge.copyWith(dialogAccept2Text: text),
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
          text: 'manage actions',
          onClicked: () {
            _loadActions(context);
          },
        ),
        const SizedBox(height: 36),
        DarkButtonWidget(
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

  void _loadActions(BuildContext context) {
    FirestoreHelper.pullChallengeActions(widget.challenge.id).then((res) {
      List<ChallengeAction> cas = [];

      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final ChallengeAction ca = Fresh.freshChallengeActionMap(data, false);
          cas.add(ca);
        }
      }

      _showActionsDialog(context, cas);
    });
  }

  void _showActionsDialog(BuildContext context, List<ChallengeAction> cas) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'actions'.toLowerCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, color: Colors.black),
          ),
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cas.length,
              itemBuilder: (BuildContext context, int index) {
                ChallengeAction ca = cas[index];
                return

                  Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => ChallengeActionAddEditScreen(
                                challengeAction: ca,
                                task: 'edit',
                              )),
                        );
                      },
                      child: ListTile(
                        title: Text(ca.buttonTitle),
                        subtitle: Text(ca.action),
                        trailing: Text('${ca.buttonCount}'),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 5),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('close',
                  style: TextStyle(color: Constants.background)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();

                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (ctx) => ChallengeActionAddEditScreen(
                            challengeAction: Dummy.getDummyChallengeAction(
                                widget.challenge.id),
                            task: 'add',
                          )),
                );
              },
              child: const Text('add action',
                  style: TextStyle(color: Constants.background)),
            )
          ],
        );
      },
    );
  }
}
