import 'dart:io';

import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/helpers/fresh.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../db/entity/party.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/logx.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/profile_widget.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';
import '../../../widgets/ui/toaster.dart';

class PartyAddEditScreen extends StatefulWidget {
  Party party;
  String task;

  PartyAddEditScreen({key, required this.party, required this.task})
      : super(key: key);

  @override
  _PartyAddEditScreenState createState() => _PartyAddEditScreenState();
}

class _PartyAddEditScreenState extends State<PartyAddEditScreen> {
  static const String _TAG = 'PartyAddEditScreen';

  bool isPhotoChanged = false;
  late String oldImageUrl;
  late String newImageUrl;
  String imagePath = '';
  String storyImagePath = '';

  List<BlocService> blocServices = [];
  List<String> blocServiceNames = [];
  late String _sBlocServiceName;
  late String _sBlocServiceId;
  bool _isBlocServicesLoading = true;

  DateTime sStartDateTime = DateTime.now();
  DateTime sEndDateTime = DateTime.now();
  DateTime sEndGuestListDateTime = DateTime.now();
  bool _isGuestListDateBeingSet = true;

  DateTime sDate = DateTime.now();

  TimeOfDay sTimeOfDay = TimeOfDay.now();
  bool _isStartDateBeingSet = true;
  bool _isEndDateBeingSet = true;

  late String sGuestCount;
  List<String> guestCounts = [];

  late String _sPartyType;
  List<String> partyTypes = ['artist', 'event'];

  @override
  void initState() {
    super.initState();

    _sPartyType = widget.party.type;

    FirestoreHelper.pullAllBlocServices().then((res) {
      Logx.i(_TAG, "successfully pulled in all bloc services ");

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
        Logx.i(_TAG, 'no bloc services found!');
        setState(() {
          _isBlocServicesLoading = false;
        });
      }
    });

