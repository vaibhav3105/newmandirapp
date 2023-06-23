import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mandir_app/screens/search_screen.dart';
import 'package:mandir_app/utils/utils.dart';

import '../utils/helper.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
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
      child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Column(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.black,
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
            onTap: () => Navigator.of(context).pop(),
            child: const ListTile(
              leading: FaIcon(FontAwesomeIcons.userGroup),
              title: Text("My Family"),
              trailing: FaIcon(FontAwesomeIcons.angleRight),
            ),
          ),
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
              leading: Icon(Icons.search),
              title: Text("Search Members"),
              trailing: FaIcon(FontAwesomeIcons.angleRight),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
