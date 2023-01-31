import 'dart:io';

import 'package:bloc/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../db/entity/category.dart';
import '../../../db/entity/product.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/profile_widget.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class CategoryAddEditScreen extends StatefulWidget {
  Category category;
  String task;

  CategoryAddEditScreen({key, required this.category, required this.task})
      : super(key: key);

  @override
  _CategoryAddEditScreenState createState() => _CategoryAddEditScreenState();
}

class _CategoryAddEditScreenState extends State<CategoryAddEditScreen> {
  bool isPhotoChanged = false;
  late String oldImageUrl;
  late String newImageUrl;
  String imagePath ='';

  List<String> typeNames = ['Alcohol', 'Food'];
  String sType = 'Alcohol';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('category | ' + widget.task),
    ),
    body: _buildBody(context),
  );

  _buildBody(BuildContext context) {
    return ListView(
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

        // const SizedBox(height: 24),
        // TextFieldWidget(
        //   label: 'sequence',
        //   text: widget.category.sequence.toString(),
        //   maxLines: 5,
        //   onChanged: (value) {
        //     int newValue = int.parse(value);
        //     widget.category = widget.category.copyWith(sequence: newValue);
        //   },
        // ),
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
              FirestorageHelper.deleteFile(oldImageUrl);
            }

            FirestoreHelper.pushCategory(widget.category);

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
