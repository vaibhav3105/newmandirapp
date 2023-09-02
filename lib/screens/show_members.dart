// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

import 'package:mandir_app/screens/show_member_info.dart';

import '../constants.dart';
import '../service/api_service.dart';
import '../utils/utils.dart';

class Show_members_Screen extends StatefulWidget {
  final String? familyCode;
  final String address;
  const Show_members_Screen({
    Key? key,
    required this.familyCode,
    required this.address,
  }) : super(key: key);

  @override
  State<Show_members_Screen> createState() => _Show_members_ScreenState();
}

class _Show_members_ScreenState extends State<Show_members_Screen> {
  var members = [];
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMembers();
  }

  void getMembers() async {
    setState(() {
      isLoading = true;
    });
    var response = await ApiService().post(
      "/api/family-member/list",
      {},
      headers,
      context,
    );

    setState(() {
      members = response['familyMember'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Family"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                if (widget.familyCode != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          "Members of ",
                          style: TextStyle(
                            fontSize: 15,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        Text(
                          widget.address,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (widget.familyCode == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Text('Showing full family...'),
                  ),
                const SizedBox(
                  height: 5,
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 30,
                //   ),
                //   child: Text(
                //     widget.address,
                //     style: TextStyle(
                //       fontSize: 15,
                //       // fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () => nextScreen(
                              context,
                              ShowMemberInfo(
                                memberCode: members[index]['code'],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Container(
                                color: Colors.white,
                                child: ListTile(
                                  // tileColor: members[index]['isFamilyHead'] == true
                                  //     ? Colors.blue[50]
                                  //     : null,
                                  subtitle: members[index]['t3'] != null
                                      ? Text(
                                          members[index]['t3'],
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        )
                                      : const Text(""),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 1,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        colors[index % colors.length],
                                    child: Text(
                                      members[index]['t1'][0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        members[index]['t1'],
                                        style: const TextStyle(),
                                      ),
                                      Text(
                                        members[index]['t2'],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      )
                                    ],
                                  ),
                                  // trailing: Text(
                                  //   members[index]['t2'],
                                  // ),
                                  // trailing: FaIcon(
                                  //   FontAwesomeIcons.angleRight,
                                  // ),
                                ),
                              ),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //     left: 85,
                          //     right: 20,
                          //   ),
                          //   child: const Divider(
                          //     color: Colors.transparent,
                          //     // color: Color.fromARGB(
                          //     //   255,
                          //     //   243,
                          //     //   235,
                          //     //   234,
                          //     // ),
                          //     thickness: 0,
                          //   ),
                          // ),
                          const Divider(
                            color: Colors.transparent,
                            height: 3,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
