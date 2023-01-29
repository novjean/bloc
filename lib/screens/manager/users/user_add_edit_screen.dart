import 'dart:io';

import 'package:bloc/db/entity/bloc_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../db/entity/user.dart';
import '../../../db/entity/user_level.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/profile_widget.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class UserAddEditScreen extends StatefulWidget {
  User user;
  String task;
  List<UserLevel> userLevels;

  UserAddEditScreen({key, required this.user, required this.task, required this.userLevels})
      : super(key: key);

  @override
  _UserAddEditScreenState createState() => _UserAddEditScreenState();
}

class _UserAddEditScreenState extends State<UserAddEditScreen> {
  bool isPhotoChanged = false;
  late String oldImageUrl;
  late String newImageUrl;
  String imagePath = '';

  List<BlocService> blocServices = [];
  List<String> blocServiceNames = [];
  late String _sBlocServiceName;
  late String _sBlocServiceId;
  bool _isBlocServicesLoading = true;

  List<String> userLevelNames = [];
  late String _sUserLevelName;
  late int _sUserLevel;

  DateTime sStartDateTime = DateTime.now();
  DateTime sEndDateTime = DateTime.now();

  TimeOfDay _sTimeOfDay = TimeOfDay.now();
  bool _isStartDateBeingSet = true;

  @override
  void initState() {
    super.initState();

    for(UserLevel userLevel in widget.userLevels){
      userLevelNames.add(userLevel.name);
      if(widget.user.clearanceLevel == userLevel.level){
        _sUserLevelName = userLevel.name;
      }
    }

    FirestoreHelper.pullAllBlocServices().then((res) {
      print("successfully pulled in all bloc services");

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
      title: Text('user | ' + widget.task),
    ),
    body: _buildBody(context),
  );

  // Future<void> _selectDate(BuildContext context, DateTime initDate) async {
  //   final DateTime? _sDate = await showDatePicker(
  //       context: context,
  //       initialDate: initDate,
  //       firstDate: DateTime(2023, 1),
  //       lastDate: DateTime(2101));
  //   if (_sDate != null) {
  //     _selectTime(context);
  //
  //     setState(() {
  //       DateTime _sDateTime = DateTime(_sDate.year, _sDate.month, _sDate.day,
  //           _sTimeOfDay.hour, _sTimeOfDay.minute);
  //
  //       // from here we decide what field to put it into
  //       if (_isStartDateBeingSet) {
  //         sStartDateTime = _sDateTime;
  //         widget.user = widget.user
  //             .copyWith(startTime: sStartDateTime.millisecondsSinceEpoch);
  //       } else {
  //         sEndDateTime = _sDateTime;
  //         widget.user = widget.user
  //             .copyWith(endTime: sEndDateTime.millisecondsSinceEpoch);
  //       }
  //     });
  //   }
  // }

  // Future<TimeOfDay> _selectTime(BuildContext context) async {
  //   TimeOfDay initialTime = TimeOfDay.now();
  //
  //   TimeOfDay? pickedTime = await showTimePicker(
  //     context: context,
  //     initialTime: initialTime,
  //   );
  //
  //   _sTimeOfDay = pickedTime!;
  //   return _sTimeOfDay;
  // }

  // Widget dateTimeContainer(BuildContext context, String type) {
  //   DateTime dateTime = type=='Start' ? sStartDateTime:sEndDateTime;
  //
  //   return Container(
  //     decoration: BoxDecoration(
  //         border: Border.all(
  //           color: Colors.black38,
  //         ),
  //         borderRadius: BorderRadius.all(Radius.circular(20))),
  //     padding: EdgeInsets.only(left: 10, top: 5, right: 5, bottom: 5),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text("${dateTime.toLocal()}".split(' ')[0], style: TextStyle(
  //           fontSize: 18,
  //         )),
  //         SizedBox(
  //           height: 20.0,
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             primary: Theme.of(context).primaryColor,
  //             onPrimary: Colors.white,
  //             shadowColor: Theme.of(context).shadowColor,
  //             elevation: 3,
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(32.0)),
  //             minimumSize: Size(50, 50), //////// HERE
  //           ),
  //           onPressed: () {
  //             if(type == 'Start'){
  //               _isStartDateBeingSet = true;
  //             } else {
  //               _isStartDateBeingSet = false;
  //             }
  //             _selectDate(context, dateTime);
  //           },
  //           child: Text(type + ' Date & Time'),
  //         ),
  //       ],
  //     ),
  //   );
  //
  // }

  _buildBody(BuildContext context) {
    return _isBlocServicesLoading
        ? Center(
      child: Text('loading user...'),
    )
        : ListView(
      padding: EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        ProfileWidget(
          imagePath: imagePath.isEmpty? widget.user.imageUrl:imagePath,
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

            oldImageUrl = widget.user.imageUrl;
            newImageUrl = await FirestorageHelper.uploadFile(
                FirestorageHelper.USER_IMAGES,
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
          text: widget.user.name,
          onChanged: (name) =>
          widget.user = widget.user.copyWith(name: name),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'phone',
          text: widget.user.phoneNumber.toString(),
          maxLines: 1,
          onChanged: (value) {
            int phoneNumber = int.parse(value);
            widget.user = widget.user.copyWith(phoneNumber: phoneNumber);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'email',
          text: widget.user.email,
          maxLines: 1,
          onChanged: (value) {
            widget.user = widget.user.copyWith(email: value);
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

                      widget.user = widget.user
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
        FormField<String>(
          builder: (FormFieldState<String> state) {
            return InputDecorator(
              key: const ValueKey('user_level'),
              decoration: InputDecoration(
                  errorStyle: TextStyle(
                      color: Theme.of(context).errorColor,
                      fontSize: 16.0),
                  hintText: 'please select user level',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              isEmpty: _sUserLevelName == '',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sUserLevelName,
                  isDense: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      _sUserLevelName = newValue!;

                      for (UserLevel userLevel in widget.userLevels) {
                        if (userLevel.name == _sUserLevelName) {
                          _sUserLevel = userLevel.level;
                        }
                      }

                      widget.user = widget.user
                          .copyWith(clearanceLevel: _sUserLevel);
                      state.didChange(newValue);
                    });
                  },
                  items: userLevelNames.map((String value) {
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
        ButtonWidget(
          text: 'save',
          onClicked: () {
            if (isPhotoChanged) {
              widget.user = widget.user.copyWith(imageUrl: newImageUrl);
              if(oldImageUrl.isNotEmpty){
                try {
                  FirestorageHelper.deleteFile(oldImageUrl);
                } catch (err){
                  print(err);
                }
              }
            }

            if (widget.user.blocServiceId.isEmpty) {
              widget.user =
                  widget.user.copyWith(blocServiceId: _sBlocServiceId);
            }

            FirestoreHelper.pushUser(widget.user);

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}


