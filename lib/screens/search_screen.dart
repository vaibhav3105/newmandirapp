// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mandir_app/screens/loginInfo.dart';

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
  List<DropdownMenuEntry<LookupItem>> dropDownItems =
      <DropdownMenuEntry<LookupItem>>[];
  LookupItem? selectedValue;
  List<dynamic> members = [];
  int userType = 0;
  bool isLoading = false;
  void getMembers(LookupItem selectedItem) async {
    var response = await ApiService().post(
      "/api/family-member/search",
      {
        'searchBy': selectedItem.actualValue,
        'searchText': textController.text.trim()
      },
      headers,
      context,
    );

    setState(() {
      members = response;
      isLoading = false;
    });
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
    var response = await ApiService().post(
      "/api/lookup/key-details",
      {'keyName': "SEARCH_MEMBER_BY"},
      headers,
      context,
    );
    print(response);
    var items = (response as List<dynamic>)
        .map((lookUpItem) => LookupItem(
            displayText: lookUpItem["displayText"],
            actualValue: lookUpItem["actualValue"]))
        .toList();

    setState(() {
      dropDownItems = items
          .map(
            (LookupItem item) => DropdownMenuEntry<LookupItem>(
              label: item.displayText,
              value: item,
            ),
          )
          .toList();
      isLoading = false;
    });
  }

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 20,
                        ),
                        child: DropdownMenu<LookupItem>(
                          width: 130,
                          label: const Text(
                            "Search By",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          dropdownMenuEntries: dropDownItems,
                          onSelected: (LookupItem? item) {
                            setState(() {
                              selectedValue = item;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: textController,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 10,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                            labelText: "Search",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                        ),
                        child: ElevatedButton(
                          onPressed: () => getMembers(selectedValue!),
                          child: const Text("Go"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 13,
                ),
                !isLoading
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Container(
                                    color: Colors.white,
                                    child: ListTile(
                                      subtitle: members[index]['t3'] != null
                                          ? Text(
                                              members[index]['t3'],
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            )
                                          : const Text(""),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 30,
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
                                      title: Text(
                                        members[index]['t1'],
                                        style: const TextStyle(),
                                      ),
                                      trailing: GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (context) {
                                                return SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.20,
                                                  width: double.infinity,
                                                  child: Padding(
                                                    padding: const EdgeInsets
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
                                                          style: TextStyle(
                                                            color:
                                                                Color.fromARGB(
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
                                                          child: const ListTile(
                                                            title: Text(
                                                              "View Member Info",
                                                            ),
                                                            leading: FaIcon(
                                                              FontAwesomeIcons
                                                                  .circleInfo,
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
                                                        if (userType == 99)
                                                          GestureDetector(
                                                            onTap: () =>
                                                                nextScreen(
                                                              context,
                                                              LoginInfo(
                                                                memberCode:
                                                                    members[index]
                                                                        [
                                                                        'code'],
                                                              ),
                                                            ),
                                                            child:
                                                                const ListTile(
                                                              title: Text(
                                                                "View Login Info",
                                                              ),
                                                              leading: FaIcon(
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
                                            FontAwesomeIcons.ellipsisVertical,
                                            color: Colors.grey[600],
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
                    : const Center(
                        child: CircularProgressIndicator(),
                      )
              ],
            ),
    );
  }
}