    for (int i = 1; i <= 10; i++) {
      guestCounts.add(i.toString());
    }
    sGuestCount = widget.party.guestListCount.toString();
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
      } else if(_isEndDateBeingSet) {
        sEndDateTime = sDateTime;
        widget.party = widget.party
            .copyWith(endTime: sEndDateTime.millisecondsSinceEpoch);
      } else if(_isGuestListDateBeingSet){
        sEndGuestListDateTime = sDateTime;
        widget.party = widget.party
            .copyWith(guestListEndTime: sEndGuestListDateTime.millisecondsSinceEpoch);
      } else {
        Logx.em(_TAG, 'unhandled date time');
      }
    });
    return sTimeOfDay;
  }

  Widget dateTimeContainer(BuildContext context, String type) {
    sStartDateTime = DateTimeUtils.getDate(widget.party.startTime);
    sEndDateTime = DateTimeUtils.getDate(widget.party.endTime);
    sEndGuestListDateTime = DateTimeUtils.getDate(widget.party.guestListEndTime);

    DateTime dateTime;
    if(type=='start'){
      dateTime = sStartDateTime;
    } else if (type == 'end'){
      dateTime = sEndDateTime;
    } else {
      dateTime = sEndGuestListDateTime;
    }

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
          Text(DateTimeUtils.getFormattedDateString(dateTime.millisecondsSinceEpoch),
              style: const TextStyle(
            fontSize: 18,
          )),
          const SizedBox(
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
              minimumSize: const Size(50, 50), //////// HERE
            ),
            onPressed: () {
              if(type == 'start'){
                _isStartDateBeingSet = true;
                _isEndDateBeingSet = false;
                _isGuestListDateBeingSet = false;
              } else if (type == 'end'){
                _isStartDateBeingSet = false;
                _isEndDateBeingSet = true;
                _isGuestListDateBeingSet = false;
              } else {
                _isStartDateBeingSet = false;
                _isEndDateBeingSet = false;
                _isGuestListDateBeingSet = true;
              }
              _selectDate(context, dateTime);
            },
            child: Text(type == 'guestListEndTime'? 'guestlist end time'  : type + ' date & time'),
          ),
        ],
      ),
    );
  }

  _buildBody(BuildContext context) {
    return _isBlocServicesLoading
        ? const LoadingWidget()
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
                  ProfileWidget(
                    imagePath: storyImagePath.isEmpty ? widget.party.storyImageUrl : storyImagePath,
                    isEdit: true,
                    onClicked: () async {
                      final image = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 100,
                          maxHeight: 1920,
                          maxWidth: 1080);
                      if (image == null) return;

                      final directory = await getApplicationDocumentsDirectory();
                      final name = basename(image.path);
                      final imageFile = File('${directory.path}/$name');
                      final newImage = await File(image.path).copy(imageFile.path);

                      String tempImageUrl = await FirestorageHelper.uploadFile(
                          FirestorageHelper.PARTY_STORY_IMAGES,
                          StringUtils.getRandomString(28),
                          newImage);

                      setState(() {
                        storyImagePath = imageFile.path;

                        if(widget.party.storyImageUrl.isNotEmpty){
                          FirestorageHelper.deleteFile(widget.party.storyImageUrl);
                        }

                        widget.party = widget.party.copyWith(storyImageUrl: tempImageUrl);
                        FirestoreHelper.pushParty(widget.party);
                        Toaster.shortToast('updated party story image');
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ButtonWidget(
                text: 'pick story image file',
                onClicked: () async {
                  final image = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 100,
                      maxHeight: 1920,
                      maxWidth: 1080);
                  if (image == null) return;

                  final directory = await getApplicationDocumentsDirectory();
                  final name = basename(image.path);
                  final imageFile = File('${directory.path}/$name');
                  final newImage = await File(image.path).copy(imageFile.path);

                  newImageUrl = await FirestorageHelper.uploadFile(
                      FirestorageHelper.PARTY_STORY_IMAGES,
                      StringUtils.getRandomString(28),
                      newImage);

                  setState(() {
                    widget.party = widget.party.copyWith(storyImageUrl: newImageUrl);
                    FirestoreHelper.pushParty(widget.party);
                    Toaster.shortToast('updated party story image');
                  });
                },
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'name \*',
                text: widget.party.name,
                onChanged: (name) =>
                    widget.party = widget.party.copyWith(name: name),
              ),

              const SizedBox(height: 24),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    key: const ValueKey('party_type'),
                    decoration: InputDecoration(
                        errorStyle: TextStyle(
                            color: Theme.of(context).errorColor,
                            fontSize: 16.0),
                        hintText: 'please select party type',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    isEmpty: _sPartyType == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sPartyType,
                        isDense: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            _sPartyType = newValue!;

                            widget.party = widget.party
                                .copyWith(type: _sPartyType);
                            state.didChange(newValue);
                          });
                        },
                        items: partyTypes.map((String value) {
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
                label: 'event name',
                text: widget.party.eventName,
                maxLength: 20,
                onChanged: (eventName) =>
                widget.party = widget.party.copyWith(eventName: eventName),
              ),

              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'genre',
                text: widget.party.genre,
                maxLength: 20,
                onChanged: (genre) =>
                widget.party = widget.party.copyWith(genre: genre),
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
              dateTimeContainer(context, 'start'),

              const SizedBox(height: 24),
              dateTimeContainer(context, 'end'),

              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  const Text(
                    'active : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
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
              Row(
                children: <Widget>[
                  const Text(
                    'to be announced : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
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
              Row(
                children: <Widget>[
                  const Text(
                    'big act : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isBigAct,
                    onChanged: (value) {
                      setState(() {
                        widget.party = widget.party.copyWith(isBigAct: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),

              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  const Text(
                    'ticketed event : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isTicketed,
                    onChanged: (value) {
                      setState(() {
                        widget.party = widget.party.copyWith(isTicketed: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),

              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Text(
                    'guestlist active : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isGuestListActive,
                    onChanged: (value) {
                      setState(() {
                        widget.party = widget.party.copyWith(isGuestListActive: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'guests count',
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
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
                            hintText: 'please select guest count',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
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
                                color: Theme.of(context).primaryColorLight),
                            dropdownColor: Theme.of(context).backgroundColor,
                            value: sGuestCount,
                            isDense: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                sGuestCount = newValue!;
                                int count = int.parse(sGuestCount);

                                widget.party = widget.party
                                    .copyWith(guestListCount: count);
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
                ],
              ),

              const SizedBox(height: 24),
              dateTimeContainer(context, 'guestListEndTime'),

              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  const Text(
                    'email required : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isEmailRequired,
                    onChanged: (value) {
                      setState(() {
                        widget.party = widget.party.copyWith(isEmailRequired: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),

              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'guest list rules',
                text: widget.party.guestListRules,
                maxLines: 5,
                onChanged: (value) {
                  widget.party = widget.party.copyWith(guestListRules: value);
                },
              ),

              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'club rules',
                text: widget.party.clubRules,
                maxLines: 5,
                onChanged: (value) {
                  widget.party = widget.party.copyWith(clubRules: value);
                },
              ),

              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  const Text(
                    'challenge active : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isChallengeActive,
                    onChanged: (value) {
                      setState(() {
                        widget.party = widget.party.copyWith(isChallengeActive: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'challenge',
                text: widget.party.challenge,
                maxLines: 5,
                onChanged: (value) {
                  widget.party = widget.party.copyWith(challenge: value);
                },
              ),

              const SizedBox(height: 24),
              ButtonWidget(
                text: 'save',
                onClicked: () {
                  if (isPhotoChanged) {
                    widget.party = widget.party.copyWith(imageUrl: newImageUrl);
                    if(oldImageUrl.isNotEmpty) {
                      FirestorageHelper.deleteFile(oldImageUrl);
                    }
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
              const SizedBox(height: 24),
              ButtonWidget(
                text: 'delete',
                onClicked: () {
                  if(widget.party.imageUrl.isNotEmpty){
                    FirestorageHelper.deleteFile(widget.party.imageUrl);
                  }

                  FirestoreHelper.deleteParty(widget.party);
                  Toaster.shortToast('deleted party ' + widget.party.name);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 5),
            ],
          );
  }
}


