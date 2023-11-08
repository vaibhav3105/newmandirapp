import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mandir_app/screens/editScreen.dart';
import 'package:mandir_app/utils/utils.dart';

import '../service/api_service.dart';

class DiscrepancyScreen extends StatefulWidget {
  const DiscrepancyScreen({super.key});

  @override
  State<DiscrepancyScreen> createState() => _DiscrepancyScreenState();
}

class _DiscrepancyScreenState extends State<DiscrepancyScreen> {
  List<dynamic> missingInfo = [];
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMissingInfo();
  }

  void getMissingInfo() async {
    setState(() {
      isLoading = true;
    });
    var response = await ApiService().post(
      "/api/family-group/discrepancy-list",
      {'familyGroupCode': ''},
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
      missingInfo = data;

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Missing Info'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: missingInfo.length,
                    itemBuilder: (context, outerIndex) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                            ),
                            child: Text(
                              missingInfo[outerIndex]['cat'],
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
                                  missingInfo[outerIndex]['items'].length,
                                  (innerIndex) {
                                    final missingItem = missingInfo[outerIndex]
                                        ['items'][innerIndex];
                                    Widget? icon;
                                    switch (missingInfo[outerIndex]['items']
                                        [innerIndex]['t']) {
                                      case 'INFO':
                                        icon = const Icon(
                                          Icons.info_outline,
                                          color: Colors.green,
                                          size: 35,
                                        );
                                        break;
                                      case 'WARN':
                                        icon = const Icon(
                                          Icons.error_outline,
                                          color: Colors.orange,
                                          size: 35,
                                        );

                                        break;
                                      case 'ERROR':
                                        icon = const Icon(
                                          FontAwesomeIcons.circleXmark,
                                          color: Colors.red,
                                          size: 30,
                                        );

                                        break;
                                    }
                                    return Column(
                                      children: [
                                        ListTile(
                                          title: Text(
                                              missingInfo[outerIndex]['items']
                                                  [innerIndex]['k'],
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16)),
                                          trailing:
                                              missingInfo[outerIndex]['items']
                                                          [innerIndex]['a']
                                                      .toString()
                                                      .isNotEmpty
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        missingInfo[outerIndex][
                                                                            'items']
                                                                        [
                                                                        innerIndex]['a']
                                                                    .toString() ==
                                                                'EDIT_MEMBER'
                                                            ? nextScreen(
                                                                context,
                                                                EditScreen(
                                                                    membercode: missingInfo[outerIndex]['items']
                                                                            [
                                                                            innerIndex]
                                                                        ['fmc'],
                                                                    groupCode:
                                                                        ''),
                                                              )
                                                            : null;
                                                      },
                                                      child: Icon(
                                                        FontAwesomeIcons
                                                            .angleRight,
                                                        color: Colors.grey[350],
                                                        size: 20,
                                                      ),
                                                    )
                                                  : null,
                                          leading: icon,
                                          subtitle: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: missingInfo[outerIndex]
                                                          ['items'][innerIndex]
                                                      ['v'],
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
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
                ],
              ),
            ),
    );
  }
}
