import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mandir_app/constants.dart';
import 'package:mandir_app/screens/show_member_info.dart';
import 'package:mandir_app/utils/utils.dart';
import 'package:mandir_app/widgets/drawer.dart';

import '../service/api_service.dart';
//okkkforgood
class MyFamilyList extends StatefulWidget {
  const MyFamilyList({super.key});

  @override
  State<MyFamilyList> createState() => _MyFamilyListState();
}

class _MyFamilyListState extends State<MyFamilyList> {
  var answer = [];
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyFamily();
  }

  void getMyFamily() async {
    setState(() {
      isLoading = true;
    });
    try {
      var response = await ApiService()
          .post("/api/family-member/list", {}, headers, context);
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
        title: const Text("My Family"),
      ),
      drawer: const MyDrawer(),
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
                    itemCount: answer.length,
                    itemBuilder: (context, outerIndex) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                            ),
                            child: Text(
                              answer[outerIndex]['address'],
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
                                  answer[outerIndex]['familyMembers'].length,
                                  (innerIndex) {
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () => nextScreen(
                                              context,
                                              ShowMemberInfo(
                                                  memberCode: answer[outerIndex]
                                                          ['familyMembers']
                                                      [innerIndex]['code'])),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: colors[
                                                  innerIndex % colors.length],
                                              child: Text(
                                                answer[outerIndex]
                                                            ['familyMembers']
                                                        [innerIndex]['t1']
                                                    .toString()[0],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            title: Text(answer[outerIndex]
                                                    ['familyMembers']
                                                [innerIndex]['t1']),
                                            trailing: FaIcon(
                                              FontAwesomeIcons.angleRight,
                                              color: Colors.grey[600],
                                            ),
                                            subtitle: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: answer[outerIndex]
                                                            ['familyMembers']
                                                        [innerIndex]['t2'],
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  if (answer[outerIndex][
                                                                  'familyMembers']
                                                              [innerIndex]['t3']
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
                                                          alignment:
                                                              Alignment.center,
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
                                                        [innerIndex]['t3'],
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
    );
  }
}
