// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:mandir_app/constants.dart';
import 'package:mandir_app/screens/changeAddressScreen.dart';
import 'package:mandir_app/screens/editScreen.dart';
import 'package:mandir_app/screens/show_member_info.dart';
import 'package:mandir_app/utils/utils.dart';
import 'package:mandir_app/widgets/custom_textfield.dart';
import 'package:mandir_app/widgets/drawer.dart';

import '../service/api_service.dart';

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
  final remarkController = TextEditingController();
  var answer = [];
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyFamily();
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
      setState(() {
        isLoading = false;
        answer = familyGroups;
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
        title: widget.code == ''
            ? const Text("My Family")
            : const Text("Their Family"),
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
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView.builder(
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
                                  GestureDetector(
                                    onTap: () {
                                      nextScreen(
                                        context,
                                        ChangeAddressScreen(
                                          groupCode: answer[outerIndex]['code'],
                                        ),
                                      );
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
                                        FontAwesomeIcons.pencil,
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
                                              trailing: GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  showModalBottomSheet(
                                                      context: context,
                                                      builder: (context) {
                                                        return SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.4,
                                                          width:
                                                              double.infinity,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 13,
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                const Text(
                                                                  "     Select an action",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                      255,
                                                                      106,
                                                                      78,
                                                                      179,
                                                                    ),
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                    nextScreen(
                                                                        context,
                                                                        ShowMemberInfo(
                                                                            memberCode:
                                                                                answer[outerIndex]['familyMembers'][innerIndex]['code']));
                                                                  },
                                                                  child:
                                                                      const ListTile(
                                                                    title: Text(
                                                                      "View Member Info",
                                                                    ),
                                                                    leading:
                                                                        FaIcon(
                                                                      FontAwesomeIcons
                                                                          .userLarge,
                                                                      color: Color
                                                                          .fromARGB(
                                                                        255,
                                                                        106,
                                                                        78,
                                                                        179,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                if (widget
                                                                        .code ==
                                                                    '')
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      nextScreen(
                                                                        context,
                                                                        EditScreen(
                                                                          groupCode:
                                                                              answer[outerIndex]['familyMembers'][innerIndex]['fgc'],
                                                                          membercode:
                                                                              answer[outerIndex]['familyMembers'][innerIndex]['code'],
                                                                        ),
                                                                      );
                                                                    },
                                                                    child:
                                                                        const ListTile(
                                                                      title:
                                                                          Text(
                                                                        "Edit Member Info",
                                                                      ),
                                                                      leading:
                                                                          FaIcon(
                                                                        FontAwesomeIcons
                                                                            .pencil,
                                                                        color: Color
                                                                            .fromARGB(
                                                                          255,
                                                                          106,
                                                                          78,
                                                                          179,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                if (widget
                                                                        .code ==
                                                                    '')
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      nextScreen(
                                                                        context,
                                                                        EditScreen(
                                                                          groupCode:
                                                                              answer[outerIndex]['familyMembers'][innerIndex]['fgc'],
                                                                          membercode:
                                                                              '',
                                                                        ),
                                                                      );
                                                                    },
                                                                    child:
                                                                        const ListTile(
                                                                      title:
                                                                          Text(
                                                                        "Add new member",
                                                                      ),
                                                                      leading:
                                                                          FaIcon(
                                                                        FontAwesomeIcons
                                                                            .squarePlus,
                                                                        color: Color
                                                                            .fromARGB(
                                                                          255,
                                                                          106,
                                                                          78,
                                                                          179,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                if (widget
                                                                        .code ==
                                                                    '')
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (context) {
                                                                            return AlertDialog(
                                                                              title: const Text(
                                                                                "Delete Member",
                                                                              ),
                                                                              actions: [
                                                                                ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.red,
                                                                                  ),
                                                                                  onPressed: () async {
                                                                                    var response = await ApiService().post(
                                                                                      '/api/family-member/delete',
                                                                                      {
                                                                                        "familyMemberCode": answer[outerIndex]['familyMembers'][innerIndex]['code'],
                                                                                        'remark': remarkController.text.trim()
                                                                                      },
                                                                                      headers,
                                                                                      context,
                                                                                    );
                                                                                    if (response['errorCode'] == 0) {
                                                                                      Navigator.pop(context);
                                                                                      remarkController.text = '';
                                                                                      showCustomSnackbar(
                                                                                        context,
                                                                                        Colors.black,
                                                                                        response['message'],
                                                                                      );
                                                                                      getMyFamily();
                                                                                    }
                                                                                  },
                                                                                  child: const Text(
                                                                                    "Delete",
                                                                                    style: TextStyle(
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                ElevatedButton(
                                                                                  // style: ElevatedButton.styleFrom(
                                                                                  //   backgroundColor: const Color.fromARGB(
                                                                                  //     255,
                                                                                  //     106,
                                                                                  //     78,
                                                                                  //     179,
                                                                                  //   ),
                                                                                  // ),
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: const Text(
                                                                                    "Cancel",
                                                                                    style: TextStyle(
                                                                                      color: Colors.black,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                              content: Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  const Text(
                                                                                    "Are you sure you want to delete this member?",
                                                                                    style: TextStyle(
                                                                                      fontSize: 15,
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 13,
                                                                                  ),
                                                                                  CustomTextAreaField(
                                                                                    labelText: "Please enter a remark",
                                                                                    controller: remarkController,
                                                                                  )
                                                                                  // TextFormField(
                                                                                  //   controller: remarkController,
                                                                                  //   decoration: InputDecoration(
                                                                                  //     hintText: "Please enter a remark",
                                                                                  //     hintStyle: const TextStyle(
                                                                                  //       fontSize: 13,
                                                                                  //     ),
                                                                                  //     filled: true,
                                                                                  //     fillColor: Colors.white,
                                                                                  //     contentPadding: const EdgeInsets.symmetric(
                                                                                  //       vertical: 5,
                                                                                  //       horizontal: 10,
                                                                                  //     ),
                                                                                  //     border: OutlineInputBorder(
                                                                                  //       borderRadius: BorderRadius.circular(
                                                                                  //         12,
                                                                                  //       ),
                                                                                  //     ),
                                                                                  //   ),
                                                                                  //   maxLines: 4,
                                                                                  // ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          });
                                                                    },
                                                                    child:
                                                                        const ListTile(
                                                                      title:
                                                                          Text(
                                                                        "Delete Member",
                                                                      ),
                                                                      leading:
                                                                          FaIcon(
                                                                        FontAwesomeIcons
                                                                            .trash,
                                                                        color: Color
                                                                            .fromARGB(
                                                                          255,
                                                                          106,
                                                                          78,
                                                                          179,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  color: Colors.white,
                                                  width: 30,
                                                  child: FaIcon(
                                                    FontAwesomeIcons
                                                        .ellipsisVertical,
                                                    color: Colors.grey[600],
                                                    size: 20,
                                                  ),
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
                  ),
                ],
              ),
            ),
    );
  }
}
