import 'package:flutter/material.dart';
import 'package:mandir_app/auth/login_screen.dart';
import 'package:mandir_app/service/api_service.dart';
import 'package:mandir_app/utils/utils.dart';

import '../utils/helper.dart';
import '../widgets/custom_textfield.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool isLoading = false;
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  updatePassword() async {
    try {
      setState(() {
        isLoading = true;
      });
      FocusScope.of(context).unfocus();
      var response = await ApiService().post(
          '/api/account/change-password',
          {
            "newPassword": newPasswordController.text.trim(),
            "confirmPassword": confirmPasswordController.text.trim(),
          },
          headers,
          context);
      if (response['errorCode'] == 0) {
        showCustomSnackbar(
          context,
          Colors.black,
          response['message'],
        );
        await Helper.saveUserAccessToken("");
        // await Helper.saveUserSsnCode('');
        await Helper.saveUserType(0);
        await Helper.saveUserTypeText('');
        await Helper.showBiometricLogin(false);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false);
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      isLoading = false;
      print(e.toString());
      // showCustomSnackbar(
      //   context,
      //   Colors.black,
      //   e.toString(),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        child: Form(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  labelText: 'New Password',
                  controller: newPasswordController,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  controller: confirmPasswordController,
                  labelText: 'Confirm Password',
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        updatePassword();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        fixedSize: const Size(170, 40),
                        backgroundColor: const Color.fromARGB(
                          255,
                          106,
                          78,
                          179,
                        ),
                      ),
                      child: isLoading == true
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Update",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  '• Password should be between 6 to 20 character and long.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(
                  height: 7,
                ),
                Text(
                    '• Password must have one capital, one small, one number and one special character.',
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(
                  height: 7,
                ),
                Text('• The allowed special characters are “~!@#\$%^*+:;?.,”',
                    style: TextStyle(color: Colors.grey[600]))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
