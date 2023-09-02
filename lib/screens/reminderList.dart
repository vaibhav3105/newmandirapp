// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mandir_app/screens/addReminderScreen.dart';

import '../constants.dart';
import '../service/api_service.dart';
import '../utils/utils.dart';
import 'editScreen.dart';

class ReminderList extends StatefulWidget {
  // final String date;
  const ReminderList({
    Key? key,
    // required this.date,
  }) : super(key: key);

  @override
  State<ReminderList> createState() => _ReminderListState();
}

class _ReminderListState extends State<ReminderList> {
  bool isLoadingDropControls = false;
  bool gettingReminders = false;
  List<dynamic> reminders = [];
  final textController = TextEditingController();
  // final dateController = TextEditingController(
  //   text: DateFormat('dd-MMM-yyyy').format(
  //     DateTime.now(),
  //   ),
  // );
  APIDropDownItem? initialSearchBy;
  List<DropdownMenuItem<APIDropDownItem>> SearchByOptionsButton =
      <DropdownMenuItem<APIDropDownItem>>[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // if (widget.date.isNotEmpty) {
    //   dateController.text = widget.date;
    // }
    getSearchByControls();
    getListOfReminders();
  }

  getListOfReminders() async {
    try {
      setState(() {
        gettingReminders = true;
      });

      var response = await ApiService().post(
          '/api/reminder/list',
          {
            "searchType": initialSearchBy!.actualValue,
            "searchValue": textController.text.trim()
          },
          headers,
          context);
      setState(() {
        reminders = response['reminders'];
        print(reminders);
        gettingReminders = false;
      });
    } catch (e) {
      gettingReminders = false;
      print(e.toString());
    }
  }

