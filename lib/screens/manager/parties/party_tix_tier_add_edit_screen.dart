import 'package:bloc/db/entity/party_tix_tier.dart';
import 'package:bloc/helpers/fresh.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../helpers/firestore_helper.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/dark_button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class PartyTixTierAddEditScreen extends StatefulWidget {
  PartyTixTier tixTier;
  String task;

  PartyTixTierAddEditScreen({key, required this.tixTier, required this.task})
      : super(key: key);

  @override
  _PartyTixTierAddEditScreenState createState() =>
      _PartyTixTierAddEditScreenState();
}

class _PartyTixTierAddEditScreenState extends State<PartyTixTierAddEditScreen> {
  static const String _TAG = 'PartyTixTierAddEditScreen';

  DateTime sEndDateTime = DateTime.now();
  DateTime sDate = DateTime.now();
  TimeOfDay sTimeOfDay = TimeOfDay.now();

  @override
  void initState() {
    sEndDateTime = DateTimeUtils.getDate(widget.tixTier.endTime == 0
        ? Timestamp.now().millisecondsSinceEpoch
        : widget.tixTier.endTime);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: AppBarTitle(
            title: '${widget.task} tix tier',
          ),
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
        TextFieldWidget(
          label: 'level *',
          text: widget.tixTier.tierLevel.toString(),
          maxLines: 1,
          onChanged: (value) {
            int? num = int.tryParse(value);
            widget.tixTier = widget.tixTier.copyWith(tierLevel: num);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'name *',
          text: widget.tixTier.tierName,
          onChanged: (text) =>
              widget.tixTier = widget.tixTier.copyWith(tierName: text),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'description *',
          text: widget.tixTier.tierDescription,
          maxLines: 5,
          onChanged: (text) =>
              widget.tixTier = widget.tixTier.copyWith(tierDescription: text),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'price *',
          text: widget.tixTier.tierPrice.toString(),
          maxLines: 1,
          onChanged: (value) {
            double? num = double.tryParse(value);
            widget.tixTier = widget.tixTier.copyWith(tierPrice: num);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'sold count',
          text: widget.tixTier.soldCount.toString(),
          maxLines: 1,
          onChanged: (value) {
            int? num = int.tryParse(value);
            widget.tixTier = widget.tixTier.copyWith(soldCount: num);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'total tix',
          text: widget.tixTier.totalTix.toString(),
          maxLines: 1,
          onChanged: (value) {
            int? num = int.tryParse(value);
            widget.tixTier = widget.tixTier.copyWith(totalTix: num);
          },
        ),
        const SizedBox(height: 24),
        dateTimeContainer(context, 'end'),
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            const Text(
              'sold out : ',
              style: TextStyle(fontSize: 17.0),
            ), //Text
            const SizedBox(width: 10), //SizedBox
            Checkbox(
              value: widget.tixTier.isSoldOut,
              onChanged: (value) {
                setState(() {
                  widget.tixTier = widget.tixTier.copyWith(isSoldOut: value);
                });
              },
            ), //Checkbox
          ], //<Widget>[]
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: '💾 save',
          onClicked: () async {
            PartyTixTier freshTixTier = Fresh.freshPartyTixTier(widget.tixTier);

            FirestoreHelper.pushPartyTixTier(freshTixTier);
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 24),
        DarkButtonWidget(
          text: 'delete',
          onClicked: () {
            FirestoreHelper.deletePartyTixTier(widget.tixTier.id);
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget dateTimeContainer(BuildContext context, String type) {
    // sEndDateTime = DateTimeUtils.getDate(widget.tixTier.endTime == 0
    //     ? Timestamp.now().millisecondsSinceEpoch
    //     : widget.tixTier.endTime);

    DateTime dateTime;
    dateTime = sEndDateTime;

    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black38,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      padding: const EdgeInsets.only(left: 10, top: 5, right: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              DateTimeUtils.getFormattedDateString(
                  dateTime.millisecondsSinceEpoch),
              style: const TextStyle(
                fontSize: 18,
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
            onPressed: () {
              _selectDate(context, dateTime);
            },
            child: const Text('end date & time'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime initDate) async {
    final DateTime? _sDate = await showDatePicker(
        context: context,
        initialDate: initDate,
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2101));
    if (_sDate != null) {
      DateTime sDateTemp = DateTime(_sDate.year, _sDate.month, _sDate.day);

      setState(() {
        sDate = sDateTemp;
        _selectTime(context);
      });
    }
  }

  Future<TimeOfDay> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    setState(() {
      sTimeOfDay = pickedTime!;
      DateTime sDateTime = DateTime(sDate.year, sDate.month, sDate.day,
          sTimeOfDay.hour, sTimeOfDay.minute);
      sEndDateTime = sDateTime;

      widget.tixTier =
          widget.tixTier.copyWith(endTime: sDateTime.millisecondsSinceEpoch);
    });
    return sTimeOfDay;
  }
}
