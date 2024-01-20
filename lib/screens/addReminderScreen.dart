// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mandir_app/screens/assistant.dart';

import 'package:mandir_app/screens/editScreen.dart';
import 'package:mandir_app/screens/reminderList.dart';
import 'package:mandir_app/service/api_service.dart';
import 'package:mandir_app/utils/styling.dart';
import 'package:mandir_app/utils/utils.dart';

import '../widgets/custom_textfield.dart';

class AddReminderScreen extends StatefulWidget {
  final String reminderCode;
  const AddReminderScreen({
    Key? key,
    required this.reminderCode,
  }) : super(key: key);

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
  }

  getMonthlyString() {
    print(monthString);
    if (initialRepeat!.actualValue == 'M') {
      for (var i = 0; i < _isCheckedList.length; i++) {
        if (_isCheckedList[i] == true) {
          monthString += '${i + 1},';
        }
      }

      setState(() {});
    }
    print(monthString);
  }

  var monthString = '';

  bool isLoading = false;
  bool isClickedButton = false;
  var result = {};
  var repeatItemss = [];
  var categoryItemss = [];
  APIDropDownItem? initialRepeat;
  APIDropDownItem? initialCategory;
  List<DropdownMenuItem<APIDropDownItem>> repeatOptionsButton =
      <DropdownMenuItem<APIDropDownItem>>[];
  List<DropdownMenuItem<APIDropDownItem>> categoryOptionsButton =
      <DropdownMenuItem<APIDropDownItem>>[];
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final remindTillController = TextEditingController(text: '10');
  final dateController = TextEditingController(
    text: DateFormat('dd-MMM-yyyy').format(
      DateTime.now(),
    ),
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRepeatControls();
    getCategoryControls();
  }

  final List<bool> _isCheckedList = List.generate(12, (index) => false);

  updateReminder() async {
    try {
      setState(() {
        isClickedButton = true;
      });
      getMonthlyString();
      print(monthString);
      FocusScope.of(context).unfocus();
      var response = await ApiService().post(
          '/api/reminder/update',
          {
            "reminderCode": widget.reminderCode,
            "title": titleController.text.trim(),
            "desc": descriptionController.text.trim(),
            "remindOn": dateController.text.trim(),
            "repeatFlag": initialRepeat!.actualValue,
            'category': 'GENERAL',
            'repeatString': monthString,
            'remindYearCount': int.parse(remindTillController.text.trim())
          },
          headers,
          context);
      setState(() {
        isClickedButton = false;
      });
      if (response['errorCode'] == 0) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ReminderList(
                  // date: dateController.text,
                  ),
            ),
            (route) => route.isFirst);

        showCustomSnackbar(context, Colors.black, response['message']);
        print(response);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  createReminder() async {
    try {
      setState(() {
        isClickedButton = true;
      });
      getMonthlyString();
      FocusScope.of(context).unfocus();
      var response = await ApiService().post(
          '/api/reminder/create',
          {
            "title": titleController.text.trim(),
            "desc": descriptionController.text.trim(),
            "remindOn": dateController.text.trim(),
            "repeatFlag": initialRepeat!.actualValue,
            'category': 'GENERAL',
            'repeatString': monthString,
            'remindYearCount': int.parse(remindTillController.text.trim())
          },
          headers,
          context);
      print(response);
      setState(() {
        isClickedButton = false;
      });
      if (response['errorCode'] == 0) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ReminderList(
                  // date: dateController.text,
                  ),
            ),
            (route) => route.isFirst);

        showCustomSnackbar(context, Colors.black, response['message']);
        print(response);
      }
    } catch (e) {
      showCustomSnackbar(
        context,
        Colors.black,
        e.toString(),
      );
    }
  }

  getReminderItem() async {
    try {
      var response = await ApiService().post('/api/reminder/item',
          {"reminderCode": widget.reminderCode}, headers, context);
      var initialRepeatValue = response['repeatFlag'];
      print(response);
      var initialCategoryValue = response['category'];
      setState(() {
        result = response;
        initialRepeat = repeatItemss.firstWhere(
          (element) => element.actualValue == initialRepeatValue,
        );
        initialCategory = categoryItemss.firstWhere(
          (element) => element.actualValue == initialCategoryValue,
        );

        titleController.text = response['title'];
        descriptionController.text = result['desc'];
        remindTillController.text = result['remindYearCount'].toString();
        var dummyMonthString = result['repeatString'];
        print(dummyMonthString);
        var x = dummyMonthString.split(',');
        for (var element in x) {
          if (element.isNotEmpty) {
            _isCheckedList[int.parse(element) - 1] = true;
          }
        }

        print(x);
        dateController.text = DateFormat('dd-MMM-yyyy').format(
          DateTime.parse(
            result['remindOn'],
          ),
        );
        isLoading = false;
      });
    } catch (e) {
      showCustomSnackbar(
        context,
        Colors.black,
        e.toString(),
      );
    }
  }

  void getRepeatControls() async {
    try {
      setState(() {
        isLoading = true;
      });
      var response = await ApiService().post('/api/lookup/key-details',
          {"keyName": "REMINDER_REPEAT"}, headers, context);
      var repeatItems = (response as List<dynamic>)
          .map(
            (apiItem) => APIDropDownItem(
              displayText: apiItem['displayText'],
              actualValue: apiItem['actualValue'],
            ),
          )
          .toList();
      setState(() {
        repeatItemss = repeatItems;
        repeatOptionsButton = repeatItems
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
        initialRepeat = repeatItems[0];
      });
      if (widget.reminderCode != '') {
        getReminderItem();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      showCustomSnackbar(
        context,
        Colors.black,
        e.toString(),
      );
    }
  }

  void getCategoryControls() async {
    try {
      setState(() {
        isLoading = true;
      });
      var response = await ApiService().post('/api/lookup/key-details',
          {"keyName": "REMINDER_CATEGORY"}, headers, context);
      var categoryItems = (response as List<dynamic>)
          .map(
            (apiItem) => APIDropDownItem(
              displayText: apiItem['displayText'],
              actualValue: apiItem['actualValue'],
            ),
          )
          .toList();
      setState(() {
        categoryItemss = categoryItems;
        categoryOptionsButton = categoryItems
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
        initialCategory = categoryItems[0];
      });
      if (widget.reminderCode != '') {
        getReminderItem();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: widget.reminderCode == ''
            ? const Text(
                "Add Reminder",
              )
            : const Text("Edit Reminder"),
      ),
      body: isLoading == true
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Form(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Title'),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTextField(
                        controller: titleController,
                        labelText: '',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Frequency'),
                      const SizedBox(
                        height: 5,
                      ),
                      DropdownButtonFormField(
                        value: initialRepeat,
                        decoration: textInputDecoration.copyWith(
                          // labelText: 'Frequency',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        items: repeatOptionsButton,
                        onChanged: (APIDropDownItem? item) {
                          setState(() {
                            initialRepeat = item!;
                            print(initialRepeat!.actualValue);
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (initialRepeat!.actualValue == 'M')
                        GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing:
                                      1.0, // Adjust spacing as needed
                                  crossAxisSpacing: 1.0,
                                  childAspectRatio: 2),
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            final monthName = _getMonthName(index + 1);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isCheckedList[index] =
                                      !_isCheckedList[index];
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    // activeColor: Colors.red,
                                    value: _isCheckedList[index],
                                    onChanged: (value) {
                                      setState(() {
                                        _isCheckedList[index] = value!;
                                      });
                                      print(monthString);
                                    },
                                  ),
                                  Text(monthName),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Remind On'),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        readOnly: true,
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              // firstDate: DateTime(1920),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2080));
                          if (pickedDate != null) {
                            setState(() {
                              dateController.text =
                                  DateFormat('dd-MMM-yyyy').format(pickedDate);
                            });
                          }
                        },
                        controller: dateController,
                        decoration: textInputDecoration.copyWith(
                          // labelText: 'Remind On',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Remind Till'),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: remindTillController,
                        decoration: textInputDecoration.copyWith(
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      // CustomTextField(
                      //   controller: remindTillController,
                      //   labelText: '',

                      // ),
                      // const SizedBox(
                      //   height: 20,
                      // ),
                      // DropdownButtonFormField(
                      //   value: initialCategory,
                      //   decoration: textInputDecoration.copyWith(
                      //     labelText: 'Category',
                      //     fillColor: Colors.white,
                      //     filled: true,
                      //   ),
                      //   items: categoryOptionsButton,
                      //   onChanged: (APIDropDownItem? item) {
                      //     setState(() {
                      //       initialCategory = item!;
                      //     });
                      //   },
                      // ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Description'),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: textInputDecoration.copyWith(
                          // labelText: 'Description',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),

                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.reminderCode != ''
                                  ? updateReminder()
                                  : createReminder();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              fixedSize: const Size(170, 45),
                              backgroundColor: const Color.fromARGB(
                                255,
                                106,
                                78,
                                179,
                              ),
                            ),
                            child: !isClickedButton
                                ? widget.reminderCode != ''
                                    ? const Text(
                                        "Update",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      )
                                    : const Text(
                                        'Create',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      )
                                : const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String _getMonthName(int monthNumber) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[monthNumber - 1];
  }
}
