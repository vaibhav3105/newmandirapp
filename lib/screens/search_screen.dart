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
  List<dynamic> members = [];
  List<LookupItem> SearchByList = [];
  LookupItem? SearchByItem;

  bool isLoading = false;
  bool isLoadingMembers = false;

  void loadMembers() async {
    try {
      setState(() {
        isLoadingMembers = true;
      });
      var response = await ApiService().post2(
        context,
        "/api/family-member/search",
        {
          'searchBy': SearchByItem?.actualValue,
          'searchText': textController.text.trim()
        },
        headers,
      );
      if (response.success == false) {
        ApiService().handleApiResponse2(context, response.data);
        setState(() {
          isLoadingMembers = false;
          members = [];
        });
        return;
      }

      setState(() {
        isLoadingMembers = false;
        members = response.data;
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
    loadSearchFiltersFromApi();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    textController.dispose();
  }

  void loadSearchFiltersFromApi() async {
    // isLoading = true;
    setState(() {
      isLoading = true;
    });

    var response = await ApiService().post2(
      context,
      "/api/lookup/key-details",
      {'keyName': "SEARCH_MEMBER_BY"},
      headers,
    );
    if (response.success == false) {
      ApiService().handleApiResponse2(context, response.data);
    }

    List<LookupItem> result = [];
    if (response.success == true && response.data.length > 0) {
      result = (response.data as List<dynamic>)
          .map((lookUpItem) => LookupItem(
              displayText: lookUpItem["displayText"],
              actualValue: lookUpItem["actualValue"]))
          .toList();
    }

    setState(() {
      isLoading = false;
      SearchByList = result;
      if (SearchByList.isNotEmpty) {
        SearchByItem = SearchByList[0];
      }
    });
    // isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Members"),
        actions: [
          IconButton(
              onPressed: () {
                fnShowBottomSheet(context);
              },
              icon: Icon(
                Icons.filter_alt,
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
                  child: Text('${SearchByItem?.displayText}'),
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
                                loadMembers();
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

  void fnShowBottomSheet(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (context) {
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
                    width: MediaQuery.of(context).size.width * 0.25,
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
                height: 10,
              ),
              Text(
                "     Select an action",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(
                height: SearchByList.length * 60.0,
                child: ListView.builder(
                  itemCount: SearchByList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(SearchByList[index].displayText),
                      onTap: () {
                        setState(() {
                          SearchByItem = SearchByList[index];
                        });
                        Navigator.pop(context);
                      },
                      leading: Icon(
                        FontAwesomeIcons.magnifyingGlass,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        });
  }
}
