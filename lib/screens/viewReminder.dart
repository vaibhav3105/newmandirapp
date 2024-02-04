// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mandir_app/constants.dart';
import 'package:mandir_app/screens/addReminderScreen.dart';
import 'package:mandir_app/screens/notes.dart';
import 'package:mandir_app/screens/reminderList.dart';
import 'package:mandir_app/utils/utils.dart';

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
  dynamic reminderInfo;
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
    print(result.data);
    if (result.success == false) {
      ApiService().handleApiResponse2(context, result.data);
      return;
    }

    // var cats = List.from(Set.from(result.data.map((e) => e['c'])));
    // var data = [];
    // for (var cat in cats) {
    //   var item = {"cat": cat};
    //   item['items'] = result.data.where((x) => x['c'] == cat).toList();
    //   data.add(item);
    // }

    setState(() {
      reminderInfo = result.data;
      isLoading = false;
    });
  }

  Color? primaryColor = null;

  @override
  Widget build(BuildContext context) {
    primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
        appBar: AppBar(
          title: const Text("View Reminder"),
          actions: [
            // IconButton(
            //   icon: Icon(
            //     Icons.more_vert,
            //     size: 28,
            //     color: themeVeryLightColor,
            //   ),
            //   onPressed: showAppBarContextMenu,
            // ),
            IconButton(
              icon: Icon(
                FontAwesomeIcons.pencil,
                size: 20,
                color: themeVeryLightColor,
              ),
              onPressed: () {
                Navigator.pop(context);
                nextScreen(context,
                    AddReminderScreen(reminderCode: widget.reminderCode));
              },
            )
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      renderCategory('Title'),
                      Padding(
                        padding: getCardPaddingStyle(),
                        child: Card(
                            elevation: 0,
                            shape: getCardBorderStyle(),
                            margin: EdgeInsets.zero,
                            color: Colors.white,
                            child: ListTile(
                              title: Text(reminderInfo['info'][0]['title'],
                                  style: getValueStyle()),
                            )),
                      ),
                      renderCategory('Schedule'),
                      Padding(
                        padding: getCardPaddingStyle(),
                        child: Card(
                            elevation: 0,
                            shape: getCardBorderStyle(),
                            margin: EdgeInsets.zero,
                            color: Colors.white,
                            child: Column(
                              children: [
                                ListTile(
                                  title:
                                      Text('Remind on', style: getKeyStyle()),
                                  subtitle: Text(
                                      reminderInfo['info'][0]['remindOnText'],
                                      style: getValueStyle()),
                                ),
                                renderDivider(),
                                ListTile(
                                  title:
                                      Text('Remind till', style: getKeyStyle()),
                                  subtitle: Text(
                                      reminderInfo['info'][0]['endDateText'],
                                      style: getValueStyle()),
                                ),
                              ],
                            )),
                      ),
                      renderCategory('Top 5 Last Reminders'),
                      Padding(
                        padding: getCardPaddingStyle(),
                        child: Card(
                            elevation: 0,
                            shape: getCardBorderStyle(),
                            margin: EdgeInsets.zero,
                            color: Colors.white,
                            child: Column(
                              children: renderLastReminderList(),
                            )),
                      ),
                      renderCategory('Top 5 Next Reminders'),
                      Padding(
                        padding: getCardPaddingStyle(),
                        child: Card(
                            elevation: 0,
                            shape: getCardBorderStyle(),
                            margin: EdgeInsets.zero,
                            color: Colors.white,
                            child: Column(
                              children: renderUpcomingReminderList(),
                            )),
                      ),
                      renderCategory('Other info'),
                      Padding(
                        padding: getCardPaddingStyle(),
                        child: Card(
                            elevation: 0,
                            shape: getCardBorderStyle(),
                            margin: EdgeInsets.zero,
                            color: Colors.white,
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text('Category', style: getKeyStyle()),
                                  subtitle: Text(
                                      reminderInfo['info'][0]['categoryText'],
                                      style: getValueStyle()),
                                ),
                                renderDivider(),
                                ListTile(
                                  title:
                                      Text('Description', style: getKeyStyle()),
                                  subtitle: Text(
                                      reminderInfo['info'][0]['description'],
                                      style: getValueStyle()),
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
              ));
  }

  // Widget? renderTrailing(data) {
  //   return null;
  //   // switch (data['ic']) {
  //   //   case 'DONE':
  //   //     return Icon(Icons.check_circle, color: Colors.green);
  //   //     // return const Text('Done', style: TextStyle(color: Colors.green));
  //   //   case 'PENDNIG':
  //   //     return Icon(Icons.cancel, color: Colors.orange);
  //   //     // return const Text('Pending', style: TextStyle(color: Colors.orange));
  //   //   case 'MISSED':
  //   //     return Icon(Icons.cancel, color: Colors.red);
  //   //     // return const Text('Missed', style: TextStyle(color: Colors.red));
  //   //   default:
  //   //     return null;
  //   // }
  // }

  // Widget? renderTitle(data) {
  //   //return const Text('Gaurav Jain', style: TextStyle(color: Colors.orange));

  //   if (data['k'] != '' && data['v'] != '')
  //     return Text(data['k'],
  //         style: TextStyle(color: Colors.grey, fontSize: 14));
  //   else if (data['k'] != '' && data['v'] == '')
  //     return Text(data['k'],
  //         style: TextStyle(color: Colors.grey, fontSize: 14));
  //   else if (data['k'] == '' && data['v'] != '')
  //     return Text(data['v'],
  //         style: TextStyle(color: Colors.black, fontSize: 16));
  //   else
  //     return Text(data['k']);
  // }

  // Widget? renderSubTitle(data) {
  //   List<Widget>? output;
  //   switch (data['ic']) {
  //     case 'DONE':
  //       output = [
  //         const Icon(Icons.circle, color: Colors.green, size: 10),
  //         RichText(
  //             text: TextSpan(
  //           children: <TextSpan>[
  //             const TextSpan(
  //                 text: ' Completed on ',
  //                 style: TextStyle(color: Colors.black)),
  //             TextSpan(
  //                 text: data['v'], style: const TextStyle(color: Colors.black)),
  //           ],
  //         )),
  //       ];
  //       break;
  //     case 'PENDNIG':
  //       output = [
  //         const Icon(Icons.circle, color: Colors.orange, size: 10),
  //         RichText(
  //             text: TextSpan(
  //           children: <TextSpan>[
  //             const TextSpan(
  //                 text: ' Due for ', style: TextStyle(color: Colors.black)),
  //             TextSpan(
  //                 text: data['v'], style: const TextStyle(color: Colors.black)),
  //           ],
  //         )),
  //       ];
  //       break;
  //     case 'MISSED':
  //       output = [
  //         const Icon(Icons.circle, color: Colors.red, size: 10),
  //         RichText(
  //             text: TextSpan(
  //           children: <TextSpan>[
  //             const TextSpan(
  //                 text: ' Missed on ', style: TextStyle(color: Colors.black)),
  //             TextSpan(
  //                 text: data['v'], style: const TextStyle(color: Colors.black)),
  //           ],
  //         )),
  //       ];
  //       break;
  //     default:
  //       if (data['k'] != '' && data['v'] != '')
  //         output = [
  //           Text(data['v'], style: TextStyle(color: Colors.black, fontSize: 16))
  //         ];
  //       else if (data['k'] != '' && data['v'] == '')
  //         output = null;
  //       else if (data['k'] == '' && data['v'] != '')
  //         output = null;
  //       else
  //         output = [Text(data['v'])];
  //       break;
  //   }

  //   if (output == null) {
  //     return null;
  //   }

  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: output,
  //   );
  // }

  // Function? showAppBarContextMenu() {
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (context) {
  //         return SizedBox(
  //           height: MediaQuery.of(context).size.height * 0.3,
  //           width: double.infinity,
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(
  //               horizontal: 13,
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 Text(
  //                   "     Select an action",
  //                   style: TextStyle(
  //                     color: primaryColor,
  //                   ),
  //                 ),
  //                 GestureDetector(
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                     nextScreen(
  //                         context,
  //                         NotesScreen(
  //                           reminderCode: widget.reminderCode,
  //                         ));
  //                   },
  //                   child: ListTile(
  //                     title: const Text(
  //                       "View Reminder Notes",
  //                     ),
  //                     leading: FaIcon(
  //                       FontAwesomeIcons.noteSticky,
  //                       color: primaryColor,
  //                     ),
  //                   ),
  //                 ),
  //                 GestureDetector(
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                     nextScreen(context,
  //                         AddReminderScreen(reminderCode: widget.reminderCode));
  //                   },
  //                   child: ListTile(
  //                     title: const Text(
  //                       "Edit Reminder",
  //                     ),
  //                     leading: FaIcon(
  //                       FontAwesomeIcons.pencil,
  //                       color: primaryColor,
  //                     ),
  //                   ),
  //                 ),
  //                 GestureDetector(
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                     showDialog(
  //                         context: context,
  //                         builder: (context) {
  //                           return AlertDialog(
  //                             title: const Text(
  //                               "Delete Reminder",
  //                             ),
  //                             actions: [
  //                               ElevatedButton(
  //                                 style: ElevatedButton.styleFrom(
  //                                   backgroundColor: Colors.red,
  //                                 ),
  //                                 onPressed: () async {
  //                                   try {
  //                                     var response = await ApiService().post(
  //                                       '/api/reminder/delete',
  //                                       {'reminderCode': widget.reminderCode},
  //                                       headers,
  //                                       context,
  //                                     );

  //                                     showCustomSnackbar(
  //                                       context,
  //                                       Colors.black,
  //                                       response['message'],
  //                                     );

  //                                     Navigator.pop(context);
  //                                     //todo: we need to remove the "ReminderList" from the navigator history, so that we can reload the page.
  //                                     nextScreen(context, const ReminderList());
  //                                   } catch (e) {
  //                                     showCustomSnackbar(
  //                                       context,
  //                                       Colors.black,
  //                                       e.toString(),
  //                                     );
  //                                   }
  //                                 },
  //                                 child: const Text(
  //                                   "Delete",
  //                                   style: TextStyle(
  //                                     color: Colors.white,
  //                                   ),
  //                                 ),
  //                               ),
  //                               ElevatedButton(
  //                                 style: ElevatedButton.styleFrom(
  //                                   backgroundColor: primaryColor,
  //                                 ),
  //                                 onPressed: () {
  //                                   Navigator.pop(context);
  //                                 },
  //                                 child: const Text(
  //                                   "Cancel",
  //                                   style: TextStyle(
  //                                     color: Colors.white,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                             content: const Column(
  //                               mainAxisSize: MainAxisSize.min,
  //                               children: [
  //                                 Text(
  //                                   "This will delete the reminder and all of its schedules. Do you want to continue?",
  //                                   style: TextStyle(
  //                                     fontSize: 15,
  //                                   ),
  //                                 ),
  //                                 SizedBox(
  //                                   height: 13,
  //                                 ),
  //                               ],
  //                             ),
  //                           );
  //                         });
  //                   },
  //                   child: ListTile(
  //                     title: Text(
  //                       "Delete Reminder",
  //                     ),
  //                     leading: FaIcon(
  //                       FontAwesomeIcons.trash,
  //                       color: primaryColor,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  //   return null;
  // }

  EdgeInsets getCardPaddingStyle() {
    return const EdgeInsets.only(top: 10, bottom: 15);
  }

  RoundedRectangleBorder getCardBorderStyle() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    );
  }

  Widget renderCategory(data) {
    return Text(
      data,
      style: TextStyle(
        color: Colors.grey[700],
        fontWeight: FontWeight.bold,
      ),
    );
  }

  TextStyle getKeyStyle() {
    return const TextStyle(color: Colors.grey, fontSize: 14);
  }

  TextStyle getValueStyle() {
    return const TextStyle(color: Colors.black, fontSize: 16);
  }

  TextStyle getScheduleStyle() {
    return const TextStyle(color: Colors.black, fontSize: 14);
  }

  Widget renderDivider() {
    return const Divider(
      height: 0,
      thickness: 1,
      color: Color.fromARGB(255, 212, 215, 221),
    );
  }

  List<Widget> renderLastReminderList() {
    if (reminderInfo['lastReminders'].length == 0) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text('No record found.')],
          ),
        )
      ];
    }

    List<Widget> list =
        List.generate(reminderInfo['lastReminders'].length, (index) {
      return renderUpcomingReminderItem(reminderInfo['lastReminders'][index]);
    });
    list.add(const SizedBox(height: 10));
    list.insert(0, const SizedBox(height: 10));
    return list;
  }

  List<Widget> renderUpcomingReminderList() {
    if (reminderInfo['upcomimgReminders'].length == 0) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text('No record found.')],
          ),
        )
      ];
    }

    List<Widget> list =
        List.generate(reminderInfo['upcomimgReminders'].length, (index) {
      return renderUpcomingReminderItem(
          reminderInfo['upcomimgReminders'][index]);
    });
    list.add(const SizedBox(height: 10));
    list.insert(0, const SizedBox(height: 10));
    return list;
  }

  Widget renderLastReminderItem(data) {
    List<Widget>? output;
    if (data['completedOn'] != null) {
      output = [
        const Icon(Icons.circle, color: Colors.green, size: 12),
        const Text(' '),
        Text(data['message']),
      ];
    } else {
      output = [
        const Icon(Icons.circle, color: Colors.red, size: 12),
        const Text(' '),
        Expanded(
          child: Text(
            data['message'],
            // overflow: TextOverflow.ellipsis,
            // softWrap: false,
          ),
        ),
      ];
    }

    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: output,
      ),
    );
  }

  Widget renderUpcomingReminderItem(data) {
    print(data);
    List<Widget>? output;
    if (data['completedOn'] != null) {
      output = [
        const Icon(Icons.circle, color: Colors.green, size: 12),
        const Text(' '),
        Text(data['message']),
      ];
    } else {
      output = [
        const Icon(Icons.circle, color: Colors.orange, size: 12),
        const Text(' '),
        Expanded(
          child: Text(
            data['message'],
            // overflow: TextOverflow.ellipsis,
            // softWrap: false,
          ),
        ),
      ];
    }

    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: output,
      ),
    );
  }
}
