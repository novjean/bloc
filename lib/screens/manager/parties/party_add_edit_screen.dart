import 'dart:io';

import 'package:bloc/db/entity/bloc_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../db/entity/party.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
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

  List<BlocService> blocServices = [];
  List<String> blocServiceNames = [];
  late String _sBlocServiceName;
  late String _sBlocServiceId;

  bool _isBlocServicesLoading = true;


  @override
  void initState() {
    super.initState();

    FirestoreHelper.pullAllBlocServices().then((res) {
      print("successfully pulled in all bloc services... ");

      if (res.docs.isNotEmpty) {
        // _productCategory = widget.party.;
        // _productType = widget.party.type;

        List<BlocService> _blocServices = [];
        List<String> _blocServiceNames = [];

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final BlocService blocService = BlocService.fromMap(data);

          if(i==0){
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
      title: Text('Party | ' + widget.task),
    ),
    body: _buildBody(context),
  );

  _buildBody(BuildContext context) {
    return
      _isBlocServicesLoading
        ? Center(
      child: Text('Loading...'),
    )
        :
    ListView(
      padding: EdgeInsets.symmetric(horizontal: 32),
      physics: BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        ProfileWidget(
          imagePath: widget.party.imageUrl,
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

            setState(() async {
              oldImageUrl = widget.party.imageUrl;
              newImageUrl = await FirestorageHelper.uploadFile(
                  FirestorageHelper.PARTY_IMAGES,
                  widget.party.id,
                  newImage);
              isPhotoChanged = true;
            });
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Name',
          text: widget.party.name,
          onChanged: (name) =>
          widget.party = widget.party.copyWith(name: name),
        ),

        // _productType == 'Food'
        //     ? Column(
        //   children: [
        //     const SizedBox(height: 24),
        //     FormField<String>(
        //       builder: (FormFieldState<String> state) {
        //         return InputDecorator(
        //           key: const ValueKey('product_category_food'),
        //           decoration: InputDecoration(
        //               errorStyle: TextStyle(
        //                   color: Theme.of(context).errorColor,
        //                   fontSize: 16.0),
        //               hintText: 'Please select product category',
        //               border: OutlineInputBorder(
        //                   borderRadius:
        //                   BorderRadius.circular(5.0))),
        //           isEmpty: _sCategoryFood == '',
        //           child: DropdownButtonHideUnderline(
        //             child: DropdownButton<String>(
        //                 value: widget.party.category,
        //                 isDense: true,
        //                 onChanged: (String? newValue) {
        //                   setState(() {
        //                     _productCategory = newValue!;
        //                     _sCategoryFood = _productCategory;
        //                     widget.party = widget.party
        //                         .copyWith(category: newValue);
        //                     // state.didChange(newValue);
        //                   });
        //                 },
        //                 items: catFoodNames.map((String value) {
        //                   return DropdownMenuItem<String>(
        //                     value: value,
        //                     child: Text(value),
        //                   );
        //                 }).toList()),
        //           ),
        //         );
        //       },
        //     ),
        //   ],
        // )
        //     : Column(
        //   children: [
        //     const SizedBox(height: 24),
        //     FormField<String>(
        //       builder: (FormFieldState<String> state) {
        //         return InputDecorator(
        //           key: const ValueKey('product_category_alcohol'),
        //           decoration: InputDecoration(
        //               errorStyle: TextStyle(
        //                   color: Theme.of(context).errorColor,
        //                   fontSize: 16.0),
        //               hintText: 'Please select product category',
        //               border: OutlineInputBorder(
        //                   borderRadius:
        //                   BorderRadius.circular(5.0))),
        //           isEmpty: _sCategoryAlcohol == '',
        //           child: DropdownButtonHideUnderline(
        //             child: DropdownButton<String>(
        //                 value: widget.party.category,
        //                 isDense: true,
        //                 onChanged: (String? newValue) {
        //                   setState(() {
        //                     _productCategory = newValue!;
        //                     _sCategoryAlcohol = _productCategory;
        //                     widget.party = widget.party
        //                         .copyWith(category: newValue);
        //                     // state.didChange(newValue);
        //                   });
        //                 },
        //                 items: catAlcoholNames.map((String value) {
        //                   return DropdownMenuItem<String>(
        //                     value: value,
        //                     child: Text(value),
        //                   );
        //                 }).toList()),
        //           ),
        //         );
        //       },
        //     ),
        //   ],
        // ),

        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Description',
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
                  hintText: 'Please select bloc service',
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

                      for(BlocService service in blocServices){
                        if(service.name == _sBlocServiceName){
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
          label: 'Instagram URL',
          text: widget.party.instagramUrl,
          maxLines: 1,
          onChanged: (value) {
            widget.party = widget.party.copyWith(instagramUrl: value);
          },
        ),

        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Ticket URL',
          text: widget.party.ticketUrl,
          maxLines: 1,
          onChanged: (value) {
            widget.party = widget.party.copyWith(ticketUrl: value);
          },
        ),

        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            SizedBox(
              width: 0,
            ), //SizedBox
            Text(
              'Available : ',
              style: TextStyle(fontSize: 17.0),
            ), //Text
            SizedBox(width: 10), //SizedBox
            Checkbox(
              value: widget.party.isActive,
              onChanged: (value) {
                setState(() {
                  widget.party =
                      widget.party.copyWith(isActive: value);
                });
              },
            ), //Checkbox
          ], //<Widget>[]
        ),
        const SizedBox(height: 24),

        // Column(children: [
        //   Text("${selectedDate.toLocal()}".split(' ')[0]),
        //   SizedBox(height: 20.0,),
        //   RaisedButton(
        //     onPressed: () => _selectDate(context),
        //     child: Text('Select date'),
        //   ),
        // ],),

        ButtonWidget(
          text: 'Save',
          onClicked: () {
            if (isPhotoChanged) {
              widget.party =
                  widget.party.copyWith(imageUrl: newImageUrl);
            }

            if(widget.party.blocServiceId.isEmpty){
              widget.party =
                  widget.party.copyWith(blocServiceId: _sBlocServiceId);
            }

            FirestoreHelper.pushParty(widget.party);

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
