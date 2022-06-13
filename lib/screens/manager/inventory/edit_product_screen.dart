import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../db/entity/product.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/profile_widget.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class EditProductScreen extends StatefulWidget {
  Product product;
  // BlocDao dao;

  EditProductScreen({key, required this.product}):super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // late User user;
  bool isPhotoChanged = false;
  late String oldImageUrl;
  late String newImageUrl;

  @override
  void initState() {
    super.initState();

    // user = UserPreferences.getUser();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Product | Edit'),),
    body: _buildBody(context),
  );

  _buildBody(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 32),
      physics: BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        ProfileWidget(
          imagePath: widget.product.imageUrl,
          isEdit: true,
          onClicked: () async {
            final image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                imageQuality: 90, maxWidth: 300);
            if (image == null) return;

            final directory = await getApplicationDocumentsDirectory();
            final name = basename(image.path);
            final imageFile = File('${directory.path}/$name');
            final newImage = await File(image.path).copy(imageFile.path);

            setState(() async {
              oldImageUrl = widget.product.imageUrl;
              newImageUrl = await FirestorageHelper.uploadFile(
                  FirestorageHelper.PRODUCT_IMAGES, widget.product.id, newImage);
              isPhotoChanged = true;
            });
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Product Name',
          text: widget.product.name,
          onChanged: (name) => widget.product = widget.product.copyWith(name: name),
        ),
        const SizedBox(height: 24),
        TextFormField(
          key: const ValueKey('product_type'),
          initialValue: widget.product.type,
          enabled: false,
          autocorrect: false,
          textCapitalization: TextCapitalization.words,
          enableSuggestions: false,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'Product Type',
          ),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Description',
          text: widget.product.description,
          maxLines: 5,
          onChanged: (value) {
            widget.product = widget.product.copyWith(description: value);
          },
        ),
        const SizedBox(height: 24),
        TextFormField(
          key: const ValueKey('product_price'),
          initialValue: widget.product.price.toString(),
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: false,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter a valid price for the product.';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Product Price',
          ),
          onChanged: (value) {
            double? newPrice = double.tryParse(value);
            widget.product = widget.product.copyWith(price: newPrice);
          },
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'Save',
          onClicked: () {
            if(isPhotoChanged){
              widget.product = widget.product.copyWith(imageUrl: newImageUrl);
            }

            FirestoreHelper.updateProductTest(widget.product);

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

