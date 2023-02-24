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
import '../../../widgets/ui/toaster.dart';

class ProductAddEditScreen extends StatefulWidget {
  Product product;
  String task;

  ProductAddEditScreen({key, required this.product, required this.task})
      : super(key: key);

  @override
  _ProductAddEditScreenState createState() => _ProductAddEditScreenState();
}

class _ProductAddEditScreenState extends State<ProductAddEditScreen> {
  bool isPhotoChanged = false;
  late String oldImageUrl;
  late String newImageUrl;
  String imagePath ='';

  List<String> catTypeNames = [];
  List<String> catNames = [];

  List<String> catAlcoholNames = [];
  List<String> catFoodNames = [];
  late String _sCategoryAlcohol;
  late String _sCategoryFood;

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
            _catNames.add(category.name);
          }

          if (category.type == 'Alcohol') {
            _catAlcoholNames.add(category.name);
            if (_catAlcoholNames.length == 1) {
              _sCategoryAlcohol = category.name;
            }
          } else if (category.type == 'Food') {
            _catFoodNames.add(category.name);
            if (_catFoodNames.length == 1) {
              _sCategoryFood = category.name;
            }
          }
        }

        setState(() {
          catAlcoholNames = _catAlcoholNames;
          catFoodNames = _catFoodNames;
          catNames = _catNames;
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
          title: Text('product | ' + widget.task),
        ),
        body: _buildBody(context),
      );

  _buildBody(BuildContext context) {
    return _isCategoriesLoading
        ? Center(
            child: Text('categories loading...'),
          )
        : ListView(
            padding: EdgeInsets.symmetric(horizontal: 32),
            physics: BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 15),
              ProfileWidget(
                imagePath: imagePath.isEmpty ? widget.product.imageUrl : imagePath,
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

                  oldImageUrl = widget.product.imageUrl;
                  newImageUrl = await FirestorageHelper.uploadFile(
                      FirestorageHelper.PRODUCT_IMAGES,
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
                        errorStyle: TextStyle(
                            color: Theme.of(context).errorColor,
                            fontSize: 16.0),
                        hintText: 'please select product type',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    isEmpty: _productType == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: widget.product.type,
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

              _productType == 'Food'
                  ? Column(
                      children: [
                        const SizedBox(height: 24),
                        FormField<String>(
                          builder: (FormFieldState<String> state) {
                            return buildFoodCategoryDropdown(context);
                          },
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const SizedBox(height: 24),
                        FormField<String>(
                          builder: (FormFieldState<String> state) {
                            return buildAlcoholCategoryDropdown(context);
                          },
                        ),
                      ],
                    ),

              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'description',
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
                    return 'please enter a valid price for the product';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'price',
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
                    return 'please enter a valid community price for the product';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'community price',
                ),
                onChanged: (value) {
                  double? newPrice = double.tryParse(value);
                  widget.product =
                      widget.product.copyWith(priceCommunity: newPrice);
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const ValueKey('product_community_price_lowest'),
                initialValue: widget.product.priceLowest.toString(),
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                enableSuggestions: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'please enter a valid lowest community price for the product';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'community lowest price',
                ),
                onChanged: (value) {
                  double? newPrice = double.tryParse(value);
                  widget.product =
                      widget.product.copyWith(priceLowest: newPrice);
                  widget.product = widget.product.copyWith(
                      priceLowestTime: Timestamp.now().millisecondsSinceEpoch);
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const ValueKey('product_community_price_highest'),
                initialValue: widget.product.priceHighest.toString(),
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                enableSuggestions: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'please enter a valid highest community price for the product';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'community highest price',
                ),
                onChanged: (value) {
                  double? newPrice = double.tryParse(value);
                  widget.product =
                      widget.product.copyWith(priceHighest: newPrice);
                  widget.product = widget.product.copyWith(
                      priceHighestTime: Timestamp.now().millisecondsSinceEpoch);
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 0,
                  ), //SizedBox
                  Text(
                    'veg : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.product.isVeg,
                    onChanged: (value) {
                      setState(() {
                        widget.product =
                            widget.product.copyWith(isVeg: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 0,
                  ), //SizedBox
                  Text(
                    'available : ',
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
                text: 'save',
                onClicked: () {
                 if (isPhotoChanged) {
                    widget.product =
                        widget.product.copyWith(imageUrl: newImageUrl);
                    FirestorageHelper.deleteFile(oldImageUrl);
                  }

                  FirestoreHelper.pushProduct(widget.product);

                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 24),
              ButtonWidget(
                text: 'delete photo',
                onClicked: () async {
                  if (widget.product.imageUrl.isNotEmpty) {
                    bool isPhotoDeleted = await FirestorageHelper.deleteFile(widget.product.imageUrl);
                    if(isPhotoDeleted){
                      print('photo deleted successfully');
                      Toaster.shortToast('photo deleted successfully');
                      widget.product =
                          widget.product.copyWith(imageUrl: '');
                      FirestoreHelper.pushProduct(widget.product);
                    } else {
                      print('photo deletion failed');
                      Toaster.shortToast('photo deleted failed');
                    }
                  }

                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 24),
              ButtonWidget(
                text: 'delete',
                onClicked: () async {
                  bool isPhotoDeleted = await FirestorageHelper.deleteFile(widget.product.imageUrl);
                  if(isPhotoDeleted){
                    print('photo deleted successfully');
                    Toaster.shortToast('photo deleted successfully');
                    widget.product =
                        widget.product.copyWith(imageUrl: '');
                    FirestoreHelper.deleteProduct(widget.product.id);
                    Navigator.of(context).pop();

                  } else {
                    print('photo deletion failed');
                    Toaster.shortToast('photo deleted failed. product delete failed');
                  }
                },
              ),
            ],
          );
  }

  buildFoodCategoryDropdown(context) {
    String existingCategory = widget.product.category;

    if(!catFoodNames.contains(existingCategory)){
      widget.product = widget.product.copyWith(category: catFoodNames[0]);
    }

    return InputDecorator(
      key: const ValueKey('product_category_food'),
      decoration: InputDecoration(
          errorStyle: TextStyle(
              color: Theme.of(context).errorColor,
              fontSize: 16.0),
          hintText: 'select product category',
          border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(5.0))),
      isEmpty: _sCategoryFood == '',
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            value: widget.product.category,
            isDense: true,
            onChanged: (String? newValue) {
              setState(() {
                _productCategory = newValue!;
                _sCategoryFood = _productCategory;
                widget.product = widget.product
                    .copyWith(category: newValue);
                // state.didChange(newValue);
              });
            },
            items: catFoodNames.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList()),
      ),
    );
  }

  buildAlcoholCategoryDropdown(BuildContext context) {
    String existingCategory = widget.product.category;

    if(!catAlcoholNames.contains(existingCategory)){
      widget.product = widget.product.copyWith(category: catAlcoholNames[0]);
    }
    return InputDecorator(
      key: const ValueKey('product_category_alcohol'),
      decoration: InputDecoration(
          errorStyle: TextStyle(
              color: Theme.of(context).errorColor,
              fontSize: 16.0),
          hintText: 'select product category',
          border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(5.0))),
      isEmpty: _sCategoryAlcohol == '',
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            value: widget.product.category,
            isDense: true,
            onChanged: (String? newValue) {
              setState(() {
                _productCategory = newValue!;
                _sCategoryAlcohol = _productCategory;
                widget.product = widget.product
                    .copyWith(category: newValue);
                // state.didChange(newValue);
              });
            },
            items: catAlcoholNames.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList()),
      ),
    );
  }
}
