// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mandir_app/screens/addReminderScreen.dart';
import 'package:mandir_app/screens/notes.dart';
import 'package:mandir_app/screens/scheduleScreen.dart';
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
  List<dynamic> upcomingReminders = [];
  List<dynamic> missedReminders = [];
  List<dynamic> allReminders = [];
  String? reminderCaption;
  final textController = TextEditingController();
  APIDropDownItem? initialSearchBy;
  List<DropdownMenuItem<APIDropDownItem>> SearchByOptionsButton =
      <DropdownMenuItem<APIDropDownItem>>[];
  Color? primaryColor;

  double totalWidth = 0.0;
  double oneTabWidth = 0.0;
  double otherTabWidth = 0.0;

  TabBar get myTabBar => TabBar(
        tabs: [
          SizedBox(
            width: otherTabWidth,
            child: const Tab(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Upcoming ',
                ),
                Icon(
                  FontAwesomeIcons.clock,
                  size: 20,
                  color: Colors.orange,
                ),
              ],
            )),
          ),
          SizedBox(
            width: otherTabWidth,
            child: const Tab(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Missed ',
                ),
                Icon(
                  FontAwesomeIcons.circleXmark,
                  size: 20,
                  color: Colors.red,
                ),
              ],
            )),
          ),
          SizedBox(
            width: oneTabWidth,
            child: Tab(
              icon: Icon(
                FontAwesomeIcons.bars,
                size: 20,
                color: primaryColor,
              ),
            ),
          ),
        ],
        controller: myTabController,
        isScrollable: true,
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
    myTabController = TabController(vsync: this, length: 3);
    myTabController!.index = 0;
    myTabBarView = [
      const Center(
        child: CircularProgressIndicator(),
      ),
      const Center(
        child: CircularProgressIndicator(),
      ),
      const Center(
        child: CircularProgressIndicator(),
      ),
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
                  getListOfReminders();
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            // if (initialSearchBy!.actualValue == 'SEARCH_BY_TEXT')
            //   TextFormField(
            //     controller: textController,
            //     decoration: InputDecoration(
            //       filled: true,
            //       fillColor: Colors.white,
            //       contentPadding: const EdgeInsets.symmetric(
            //         vertical: 14,
            //         horizontal: 10,
            //       ),
            //       suffixIcon: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Container(
            //             height: 50,
            //             width: 1,
            //             color: Colors.grey,
            //             margin: const EdgeInsets.symmetric(horizontal: 8),
            //           ),
            //           Padding(
            //             padding: const EdgeInsets.only(
            //               right: 5,
            //             ),
            //             child: IconButton(
            //               icon: const Icon(
            //                 Icons.search,
            //               ),
            //               onPressed: () {
            //                 FocusScope.of(context).unfocus();
            //                 getListOfReminders();
            //               },
            //             ),
            //           ),
            //         ],
            //       ),
            //       hintText: "Enter your text...",
            //       hintStyle: const TextStyle(
            //         color: Colors.grey,
            //         fontSize: 14,
            //       ),
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(
            //           12,
            //         ),
            //       ),
            //     ),
            //   ),
            // if (initialSearchBy!.actualValue == 'SEARCH_BY_TEXT')
            //   const SizedBox(
            //     height: 20,
            //   ),
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
                      itemCount: upcomingReminders.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => onTapReminderSchedule(
                                  upcomingReminders[index]),
                              child: Container(
                                color: Colors.white,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 3,
                                  ),
                                  leading: renderLeading(
                                    upcomingReminders[index],
                                  ),
                                  title: renderTitle(upcomingReminders[index]),
                                  subtitle: renderSubTitle(
                                    upcomingReminders[index],
                                  ),
                                  trailing: renderTrailing(
                                    upcomingReminders[index],
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

  final searchController = TextEditingController();
  List<dynamic> searchReminders = [];

  Widget renderAllReminders() {
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
            //

            TextField(
              onChanged: (p0) {
                print(allReminders);
                print(searchController.text.trim());
                searchReminders = allReminders
                    .where((element) => element['title']
                        .toString()
                        .toLowerCase()
                        .contains(searchController.text.trim().toLowerCase()))
                    .toList();
                print(searchReminders);
                setState(() {
                  myTabBarView = [
                    renderUpcomingReminders(),
                    renderMissedReminders(),
                    renderAllReminders()
                  ];
                });
              },
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by text',
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
            ),
            const SizedBox(
              height: 20,
            ),
            if (allReminders.length != searchReminders.length)
              RichText(
                text: TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Total ', style: TextStyle(color: Colors.black)),
                  TextSpan(
                      // text: allReminders.length.toString(),
                      text: searchReminders.length.toString(),
                      style: const TextStyle(color: Colors.black)),
                  const TextSpan(
                      text: ' reminders found out of ',
                      style: TextStyle(color: Colors.black)),
                  TextSpan(
                      // text: allReminders.length.toString(),
                      text: allReminders.length.toString(),
                      style: const TextStyle(color: Colors.black)),
                ]),
              ),
            if (allReminders.length == searchReminders.length)
              RichText(
                text: TextSpan(children: <TextSpan>[
                  const TextSpan(
                      text: 'Total ', style: TextStyle(color: Colors.black)),
                  TextSpan(
                      // text: allReminders.length.toString(),
                      text: searchReminders.length.toString(),
                      style: const TextStyle(color: Colors.black)),
                  const TextSpan(
                      text: ' reminders found',
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
                      // itemCount: allReminders.length,
                      itemCount: searchReminders.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  // onTapReminderItem(allReminders[index]),
                                  onTapReminderItem(searchReminders[index]),
                              child: Container(
                                color: Colors.white,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 3,
                                  ),
                                  // leading: renderLeading(allReminders[index]),
                                  leading:
                                      renderLeading(searchReminders[index]),
                                  // title: renderTitle(allReminders[index]),
                                  title: renderTitle(searchReminders[index]),
                                  // subtitle: renderSubTitle(
                                  //   allReminders[index],
                                  // ),
                                  subtitle: renderSubTitle(
                                    searchReminders[index],
                                  ),
                                  // trailing: renderTrailing(
                                  //   allReminders[index],
                                  // ),
                                  trailing: renderTrailing(
                                    searchReminders[index],
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
                    text: 'You have missed below ',
                    style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: missedReminders.length.toString(),
                    style: const TextStyle(color: Colors.black)),
                const TextSpan(
                    text: ' schedules..',
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
                                  onTapReminderSchedule(missedReminders[index]),
                              child: Container(
                                color: Colors.white,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 3,
                                  ),
                                  leading:
                                      renderLeading(missedReminders[index]),
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
    totalWidth = MediaQuery.of(context).size.width;
    oneTabWidth = totalWidth * 0.1;
    otherTabWidth = totalWidth * 0.33;
    primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Reminder Schedules",
          ),
          bottom: PreferredSize(
            preferredSize: myTabBar.preferredSize,
            child: Material(
              color: Colors.white,
              child: myTabBar,
            ),
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
          backgroundColor: primaryColor,
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
          upcomingReminders = result.data['upcoming'];
          missedReminders = result.data['missed'];
          allReminders = result.data['all'];
          searchReminders = allReminders;
          // print(upcomingReminders);
          // print(missedReminders);
          // print(allReminders);
          gettingReminders = false;
          myTabBarView = [
            renderUpcomingReminders(),
            renderMissedReminders(),
            renderAllReminders()
          ];
        });
      }
    } catch (e) {
      setState(() {
        upcomingReminders = [];
        missedReminders = [];
        gettingReminders = false;
        myTabBarView = [
          renderUpcomingReminders(),
          renderMissedReminders(),
          renderAllReminders()
        ];
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

  Widget? renderTitle(data) {
    return Text(data['title'],
        style: const TextStyle(color: Colors.black, fontSize: 16));
  }

  // GJ: this is the 2 liner subtitle
  Widget? renderSubTitle(data) {
    switch (data['status']) {
      case 'C':
        return Text(data['subTitle'],
            style: const TextStyle(color: Colors.grey, fontSize: 14));
      // case 'M':
      // case 'D':
      default:
        return Text(data['subTitle'],
            style: const TextStyle(color: Colors.grey, fontSize: 14));
    }
  }

  Widget? renderTrailing(data) {
    if (data['status'] == '') {
      return null;
    }

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

  Widget? renderLeading(data) {
    switch (data['status']) {
      case 'C':
        return const Icon(
          FontAwesomeIcons.circleCheck,
          color: Colors.green,
        );
      case 'M':
        return const Icon(
          FontAwesomeIcons.circleXmark,
          color: Colors.red,
        );
      case 'D':
        return const Icon(
          FontAwesomeIcons.clock,
          color: Colors.orange,
        );
      default:
        return Icon(
          FontAwesomeIcons.calendar,
          color: primaryColor,
        );
    }
  }

  onTapReminderSchedule(data) {
    switch (data['type']) {
      case 'FM-BDAY':
        nextScreen(context, ShowMemberInfo(memberCode: data['code']));
        break;
      default:
        showModalBottomSheet(
            isScrollControlled: true,
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
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.22,
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            nextScreen(context,
                                ViewReminder(reminderCode: data['code']));
                          },
                          child: ListTile(
                            title: const Text('View Reminder'),
                            leading: FaIcon(
                              FontAwesomeIcons.eye,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            nextScreen(context,
                                ScheduleScreen(reminderCode: data['code']));
                            // showToast(context, ToastTypes.INFO,
                            //     'Feature coming soon.');
                          },
                          child: ListTile(
                            title: const Text('View schedules'),
                            leading: FaIcon(
                              FontAwesomeIcons.listUl,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        if (data['status'] == 'M' || data['status'] == 'D')
                          GestureDetector(
                            onTap: () => onClickMarkAsCompleteContextMenu(data),
                            child: const ListTile(
                              title: Text('Mark as Complete'),
                              leading: FaIcon(
                                FontAwesomeIcons.circleCheck,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        if (data['status'] == 'C')
                          GestureDetector(
                            onTap: () =>
                                onClickUnmarkAsPendingContextMenu(data),
                            child: const ListTile(
                              title: Text('Mark as Pending'),
                              leading: FaIcon(
                                FontAwesomeIcons.clock,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            });
        break;
    }
  }

  onTapReminderItem(data) {
    switch (data['type']) {
      case 'FM-BDAY':
        nextScreen(context, ShowMemberInfo(memberCode: data['code']));
        break;
      default:
        showModalBottomSheet(
            isScrollControlled: true,
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
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.40,
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            nextScreen(context,
                                ViewReminder(reminderCode: data['code']));
                          },
                          child: ListTile(
                            title: const Text('View Reminder'),
                            leading: FaIcon(
                              FontAwesomeIcons.eye,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            nextScreen(context,
                                ScheduleScreen(reminderCode: data['code']));
                            // showToast(context, ToastTypes.INFO,
                            //     'Feature coming soon.');
                          },
                          child: ListTile(
                            title: const Text('View schedules'),
                            leading: FaIcon(
                              FontAwesomeIcons.listUl,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            nextScreen(context,
                                AddReminderScreen(reminderCode: data['code']));
                          },
                          child: ListTile(
                            title: const Text(
                              "Edit Reminder",
                            ),
                            leading: FaIcon(
                              FontAwesomeIcons.pencil,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                      "Delete Reminder",
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () async {
                                          try {
                                            var response =
                                                await ApiService().post(
                                              '/api/reminder/delete',
                                              {'reminderCode': data['code']},
                                              headers,
                                              context,
                                            );

                                            showCustomSnackbar(
                                              context,
                                              Colors.black,
                                              response['message'],
                                            );

                                            Navigator.pop(context);
                                            //todo: we need to remove the "ReminderList" from the navigator history, so that we can reload the page.
                                            nextScreen(
                                                context, const ReminderList());
                                          } catch (e) {
                                            showCustomSnackbar(
                                              context,
                                              Colors.black,
                                              e.toString(),
                                            );
                                          }
                                        },
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                    content: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "This will delete the reminder and all of its schedules. Do you want to continue?",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 13,
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: ListTile(
                            title: const Text(
                              "Delete Reminder",
                            ),
                            leading: FaIcon(
                              FontAwesomeIcons.trash,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            });
        break;
    }
  }

  bool showScheduleControl = false;

  // GJ [20-JAN-24] this shows a pop-up on "mark complete"
  showMarkAsCompletePopup(data) async {
    Navigator.pop(context);
    print(data);
    markAsCompletePopup_remark.text = '';
    markAsCompletePopup_nextSchedule.text = '';
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SizedBox(
                  // height: (MediaQuery.of(context).size.height * 0.55),
                  height: (data['repeatFlag'] == 'O')
                      ? (MediaQuery.of(context).size.height * 0.7)
                      : (MediaQuery.of(context).size.height * 0.42),
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
                                color:
                                    Theme.of(context).primaryColor.withOpacity(
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
                        ListTile(
                          leading: renderLeading(data),
                          title: renderTitle(data),
                          subtitle: renderSubTitle(data),
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            side:
                                const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Enter your remark',
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        CustomTextAreaField(
                            labelText: '',
                            controller: markAsCompletePopup_remark),
                        if (data['repeatFlag'] == 'O')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: showScheduleControl,
                                    onChanged: ((value) {
                                      setModalState(() {
                                        showScheduleControl =
                                            !showScheduleControl;
                                      });
                                    }),
                                  ),
                                  const Text("Do you want to reschedule?")
                                ],
                              ),
                              if (showScheduleControl == true)
                                const Text(
                                  'Reschedule date',
                                ),
                              if (showScheduleControl == true)
                                const SizedBox(
                                  height: 4,
                                ),
                              if (showScheduleControl == true)
                                TextFormField(
                                  onTap: () async {
                                    final DateTime? pickedDate =
                                        await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1920),
                                            lastDate: DateTime(2080));
                                    if (pickedDate != null) {
                                      setState(() {
                                        markAsCompletePopup_nextSchedule.text =
                                            DateFormat('dd-MMM-yyyy')
                                                .format(pickedDate);
                                      });
                                    }
                                  },
                                  controller: markAsCompletePopup_nextSchedule,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    suffixIcon: const Icon(
                                      FontAwesomeIcons.calendar,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 10,
                                    ),
                                    hintText: "Enter your text...",
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ),
                                    ),
                                  ),
                                ),
                              if (showScheduleControl == true)
                                const Text(
                                  'Help: enter a date if you want to reschedule it once again.',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(
                          height: 14,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                onClickMarkAsCompleteButtonInPopup(data);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor),
                              child: const Text(
                                'Mark as Complete',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Cancel",
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  onClickMarkAsCompleteContextMenu(data) async {
    showMarkAsCompletePopup(data);
  }

  onClickMarkAsCompleteButtonInPopup(data) async {
    Navigator.pop(context);
    await executeMarkReminder(data);
    getListOfReminders();
  }

  onClickUnmarkAsPendingContextMenu(data) async {
    Navigator.pop(context);
    await executeUnmarkReminder(data);
    getListOfReminders();
  }

  executeMarkReminder(data) async {
    try {
      setState(() {
        showLoader = true;
      });

      var data0 = {
        "reminderCode": data['code'],
        "schedule": data['schedule'],
        'remark': markAsCompletePopup_remark.text.trim(),
        'nextSchedule': markAsCompletePopup_nextSchedule.text.trim(),
      };
      // print(_data);

      ApiResult result = await ApiService()
          .post2(context, '/api/reminder/mark-as-complete', data0, headers);

      if (result.success == false) {
        ApiService().handleApiResponse2(context, result.data);
        setState(() {
          showLoader = false;
        });
        return;
      }
      showToast(context, ToastTypes.SUCCESS, result.data['message']);

      setState(() {
        showLoader = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        showLoader = false;
      });
    }
  }

  executeUnmarkReminder(data) async {
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
        setState(() {
          showLoader = false;
        });
        return;
      }
      showToast(context, ToastTypes.SUCCESS, result.data['message']);

      setState(() {
        showLoader = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        showLoader = false;
      });
    }
  }

  final markAsCompletePopup_remark = TextEditingController();
  final markAsCompletePopup_nextSchedule = TextEditingController();
}
