// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String mobile = '';
  String email = '';
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getMemberInfo();
  }

  bool isValidEmail(String email) {
    RegExp regExp = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
      caseSensitive: false,
      multiLine: false,
    );

    return regExp.hasMatch(email);
  }

  bool isMobileNumber10Digit(String mobileNumber) {
    RegExp regExp = RegExp(r'^[0-9]{10}$');
    return regExp.hasMatch(mobileNumber);
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
    for (var item in response) {
      if (item['k'] == 'Mobile') {
        mobile = item['v'];
      }
    }
    for (var item in response) {
      if (item['k'] == 'Email') {
        email = item['v'];
      }
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
        actions: [
          if (isMobileNumber10Digit(mobile) == true)
            const SizedBox(
              width: 30,
            ),
          if (isMobileNumber10Digit(mobile) == true)
            GestureDetector(
              onTap: () async {
                await launchUrl(
                  Uri(scheme: 'tel', path: mobile),
                );
              },
              child: const FaIcon(
                FontAwesomeIcons.phone,
                size: 20,
              ),
            ),
          if (isMobileNumber10Digit(mobile) == true)
            const SizedBox(
              width: 30,
            ),
          if (isMobileNumber10Digit(mobile) == true)
            GestureDetector(
              onTap: () async {
                await launchUrl(Uri(scheme: 'https', path: 'wa.me/$mobile'),
                    mode: LaunchMode.externalApplication);
              },
              child: const FaIcon(
                FontAwesomeIcons.solidMessage,
                size: 20,
              ),
            ),
          if (isValidEmail(email) == true)
            const SizedBox(
              width: 30,
            ),
          if (isValidEmail(email) == true)
            GestureDetector(
              onTap: () async {
                await launchUrl(
                  Uri(scheme: 'mailto', path: email),
                );
              },
              child: const FaIcon(
                FontAwesomeIcons.solidEnvelope,
                size: 20,
              ),
            ),
          const SizedBox(
            width: 30,
          ),
        ],
        title: const Text("Details"),
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
