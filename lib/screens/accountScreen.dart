import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mandir_app/auth/login_screen.dart';
import 'package:mandir_app/constants.dart';

import 'package:mandir_app/utils/helper.dart';
import 'package:mandir_app/utils/utils.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool isLoading = false;
  bool showBiometric = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadAccountList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
      // appBar: AppBar(
      //   title: const Text('Directory App'),
      // ),
      body: FutureBuilder(
        future: _authenticateWithBiometric(), // your authentication function
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.data!) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  const Text('Welcome! Please Login to Your Account.',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  if (AccountList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 19),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              nextScreen(
                                  context,
                                  const LoginScreen(
                                      loginName: '', password: ''));
                            },
                            child: Container(
                              color: Colors.white,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 1,
                                ),
                                leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.add,
                                      color: Theme.of(context).primaryColor,
                                    )),
                                title: const Text(
                                  "Add new account",
                                  style: TextStyle(),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.angleRight,
                                      color: Colors.grey[350],
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: AccountList.length,
                      itemBuilder: ((context, index) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 19,
                              ),
                              child: Dismissible(
                                key: Key(AccountList[index]['loginName']),
                                direction: DismissDirection.startToEnd,
                                onDismissed: (direction) {
                                  _removeAccount(index);
                                },
                                background: Container(
                                  color: Colors.red[400],
                                  padding: const EdgeInsets.only(left: 16),
                                  alignment: Alignment.centerLeft,
                                  child: const Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.trashAlt,
                                        color: Colors.white,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Swipe right to delete',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    nextScreen(
                                        context,
                                        LoginScreen(
                                            loginName: AccountList[index]
                                                ['loginName'],
                                            password: AccountList[index]
                                                ['password']));
                                  },
                                  child: Container(
                                    color: Colors.white,
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 1,
                                      ),
                                      leading: CircleAvatar(
                                          backgroundColor:
                                              colors[index % colors.length]
                                                  .withOpacity(0.1),
                                          child: Icon(
                                            FontAwesomeIcons.userLarge,
                                            color:
                                                colors[index % colors.length],
                                          )),
                                      title: Text(
                                        AccountList[index]['loginName'],
                                        style: const TextStyle(),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.angleRight,
                                            color: Colors.grey[350],
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Divider(
                              color: Colors.transparent,
                              height: 5,
                            ),
                            if (index == AccountList.length - 1)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 19),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        nextScreen(
                                            context,
                                            const LoginScreen(
                                                loginName: '', password: ''));
                                      },
                                      child: Container(
                                        color: Colors.white,
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 1,
                                          ),
                                          leading: CircleAvatar(
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.1),
                                              child: Icon(
                                                Icons.add,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              )),
                                          title: const Text(
                                            "Add new account",
                                            style: TextStyle(),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              FaIcon(
                                                FontAwesomeIcons.angleRight,
                                                color: Colors.grey[350],
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const Text('ver 1.0'),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<bool> _authenticateWithBiometric() async {
    if (showBiometric == true) {
      return true;
    }
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Login with fingerprint, face, pattern or PIN',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      if (authenticated) {
        setState(() {
          showBiometric = true;
        });
      }
    } on PlatformException {
      return true;
    }
    if (!mounted) {
      setState(() {
        isLoading = false;
      });
      return false;
    }
    return authenticated;
  }

  var AccountList = [];

  _loadAccountList() async {
    List accountList = await getAccountList();
    setState(() {
      AccountList = accountList;
    });
  }

  _addNewAccount() async {
    nextScreen(context, const LoginScreen(loginName: '', password: ''));
  }

  _removeAccount(int index) {
    setState(() {
      AccountList.removeAt(index);
      Helper.saveAccountList(jsonEncode(AccountList));
    });
  }
}
