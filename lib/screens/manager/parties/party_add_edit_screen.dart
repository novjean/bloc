import 'dart:io';

import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/helpers/fresh.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../db/entity/party.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/profile_widget.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class PartyAddEditScreen extends StatefulWidget {
  Party party;
  String task;

  PartyAddEditScreen({key, required this.party, required this.task})
      : super(key: key);

  @override
  _PartyAddEditScreenState createState() => _PartyAddEditScreenState();
}

class _PartyAddEditScreenState extends State<PartyAddEditScreen> {
  bool isPhotoChanged = false;
  late String oldImageUrl;
  late String newImageUrl;
  String imagePath = '';

  List<BlocService> blocServices = [];
  List<String> blocServiceNames = [];
  late String _sBlocServiceName;
  late String _sBlocServiceId;
  bool _isBlocServicesLoading = true;

  DateTime sStartDateTime = DateTime.now();
  DateTime sEndDateTime = DateTime.now();
  DateTime sDate = DateTime.now();

  TimeOfDay sTimeOfDay = TimeOfDay.now();
  bool _isStartDateBeingSet = true;

  @override
  void initState() {
    super.initState();

    FirestoreHelper.pullAllBlocServices().then((res) {
      print("successfully pulled in all bloc services ");

      if (res.docs.isNotEmpty) {
        List<BlocService> _blocServices = [];
        List<String> _blocServiceNames = [];

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final BlocService blocService = BlocService.fromMap(data);

          if (i == 0) {
            _sBlocServiceId = blocService.id;
            _sBlocServiceName = blocService.name;
          }

          _blocServiceNames.add(blocService.name);
          _blocServices.add(blocService);
        }

        setState(() {
          blocServiceNames = _blocServiceNames;
          blocServices = _blocServices;
          _isBlocServicesLoading = false;
        });
      } else {
        print('no bloc services found!');
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('party | ' + widget.task),
        ),
        body: _buildBody(context),
      );

  Future<void> _selectDate(BuildContext context, DateTime initDate) async {
    final DateTime? _sDate = await showDatePicker(
        context: context,
        initialDate: initDate,
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2101));
    if (_sDate != null) {
      DateTime _sDateTemp = DateTime(_sDate.year, _sDate.month, _sDate.day);

      setState(() {
        sDate = _sDateTemp;
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

    setState((){
      sTimeOfDay = pickedTime!;

      DateTime sDateTime = DateTime(sDate.year, sDate.month, sDate.day, sTimeOfDay.hour, sTimeOfDay.minute);

      if (_isStartDateBeingSet) {
        sStartDateTime = sDateTime;
        widget.party = widget.party
            .copyWith(startTime: sStartDateTime.millisecondsSinceEpoch);
      } else {
        sEndDateTime = sDateTime;
        widget.party = widget.party
            .copyWith(endTime: sEndDateTime.millisecondsSinceEpoch);
      }
    });
    return sTimeOfDay;
  }

  Widget dateTimeContainer(BuildContext context, String type) {
    sStartDateTime = DateTimeUtils.getDate(widget.party.startTime);
    sEndDateTime = DateTimeUtils.getDate(widget.party.endTime);

    DateTime dateTime = type=='start' ? sStartDateTime:sEndDateTime;

    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black38,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      padding: EdgeInsets.only(left: 10, top: 5, right: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${DateTimeUtils.getFormattedDateString(dateTime.millisecondsSinceEpoch)}", style: TextStyle(
            fontSize: 18,
          )),
          SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              shadowColor: Theme.of(context).shadowColor,
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0)),
              minimumSize: Size(50, 50), //////// HERE
            ),
            onPressed: () {
              if(type == 'start'){
                _isStartDateBeingSet = true;
              } else {
                _isStartDateBeingSet = false;
              }
              _selectDate(context, dateTime);
            },
            child: Text(type + ' date & time'),
          ),
        ],
      ),
    );

  }

  _buildBody(BuildContext context) {
    return _isBlocServicesLoading
        ? const Center(
            child: Text('parties loading...'),
          )
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 15),
              ProfileWidget(
                imagePath: imagePath.isEmpty ? widget.party.imageUrl : imagePath,
                isEdit: true,
                onClicked: () async {
                  final image = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 90,
                      maxWidth: 500);
                  if (image == null) return;

                  final directory = await getApplicationDocumentsDirectory();
                  final name = basename(image.path);
                  final imageFile = File('${directory.path}/$name');
                  final newImage = await File(image.path).copy(imageFile.path);

                  oldImageUrl = widget.party.imageUrl;
                  newImageUrl = await FirestorageHelper.uploadFile(
                      FirestorageHelper.PARTY_IMAGES,
                      StringUtils.getRandomString(28),
                      newImage);

                  setState(() {
                    imagePath = imageFile.path;
                    isPhotoChanged = true;
                  });
                },
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'name',
                text: widget.party.name,
                onChanged: (name) =>
                    widget.party = widget.party.copyWith(name: name),
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'event name',
                text: widget.party.eventName,
                onChanged: (eventName) =>
                widget.party = widget.party.copyWith(eventName: eventName),
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'description',
                text: widget.party.description,
                maxLines: 5,
                onChanged: (value) {
                  widget.party = widget.party.copyWith(description: value);
                },
              ),

              const SizedBox(height: 24),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    key: const ValueKey('bloc_service_id'),
                    decoration: InputDecoration(
                        errorStyle: TextStyle(
                            color: Theme.of(context).errorColor,
                            fontSize: 16.0),
                        hintText: 'please select bloc service',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    isEmpty: _sBlocServiceName == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sBlocServiceName,
                        isDense: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            _sBlocServiceName = newValue!;

                            for (BlocService service in blocServices) {
                              if (service.name == _sBlocServiceName) {
                                _sBlocServiceId = service.id;
                              }
                            }

                            widget.party = widget.party
                                .copyWith(blocServiceId: _sBlocServiceId);
                            state.didChange(newValue);
                          });
                        },
                        items: blocServiceNames.map((String value) {
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
              TextFieldWidget(
                label: 'instagram url',
                text: widget.party.instagramUrl,
                maxLines: 1,
                onChanged: (value) {
                  widget.party = widget.party.copyWith(instagramUrl: value);
                },
              ),

              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'ticket url',
                text: widget.party.ticketUrl,
                maxLines: 1,
                onChanged: (value) {
                  widget.party = widget.party.copyWith(ticketUrl: value);
                },
              ),

              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'listen url',
                text: widget.party.listenUrl,
                maxLines: 1,
                onChanged: (value) {
                  widget.party = widget.party.copyWith(listenUrl: value);
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Text(
                    'active : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isActive,
                    onChanged: (value) {
                      setState(() {
                        widget.party = widget.party.copyWith(isActive: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 24),
              dateTimeContainer(context, 'start'),

              const SizedBox(height: 24),
              dateTimeContainer(context, 'end'),

              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Text(
                    'to be announced : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isTBA,
                    onChanged: (value) {
                      setState(() {
                        widget.party = widget.party.copyWith(isTBA: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),

              const SizedBox(height: 24),
              ButtonWidget(
                text: 'save',
                onClicked: () {
                  if (isPhotoChanged) {
                    widget.party = widget.party.copyWith(imageUrl: newImageUrl);
                    FirestorageHelper.deleteFile(oldImageUrl);
                  }

                  if (widget.party.blocServiceId.isEmpty) {
                    widget.party =
                        widget.party.copyWith(blocServiceId: _sBlocServiceId);
                  }

                  Party freshParty = Fresh.freshParty(widget.party);
                  FirestoreHelper.pushParty(freshParty);

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
  }
}


