import 'package:flutter/material.dart';
import 'package:mandir_app/services/account_service.dart';

import '../auth/login_screen.dart';
import '../utils/helper.dart';
import '../utils/utils.dart';
import '../widgets/custom_textfield.dart';

class ChangeLoginName extends StatefulWidget {
  const ChangeLoginName({super.key});

  @override
  State<ChangeLoginName> createState() => _ChangeLoginNameState();
}

class _ChangeLoginNameState extends State<ChangeLoginName> {
  bool isLoading = false;
  final loginController = TextEditingController();
  changeLoginName() async {
    try {
      setState(() {
        isLoading = true;
      });
      FocusScope.of(context).unfocus();
      var response = await AccountService().changeLoginName(
        loginController.text.trim(),
        context,
      );
      if (response['errorCode'] == 0) {
        showCustomSnackbar(
          context,
          Colors.black,
          response['message'],
        );
        await Helper.saveUserAccessToken("");
        await Helper.saveUserSsnCode('');
        await Helper.saveUserType(0);
        await Helper.saveUserTypeText('');
        await Helper.showBiometricLogin(false);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false);
        setState(() {
          isLoading = false;
        });
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Login Name"),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              CustomTextAreaField(
                labelText: 'New Login Name',
                controller: loginController,
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        changeLoginName();
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
                            )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
