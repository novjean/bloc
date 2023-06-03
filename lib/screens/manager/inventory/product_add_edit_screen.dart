import 'dart:io';

import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:multiselect/multiselect.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../db/entity/bloc_service.dart';
import '../../../db/entity/category.dart';
import '../../../db/entity/product.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../utils/logx.dart';
import '../../../utils/string_utils.dart';
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
  static const String _TAG = 'ProductAddEditScreen';

  bool isPhotoChanged = false;
  late String oldImageUrl;
  late String newImageUrl;
  String imagePath = '';

  List<String> catTypeNames = [];
  List<String> catNames = [];

  List<String> catAlcoholNames = [];
  List<String> catFoodNames = [];
  late String _sCategoryAlcohol;
  late String _sCategoryFood;

  bool _isCategoriesLoading = true;
  late String _productCategory;
  late String _productType;

  List<BlocService> blocServices = [];
  List<String> blocServiceNames = [];

  List<BlocService> sBlocs = [];
  List<String> sBlocIds = [];
  List<String> sBlocNames = [];

  late String _sBlocServiceName;
  late String _sBlocServiceId;
  bool _isBlocServicesLoading = true;

  @override
  void initState() {
    super.initState();

    FirestoreHelper.pullAllBlocServices().then((res) {
      Logx.i(_TAG, "successfully pulled in all bloc services ");

      if (res.docs.isNotEmpty) {
        List<BlocService> _blocServices = [];
        List<String> _blocServiceNames = [];
        List<String> _sBlocIds = [];
        List<String> _sBlocNames = [];
        List<BlocService> _sBlocs = [];

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

          for(String blocId in widget.product.blocIds){
            if(blocId == blocService.id){
              _sBlocIds.add(blocId);
              _sBlocNames.add(blocService.name);
              _sBlocs.add(blocService);
            }
          }
        }

        setState(() {
          blocServiceNames = _blocServiceNames;
          blocServices = _blocServices;

          sBlocs = _sBlocs;
          sBlocIds = _sBlocIds;
          sBlocNames = _sBlocNames;

          _isBlocServicesLoading = false;
        });
      } else {
        Logx.i(_TAG, 'no bloc services found!');
        setState(() {
          _isBlocServicesLoading = false;
        });
      }
    });

    FirestoreHelper.pullCategories(widget.product.serviceId).then((res) {
      Logx.i(_TAG, "successfully pulled in categories... ");

      if (res.docs.isNotEmpty) {
        _productCategory = widget.product.category;
        _productType = widget.product.type;

        List<String> _catAlcoholNames = [];
        List<String> _catFoodNames = [];
        List<String> _catNames = [];

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
          final Category category = Fresh.freshCategoryMap(map, false);
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
        Logx.i(_TAG, 'no categories found!');
        setState(() {
          _isCategoriesLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('product | ${widget.task}'),
        ),
        body: _buildBody(context),
      );

  _buildBody(BuildContext context) {
    return _isCategoriesLoading | _isBlocServicesLoading
        ? const LoadingWidget()
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 15),
              ProfileWidget(
                imagePath:
                    imagePath.isEmpty ? widget.product.imageUrl : imagePath,
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
              // DropDownMultiSelect(
              //   onChanged: (List<String> x) {
              //     setState(() {
              //       sBlocNames = x;
              //       sBlocs = [];
              //       sBlocIds = [];
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
              //         Logx.i(_TAG, 'no blocs selected');
              //         Toaster.shortToast('no blocs selected');
              //       } else {
              //         widget.product = widget.product.copyWith(blocIds: sBlocIds);
              //       }
              //     });
              //   },
              //   options: blocServiceNames,
              //   selectedValues: sBlocNames,
              //   whenEmpty: 'select blocs',
              // ),

              const SizedBox(height: 24,),
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
              TextFormField(
                key: const ValueKey('product_bottle'),
                initialValue: widget.product.priceBottle.toString(),
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                enableSuggestions: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'please enter a valid bottle price for the product';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'bottle price',
                ),
                onChanged: (value) {
                  int? newPrice = int.tryParse(value);
                  widget.product =
                      widget.product.copyWith(priceBottle: newPrice);
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[ //SizedBox
                  Text(
                    'veg : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.product.isVeg,
                    onChanged: (value) {
                      setState(() {
                        widget.product = widget.product.copyWith(isVeg: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[ //SizedBox
                  const Text(
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
                    if(oldImageUrl.isNotEmpty) {
                      FirestorageHelper.deleteFile(oldImageUrl);
                    }
                  }

                  Product freshProduct = Fresh.freshProduct(widget.product);
                  FirestoreHelper.pushProduct(freshProduct);

                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 24),
              ButtonWidget(
                text: 'delete photo',
                onClicked: () async {
                  if (widget.product.imageUrl.isNotEmpty) {
                    bool isPhotoDeleted = await FirestorageHelper.deleteFile(
                        widget.product.imageUrl);
                    if (isPhotoDeleted) {
                      Logx.i(_TAG, 'photo deleted successfully');
                      Toaster.shortToast('photo deleted successfully');
                      widget.product = widget.product.copyWith(imageUrl: '');

                      Product freshProduct = Fresh.freshProduct(widget.product);
                      FirestoreHelper.pushProduct(freshProduct);
                    } else {
                      Logx.em(_TAG, 'photo deletion failed');
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
                  bool isPhotoDeleted = false;
                  if(widget.product.imageUrl.isNotEmpty) {
                    isPhotoDeleted = await FirestorageHelper.deleteFile(
                        widget.product.imageUrl);
                    if(isPhotoDeleted) {
                      Logx.i(_TAG, 'photo deleted successfully');
                      Toaster.shortToast('photo deleted successfully');
                    } else {
                      Logx.em(_TAG, 'photo deletion failed');
                      Toaster.shortToast('photo deletion failed');
                    }
                  } else {
                    isPhotoDeleted = true;
                  }

                  if (isPhotoDeleted) {
                    FirestoreHelper.deleteProduct(widget.product.id);
                    Navigator.of(context).pop();
                  } else {
                    Logx.em(_TAG, 'product photo deletion failed');
                    Toaster.shortToast('product deletion failed as photo deletion failed');
                  }
                },
              ),
            ],
          );
  }

  buildFoodCategoryDropdown(context) {
    String existingCategory = widget.product.category;

    if (!catFoodNames.contains(existingCategory)) {
      widget.product = widget.product.copyWith(category: catFoodNames[0]);
    }

    return InputDecorator(
      key: const ValueKey('product_category_food'),
      decoration: InputDecoration(
          errorStyle:
              TextStyle(color: Theme.of(context).errorColor, fontSize: 16.0),
          hintText: 'select product category',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
      isEmpty: _sCategoryFood == '',
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            value: widget.product.category,
            isDense: true,
            onChanged: (String? newValue) {
              setState(() {
                _productCategory = newValue!;
                _sCategoryFood = _productCategory;
                widget.product = widget.product.copyWith(category: newValue);
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

    if (!catAlcoholNames.contains(existingCategory)) {
      widget.product = widget.product.copyWith(category: catAlcoholNames[0]);
    }
    return InputDecorator(
      key: const ValueKey('product_category_alcohol'),
      decoration: InputDecoration(
          errorStyle:
              TextStyle(color: Theme.of(context).errorColor, fontSize: 16.0),
          hintText: 'select product category',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
      isEmpty: _sCategoryAlcohol == '',
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            value: widget.product.category,
            isDense: true,
            onChanged: (String? newValue) {
              setState(() {
                _productCategory = newValue!;
                _sCategoryAlcohol = _productCategory;
                widget.product = widget.product.copyWith(category: newValue);
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