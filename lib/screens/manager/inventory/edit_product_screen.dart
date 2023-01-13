import 'dart:io';

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

class EditProductScreen extends StatefulWidget {
  Product product;

  EditProductScreen({key, required this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // late User user;
  bool isPhotoChanged = false;
  late String oldImageUrl;
  late String newImageUrl;

  List<Category> subCategories = [];
  List<String> subCatsList = [];
  bool _isCategoriesLoading = true;
  late String _productCategory;


  @override
  void initState() {
    super.initState();

    FirestoreHelper.pullCategories(widget.product.serviceId).then((res) {
      print("successfully pulled in categories... ");

      if (res.docs.isNotEmpty) {
        _productCategory = widget.product.category;

        List<Category> _categories = [];
        List<String> _catsStringList = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Category category = Category.fromMap(data);
          if(category.name=='Alcohol' || category.name=='Food')
            continue;

          if (widget.product.type == category.type) {
            _categories.add(category);
            _catsStringList.add(category.name);
          }
        }

        setState(() {
          subCategories = _categories;
          subCatsList = _catsStringList;
          _isCategoriesLoading = false;
        });
      } else {
        print('no categories found!');
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Product | Edit'),
        ),
        body: _buildBody(context),
      );

  _buildBody(BuildContext context) {
    return _isCategoriesLoading
        ? Center(
            child: Text('Loading...'),
          )
        : ListView(
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
                      imageQuality: 90,
                      maxWidth: 300);
                  if (image == null) return;

                  final directory = await getApplicationDocumentsDirectory();
                  final name = basename(image.path);
                  final imageFile = File('${directory.path}/$name');
                  final newImage = await File(image.path).copy(imageFile.path);

                  setState(() async {
                    oldImageUrl = widget.product.imageUrl;
                    newImageUrl = await FirestorageHelper.uploadFile(
                        FirestorageHelper.PRODUCT_IMAGES,
                        widget.product.id,
                        newImage);
                    isPhotoChanged = true;
                  });
                },
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'Product Name',
                text: widget.product.name,
                onChanged: (name) =>
                    widget.product = widget.product.copyWith(name: name),
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
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    key: const ValueKey('product_category'),
                    decoration: InputDecoration(
                        errorStyle: TextStyle(
                            color: Colors.redAccent, fontSize: 16.0),
                        hintText: 'Please select product category',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    isEmpty: _productCategory == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _productCategory,
                        isDense: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            _productCategory = newValue!;
                            widget.product = widget.product.copyWith(category: newValue);
                            // state.didChange(newValue);
                          });
                        },
                        items: subCatsList.map((String value) {
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
              // DropdownButton<String>(
              //   items: subCatsList.map((String value) {
              //     return DropdownMenuItem<String>(
              //       value: value,
              //       child: Text(value),
              //     );
              //   }).toList(),
              //   onChanged: (sCategory) {
              //
              //   },
              // ),
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
              TextFormField(
                key: const ValueKey('product_price_community'),
                initialValue: widget.product.priceCommunity.toString(),
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                enableSuggestions: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a valid community price for the product.';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Community Price',
                ),
                onChanged: (value) {
                  double? newPrice = double.tryParse(value);
                  widget.product =
                      widget.product.copyWith(priceCommunity: newPrice);
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
                    value: widget.product.isAvailable,
                    onChanged: (value) {
                      setState(() {
                        widget.product =
                            widget.product.copyWith(isAvailable: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 24),
              ButtonWidget(
                text: 'Save',
                onClicked: () {
                  if (isPhotoChanged) {
                    widget.product =
                        widget.product.copyWith(imageUrl: newImageUrl);
                  }

                  FirestoreHelper.updateProduct(widget.product);

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
  }
}
