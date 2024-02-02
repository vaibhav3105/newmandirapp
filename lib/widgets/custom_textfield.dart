// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../utils/styling.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final FocusNode? focus;
  final Icon? suffixIcon;
  const CustomTextField(
      {Key? key,
      required this.labelText,
      required this.controller,
      this.focus,
      this.suffixIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focus,
      controller: controller,
      decoration: textInputDecoration.copyWith(
        suffixIcon: suffixIcon,
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
  final void Function(String)? onChanged;

  const CustomTextAreaField({
    Key? key,
    required this.labelText,
    required this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
      minLines: 3,
      onChanged: onChanged,
      decoration: textInputDecoration.copyWith(
        filled: true,
        fillColor: Colors.white,
        labelText: labelText,
      ),
    );
  }
}
