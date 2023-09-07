// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../utils/styling.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  const CustomTextField({
    Key? key,
    required this.labelText,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: textInputDecoration.copyWith(
        filled: true,
        fillColor: Colors.white,
        labelText: labelText,
      ),
    );
  }
}

class CustomTextAreaField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  const CustomTextAreaField({
    Key? key,
    required this.labelText,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
      minLines: 1,
      decoration: textInputDecoration.copyWith(
        filled: true,
        fillColor: Colors.white,
        labelText: labelText,
      ),
    );
  }
}
