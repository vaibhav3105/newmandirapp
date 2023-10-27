// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mandir_app/screens/addReminderScreen.dart';
import 'package:mandir_app/screens/notes.dart';
import 'package:mandir_app/screens/show_member_info.dart';
import 'package:mandir_app/screens/viewReminder.dart';

import '../entity/apiResult.dart';
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

class _ReminderListState extends State<ReminderList>
    with AutomaticKeepAliveClientMixin<ReminderList> {
  @override
  bool get wantKeepAlive => true;
  bool isLoadingDropControls = false;
  bool gettingReminders = false;
  List<dynamic> reminders = [];
  String? reminderCaption;
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
  }

  getListOfReminders() async {
    try {
      setState(() {
        gettingReminders = true;
      });

      ApiResult result = await ApiService().post2(
          context,
          '/api/reminder/list',
          {
            "searchType": initialSearchBy!.actualValue,
            "searchValue": textController.text.trim()
          },
          headers);

      if (result.success == false) {
        ApiService().handleApiResponse2(context, result.data);
        return;
      }

      if (result.data['status'][0]['errorCode'] == 0) {
        setState(() {
          reminders = result.data['reminders'];
          reminderCaption = result.data['status'][0]['errorMessage'];
          gettingReminders = false;
        });
      }
    } catch (e) {
      setState(() {
        gettingReminders = false;
      });

      print(e.toString());
    }
  }

  void getSearchByControls() async {
    try {
      setState(() {
        isLoadingDropControls = true;
      });

      ApiResult result = await ApiService().post2(
          context,
          '/api/lookup/key-details',
          {"keyName": "SEARCH_REMINDER_BY"},
          headers);

      if (result.success == false) {
        ApiService().handleApiResponse2(context, result.data);
        result.data = [];
      }

      var searchByItems = (result.data as List<dynamic>)
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
      getListOfReminders();
    } catch (e) {
      isLoadingDropControls = false;
      showCustomSnackbar(
        context,
        Colors.black,
        e.toString(),
      );
    }
  }

  Widget? renderLeading(data) {
    return null;
  }

  // Widget? renderLeading(data) {
  //   Widget? icon;
  //   Color? color;

  //   switch (data['icon']) {
  //     case 'M':
  //       icon = Text(
  //         data['icon'],
  //         style: const TextStyle(
  //           color: Colors.white,
  //         ),
  //       );
  //       color = const Color(0xff8eb564);
  //       break;
  //     case 'Y':
  //       icon = Text(
  //         data['icon'],
  //         style: const TextStyle(
  //           color: Colors.white,
  //         ),
  //       );
  //       color = const Color(0xffd27f71);
  //       break;
  //     case 'O':
  //       icon = Text(
  //         data['icon'],
  //         style: const TextStyle(
  //           color: Colors.white,
  //         ),
  //       );
  //       color = const Color(0xff6a89d8);
  //       break;
  //     case 'BDAY':
  //       icon = const Icon(
  //         FontAwesomeIcons.cakeCandles,
  //         color: Colors.white,
  //       );
  //       color = const Color(0xffd27f71);
  //       break;
  //     case 'ANNI':
  //       icon = const Icon(
  //         FontAwesomeIcons.heart,
  //         color: Colors.white,
  //       );
  //       color = const Color(0xffd27f71);
  //       break;
  //     default:
  //       icon = Text(
  //         data['icon'],
  //       );
  //       color = const Color(0xff540b0e);
  //   }

  //   return CircleAvatar(
  //     backgroundColor: color,
  //     // colors[index % colors.length],
  //     child: icon,
  //   );
  // }

  Widget? renderTitle(data) {
    return Text(data['title'],
        style: TextStyle(color: Colors.black, fontSize: 16));
  }

  // GJ: this is the 2 liner subtitle
  Widget? renderSubTitle(data) {
    return Text(data['subTitle'],
        style: TextStyle(color: Colors.grey, fontSize: 14));
  }

  // GJ: this is the 2 liner subtitle
  // Widget? renderSubTitle(data) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       RichText(
  //           text: TextSpan(
  //         children: <TextSpan>[
  //           TextSpan(
  //               text: data['repeatText'],
  //               style: const TextStyle(color: Colors.grey, fontSize: 11)),
  //           TextSpan(
  //               text: data['endDateText'],
  //               style: const TextStyle(color: Colors.grey, fontSize: 11)),
  //         ],
  //       )),
  //       Text(data['subTitle'],
  //           style: const TextStyle(color: Colors.blue, fontSize: 13)),
  //     ],
  //   );
  // }

  Widget? renderTrailing(data) {
    List<Widget>? trailChildren;
    switch (data['repeatFlag']) {
      case 'M':
      case 'Y':
        trailChildren = [
          RichText(
              text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: data['repeatText'],
                  style: const TextStyle(color: Colors.blue, fontSize: 12)),
              const TextSpan(
                  text: ' till',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )),
          Text(data['endDateText'],
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ];
        break;
      case 'O':
        trailChildren = [
          const Text('One time',
              style: TextStyle(color: Colors.blue, fontSize: 12)),
          const Text('reminder',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ];
        break;
      default:
        trailChildren = null;
        break;
    }

    if (trailChildren == null) {
      return null;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: trailChildren,
    );
  }

  // Widget? renderTrailing(data) {
  //   return GestureDetector(
  //     onTap: () {
  //       FocusScope.of(context).unfocus();
  //       showModalBottomSheet(
  //           context: context,
  //           builder: (context) {
  //             return SizedBox(
  //               height: MediaQuery.of(context).size.height * 0.3,
  //               width: double.infinity,
  //               child: Padding(
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 13,
  //                 ),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     const SizedBox(
  //                       height: 10,
  //                     ),
  //                     const Text(
  //                       "     Select an action",
  //                       style: TextStyle(
  //                         color: Color.fromARGB(
  //                           255,
  //                           106,
  //                           78,
  //                           179,
  //                         ),
  //                       ),
  //                     ),
  //                     // if (reminders[index][
  //                     //             'type'] ==
  //                     //         'REM' &&
  //                     //     reminders[index][
  //                     //             'repeat'] ==
  //                     //         'O' &&
  //                     //     initialSearchBy!
  //                     //             .actualValue ==
  //                     //         'SEARCH_BY_DATE')
  //                     //   GestureDetector(
  //                     //     onTap: () async {
  //                     //       var response =
  //                     //           await ApiService().post(
  //                     //               '/api/reminder/item',
  //                     //               {
  //                     //                 "reminderCode":
  //                     //                     reminders[index]['code']
  //                     //               },
  //                     //               headers,
  //                     //               context);

  //                     //       DateTime date =
  //                     //           DateTime.parse(
  //                     //                   response['remindOn'])
  //                     //               .add(
  //                     //         const Duration(
  //                     //             days: 1),
  //                     //       );

  //                     //       await ApiService()
  //                     //           .post(
  //                     //               '/api/reminder/update',
  //                     //               {
  //                     //                 "reminderCode":
  //                     //                     reminders[index]['code'],
  //                     //                 "title":
  //                     //                     response['title'],
  //                     //                 "desc":
  //                     //                     response['desc'],
  //                     //                 "remindOn":
  //                     //                     date.toString(),
  //                     //                 "repeatFlag":
  //                     //                     response['repeatFlag']
  //                     //               },
  //                     //               headers,
  //                     //               context);
  //                     //       Navigator.pop(
  //                     //           context);
  //                     //       showCustomSnackbar(
  //                     //           context,
  //                     //           Colors
  //                     //               .black,
  //                     //           'Reminder updated successfully.');
  //                     //       // dateController
  //                     //       //         .text =
  //                     //       //     DateFormat(
  //                     //       //             'dd-MMM-yyyy')
  //                     //       //         .format(
  //                     //       //             date);
  //                     //       getListOfReminders();
  //                     //     },
  //                     //     child:
  //                     //         const ListTile(
  //                     //       title: Text(
  //                     //         "Remind me tomorrow",
  //                     //       ),
  //                     //       leading: FaIcon(
  //                     //         FontAwesomeIcons
  //                     //             .clock,
  //                     //         color: Color
  //                     //             .fromARGB(
  //                     //           255,
  //                     //           106,
  //                     //           78,
  //                     //           179,
  //                     //         ),
  //                     //       ),
  //                     //     ),
  //                     //   ),
  //                     if (data['type'] == 'REM')
  //                       GestureDetector(
  //                         onTap: () {
  //                           Navigator.pop(context);
  //                           nextScreen(
  //                               context,
  //                               NotesScreen(
  //                                 reminderCode: data['code'],
  //                               ));
  //                         },
  //                         child: const ListTile(
  //                           title: Text(
  //                             "View Reminder Notes",
  //                           ),
  //                           leading: FaIcon(
  //                             FontAwesomeIcons.noteSticky,
  //                             color: Color.fromARGB(
  //                               255,
  //                               106,
  //                               78,
  //                               179,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     if (data['type'] == 'REM')
  //                       GestureDetector(
  //                         onTap: () {
  //                           Navigator.pop(context);
  //                           nextScreen(context,
  //                               AddReminderScreen(reminderCode: data['code']));
  //                         },
  //                         child: const ListTile(
  //                           title: Text(
  //                             "Edit Reminder",
  //                           ),
  //                           leading: FaIcon(
  //                             FontAwesomeIcons.pencil,
  //                             color: Color.fromARGB(
  //                               255,
  //                               106,
  //                               78,
  //                               179,
  //                             ),
  //                           ),
  //                         ),
  //                       ),

  //                     GestureDetector(
  //                       onTap: () {
  //                         Navigator.pop(context);
  //                         showDialog(
  //                             context: context,
  //                             builder: (context) {
  //                               return AlertDialog(
  //                                 title: const Text(
  //                                   "Delete Reminder",
  //                                 ),
  //                                 actions: [
  //                                   ElevatedButton(
  //                                     style: ElevatedButton.styleFrom(
  //                                       backgroundColor: Colors.red,
  //                                     ),
  //                                     onPressed: data['type'] == 'REM'
  //                                         ? () async {
  //                                             try {
  //                                               var response =
  //                                                   await ApiService().post(
  //                                                 '/api/reminder/delete',
  //                                                 {
  //                                                   'reminderCode': data['code']
  //                                                 },
  //                                                 headers,
  //                                                 context,
  //                                               );
  //                                               Navigator.pop(context);
  //                                               getListOfReminders();

  //                                               showCustomSnackbar(
  //                                                 context,
  //                                                 Colors.black,
  //                                                 response['message'],
  //                                               );
  //                                             } catch (e) {
  //                                               showCustomSnackbar(
  //                                                 context,
  //                                                 Colors.black,
  //                                                 e.toString(),
  //                                               );
  //                                             }
  //                                           }
  //                                         : () async {
  //                                             try {
  //                                               var response =
  //                                                   await ApiService().post(
  //                                                 '/api/family-member/toggle-birthday-reminder',
  //                                                 {
  //                                                   'familyMemberCode':
  //                                                       data['code']
  //                                                 },
  //                                                 headers,
  //                                                 context,
  //                                               );
  //                                               Navigator.pop(context);
  //                                               getListOfReminders();

  //                                               showCustomSnackbar(
  //                                                 context,
  //                                                 Colors.black,
  //                                                 response['message'],
  //                                               );
  //                                             } catch (e) {
  //                                               showCustomSnackbar(
  //                                                 context,
  //                                                 Colors.black,
  //                                                 e.toString(),
  //                                               );
  //                                             }
  //                                           },
  //                                     child: const Text(
  //                                       "Delete",
  //                                       style: TextStyle(
  //                                         color: Colors.white,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   ElevatedButton(
  //                                     style: ElevatedButton.styleFrom(
  //                                       backgroundColor: const Color.fromARGB(
  //                                         255,
  //                                         106,
  //                                         78,
  //                                         179,
  //                                       ),
  //                                     ),
  //                                     onPressed: () {
  //                                       Navigator.pop(context);
  //                                     },
  //                                     child: const Text(
  //                                       "Cancel",
  //                                       style: TextStyle(
  //                                         color: Colors.white,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                                 content: const Column(
  //                                   mainAxisSize: MainAxisSize.min,
  //                                   children: [
  //                                     Text(
  //                                       "Are you sure you want to delete this reminder?",
  //                                       style: TextStyle(
  //                                         fontSize: 15,
  //                                       ),
  //                                     ),
  //                                     SizedBox(
  //                                       height: 13,
  //                                     ),
  //                                   ],
  //                                 ),
  //                               );
  //                             });
  //                       },
  //                       child: const ListTile(
  //                         title: Text(
  //                           "Delete Reminder",
  //                         ),
  //                         leading: FaIcon(
  //                           FontAwesomeIcons.trash,
  //                           color: Color.fromARGB(
  //                             255,
  //                             106,
  //                             78,
  //                             179,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           });
  //     },
  //     child: Container(
  //       alignment: Alignment.center,
  //       color: Colors.white,
  //       width: 30,
  //       child: FaIcon(
  //         FontAwesomeIcons.ellipsisVertical,
  //         color: Colors.grey[600],
  //         size: 20,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     "Personal Assistant",
      //   ),
      // ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        if (initialSearchBy!.actualValue != 'SEARCH_BY_TEXT') {
                          getListOfReminders();
                        }
                      });
                    },
                  ),
                  const SizedBox(
                    height: 10,
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
                                  FocusScope.of(context).unfocus();
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
                  if (initialSearchBy!.actualValue == 'SEARCH_BY_TEXT')
                    const SizedBox(
                      height: 20,
                    ),
                  Text(
                    reminderCaption == null ? '' : reminderCaption!,
                  ),
                  const SizedBox(
                    height: 10,
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
                                  GestureDetector(
                                    onTap: () {
                                      nextScreen(
                                        context,
                                        reminders[index]['type'] == 'FM-BDAY'
                                            ? ShowMemberInfo(
                                                memberCode: reminders[index]
                                                    ['code'],
                                              )
                                            : ViewReminder(
                                                reminderCode: reminders[index]
                                                    ['code'],
                                              ),
                                      );
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 3,
                                        ),
                                        leading: renderLeading(
                                          reminders[index],
                                        ),
                                        title: renderTitle(reminders[index]),
                                        subtitle: renderSubTitle(
                                          reminders[index],
                                        ),
                                        trailing: renderTrailing(
                                          reminders[index],
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
