import 'package:bloc/widgets/ui/textfield_widget.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/lounge.dart';
import '../../../db/entity/user.dart' as blocUser;

import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/dark_button_widget.dart';
import '../../../widgets/ui/toaster.dart';

class LoungeAddEditScreen extends StatefulWidget {
  Lounge lounge;
  String task;

  LoungeAddEditScreen(
      {Key? key, required this.lounge, required this.task})
      : super(key: key);

  @override
  State<LoungeAddEditScreen> createState() =>
      _LoungeAddEditScreenState();
}

class _LoungeAddEditScreenState extends State<LoungeAddEditScreen> {
  static const String _TAG = 'LoungeAddEditScreen';

  final TextEditingController _controller = TextEditingController();

  DateTime sDateArrival = DateTime.now();
  TimeOfDay sArrivalTime = TimeOfDay.now();

  List<String> guestCounts = [];
  late String sGuestCount;

  List<String> loungeTypes = ['artist', 'community'];
  late String sType;

  final pinController = TextEditingController();
  final focusNode = FocusNode();
  bool isLoggedIn = false;
  String completePhoneNumber = '';
  String _verificationCode = '';

  late blocUser.User bloc_user;
  bool isEdit = false;



  @override
  void initState() {
    sType = widget.lounge.type;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('lounge | ${widget.task}')),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        TextFieldWidget(
            label: 'name \*',
            text: widget.lounge.name,
            onChanged: (name) {
              widget.lounge = widget.lounge.copyWith(name: name);
            }),
        const SizedBox(height: 24),

        FormField<String>(
          builder: (FormFieldState<String> state) {
            return InputDecorator(
              key: const ValueKey('lounge_type'),
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  errorStyle: TextStyle(
                      color: Theme.of(context).errorColor, fontSize: 16.0),
                  hintText: 'please select lounge type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // width: 0.0 produces a thin "hairline" border
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 0.0),
                  )),
              isEmpty: sType == '',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  style:
                  TextStyle(color: Theme.of(context).primaryColorLight),
                  dropdownColor: Theme.of(context).backgroundColor,
                  value: sType,
                  isDense: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      sType = newValue!;
                      widget.lounge =
                          widget.lounge.copyWith(type: sType);
                      state.didChange(newValue);
                    });
                  },
                  items: loungeTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 5),
              child: DelayedDisplay(
                delay: const Duration(seconds: 1),
                child: Text(
                  "* required",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ButtonWidget(
              height: 50,
              text: 'save',
              onClicked: () {
                Lounge freshLounge = Fresh.freshLounge(widget.lounge);
                FirestoreHelper.pushLounge(freshLounge);

                Toaster.shortToast('lounge saved');
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 36),
            DarkButtonWidget(
                height: 50,
                text: 'delete',
                onClicked: () {
                  FirestoreHelper.deleteLounge(widget.lounge.id);
                  Toaster.shortToast('lounge deleted');
                  Navigator.of(context).pop();
                }),
          ],
        ),
        const SizedBox(height: 48),
      ],
    );
  }


}
