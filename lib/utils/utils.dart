import 'package:flutter/material.dart';

nextScreenReplace(BuildContext context, Widget screen) {
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: ((context) => screen)));
}

nextScreen(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute(builder: ((context) => screen)));
}

showCustomSnackbar(BuildContext context, Color color, String content) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      content: Text(content),
      behavior: SnackBarBehavior.floating, // Make the SnackBar float
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Customize the border shape
      ),
      margin: const EdgeInsets.all(
          16), // Adjust the margin to position the SnackBar
      elevation: 10, // Increase the elevation for an elevated effect
    ),
  );
}
