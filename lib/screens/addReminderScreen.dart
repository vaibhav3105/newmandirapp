// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  updateReminder() async {
    try {
      FocusScope.of(context).unfocus();
      var response = await ApiService().post(
          '/api/reminder/update',
          {
            "reminderCode": widget.reminderCode,
            "title": titleController.text.trim(),
            "desc": descriptionController.text.trim(),
            "remindOn": dateController.text.trim(),
            "repeatFlag": initialRepeat!.actualValue
          },
          headers,
          context);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const ReminderList(
                // date: dateController.text,
                ),
          ),
          (route) => route.isFirst);
      // nextScreen(
      //   context,
      //   ReminderList(
      //     date: dateController.text,
      //   ),
      // );
      showCustomSnackbar(context, Colors.black, response['message']);
      print(response);
    } catch (e) {
      print(e.toString());
    }
  }

  createReminder() async {
    try {
      FocusScope.of(context).unfocus();
      var response = await ApiService().post(
          '/api/reminder/create',
          {
            "title": titleController.text.trim(),
            "desc": descriptionController.text.trim(),
            "remindOn": dateController.text.trim(),
            "repeatFlag": initialRepeat!.actualValue
          },
          headers,
          context);
      print(response);

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const ReminderList(
                // date: dateController.text,
                ),
          ),
          (route) => route.isFirst);
      // nextScreen(
      //   context,
      //   ReminderList(
      //     date: dateController.text.trim(),
      //   ),
      // );
      showCustomSnackbar(context, Colors.black, response['message']);
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
      var initialCategoryValue = response['repeatFlag'];
      setState(() {
        result = response;
        initialRepeat = repeatItemss.firstWhere(
          (element) => element.actualValue == initialRepeatValue,
        );
        initialCategory = categoryItemss.firstWhere(
          (element) => element.actualValue == initialRepeatValue,
        );

        titleController.text = response['title'];
        descriptionController.text = result['desc'];
        dateController.text = DateFormat('dd-MMM-yyyy').format(
          DateTime.parse(
            result['remindOn'],
          ),
        );
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
      appBar: AppBar(
        title: widget.reminderCode == ''
            ? const Text(
                "Add Reminder",
              )
            : const Text("Edit Reminder"),
      ),
      body: SingleChildScrollView(
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
                CustomTextField(
                  controller: titleController,
                  labelText: 'Title',
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Description',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  readOnly: true,
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1920),
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
                    labelText: 'Remind On',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField(
                  value: initialRepeat,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Repeat',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  items: repeatOptionsButton,
                  onChanged: (APIDropDownItem? item) {
                    setState(() {
                      initialRepeat = item!;
                    });
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => widget.reminderCode != ''
                          ? updateReminder()
                          : createReminder(),
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
                      child: widget.reminderCode != ''
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
}