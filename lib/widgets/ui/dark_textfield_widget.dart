import 'package:flutter/material.dart';

class DarkTextFieldWidget extends StatefulWidget {
  final int maxLines;
  final String label;
  final String text;
  final ValueChanged<String> onChanged;

  DarkTextFieldWidget({
    Key? key,
    this.maxLines = 1,
    required this.label,
    required this.text,
    required this.onChanged,
  }) : super(key: key);

  @override
  _DarkTextFieldWidgetState createState() => _DarkTextFieldWidgetState();
}

class _DarkTextFieldWidgetState extends State<DarkTextFieldWidget> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        widget.label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Theme.of(context).primaryColorLight,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        maxLines: widget.maxLines,
        onChanged: widget.onChanged,
        style: TextStyle(color: Theme.of(context).primaryColorLight),
      ),
    ],
  );
}
