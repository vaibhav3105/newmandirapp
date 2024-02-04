// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:mandir_app/service/api_service.dart';

import '../utils/styling.dart';

class LoginScreen extends StatefulWidget {
  final String loginName;
  final String password;
  const LoginScreen({
    Key? key,
    required this.loginName,
    required this.password,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.loginName.isNotEmpty) {
      setState(() {
        emailController.text = widget.loginName;
      });
    }
    if (widget.password.isNotEmpty) {
      setState(() {
        passwordController.text = widget.password;
      });
    }
  }

  final formKey = GlobalKey<FormState>();
  String? email = "";
  String? password = "";
  bool isLoading = false;
  bool isVisible = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future login(String loginName, String password) async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      // await Future.delayed(const Duration(seconds: 5));
      ApiService.login(context, loginName, password);

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
                          TextFormField(
                            controller: emailController,
                            validator: (val) {
                              if (val!.length < 3) {
                                return "Please enter a valid login name";
                              }
                              return null;
                            },
                            decoration: textInputDecoration.copyWith(
                              border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 2, color: Colors.grey),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 2, color: Colors.grey),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 2, color: Colors.grey),
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 2,
                                ),
                              ),
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
                            controller: passwordController,
                            validator: (val) {
                              if (val!.length < 6) {
                                return "Password should be at least 6 characters long";
                              }
                              return null;
                            },
                            obscureText: !isVisible,
                            decoration: textInputDecoration.copyWith(
                              border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 2, color: Colors.grey),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 2, color: Colors.grey),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 2, color: Colors.grey),
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 2,
                                ),
                              ),
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
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              login(emailController.text.trim(),
                                  passwordController.text.trim());
                            },
                          ),
                          const SizedBox(
                            height: 0,
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
        ],
      ),
    );
  }
}
