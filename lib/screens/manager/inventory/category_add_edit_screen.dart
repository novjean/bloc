import 'dart:io';

import 'package:bloc/utils/string_utils.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../db/entity/bloc_service.dart';
import '../../../db/entity/category.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../widgets/profile_widget.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/dark_button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';
import '../../../widgets/ui/toaster.dart';

class CategoryAddEditScreen extends StatefulWidget {
  Category category;
  String task;

  CategoryAddEditScreen({key, required this.category, required this.task})
      : super(key: key);

  @override
  _CategoryAddEditScreenState createState() => _CategoryAddEditScreenState();
}

class _CategoryAddEditScreenState extends State<CategoryAddEditScreen> {
  static const String _TAG = 'CategoryAddEditScreen';

  bool isPhotoChanged = false;
  late String oldImageUrl;
  late String newImageUrl;
  String imagePath ='';

  List<String> typeNames = ['Alcohol', 'Food'];
  String sType = 'Alcohol';

  List<BlocService> blocServices = [];
  List<BlocService> sBlocs = [];
  List<String> sBlocIds = [];
  bool _isBlocServicesLoading = true;

  @override
  void initState() {
    super.initState();

    sBlocIds = widget.category.blocIds;

    FirestoreHelper.pullAllBlocServices().then((res) {
      Logx.i(_TAG, "successfully pulled in all bloc services ");

      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final BlocService blocService = BlocService.fromMap(data);
          blocServices.add(blocService);

          if (widget.category.blocIds.contains(blocService.id)) {
            sBlocs.add(blocService);
          }
        }

        setState(() {
          _isBlocServicesLoading = false;
        });
      } else {
        Logx.i(_TAG, 'no bloc services found!');
        setState(() {
          _isBlocServicesLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('category | ${widget.task}'),
    ),
    body: _buildBody(context),
  );

  _buildBody(BuildContext context) {
    return _isBlocServicesLoading ? const LoadingWidget():
    ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        ProfileWidget(
          imagePath: imagePath.isEmpty ? widget.category.imageUrl : imagePath,
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

            oldImageUrl = widget.category.imageUrl;
            newImageUrl = await FirestorageHelper.uploadFile(
                FirestorageHelper.CATEGORY_IMAGES,
                StringUtils.getRandomString(20),
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
          text: widget.category.name,
          onChanged: (name) =>
          widget.category = widget.category.copyWith(name: name),
        ),
        const SizedBox(height: 24),
        Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'select blocs',
                    style: TextStyle(
                        color: Constants.background,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            MultiSelectDialogField(
              items: blocServices
                  .map((e) => MultiSelectItem(
                  e, '${e.name.toLowerCase()} | ${e.name.toLowerCase()}'))
                  .toList(),
              initialValue: sBlocs.map((e) => e).toList(),
              listType: MultiSelectListType.CHIP,
              buttonIcon: Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade700,
              ),
              title: const Text(
                'select bloc',
                style: TextStyle(color: Colors.black),
              ),
              buttonText: const Text(
                'select',
                style: TextStyle(color: Colors.black),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: Border.all(
                  color: Constants.primary,
                  width: 0.0,
                ),
              ),
              searchable: true,
              onConfirm: (values) {
                sBlocs = values as List<BlocService>;

                List<String> sBlocIds = [];
                for (BlocService bs in sBlocs) {
                  sBlocIds.add(bs.id);
                }

                if (sBlocs.isEmpty) {
                  Logx.i(_TAG, 'no blocs selected');
                  widget.category = widget.category.copyWith(blocIds: []);
                  Logx.i(_TAG, 'no blocs selected');
                  Toaster.shortToast('no blocs selected');
                } else {
                  widget.category = widget.category.copyWith(blocIds: sBlocIds);
                }
              },
            ),
          ],
        ),

        // DropDownMultiSelect(
        //   onChanged: (List<String> x) {
        //     setState(() {
        //       sBlocNames = x;
        //       sBlocs = [];
        //       sBlocIds = [];
        //
        //       List<String> _sBlocIds = [];
        //
        //       for(String blocName in sBlocNames){
        //         for(BlocService bs in blocServices){
        //           if(blocName == bs.name){
        //             sBlocs.add(bs);
        //             sBlocIds.add(bs.id);
        //           }
        //         }
        //       }
        //       if(sBlocIds.isEmpty){
        //         print('no blocs selected');
        //         Toaster.shortToast('no blocs selected');
        //       } else {
        //         widget.category = widget.category.copyWith(blocIds: sBlocIds);
        //       }
        //     });
        //   },
        //   options: blocServiceNames,
        //   selectedValues: sBlocNames,
        //   whenEmpty: 'select blocs',
        // ),

        const SizedBox(height: 24),
        FormField<String>(
          builder: (FormFieldState<String> state) {
            return InputDecorator(
              key: const ValueKey('category_type'),
              decoration: InputDecoration(
                  errorStyle: TextStyle(
                      color: Theme.of(context).errorColor,
                      fontSize: 16.0),
                  hintText: 'please select category type',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              isEmpty: sType == '',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.category.type,
                  isDense: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      sType = newValue!;
                      widget.category =
                          widget.category.copyWith(type: newValue);
                      state.didChange(newValue);
                    });
                  },
                  items: typeNames.map((String value) {
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
          label: 'description',
          text: widget.category.description,
          maxLines: 5,
          onChanged: (value) {
            widget.category = widget.category.copyWith(description: value);
          },
        ),
        const SizedBox(height: 24),
        TextFormField(
          key: const ValueKey('category_sequence'),
          initialValue: widget.category.sequence.toString(),
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: false,
          validator: (value) {
            if (value!.isEmpty) {
              return 'please enter a valid sequence for the category';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'sequence',
          ),
          onChanged: (value) {
            int? newSequence = int.tryParse(value);
            widget.category = widget.category.copyWith(sequence: newSequence);
          },
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'save',
          onClicked: () {
            if (isPhotoChanged) {
              widget.category =
                  widget.category.copyWith(imageUrl: newImageUrl);
              if(oldImageUrl.isNotEmpty) {
                FirestorageHelper.deleteFile(oldImageUrl);
              }
            }

            Category freshCategory = Fresh.freshCategory(widget.category);
            FirestoreHelper.pushCategory(freshCategory);

            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 36),
        DarkButtonWidget(
          text: 'delete',
          onClicked: () {
            FirestoreHelper.deleteCategory(widget.category.id);

            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 12),

      ],
    );
  }
}
