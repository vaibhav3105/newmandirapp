import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mandir_app/auth/login_screen.dart';
import 'package:mandir_app/screens/accountScreen.dart';
import 'package:mandir_app/screens/birthdayScreen.dart';
import 'package:mandir_app/screens/changeLoginName.dart';
import 'package:mandir_app/screens/changePasswordScreen.dart';
import 'package:mandir_app/screens/createNewLogin.dart';
import 'package:mandir_app/screens/myFamilyList.dart';
import 'package:mandir_app/screens/assistant.dart';
import 'package:mandir_app/screens/reminderList.dart';
import 'package:mandir_app/screens/search_screen.dart';
import 'package:mandir_app/screens/todo.dart';
import 'package:mandir_app/utils/utils.dart';

import '../utils/helper.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  bool _customTileExpanded = false;
  int userType = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserTypeCode();
  }

  void getUserTypeCode() async {
    var code = await Helper.getUserType();
    setState(() {
      userType = code!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const SizedBox(
            height: 30,
          ),
          Column(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color.fromARGB(
                  255,
                  106,
                  78,
                  179,
                ),
                child: Icon(
                  Icons.person,
                  size: 35,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 17,
              ),
              if (userType == 99)
                const Text(
                  "Admin Login",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (userType != 99)
                const Text(
                  "Member Login",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(),
          GestureDetector(
            onTap: () => nextScreenReplace(context, MyFamilyList(code: '')),
            child: const ListTile(
              leading: Icon(Icons.face),
              title: Text("My Family"),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ),
          const Divider(),

          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              nextScreen(
                context,
                const BirthdayScreen(),
              );
            },
            child: const ListTile(
              leading: Icon(FontAwesomeIcons.cakeCandles),
              title: Text("Birthdays"),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ),
          // const Divider(),
          // GestureDetector(
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     nextScreen(
          //       context,
          //       const AddReminderScreen(
          //         reminderCode: '',
          //       ),
          //     );
          //   },
          //   child: const ListTile(
          //     leading: Icon(FontAwesomeIcons.add),
          //     title: Text("Add Reminder"),
          //     trailing: FaIcon(FontAwesomeIcons.angleRight),
          //   ),
          // ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              nextScreen(
                context,
                const SearchScreen(),
              );
            },
            child: const ListTile(
              leading: Icon(FontAwesomeIcons.magnifyingGlass),
              title: Text("Search Directory"),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              nextScreen(
                context,
                const ReminderList(
                    // date: '',
                    ),
              );
            },
            child: const ListTile(
              leading: Icon(FontAwesomeIcons.bell
                  // Icons.notifications_active,
                  ),
              title: Text("My Reminders"),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              nextScreen(
                context,
                const TodoScreen(
                    // date: '',
                    ),
              );
            },
            child: const ListTile(
              leading: Icon(FontAwesomeIcons.squareCheck
                  // Icons.checklist,
                  ),
              title: Text("My Todo List"),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              nextScreen(context, const CreateNewLogin());
            },
            child: const ListTile(
              leading: Icon(FontAwesomeIcons.plus),
              title: Text("Add New Login"),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const Divider(),
          ExpansionTile(
            // tilePadding: const EdgeInsets.symmetric(
            //   horizontal: 18,
            // ),
            title: const Text('Settings'),
            leading: const Icon(FontAwesomeIcons.gear),
            shape: Border.all(
              color: Colors.white,
              width: 0,
            ),
            onExpansionChanged: (value) {
              setState(() {
                _customTileExpanded = value;
              });
            },
            trailing: _customTileExpanded == true
                ? const Icon(Icons.keyboard_arrow_down)
                : const Icon(Icons.keyboard_arrow_right),
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  nextScreen(
                    context,
                    const ChangeLoginName(),
                  );
                },
                child: const ListTile(
                  leading: Icon(Icons.abc),
                  title: Text("Change Login name"),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  nextScreen(
                    context,
                    const ChangePasswordScreen(),
                  );
                },
                child: const ListTile(
                  leading: Icon(Icons.password),
                  title: Text("Change Password"),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
              )
            ],
          ),
          const Divider(),
          GestureDetector(
            onTap: () async {
              await Helper.saveUserAccessToken("");
              await Helper.saveUserType(0);
              await Helper.saveUserTypeText('');
              await Helper.showBiometricLogin(false);
              // Navigator.of(context).pushAndRemoveUntil(
              //     MaterialPageRoute(
              //       builder: (context) => const LoginScreen(),
              //     ),
              //     (route) => false);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
                  (route) => false);
            },
            child: const ListTile(
              leading: Icon(FontAwesomeIcons.powerOff),
              title: Text("Logout"),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
