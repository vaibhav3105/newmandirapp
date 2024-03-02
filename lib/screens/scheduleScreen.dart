// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mandir_app/constants.dart';
import 'package:mandir_app/service/api_service.dart';
import 'package:mandir_app/utils/styling.dart';
import 'package:mandir_app/widgets/custom_textfield.dart';

class ScheduleScreen extends StatefulWidget {
  final String reminderCode;
  const ScheduleScreen({
    Key? key,
    required this.reminderCode,
  }) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllSchedules();
  }

  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  final dateRangeController = TextEditingController();
  final searchController = TextEditingController();
  String searchBy = 'SEARCH_BY_DATE_RANGE';
  var Schedules = [];
  String Caption = '';
  bool isLoading = false;
  bool loadingRemark = false;
  getRemark(String schedule) async {
    setState(() {
      loadingRemark = true;
    });
    try {
      remarkController.text = '';
      var response = await ApiService().post2(
          context,
          '/api/reminder/instance/item',
          {"reminderCode": widget.reminderCode, 'schedule': schedule},
          headers);
      if (response.success == false) {
        ApiService().handleApiResponse2(context, response.data);

        return;
      }

      setState(() {
        response.data.length == 0
            ? remarkController.text = ''
            : remarkController.text = response.data[0]['remark'];
        loadingRemark = false;
      });
    } catch (e) {
      setState(() {
        loadingRemark = false;
      });
      print(e.toString());
    }
  }

  getAllSchedules() async {
    setState(() {
      isLoading = true;
    });
    try {
      Schedules = [];
      Caption = '';
      var response = await ApiService().post2(
          context,
          '/api/reminder/instance/list',
          {
            "reminderCode": widget.reminderCode,
            "searchType": searchBy,
            "searchText": searchController.text,
            "fromDate": fromDateController.text.trim(),
            "toDate": toDateController.text.trim()
          },
          headers);
      if (response.success == false) {
        ApiService().handleApiResponse2(context, response.data);
        setState(() {
          isLoading = false;
        });
        return;
      }

      setState(() {
        Schedules = response.data['instances'];
        Caption = response.data['info'][0]['caption'].toString().replaceAll(
              "####COUNT####",
              Schedules.length.toString(),
            );
        fromDateController.text = DateFormat('dd-MMM-yyyy').format(
          DateTime.parse(
            response.data['info'][0]['fromDate'],
          ),
        );
        toDateController.text = DateFormat('dd-MMM-yyyy').format(
          DateTime.parse(
            response.data['info'][0]['toDate'],
          ),
        );

        dateRangeController.text =
            '${fromDateController.text} - ${toDateController.text}';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Schedules",
        ),
        actions: [
          IconButton(
              onPressed: () {
                fnShowBottomSheet(context);
              },
              icon: Icon(
                Icons.filter_alt,
                size: 28,
                color: themeVeryLightColor,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          children: [
            if (searchBy == 'SEARCH_BY_DATE_RANGE')
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text('Select a Date Range'),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          onTap: () async {
                            final DateTimeRange? dateTimeRange =
                                await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(1920),
                              lastDate: DateTime(2400),
                              initialDateRange: DateTimeRange(
                                start: DateTime.now(),
                                end: DateTime.now().add(
                                  const Duration(
                                    days: 20,
                                  ),
                                ),
                              ),
                            );
                            if (dateTimeRange != null) {
                              setState(() {
                                fromDateController.text =
                                    DateFormat('dd-MMM-yyyy')
                                        .format(dateTimeRange.start);
                                toDateController.text =
                                    DateFormat('dd-MMM-yyyy').format(
                                  dateTimeRange.end,
                                );
                                dateRangeController.text =
                                    '${fromDateController.text} - ${toDateController.text}';
                              });
                            }
                          },
                          controller: dateRangeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              FontAwesomeIcons.calendar,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 50,
                                  width: 1,
                                  color: Colors.grey,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
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
                                      getAllSchedules();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 10,
                            ),
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
                      ),
                    ],
                  ),
                ],
              ),
            if (searchBy == 'SEARCH_BY_TEXT')
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search by text",
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
                                getAllSchedules();
                              },
                            ),
                          ),
                        ],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 10,
                      ),
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
                ],
              ),
            const SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(Caption),
            ),
            const SizedBox(
              height: 10,
            ),
            renderAllReminders()
          ],
        ),
      ),
    );
  }

  Widget renderAllReminders() {
    Widget? myWidget;
    if (isLoading == true) {
      myWidget = const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      myWidget = Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 80,
          ),
          // itemCount: allReminders.length,
          itemCount: Schedules.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    getRemark(Schedules[index]['schedule']);

                    onTapScheduleItem(Schedules[index]);
                  },
                  child: Container(
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 3,
                      ),
                      leading: renderLeading(Schedules[index]),
                      title: renderTitle(Schedules[index]),
                      subtitle: renderSubTitle(
                        Schedules[index],
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
      );
    }

    return myWidget;
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
          color: Theme.of(context).primaryColor,
        );
    }
  }

  onTapScheduleItem(data) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
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
                SizedBox(
                  height: 500,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Text("Remark"),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        controller: remarkController,
                        maxLines: 10,
                        minLines: 6,
                        decoration: textInputDecoration.copyWith(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: '',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: const Text(
                            "Close",
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  final remarkController = TextEditingController();

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

  void fnShowBottomSheet(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
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
                  height: 120,
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Search by Date Range'),
                        onTap: () {
                          setState(() {
                            searchBy = 'SEARCH_BY_DATE_RANGE';
                          });
                          getAllSchedules();
                          Navigator.pop(context);
                        },
                        leading: Icon(
                          FontAwesomeIcons.magnifyingGlass,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                      ListTile(
                        title: const Text('Search by Text'),
                        onTap: () {
                          setState(() {
                            searchBy = 'SEARCH_BY_TEXT';
                            searchController.text = '';
                          });
                          getAllSchedules();
                          Navigator.pop(context);
                        },
                        leading: Icon(
                          FontAwesomeIcons.magnifyingGlass,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                    ],
                  )),
            ],
          );
        });
  }
}
