import 'package:flutter/material.dart';

import 'package:mandir_app/service/api_service.dart';
import 'package:mandir_app/utils/helper.dart';
import 'package:random_string/random_string.dart';

import '../utils/styling.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  String? ssnCode = '';
  String? email = "";
  String? password = "";
  bool isLoading = false;
  bool isVisible = false;

  Future login(String loginName, String password) async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      String randomssn = randomAlphaNumeric(62);
      ssnCode = randomssn;

      await Helper.saveUserSsnCode(randomssn);
      ApiService.login({
        'loginName': loginName,
        'password': password,
        'ssnCode': ssnCode!,
      }, headers, context);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topRight,
                      child: Switch(
                        // This bool value toggles the switch.
                        value: ApiService.usePrivateIP,
                        activeColor: Colors.blue,
                        onChanged: (bool value) {
                          // This is called when the user toggles the switch.
                          setState(() {
                            ApiService.usePrivateIP = value;
                          });
                        },
                      ),
                    ),
                    const Text(
                      "जय जिनेन्द्र",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset('assets/images/jain-emblem-2.png'),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          // Padding(
                          //   padding:
                          //       const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
                          //   child: Lottie.network(
                          //       "https://assets2.lottiefiles.com/packages/lf20_suywrczk.json",
                          //       height: 200,
                          //       width: 200),
                          // ),
                          TextFormField(
                            onChanged: (newValue) {
                              email = newValue;
                            },
                            validator: (val) {
                              if (val!.length < 3) {
                                return "Please enter a valid login name";
                              }
                              return null;
                            },
                            decoration: textInputDecoration.copyWith(
                              labelText: "Login Name",
                              prefixIcon: Icon(
                                Icons.email,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 35,
                          ),
                          TextFormField(
                            onChanged: (newValue) {
                              password = newValue;
                            },
                            validator: (val) {
                              if (val!.length < 6) {
                                return "Password have at least 6 characters";
                              }
                              return null;
                            },
                            obscureText: !isVisible,
                            decoration: textInputDecoration.copyWith(
                              labelText: "Password",
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Theme.of(context).primaryColor,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isVisible = !isVisible;
                                  });
                                },
                                icon: isVisible
                                    ? const Icon(
                                        Icons.visibility,
                                        color: Colors.black,
                                      )
                                    : const Icon(
                                        Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 35, vertical: 10),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Login hat",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                            onPressed: () {
                              login(email!.trim(), password!.trim());
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          // ),
        ],
      ),
    );
  }
}
