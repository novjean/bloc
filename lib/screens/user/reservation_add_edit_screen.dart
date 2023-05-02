import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../db/entity/reservation.dart';
import '../../helpers/firestore_helper.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/logx.dart';
import '../../widgets/ui/button_widget.dart';
import '../../widgets/ui/dark_textfield_widget.dart';
import '../../widgets/ui/toaster.dart';

class ReservationAddEditScreen extends StatefulWidget {
  Reservation reservation;
  String task;

  ReservationAddEditScreen(
      {Key? key, required this.reservation, required this.task})
      : super(key: key);

  @override
  State<ReservationAddEditScreen> createState() =>
      _ReservationAddEditScreenState();
}

class _ReservationAddEditScreenState extends State<ReservationAddEditScreen> {
  static const String _TAG = 'ReservationAddEditScreen';

  final TextEditingController _controller = TextEditingController();

  DateTime sDateArrival = DateTime.now();
  TimeOfDay sArrivalTime = TimeOfDay.now();

  List<String> guestCounts = [];
  late String sGuestCount;

  bool isLoggedIn = false;
  String completePhoneNumber = '';

  @override
  void initState() {
    super.initState();

    for (int i = 1; i <= 15; i++) {
      guestCounts.add(i.toString());
    }
    sGuestCount = widget.reservation.guestsCount.toString();

    if(widget.reservation.arrivalTime.isEmpty){
      sArrivalTime = TimeOfDay.now();
    } else {
      sArrivalTime = DateTimeUtils.getTimeOfDay(widget.reservation.arrivalTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('bloc | reservations')),
      backgroundColor: Theme.of(context).backgroundColor,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        DarkTextFieldWidget(
          label: 'name \*',
          text: widget.reservation.name,
          onChanged: (name) =>
              widget.reservation = widget.reservation.copyWith(name: name),
        ),
        !UserPreferences.isUserLoggedIn()
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'phone number \*',
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: IntlPhoneField(
                      style: TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 18),
                      decoration: InputDecoration(
                          labelText: '',
                          labelStyle:
                              TextStyle(color: Theme.of(context).primaryColor),
                          hintStyle:
                              TextStyle(color: Theme.of(context).primaryColor),
                          counterStyle:
                              TextStyle(color: Theme.of(context).primaryColor),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 0.0),
                          )),
                      controller: _controller,
                      initialCountryCode: 'IN',
                      dropdownTextStyle: TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 18),
                      pickerDialogStyle: PickerDialogStyle(
                          backgroundColor: Theme.of(context).primaryColor),
                      onChanged: (phone) {
                        Logx.i(_TAG, phone.completeNumber);
                        completePhoneNumber = phone.completeNumber;
                      },
                      onCountryChanged: (country) {
                        Logx.i(_TAG, 'country changed to: ' + country.name);
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        const SizedBox(height: 24),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'date \*',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            dateContainer(context),
          ],
        ),
        const SizedBox(height: 24),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'expected time of arrival',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

              ],
            ),
            timeContainer(context),
          ],
        ),
        const SizedBox(height: 24),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'number of guests *',
                    style: TextStyle(
                        color:
                        Theme.of(context).primaryColorLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            FormField<String>(
              builder: (FormFieldState<String> state) {
                return InputDecorator(
                  key: const ValueKey('guest_count'),
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      errorStyle: TextStyle(
                          color: Theme.of(context).errorColor,
                          fontSize: 16.0),
                      hintText: 'please select guests count',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                            color:
                            Theme.of(context).primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        // width: 0.0 produces a thin "hairline" border
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 0.0),
                      )),
                  isEmpty: sGuestCount == '',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryColorLight),
                      dropdownColor:
                      Theme.of(context).backgroundColor,
                      value: sGuestCount,
                      isDense: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          sGuestCount = newValue!;
                          widget.reservation = widget.reservation
                              .copyWith(guestsCount: int.parse(sGuestCount));
                          state.didChange(newValue);
                        });
                      },
                      items: guestCounts.map((String value) {
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
          ],
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

        ButtonWidget(
          text: 'reserve',
          onClicked: () {

            FirestoreHelper.pushReservation(widget.reservation);

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget dateContainer(BuildContext context) {
    sDateArrival = DateTimeUtils.getDate(widget.reservation.arrivalDate);
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      padding: const EdgeInsets.only(left: 10, top: 5, right: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              DateTimeUtils.getFormattedDateType(
                  sDateArrival.millisecondsSinceEpoch, 0),
              style: const TextStyle(
                color: Constants.primary,
                fontSize: 18,
              )),
          const SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              shadowColor: Theme.of(context).primaryColor,
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0)),
              minimumSize: const Size(50, 50), //////// HERE
            ),
            onPressed: () {
              _selectDate(context, sDateArrival);
            },
            child: const Text('pick date'),
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
      setState(() {
        sDateArrival= DateTime(_sDate.year, _sDate.month, _sDate.day);
        widget.reservation = widget.reservation.copyWith(arrivalDate: sDateArrival.millisecondsSinceEpoch);
      });
    }
  }


Future<void> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    setState(() {
      sArrivalTime = pickedTime!;
      widget.reservation = widget.reservation.copyWith(arrivalTime: sArrivalTime.format(context));
    });
  }

  Widget timeContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      padding: const EdgeInsets.only(left: 10, top: 5, right: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(sArrivalTime.format(context),
              style: const TextStyle(
                color: Constants.primary,
                fontSize: 18,
              )),
          const SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              shadowColor: Theme.of(context).primaryColor,
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0)),
              minimumSize: const Size(50, 50), //////// HERE
            ),
            onPressed: () {
              _selectTime(context);
            },
            child: const Text('pick time'),
          ),
        ],
      ),
    );
  }
}
