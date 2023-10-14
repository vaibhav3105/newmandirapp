import 'package:flutter/material.dart';
import 'package:mandir_app/utils/app_enums.dart';

nextScreenReplace(BuildContext context, Widget screen) {
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: ((context) => screen)));
}

nextScreen(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute(builder: ((context) => screen)));
}

showCustomSnackbar(BuildContext context, Color bgcolor, String content,
    {Color? color = Colors.white}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: bgcolor,
      content: Text(
        content,
        style: TextStyle(
          color: color,
        ),
      ),
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

showToast(
  BuildContext context,
  ToastTypes? toastType,
  String content,
) {
  // toastType ??= ToastTypes.DEFAULT;
  Color bgColor;
  Color color;
  switch (toastType) {
    case ToastTypes.WARN:
      bgColor = const Color(0xffFFE9A8);
      color = const Color(0xff7A4107);
      break;
    case ToastTypes.ERROR:
      bgColor = const Color(0xffFFC8A8);
      color = const Color(0xff7A071C);
      break;
    case ToastTypes.INFO:
      bgColor = const Color(0xffAFE9FF);
      // color = const Color(0xff0A307A);
      color = Colors.black;
      break;
    case ToastTypes.SUCCESS:
      bgColor = const Color(0xffD1FBAC);
      color = const Color(0xff09670A);
      break;

    case ToastTypes.DEFAULT:
    default:
      bgColor = Colors.black;
      color = Colors.white;
      break;
  }
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: bgColor,
      content: Text(
        content,
        style: TextStyle(color: color),
      ),
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
