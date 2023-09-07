import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(
    vertical: 16,
    horizontal: 12,
  ),
  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
  border: OutlineInputBorder(
    borderSide: BorderSide(width: 1, color: Colors.grey),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(width: 1, color: Colors.grey),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(width: 1, color: Colors.grey),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey,
      width: 1,
    ),
  ),
);
