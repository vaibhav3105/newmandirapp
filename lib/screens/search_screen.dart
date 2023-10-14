// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:mandir_app/screens/show_member_info.dart';
import 'package:mandir_app/utils/helper.dart';

import '../constants.dart';
import '../service/api_service.dart';
import '../utils/styling.dart';
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
  LookupItem? initialSearchBy;
  LookupItem? initialMandir;
  // List searchOptions = [];
  List<DropdownMenuItem<LookupItem>> searchOptionsButton =
      <DropdownMenuItem<LookupItem>>[];
  List<DropdownMenuItem<LookupItem>> mandirOptionsButton =
      <DropdownMenuItem<LookupItem>>[];

  int userType = 0;
  bool isLoading = false;
  bool isLoadingMembers = false;
  void getMembers() async {
    try {
      setState(() {
        isLoadingMembers = true;
      });
      var response = await ApiService().post(
        "/api/family-member/search",
        {
          'searchBy': initialSearchBy!.actualValue,
          'searchText': textController.text.trim(),
          'mandirCode': initialMandir!.actualValue
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
    getSearchFiltersFromApi();
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

  void getSearchFiltersFromApi() async {
    setState(() {
      isLoading = true;
    });
    var response = await ApiService().post(
      "/api/lookup/key-details",
      {'keyName': "SEARCH_MEMBER_BY"},
      headers,
      context,
    );

    var searchItems = (response as List<dynamic>)
        .map((lookUpItem) => LookupItem(
            displayText: lookUpItem["displayText"],
            actualValue: lookUpItem["actualValue"]))
        .toList();
    setState(() {
      searchOptionsButton = searchItems
          .map(
            (LookupItem item) => DropdownMenuItem<LookupItem>(
              value: item,
              child: Text(
                item.displayText,
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            ),
          )
          .toList();
      initialSearchBy = searchItems[0];

      // searchOptions = searchItems;
    });
    getMandirList();
  }

  getMandirList() async {
    try {
      var response = await ApiService().post(
        '/api/master-data/mandir-ji/list',
        {},
        headers,
        context,
      );
      var mandirItems = (response as List<dynamic>)
          .map(
            (apiItem) => LookupItem(
              displayText: apiItem['name'],
              actualValue: apiItem['mandirCode'],
            ),
          )
          .toList();
      setState(() {
        mandirOptionsButton = mandirItems
            .map(
              (LookupItem item) => DropdownMenuItem<LookupItem>(
                value: item,
                child: Text(
                  item.displayText,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
            )
            .toList();
        initialMandir = mandirItems[0];
        isLoading = false;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // LookupItem filterValue = LookupItem(displayText: "Name", actualValue: "NAME");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Members"),
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    builder: (context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.35,
                        width: double.infinity,
                        // decoration: const BoxDecoration(color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                child: Center(
                                  child: Container(
                                    height: 6,
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(
                                            0.7,
                                          ),
                                      borderRadius: BorderRadius.circular(
                                        20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // const SizedBox(
                              //   height: 10,
                              // ),
                              // const Text(
                              //   "  Select a filter",
                              //   style: TextStyle(
                              //     color: Color.fromARGB(
                              //       255,
                              //       106,
                              //       78,
                              //       179,
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(
                                height: 20,
                              ),
                              DropdownButtonFormField(
                                hint: const Text("Select Search by"),
                                value: initialSearchBy,
                                decoration: textInputDecoration.copyWith(
                                  labelText: 'Search by',
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                items: searchOptionsButton,
                                onChanged: (LookupItem? item) {
                                  setState(() {
                                    initialSearchBy = item!;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              DropdownButtonFormField(
                                isDense: false,
                                isExpanded: true,
                                hint: const Text("Select Mandir Ji"),
                                value: initialMandir,
                                decoration: textInputDecoration.copyWith(
                                  labelText: 'Nearby Mandir Ji',
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                items: mandirOptionsButton,
                                onChanged: (LookupItem? item) {
                                  setState(() {
                                    initialMandir = item!;
                                  });
                                },
                              ),
                              // Center(
                              //   child: SizedBox(
                              //     width: double.infinity,
                              //     child: ElevatedButton(
                              //       onPressed: () {},
                              //       style: ElevatedButton.styleFrom(
                              //         shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(14),
                              //         ),
                              //         fixedSize: const Size(170, 45),
                              //         backgroundColor: const Color.fromARGB(
                              //           255,
                              //           106,
                              //           78,
                              //           179,
                              //         ),
                              //       ),
                              //       child: const Text(
                              //         "Apply Filter",
                              //         style: TextStyle(
                              //           color: Colors.white,
                              //           fontSize: 20,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      );
                    });
              },
              icon: Icon(
                Icons.tune,
                size: 28,
                color: themeVeryLightColor,
              ))
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Text('Search by ${initialSearchBy!.displayText}'),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 20,
                //   ),
                //   child: GestureDetector(
                //     onTap: () {
                //       showMenu(
                //         constraints: const BoxConstraints(
                //           minWidth: 150,
                //         ),
                //         context: context,
                //         position: const RelativeRect.fromLTRB(10, 120, 10, 10),
                //         items: List.generate(searchOptions.length, (index) {
                //           return PopupMenuItem(
                //             onTap: () {
                //               setState(() {
                //                 filterValue = searchOptions[index];
                //               });
                //             },
                //             value: searchOptions[index],
                //             child: Text(searchOptions[index].displayText),
                //           );
                //         }),
                //       );
                //     },
                //     child: Row(
                //       children: [
                //         Text(
                //           'Search by ${filterValue.displayText}',
                //         ),
                //         const SizedBox(
                //           width: 5,
                //         ),
                //         GestureDetector(
                //           onTap: () {
                //             showMenu(
                //               constraints: const BoxConstraints(
                //                 minWidth: 150,
                //               ),
                //               context: context,
                //               position:
                //                   const RelativeRect.fromLTRB(10, 120, 10, 10),
                //               items:
                //                   List.generate(searchOptions.length, (index) {
                //                 return PopupMenuItem(
                //                   onTap: () {
                //                     setState(() {
                //                       filterValue = searchOptions[index];
                //                     });
                //                   },
                //                   value: searchOptions[index],
                //                   child: Text(searchOptions[index].displayText),
                //                 );
                //               }),
                //             );
                //           },
                //           child: const Icon(
                //             FontAwesomeIcons.caretDown,
                //             size: 15,
                //           ),
                //         )
                //       ],
                //     ),
                //   ),
                // ),
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
                                getMembers();
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
                        : const Center(child: Text('No record found'))
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
