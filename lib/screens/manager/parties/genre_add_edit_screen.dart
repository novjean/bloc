import 'package:bloc/helpers/fresh.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/genre.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';
import '../../../widgets/ui/toaster.dart';

class GenreAddEditScreen extends StatefulWidget {
  Genre genre;
  String task;

  GenreAddEditScreen({key, required this.genre, required this.task})
      : super(key: key);

  @override
  _GenreAddEditScreenState createState() => _GenreAddEditScreenState();
}

class _GenreAddEditScreenState extends State<GenreAddEditScreen> {
  static const String _TAG = 'GenreAddEditScreen';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('genre | ${widget.task}'),
    ),
    body: _buildBody(context),
  );

  _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        TextFieldWidget(
          label: 'name \*',
          text: widget.genre.name,
          onChanged: (text) => widget.genre = widget.genre.copyWith(name: text),
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'save',
          onClicked: () {
            Genre freshGenre = Fresh.freshGenre(widget.genre);
            FirestoreHelper.pushGenre(freshGenre);

            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'delete',
          onClicked: () {
            FirestoreHelper.deleteGenre(widget.genre.id);
            Toaster.shortToast('deleted genre ${widget.genre.name}');
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
