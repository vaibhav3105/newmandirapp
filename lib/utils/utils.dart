import 'package:flutter/material.dart';

nextScreenReplace(BuildContext context, Widget screen) {
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: ((context) => screen)));
}

nextScreen(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute(builder: ((context) => screen)));
}
