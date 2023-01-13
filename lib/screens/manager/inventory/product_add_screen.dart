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

class ProductAddScreen extends StatefulWidget {
  Product product;
  String blocServiceId;

  ProductAddScreen({key, required this.blocServiceId, required this.product}) : super(key: key);

  @override
  _ProductAddScreenState createState() => _ProductAddScreenState();
}

class _ProductAddScreenState extends State<ProductAddScreen> {
  // late User user;
  bool isPhotoChanged = false;
  late String oldImageUrl;
  late String newImageUrl;

  List<Category> alcoholCategories = [];
  List<Category> foodCategories = [];

  List<String> catTypeNames = [];
  List<String> catNames = [];

  List<String> catAlcoholNames = [];
  List<String> catFoodNames = [];

  List<String> subCatsList = [];
  bool _isCategoriesLoading = true;
  late String _productCategory;
  late String _productType;

  @override
  void initState() {
    super.initState();

    FirestoreHelper.pullCategories(widget.product.serviceId).then((res) {
      print("successfully pulled in categories... ");

      if (res.docs.isNotEmpty) {
        _productCategory = widget.product.category;
        _productType = widget.product.type;

        List<String> _catAlcoholNames = [];
        List<String> _catFoodNames = [];
        List<String> _catNames = [];

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Category category = Category.fromMap(data);
          if (category.name == 'Alcohol' || category.name == 'Food') {
            catTypeNames.add(category.name);
            continue;
          }

          if (category.type == 'Alcohol' || category.type == 'Food') {
            // alcoholCategories.add(category);
            _catNames.add(category.name);
          }

          if (category.type == 'Alcohol') {
            // alcoholCategories.add(category);
            _catAlcoholNames.add(category.name);
          } else if (category.type == 'Food') {
            _catFoodNames.add(category.name);
            // foodCategories.add(category);
          }

          // if (widget.product.type == category.type) {
          //   _categories.add(category);
          //   _catsStringList.add(category.name);
          // }
        }

        setState(() {
          catAlcoholNames = _catAlcoholNames;
          catFoodNames = _catFoodNames;
          catNames = _catNames;


          // subCategories = _categories;
          // subCatsList = _catsStringList;
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
                label: 'Name',
                text: widget.product.name,
                onChanged: (name) =>
                    widget.product = widget.product.copyWith(name: name),
              ),
              const SizedBox(height: 24),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    key: const ValueKey('product_type'),
                    decoration: InputDecoration(
                        errorStyle:
                        TextStyle(color: Theme.of(context).errorColor, fontSize: 16.0),
                        hintText: 'Please select product type',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    isEmpty: _productType == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _productType,
                        isDense: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            _productType = newValue!;
                            widget.product =
                                widget.product.copyWith(type: newValue);
                                state.didChange(newValue);
                          });
                        },
                        items: catTypeNames.map((String value) {
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
                    key: const ValueKey('product_category'),
                    decoration: InputDecoration(
                        errorStyle:
                            TextStyle(color: Theme.of(context).errorColor, fontSize: 16.0),
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
                            widget.product =
                                widget.product.copyWith(category: newValue);
                            // state.didChange(newValue);
                          });
                        },
                        items: catNames.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList()
                      ),
                    ),
                  );
                },
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
                  labelText: 'Price',
                ),
                onChanged: (value) {
                  double? newPrice = double.tryParse(value);
                  widget.product = widget.product.copyWith(price: newPrice);
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const ValueKey('product_community_price'),
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
                  widget.product = widget.product.copyWith(priceCommunity: newPrice);
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const ValueKey('product_community_price_lowest'),
                initialValue: widget.product.priceCommunity.toString(),
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                enableSuggestions: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a valid lowest community price for the product.';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Community Lowest Price',
                ),
                onChanged: (value) {
                  double? newPrice = double.tryParse(value);
                  widget.product = widget.product.copyWith(priceLowest: newPrice);
                  widget.product = widget.product.copyWith(priceLowestTime: Timestamp.now().millisecondsSinceEpoch);
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const ValueKey('product_community_price_highest'),
                initialValue: widget.product.priceCommunity.toString(),
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                enableSuggestions: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a valid highest community price for the product.';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Community Highest Price',
                ),
                onChanged: (value) {
                  double? newPrice = double.tryParse(value);
                  widget.product = widget.product.copyWith(priceHighest: newPrice);
                  widget.product = widget.product.copyWith(priceHighestTime: Timestamp.now().millisecondsSinceEpoch);
                },
              ),
              const SizedBox(height: 24),
              // TextFormField(
              //   key: const ValueKey('product_sequence'),
              //   initialValue: widget.product.priceCommunity.toString(),
              //   autocorrect: false,
              //   textCapitalization: TextCapitalization.none,
              //   enableSuggestions: false,
              //   validator: (value) {
              //     if (value!.isEmpty) {
              //       return 'Please enter a valid community price for the product.';
              //     }
              //     return null;
              //   },
              //   keyboardType: TextInputType.number,
              //   decoration: const InputDecoration(
              //     labelText: 'Community Price',
              //   ),
              //   onChanged: (value) {
              //     double? newPrice = double.tryParse(value);
              //     widget.product =
              //         widget.product.copyWith(priceCommunity: newPrice);
              //   },
              // ),
              // const SizedBox(height: 24),
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

                  FirestoreHelper.pushProduct(widget.product);

                  // FirestoreHelper.updateProduct(widget.product);

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
  }
}
