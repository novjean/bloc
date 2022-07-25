import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/product.dart';
import 'package:bloc/widgets/ui/center_text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../helpers/firestore_helper.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class CommunityOfferScreen extends StatefulWidget {
  CartItem cartItem;

  CommunityOfferScreen({key, required this.cartItem}) : super(key: key);

  @override
  _CommunityOfferScreenState createState() => _CommunityOfferScreenState();
}

class _CommunityOfferScreenState extends State<CommunityOfferScreen> {
  late Product? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    FirestoreHelper.pullProduct(widget.cartItem.productId).then((res) {
      print("Successfully retrieved product ");
      for (int i = 0; i < res.docs.length; i++) {
        DocumentSnapshot document = res.docs[i];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        final Product product = Product.fromMap(data);

        if (i == res.docs.length - 1) {
          setProduct(product);
        }
      }
    });
  }

  void setProduct(Product? product) {
    setState(() {
      _product = product;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Community | Offer'),
        ),
        body: _isLoading
            ? CenterTextWidget(text: 'Loading product...')
            : _buildBody(context),
      );

  _buildBody(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 32),
      physics: BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        // ProfileWidget(
        //   imagePath: user.imageUrl,
        //   isEdit: true,
        //   onClicked: () async {
        //     final image = await ImagePicker().pickImage(
        //         source: ImageSource.gallery,
        //         imageQuality: 90, maxWidth: 300);
        //     if (image == null) return;
        //
        //     final directory = await getApplicationDocumentsDirectory();
        //     final name = basename(image.path);
        //     final imageFile = File('${directory.path}/$name');
        //     final newImage = await File(image.path).copy(imageFile.path);
        //
        //     setState(() {
        //       oldImageUrl = user.imageUrl;
        //       user = user.copyWith(imageUrl: newImage.path);
        //       isPhotoChanged = true;
        //     });
        //   },
        // ),
        // const SizedBox(height:24),
        TextFieldWidget(
          label: 'Product Name',
          text: _product!.name,
          onChanged: (name) => _product = _product,
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Community Price',
          text: _product!.priceCommunity.toStringAsFixed(2),
          onChanged: (value) {
            double? newPrice = double.tryParse(value);
            _product = _product!.copyWith(priceCommunity: newPrice);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Lowest Price',
          text: _product!.priceLowest.toStringAsFixed(2),
          onChanged: (value) {},
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Highest Price',
          text: _product!.priceHighest.toStringAsFixed(2),
          onChanged: (value) {},
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'Save',
          onClicked: () {
            FirestoreHelper.updateProduct(_product!);

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
