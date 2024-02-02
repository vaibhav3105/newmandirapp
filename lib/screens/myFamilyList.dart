// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:mandir_app/constants.dart';
import 'package:mandir_app/screens/assistant.dart';
import 'package:mandir_app/screens/discrepancy.dart';
import 'package:mandir_app/screens/editScreen.dart';
import 'package:mandir_app/screens/reminderList.dart';
import 'package:mandir_app/screens/show_member_info.dart';
import 'package:mandir_app/screens/todo.dart';
import 'package:mandir_app/services/advertisementService.dart';

import 'package:mandir_app/utils/utils.dart';
import 'package:mandir_app/widgets/drawer.dart';

import '../service/api_service.dart';
import '../widgets/advertisement.dart';
import 'changeAddressScreen.dart';

class MyFamilyList extends StatefulWidget {
  String code;
  MyFamilyList({
    Key? key,
    required this.code,
  }) : super(key: key);

  @override
  State<MyFamilyList> createState() => _MyFamilyListState();
}

class _MyFamilyListState extends State<MyFamilyList> {
  File? imageFile;
  var menus = [];
  var discrepancyCount = 0;
  final remarkController = TextEditingController();
  var answer = [];

  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRandomAdvertisement();
    getMyFamily();
  }

  var advertisementResponse = [];
  getRandomAdvertisement() async {
    try {
      var response =
          await AdvertisementService().getRandomAdvertisement(context);
      setState(() {
        advertisementResponse = response;
      });
      print(response);
    } catch (e) {}
  }

  @override
  void dispose() {
    remarkController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void getMyFamily() async {
    setState(() {
      isLoading = true;
    });
    try {
      var response = await ApiService().post("/api/family-member/list",
          {"familyMemberCode": widget.code}, headers, context);

      var familyGroups = response['familyGroup'];
      var familyMembers = response['familyMember'];

      for (var familyGroup in familyGroups) {
        familyGroup['familyMembers'] = familyMembers
            .where((x) => x['fgc'] == familyGroup['code'])
            .toList();
      }
      menus = familyGroups[0]['menu']
          .split(',')
          .map((menu) => menu.trim())
          .toList();
      setState(() {
        isLoading = false;
        answer = familyGroups;
        discrepancyCount = response['config'][0]['discrepancyCount'];
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
      bottomNavigationBar: advertisementResponse.isNotEmpty
          ? AdvertisementBanner(
              title: advertisementResponse[0]['title'],
              subTitle: advertisementResponse[0]['subTitle'],
              url: advertisementResponse[0]['url'],
              mobile: advertisementResponse[0]['mobile'],
            )
          : const AdvertisementBanner(
              title: 'Your Business Name',
              subTitle: 'Show your business details or address here.',
              url: 'www.google.com',
              mobile: '9560033422',
            ),
      appBar: AppBar(
        title: widget.code == ''
            ? const Text("My Family")
            : const Text("Their Family"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 15,
            ),
            child: GestureDetector(
              onTap: () {
                nextScreen(
                  context,
                  const ReminderList(),
                );
              },
              child: Icon(
                FontAwesomeIcons.bell,
                color: themeVeryLightColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 15,
            ),
            child: GestureDetector(
              onTap: () {
                nextScreen(
                  context,
                  const TodoScreen(),
                );
              },
              child: Icon(
                FontAwesomeIcons.squareCheck,
                color: themeVeryLightColor,
              ),
            ),
          )
        ],
      ),
      drawer: widget.code == '' ? const MyDrawer() : null,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                getMyFamily();
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    if (discrepancyCount > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            nextScreen(
                              context,
                              const DiscrepancyScreen(),
                            );
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            width: double.infinity,
                            // height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(
                                15,
                              ),
                              color: Colors.red[100],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.only(
                                left: 10,
                                top: 5,
                                bottom: 5,
                                right: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Click here to enter your missing details…',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    FontAwesomeIcons.angleRight,
                                    color: Colors.red,
                                    size: 14,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 5,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: answer.length,
                      itemBuilder: (context, outerIndex) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      answer[outerIndex]['address'],
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (menus[0].isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        _showMenuBottomSheet(
                                            context, menus, outerIndex);
                                        // nextScreen(
                                        //   context,
                                        //   ChangeAddressScreen(
                                        //     groupCode: answer[outerIndex]['code'],
                                        //   ),
                                        // );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                          5,
                                        ),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            color: Colors.grey[300]),
                                        child: FaIcon(
                                          FontAwesomeIcons.gear,
                                          size: 18,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                margin: EdgeInsets.zero,
                                color: Colors.white,
                                child: Column(
                                  children: List.generate(
                                    answer[outerIndex]['familyMembers'].length,
                                    (innerIndex) {
                                      return Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () => nextScreen(
                                                context,
                                                ShowMemberInfo(
                                                    memberCode: answer[
                                                                outerIndex]
                                                            ['familyMembers']
                                                        [innerIndex]['code'])),
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: colors[
                                                    innerIndex % colors.length],
                                                child: Text(
                                                  answer[outerIndex]
                                                              ['familyMembers']
                                                          [innerIndex]['name']
                                                      .toString()[0],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              title: Text(answer[outerIndex]
                                                      ['familyMembers']
                                                  [innerIndex]['name']),
                                              trailing: Container(
                                                alignment: Alignment.center,
                                                color: Colors.white,
                                                width: 30,
                                                child: FaIcon(
                                                  FontAwesomeIcons.angleRight,
                                                  color: Colors.grey[350],
                                                  size: 20,
                                                ),
                                              ),
                                              subtitle: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: answer[outerIndex]
                                                              ['familyMembers']
                                                          [innerIndex]['age'],
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    if (answer[outerIndex][
                                                                    'familyMembers']
                                                                [
                                                                innerIndex]['desc']
                                                            .length >
                                                        0)
                                                      const WidgetSpan(
                                                        alignment:
                                                            PlaceholderAlignment
                                                                .middle,
                                                        child: SizedBox(
                                                          width:
                                                              10, // Adjust the width of the dot separator
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              '·',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    20, // Adjust the font size of the dot separator
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    TextSpan(
                                                      text: answer[outerIndex]
                                                              ['familyMembers']
                                                          [innerIndex]['desc'],
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(
                                              left: 70,
                                              right: 20,
                                            ),
                                            child: Divider(
                                              height: 0,
                                              thickness: 1,
                                              color: Color(0xFFF0F1F3),
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        nextScreen(
                          context,
                          const ChangeAddressScreen(
                            groupCode: '',
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white),
                      child: const Text(
                        "Add new Address",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showMenuBottomSheet(BuildContext context, menuItems, int outerIndex) {
    print(menuItems.length);
    showModalBottomSheet(
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15,
              ),
              child: Center(
                child: Container(
                  height: 6,
                  width: MediaQuery.of(context).size.width * 0.2,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(
                          0.7,
                        ),
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              "     Select an action",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(
              height: menuItems.length * 60.0,
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (BuildContext context, int index) {
                  final menuItem = menuItems[index];
                  String title = '';
                  Function? onTap;
                  Icon? icon;

                  // Assign titles and functions based on menu item
                  if (menuItem == 'EDIT_ADDRESS') {
                    title = 'Edit Address';
                    icon = Icon(
                      FontAwesomeIcons.pencil,
                      color: Theme.of(context).primaryColor,
                    );
                    onTap = () async {
                      // Implement the call functionality here

                      Navigator.pop(context);
                      nextScreen(
                        context,
                        ChangeAddressScreen(
                          groupCode: answer[outerIndex]['code'],
                        ),
                      );
                    };
                  } else if (menuItem == 'ADD_MEMBER') {
                    title = 'Add New Family Member';
                    icon = Icon(
                      Icons.add_circle,
                      color: Theme.of(context).primaryColor,
                      size: 30,
                    );
                    onTap = () async {
                      // Implement the WhatsApp functionality here

                      Navigator.pop(context);
                      nextScreen(
                        context,
                        EditScreen(
                          groupCode: answer[outerIndex]['code'],
                          membercode: '',
                        ),
                      );
                    };
                  }

                  // Add more menu items as needed

                  return ListTile(
                    title: Text(title),
                    onTap: () {
                      onTap!();
                    },
                    leading: icon,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
