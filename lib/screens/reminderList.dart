// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mandir_app/screens/addReminderScreen.dart';
import 'package:mandir_app/screens/notes.dart';
import 'package:mandir_app/screens/show_member_info.dart';
import 'package:mandir_app/screens/viewReminder.dart';
import 'package:mandir_app/widgets/custom_textfield.dart';

import '../entity/apiResult.dart';
import '../service/api_service.dart';
import '../utils/app_enums.dart';
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
    with SingleTickerProviderStateMixin {
  bool showLoader = false;
  bool isLoadingSearchByDropdown = false;
  bool gettingReminders = false;
  List<dynamic> reminders = [];
  List<dynamic> missedReminders = [];
  String? reminderCaption;
  final textController = TextEditingController();
  APIDropDownItem? initialSearchBy;
  List<DropdownMenuItem<APIDropDownItem>> SearchByOptionsButton =
      <DropdownMenuItem<APIDropDownItem>>[];

  TabBar get myTabBar => TabBar(
        tabs: const [
          Tab(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Upcoming  ',
                // style: TextStyle(color: Colors.orange),
              ),
              Icon(
                FontAwesomeIcons.clock,
                size: 20,
                color: Colors.orange,
              ),
            ],
          )),
          Tab(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Missed  ',
                // style: TextStyle(color: Colors.red),
              ),
              Icon(
                FontAwesomeIcons.circleXmark,
                size: 20,
                color: Colors.red,
              ),
            ],
          )),
        ],
        controller: myTabController,
      );
  TabController? myTabController;
  List<Widget>? myTabBarView;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initScreen();
  }

  void initScreen() async {
    myTabController = TabController(vsync: this, length: 2);
    myTabController!.index = 0;
    myTabBarView = [
      const Center(
        child: CircularProgressIndicator(),
      ),
      const Center(
        child: CircularProgressIndicator(),
      )
    ];
    await LoadSearchByDropdown();
  }

  Widget renderUpcomingReminders() {
    Widget? myWidget;

    if (isLoadingSearchByDropdown == true) {
      myWidget = const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      myWidget = Padding(
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
                // print(item!.actualValue);
                setState(() {
                  initialSearchBy = item!;
                  textController.text = '';
                  if (initialSearchBy!.actualValue == 'SEARCH_BY_TEXT') {
                    // renderUpcomingReminders();
                    myTabBarView = [
                      renderUpcomingReminders(),
                      renderMissedReminders()
                    ];
                  } else {
                    getListOfReminders();
                  }
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
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
                              onTap: () => onTapReminderItem(reminders[index]),
                              child: Container(
                                color: Colors.white,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
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
      );
    }

    return myWidget;
  }

  Widget renderMissedReminders() {
    Widget? myWidget;

    if (isLoadingSearchByDropdown == true) {
      myWidget = const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      myWidget = Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            RichText(
              text: TextSpan(children: <TextSpan>[
                const TextSpan(
                    text: 'You have missed ',
                    style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: missedReminders.length.toString(),
                    style: const TextStyle(color: Colors.black)),
                const TextSpan(
                    text: ' reminders till now..',
                    style: TextStyle(color: Colors.black)),
              ]),
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
                      itemCount: missedReminders.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  onTapReminderItem(missedReminders[index]),
                              child: Container(
                                color: Colors.white,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 3,
                                  ),
                                  leading: const Icon(
                                    FontAwesomeIcons.circleXmark,
                                    color: Colors.red,
                                  ),
                                  title: renderTitle(missedReminders[index]),
                                  subtitle: renderSubTitle(
                                    missedReminders[index],
                                  ),
                                  trailing: renderTrailing(
                                    missedReminders[index],
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
          ],
        ),
      );
    }

    return myWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "My Reminders",
          ),
          bottom: PreferredSize(
            preferredSize: myTabBar.preferredSize,
            child: Material(child: myTabBar),
          ),
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
        ),
        body: TabBarView(
          controller: myTabController,
          children: myTabBarView!,
        ));
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
          reminderCaption = result.data['status'][0]['errorMessage'];
          reminders = result.data['reminders'];
          missedReminders = result.data['missed'];
          gettingReminders = false;
          myTabBarView = [renderUpcomingReminders(), renderMissedReminders()];
        });
      }
    } catch (e) {
      setState(() {
        reminders = [];
        missedReminders = [];
        gettingReminders = false;
        myTabBarView = [renderUpcomingReminders(), renderMissedReminders()];
      });

      // print(e.toString());
    }
  }

  Future LoadSearchByDropdown() async {
    try {
      setState(() {
        isLoadingSearchByDropdown = true;
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
        isLoadingSearchByDropdown = false;
      });
      await getListOfReminders();
    } catch (e) {
      isLoadingSearchByDropdown = false;
      showCustomSnackbar(
        context,
        Colors.black,
        e.toString(),
      );
    }
  }

  // GJ: icon property has been removed from the database now..
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
        style: const TextStyle(color: Colors.black, fontSize: 16));
  }

  // GJ: this is the 2 liner subtitle
  Widget? renderSubTitle(data) {
    switch (data['hasDone']) {
      case 1:
        return Text(data['subTitle'],
            style: const TextStyle(color: Colors.grey, fontSize: 14));
      default:
        return Text(data['subTitle'],
            style: const TextStyle(color: Colors.grey, fontSize: 14));
    }
  }

  Widget? renderTrailing(data) {
    List<Widget>? trailChildren;
    switch (data['repeatFlag']) {
      case 'M':
        trailChildren = [
          RichText(
              text: const TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: 'Monthly',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              TextSpan(
                  text: ' till',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )),
          Text(data['endDateText'],
              style: const TextStyle(color: Colors.blue, fontSize: 12)),
        ];
        break;
      case 'Y':
        trailChildren = [
          RichText(
              text: const TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: 'Yearly',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              TextSpan(
                  text: ' till',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )),
          Text(data['endDateText'],
              style: const TextStyle(color: Colors.blue, fontSize: 12)),
        ];
        break;
      case 'O':
        trailChildren = [
          const Text('Remind me',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const Text('One time',
              style: TextStyle(color: Colors.blue, fontSize: 12)),
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
  //                     //             'repeatFlag'] ==
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

  Widget? renderLeading(data) {
    switch (data['hasDone']) {
      case 1:
        return const Icon(
          FontAwesomeIcons.circleCheck,
          color: Colors.green,
        );
      default:
        return const Icon(
          FontAwesomeIcons.clock,
          color: Colors.orange,
        );
    }
  }

  onTapReminderItem(data) {
    switch (data['type']) {
      case 'FM-BDAY':
        nextScreen(context, ShowMemberInfo(memberCode: data['code']));
        break;
      default:
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        nextScreen(
                            context, ViewReminder(reminderCode: data['code']));
                      },
                      child: ListTile(
                        title: const Text('View Reminder'),
                        leading: FaIcon(
                          FontAwesomeIcons.eye,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    if (data['hasDone'] != 1)
                      GestureDetector(
                        onTap: () => onTapMarkAsCompleted(data),
                        child: const ListTile(
                          title: Text('Mark as Completed'),
                          leading: FaIcon(
                            FontAwesomeIcons.circleCheck,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    if (data['hasDone'] == 1)
                      GestureDetector(
                        onTap: () => onTapUnmarkAsPending(data),
                        child: const ListTile(
                          title: Text('Un-mark as Pending'),
                          leading: FaIcon(
                            FontAwesomeIcons.clock,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            });
        break;
    }
  }

  onTapMarkAsCompleted(data) async {
    Navigator.pop(context);
    print(data);
    // await unmarkReminder(data, true);
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: Column(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Title:',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          data['title'],
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Schedule:',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          DateFormat('dd-MMM-yy')
                              .format(DateTime.parse(data['schedule']))
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Remark',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    CustomTextAreaField(
                        labelText: '', controller: nextScheduleController),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Next Schedule',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    CustomTextField(
                        labelText: '', controller: remarkController),
                    const SizedBox(
                      height: 14,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(
                                      0.7,
                                    ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            markReminder(data);
                            getListOfReminders();
                          },
                          child: const Text(
                            "Mark as Complete",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  onTapUnmarkAsPending(data) async {
    Navigator.pop(context);
    await unmarkReminder(data);
    getListOfReminders();
  }

  markReminder(data) async {
    try {
      setState(() {
        showLoader = true;
      });

      ApiResult result = await ApiService().post2(
          context,
          '/api/reminder/mark-as-complete',
          {
            "reminderCode": data['code'],
            "schedule": data['schedule'],
            'remark': remarkController.text.trim(),
            'nextSchedule': null,
          },
          headers);
      print(result);

      if (result.success == false) {
        ApiService().handleApiResponse2(context, result.data);
        return;
      }

      setState(() {
        showLoader = false;
        showToast(context, ToastTypes.SUCCESS, result.data['message']);
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        showLoader = false;
      });
    }
  }

  unmarkReminder(data) async {
    try {
      setState(() {
        showLoader = true;
      });

      ApiResult result = await ApiService().post2(
          context,
          '/api/reminder/unmark-as-complete',
          {
            "reminderCode": data['code'],
            "schedule": data['schedule'],
          },
          headers);

      if (result.success == false) {
        ApiService().handleApiResponse2(context, result.data);
        return;
      }

      setState(() {
        showLoader = false;
        showToast(context, ToastTypes.SUCCESS, result.data['message']);
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        showLoader = false;
      });
    }
  }

  final remarkController = TextEditingController();
  final nextScheduleController = TextEditingController();
}
