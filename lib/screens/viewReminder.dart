// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../entity/apiResult.dart';
import '../service/api_service.dart';

class ViewReminder extends StatefulWidget {
  final String reminderCode;
  const ViewReminder({
    Key? key,
    required this.reminderCode,
  }) : super(key: key);

  @override
  State<ViewReminder> createState() => _ViewReminderState();
}

class _ViewReminderState extends State<ViewReminder> {
  bool isLoading = false;
  List<dynamic> reminderInfo = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReminderInfo();
  }

  void getReminderInfo() async {
    setState(() {
      isLoading = true;
    });
    ApiResult result = await ApiService().post2(
      context,
      "/api/reminder/view-info",
      {'reminderCode': widget.reminderCode},
      headers,
    );
    if (result.success == false) {
      ApiService().handleApiResponse2(context, result.data);
      result.data = [];
    }

    var cats = List.from(Set.from(result.data.map((e) => e['c'])));
    var data = [];
    for (var cat in cats) {
      var item = {"cat": cat};
      item['items'] = result.data.where((x) => x['c'] == cat).toList();
      data.add(item);
    }

    setState(() {
      isLoading = false;
      reminderInfo = data;
      print(reminderInfo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reminder Info"),
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reminderInfo.length,
                  itemBuilder: (context, outerIndex) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                          ),
                          child: Text(
                            reminderInfo[outerIndex]['cat'],
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
                                reminderInfo[outerIndex]['items'].length,
                                (innerIndex) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          reminderInfo[outerIndex]['items']
                                              [innerIndex]['k'],
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: reminderInfo[outerIndex]
                                                    ['items'][innerIndex]['v'],
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
              ],
            ),
    );
  }
}
