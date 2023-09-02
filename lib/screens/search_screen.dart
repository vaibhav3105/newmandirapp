// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mandir_app/screens/loginInfo.dart';
import 'package:mandir_app/screens/myFamilyList.dart';

import 'package:mandir_app/screens/show_member_info.dart';
import 'package:mandir_app/utils/helper.dart';

import '../constants.dart';
import '../service/api_service.dart';
import '../utils/utils.dart';

class LookupItem {
  String displayText;
  String actualValue;

  LookupItem({
    required this.displayText,
    required this.actualValue,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // List<DropdownMenuEntry<LookupItem>> dropDownItems =
  //     <DropdownMenuEntry<LookupItem>>[];
  // LookupItem? selectedValue;
  List<dynamic> members = [];
  List allFilterOptions = [];

  int userType = 0;
  bool isLoading = false;
  bool isLoadingMembers = false;
  void getMembers(LookupItem selectedItem) async {
    try {
      setState(() {
        isLoadingMembers = true;
      });
      var response = await ApiService().post(
        "/api/family-member/search",
        {
          'searchBy': selectedItem.actualValue,
          'searchText': textController.text.trim()
        },
        headers,
        context,
      );
      print(response);

      setState(() {
        isLoadingMembers = false;
        members = response;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  final TextEditingController textController = TextEditingController();
  @override
  void initState() {
    super.initState();
    isLoading = true;
    getJsonFromApi();
    getUserType();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    textController.dispose();
  }

  void getUserType() async {
    var code = await Helper.getUserType();
    setState(() {
      userType = code!;
    });
  }

  void getJsonFromApi() async {
    setState(() {
      isLoading = true;
    });
    var response = await ApiService().post(
      "/api/lookup/key-details",
      {'keyName': "SEARCH_MEMBER_BY"},
      headers,
      context,
    );

    var items = (response as List<dynamic>)
        .map((lookUpItem) => LookupItem(
            displayText: lookUpItem["displayText"],
            actualValue: lookUpItem["actualValue"]))
        .toList();
    setState(() {
      allFilterOptions = items;
      isLoading = false;
    });

    // setState(() {
    //   dropDownItems = items
    //       .map(
    //         (LookupItem item) => DropdownMenuEntry<LookupItem>(
    //           label: item.displayText,
    //           value: item,
    //         ),
    //       )
    //       .toList();
    //   isLoading = false;
    // });
  }

  LookupItem filterValue = LookupItem(displayText: "Name", actualValue: "NAME");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Members"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      showMenu(
                        constraints: const BoxConstraints(
                          minWidth: 150,
                        ),
                        context: context,
                        position: const RelativeRect.fromLTRB(10, 120, 10, 10),
                        items: List.generate(allFilterOptions.length, (index) {
                          return PopupMenuItem(
                            onTap: () {
                              setState(() {
                                filterValue = allFilterOptions[index];
                              });
                            },
                            value: allFilterOptions[index],
                            child: Text(allFilterOptions[index].displayText),
                          );
                        }),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'Search by ${filterValue.displayText}',
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            showMenu(
                              constraints: const BoxConstraints(
                                minWidth: 150,
                              ),
                              context: context,
                              position:
                                  const RelativeRect.fromLTRB(10, 120, 10, 10),
                              items: List.generate(allFilterOptions.length,
                                  (index) {
                                return PopupMenuItem(
                                  onTap: () {
                                    setState(() {
                                      filterValue = allFilterOptions[index];
                                    });
                                  },
                                  value: allFilterOptions[index],
                                  child:
                                      Text(allFilterOptions[index].displayText),
                                );
                              }),
                            );
                          },
                          child: const Icon(
                            FontAwesomeIcons.caretDown,
                            size: 15,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: TextFormField(
                    controller: textController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 10,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 50,
                            width: 1,
                            color: Colors.grey,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 5,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.search,
                              ),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                getMembers(filterValue);
                              },
                            ),
                          ),
                        ],
                      ),
                      hintText: "Enter your text...",
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 13,
                ),
                !isLoadingMembers
                    ? members.isNotEmpty
                        ? Expanded(
                            child: ListView.builder(
                              itemCount: members.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 19,
                                      ),
                                      child: GestureDetector(
                                        onTap: () => nextScreen(
                                            context,
                                            ShowMemberInfo(
                                                memberCode: members[index]
                                                    ['code'])),
                                        child: Container(
                                          color: Colors.white,
                                          child: ListTile(
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      if (members[index]['age']
                                                              .length >
                                                          0)
                                                        TextSpan(
                                                          text: members[index]
                                                              ['age'],
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      if (members[index]['age']
                                                              .length >
                                                          0)
                                                        const TextSpan(
                                                          text: " • ",
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      TextSpan(
                                                        text: members[index]
                                                            ['resultText'],
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      const TextSpan(
                                                        text: " • ",
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: members[index]
                                                            ['fullAddress'],
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 1,
                                            ),
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  colors[index % colors.length],
                                              child: Text(
                                                members[index]['name'][0],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              members[index]['name'],
                                              style: const TextStyle(),
                                            ),
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
                                                        width: double.infinity,
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
                                                                          members[index]
                                                                              [
                                                                              'code'],
                                                                    ),
                                                                  );
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
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  nextScreen(
                                                                      context,
                                                                      MyFamilyList(
                                                                          code: members[index]
                                                                              [
                                                                              'code']));
                                                                },
                                                                child:
                                                                    const ListTile(
                                                                  title: Text(
                                                                    "View Family",
                                                                  ),
                                                                  leading:
                                                                      FaIcon(
                                                                    FontAwesomeIcons
                                                                        .userGroup,
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
                                                              if (userType ==
                                                                  99)
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                    nextScreen(
                                                                      context,
                                                                      LoginInfo(
                                                                        memberCode:
                                                                            members[index]['code'],
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      const ListTile(
                                                                    title: Text(
                                                                      "View Login Info",
                                                                    ),
                                                                    leading:
                                                                        FaIcon(
                                                                      FontAwesomeIcons
                                                                          .key,
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
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                      color: Colors.transparent,
                                      height: 3,
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                        : const Text('No record found')
                    : const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
              ],
            ),
    );
  }
}
