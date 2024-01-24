import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class DarkTextFieldWidget extends StatefulWidget {
  final int maxLines;
  final String label;
  final String text;
  final ValueChanged<String> onChanged;
  final VoidCallback? onTap;
  bool? isReadOnly;

  DarkTextFieldWidget({
    Key? key,
    this.maxLines = 1,
    required this.label,
    required this.text,
    required this.onChanged,
    this.onTap,
    this.isReadOnly
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
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Constants.lightPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Constants.primary, width: 0.0),
                ),
                labelStyle: const TextStyle(color: Constants.lightPrimary)),
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            readOnly: widget.isReadOnly ??= false,
            style: const TextStyle(color: Constants.lightPrimary),
          ),
        ],
      );
  }
}
