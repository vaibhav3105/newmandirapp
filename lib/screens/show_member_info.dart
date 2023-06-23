// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

import '../service/api_service.dart';

class ShowMemberInfo extends StatefulWidget {
  final String memberCode;
  const ShowMemberInfo({
    Key? key,
    required this.memberCode,
  }) : super(key: key);

  @override
  State<ShowMemberInfo> createState() => _ShowMemberInfoState();
}

class _ShowMemberInfoState extends State<ShowMemberInfo> {
  List<dynamic> memberInfo = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getMemberInfo();
  }

  void getMemberInfo() async {
    setState(() {
      isLoading = true;
    });
    var response = await ApiService().post(
      "/api/family-member/view-info",
      {'familyMemberCode': widget.memberCode},
      headers,
      context,
    );
    var cats = List.from(Set.from(response.map((e) => e['c'])));
    var data = [];
    for (var cat in cats) {
      var item = {"cat": cat};
      item['items'] = response.where((x) => x['c'] == cat).toList();
      data.add(item);
    }

    setState(() {
      memberInfo = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Member Info"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: memberInfo.length,
                    itemBuilder: (context, outerIndex) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                            ),
                            child: Text(
                              memberInfo[outerIndex]['cat'],
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
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
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              margin: EdgeInsets.zero,
                              color: Colors.white,
                              child: Column(
                                children: List.generate(
                                  memberInfo[outerIndex]['items'].length,
                                  (innerIndex) {
                                    return Column(
                                      children: [
                                        ListTile(
                                          title: Text(
                                            memberInfo[outerIndex]['items']
                                                [innerIndex]['k'],
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          // trailing: FaIcon(
                                          //   FontAwesomeIcons.angleRight,
                                          //   color: Colors.grey[600],
                                          // ),
                                          subtitle: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: memberInfo[outerIndex]
                                                          ['items'][innerIndex]
                                                      ['v'],
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(
                                            left: 20,
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
    );
  }
}
