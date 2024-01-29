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
        return const Icon(
          FontAwesomeIcons.calendar,
          color: Colors.black,
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
                      color: Theme.of(context).primaryColor,
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
                            title: const Text('View details'),
                            leading: FaIcon(
                              FontAwesomeIcons.eye,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            showToast(context, ToastTypes.INFO,
                                'Feature coming soon.');
                          },
                          child: ListTile(
                            title: const Text('View schedules'),
                            leading: FaIcon(
                              FontAwesomeIcons.listUl,
                              color: Theme.of(context).primaryColor,
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
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              // height: (MediaQuery.of(context).size.height * 0.55),
              height: (data['repeatFlag'] == 'O')
                  ? (MediaQuery.of(context).size.height * 0.55)
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
                    ListTile(
                      leading: renderLeading(data),
                      title: renderTitle(data),
                      subtitle: renderSubTitle(data),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey, width: 1),
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
                        labelText: '', controller: markAsCompletePopup_remark),
                    if (data['repeatFlag'] == 'O')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Reschedule date',
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          CustomTextField(
                              labelText: '',
                              controller: markAsCompletePopup_nextSchedule),
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
                              backgroundColor: Theme.of(context).primaryColor),
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

      var _data = {
        "reminderCode": data['code'],
        "schedule": data['schedule'],
        'remark': markAsCompletePopup_remark.text.trim(),
        'nextSchedule': null,
      };
      // print(_data);

      ApiResult result = await ApiService()
          .post2(context, '/api/reminder/mark-as-complete', _data, headers);
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

  final markAsCompletePopup_remark = TextEditingController();
  final markAsCompletePopup_nextSchedule = TextEditingController();
}
