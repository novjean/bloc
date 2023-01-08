import 'package:flutter/material.dart';

import '../../db/entity/bloc.dart';
import '../../widgets/ui/button_widget.dart';

class BookTableScreen extends StatefulWidget{
  List<Bloc> blocs;

  BookTableScreen({required this.blocs});

  @override
  State<BookTableScreen> createState() => _BookTableScreenState();
}

class _BookTableScreenState extends State<BookTableScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking')),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    // var logger = Logger();

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 32),
      physics: BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),

        const SizedBox(height: 24),
        ButtonWidget(
          text: 'Save',
          onClicked: () {
            // if(isPhotoChanged){
            //   widget.product = widget.product.copyWith(imageUrl: newImageUrl);
            // }

            // FirestoreHelper.updateProduct(widget.product);

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

}