  void getSearchByControls() async {
    try {
      setState(() {
        isLoadingDropControls = true;
      });
      var response = await ApiService().post('/api/lookup/key-details',
          {"keyName": "SEARCH_REMINDER_BY"}, headers, context);
      var searchByItems = (response as List<dynamic>)
          .map(
            (apiItem) => APIDropDownItem(
              displayText: apiItem['displayText'],
              actualValue: apiItem['actualValue'],
            ),
          )
          .toList();

      setState(() {
        initialSearchBy = searchByItems[0];
        SearchByOptionsButton = searchByItems
            .map(
              (APIDropDownItem item) => DropdownMenuItem<APIDropDownItem>(
                value: item,
                child: Text(
                  item.displayText,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
            )
            .toList();
        isLoadingDropControls = false;
      });
    } catch (e) {
      isLoadingDropControls = false;
      showCustomSnackbar(
        context,
        Colors.black,
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Reminders",
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.add,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nextScreen(
            context,
            const AddReminderScreen(
              reminderCode: '',
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        // label: const Text(
        //   "Add",
        //   style: TextStyle(
        //     fontSize: 20,
        //   ),
        // ),
        // icon: const Icon(
        //   Icons.add,
        // ),
      ),
      body: isLoadingDropControls == true
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  DropdownButtonFormField(
                    value: initialSearchBy,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    items: SearchByOptionsButton,
                    onChanged: (APIDropDownItem? item) {
                      setState(() {
                        initialSearchBy = item!;
                        // dateController.text =
                        //     DateFormat('dd-MMM-yyyy').format(
                        //   DateTime.now(),
                        // );
                        textController.text = '';
                        getListOfReminders();
                      });
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // if (initialSearchBy!.actualValue == 'SEARCH_BY_DATE')
                  //   TextFormField(
                  //     readOnly: true,
                  //     onTap: () async {
                  //       final DateTime? pickedDate = await showDatePicker(
                  //           context: context,
                  //           initialDate: DateTime.now(),
                  //           firstDate: DateTime(1920),
                  //           lastDate: DateTime(2080));
                  //       if (pickedDate != null) {
                  //         setState(() {
                  //           dateController.text =
                  //               DateFormat('dd-MMM-yyyy').format(pickedDate);
                  //           getListOfReminders(false);
                  //         });
                  //       }
                  //     },
                  //     controller: dateController,
                  //     decoration: InputDecoration(
                  //       fillColor: Colors.white,
                  //       filled: true,
                  //       suffixIcon: const Icon(
                  //         Icons.event,
                  //       ),
                  //       contentPadding: const EdgeInsets.symmetric(
                  //         vertical: 5,
                  //         horizontal: 10,
                  //       ),
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(
                  //           12,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  if (initialSearchBy!.actualValue == 'SEARCH_BY_TEXT')
                    TextFormField(
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
                                  getListOfReminders();
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
                  const SizedBox(
                    height: 20,
                  ),
                  gettingReminders == true
                      ? const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              bottom: 80,
                            ),
                            itemCount: reminders.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Container(
                                    color: Colors.white,
                                    child: ListTile(
                                      subtitle: Text(
                                        reminders[index]['subTitle'],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
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
                                          reminders[index]['repeat'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        reminders[index]['title'],
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
                                                      0.3,
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
                                                        if (reminders[index]
                                                                    ['type'] ==
                                                                'REM' &&
                                                            reminders[index][
                                                                    'repeat'] ==
                                                                'O' &&
                                                            initialSearchBy!
                                                                    .actualValue ==
                                                                'SEARCH_BY_DATE')
                                                          GestureDetector(
                                                            onTap: () async {
                                                              var response =
                                                                  await ApiService().post(
                                                                      '/api/reminder/item',
                                                                      {
                                                                        "reminderCode":
                                                                            reminders[index]['code']
                                                                      },
                                                                      headers,
                                                                      context);

                                                              DateTime date =
                                                                  DateTime.parse(
                                                                          response[
                                                                              'remindOn'])
                                                                      .add(
                                                                const Duration(
                                                                    days: 1),
                                                              );

                                                              await ApiService()
                                                                  .post(
                                                                      '/api/reminder/update',
                                                                      {
                                                                        "reminderCode":
                                                                            reminders[index]['code'],
                                                                        "title":
                                                                            response['title'],
                                                                        "desc":
                                                                            response['desc'],
                                                                        "remindOn":
                                                                            date.toString(),
                                                                        "repeatFlag":
                                                                            response['repeatFlag']
                                                                      },
                                                                      headers,
                                                                      context);
                                                              Navigator.pop(
                                                                  context);
                                                              showCustomSnackbar(
                                                                  context,
                                                                  Colors.black,
                                                                  'Reminder updated successfully.');
                                                              // dateController
                                                              //         .text =
                                                              //     DateFormat(
                                                              //             'dd-MMM-yyyy')
                                                              //         .format(
                                                              //             date);
                                                              getListOfReminders();
                                                            },
                                                            child:
                                                                const ListTile(
                                                              title: Text(
                                                                "Remind me tomorrow",
                                                              ),
                                                              leading: FaIcon(
                                                                FontAwesomeIcons
                                                                    .clock,
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
                                                        if (reminders[index]
                                                                ['type'] ==
                                                            'REM')
                                                          GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              nextScreen(
                                                                  context,
                                                                  AddReminderScreen(
                                                                      reminderCode:
                                                                          reminders[index]
                                                                              [
                                                                              'code']));
                                                            },
                                                            child:
                                                                const ListTile(
                                                              title: Text(
                                                                "Edit Reminder",
                                                              ),
                                                              leading: FaIcon(
                                                                FontAwesomeIcons
                                                                    .pencil,
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
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                    title:
                                                                        const Text(
                                                                      "Delete Reminder",
                                                                    ),
                                                                    actions: [
                                                                      ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          backgroundColor:
                                                                              Colors.red,
                                                                        ),
                                                                        onPressed: reminders[index]['type'] ==
                                                                                'REM'
                                                                            ? () async {
                                                                                try {
                                                                                  var response = await ApiService().post(
                                                                                    '/api/reminder/delete',
                                                                                    {
                                                                                      'reminderCode': reminders[index]['code']
                                                                                    },
                                                                                    headers,
                                                                                    context,
                                                                                  );
                                                                                  Navigator.pop(context);
                                                                                  getListOfReminders();

                                                                                  showCustomSnackbar(
                                                                                    context,
                                                                                    Colors.black,
                                                                                    response['message'],
                                                                                  );
                                                                                } catch (e) {
                                                                                  showCustomSnackbar(
                                                                                    context,
                                                                                    Colors.black,
                                                                                    e.toString(),
                                                                                  );
                                                                                }
                                                                              }
                                                                            : () async {
                                                                                try {
                                                                                  var response = await ApiService().post(
                                                                                    '/api/family-member/toggle-birthday-reminder',
                                                                                    {
                                                                                      'familyMemberCode': reminders[index]['code']
                                                                                    },
                                                                                    headers,
                                                                                    context,
                                                                                  );
                                                                                  Navigator.pop(context);
                                                                                  getListOfReminders();

                                                                                  showCustomSnackbar(
                                                                                    context,
                                                                                    Colors.black,
                                                                                    response['message'],
                                                                                  );
                                                                                } catch (e) {
                                                                                  showCustomSnackbar(
                                                                                    context,
                                                                                    Colors.black,
                                                                                    e.toString(),
                                                                                  );
                                                                                }
                                                                              },
                                                                        child:
                                                                            const Text(
                                                                          "Delete",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          backgroundColor:
                                                                              const Color.fromARGB(
                                                                            255,
                                                                            106,
                                                                            78,
                                                                            179,
                                                                          ),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          "Cancel",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                    content:
                                                                        const Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Text(
                                                                          "Are you sure you want to delete this reminder?",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              13,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                });
                                                          },
                                                          child: const ListTile(
                                                            title: Text(
                                                              "Delete Reminder",
                                                            ),
                                                            leading: FaIcon(
                                                              FontAwesomeIcons
                                                                  .trash,
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
                                  const Divider(
                                    color: Colors.transparent,
                                    height: 3,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                  // Container(
                  //   color: Colors.white,
                  //   height: 80,
                  // )
                ],
              ),
            ),
    );
  }
}
