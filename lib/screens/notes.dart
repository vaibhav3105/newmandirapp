// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../service/api_service.dart';
import '../utils/styling.dart';
import '../utils/utils.dart';
import '../widgets/custom_textfield.dart';

class NotesScreen extends StatefulWidget {
  final String reminderCode;
  const NotesScreen({
    Key? key,
    required this.reminderCode,
  }) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool isLoading = false;
  final noteController = TextEditingController();
  final dateController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReminderNotes();

    dateController.text = DateFormat('dd-MMM-yyyy').format(DateTime.now());
  }

  @override
  List<dynamic> reminderNotes = [];

  getReminderNotes() async {
    try {
      setState(() {
        isLoading = true;
      });
      var response = await ApiService().post(
          '/api/reminder/note/list',
          {
            "reminderCode": widget.reminderCode,
          },
          headers,
          context);
      setState(() {
        reminderNotes = response;
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
        title: const Text("Reminder Notes"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    "Add Note",
                  ),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: () async {
                        var response = await ApiService().post(
                          '/api/reminder/note/create',
                          {
                            "reminderCode": widget.reminderCode,
                            'activityDate': dateController.text.trim(),
                            'desc': noteController.text.trim()
                          },
                          headers,
                          context,
                        );
                        if (response['errorCode'] == 0) {
                          Navigator.pop(context);
                          noteController.text = '';
                          dateController.text =
                              DateFormat('dd-MMM-yyyy').format(DateTime.now());
                          showCustomSnackbar(
                            context,
                            Colors.black,
                            response['message'],
                          );
                          getReminderNotes();
                        }
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        dateController.text =
                            DateFormat('dd-MMM-yyyy').format(DateTime.now());
                        noteController.text = '';
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextAreaField(
                        labelText: "Note Description",
                        controller: noteController,
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
                            fillColor: Colors.white,
                            filled: true,
                            labelText: 'Note Date'),
                      ),
                    ],
                  ),
                );
              });
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: isLoading == true
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
                    height: 10,
                  ),
                  Text(
                    reminderNotes.isEmpty
                        ? 'No notes found...'
                        : 'Showing ${reminderNotes.length} notes.....',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        bottom: 80,
                      ),
                      itemCount: reminderNotes.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Container(
                              color: Colors.white,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 1,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey[100],
                                  child: Icon(
                                    FontAwesomeIcons.solidNoteSticky,
                                    color: colors[index % colors.length],
                                  ),
                                ),
                                title: Text(
                                  reminderNotes[index]['desc'],
                                  style: const TextStyle(),
                                ),
                                subtitle: Text(
                                  DateFormat('dd-MMM-yyyy').format(
                                    DateTime.parse(
                                      reminderNotes[index]['activityDate'],
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
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
                                                0.2,
                                            width: double.infinity,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 13,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  const Text(
                                                    "     Select an action",
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                        255,
                                                        106,
                                                        78,
                                                        179,
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      var response =
                                                          await ApiService()
                                                              .post(
                                                        '/api/reminder/note/item',
                                                        {
                                                          "noteCode":
                                                              reminderNotes[
                                                                      index]
                                                                  ['noteCode'],
                                                        },
                                                        headers,
                                                        context,
                                                      );

                                                      noteController.text =
                                                          response['desc'];
                                                      dateController.text =
                                                          DateFormat(
                                                                  'dd-MMM-yyyy')
                                                              .format(
                                                        DateTime.parse(
                                                          response[
                                                              'activityDate'],
                                                        ),
                                                      );
                                                      Navigator.pop(context);
                                                      showDialog(
                                                          barrierDismissible:
                                                              false,
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                "Edit Note",
                                                              ),
                                                              actions: [
                                                                ElevatedButton(
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        Theme.of(context)
                                                                            .primaryColor,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    var response =
                                                                        await ApiService()
                                                                            .post(
                                                                      '/api/reminder/note/update',
                                                                      {
                                                                        "noteCode":
                                                                            reminderNotes[index]['noteCode'],
                                                                        'activityDate': dateController
                                                                            .text
                                                                            .trim(),
                                                                        'desc': noteController
                                                                            .text
                                                                            .trim()
                                                                      },
                                                                      headers,
                                                                      context,
                                                                    );
                                                                    if (response[
                                                                            'errorCode'] ==
                                                                        0) {
                                                                      showCustomSnackbar(
                                                                        context,
                                                                        Colors
                                                                            .black,
                                                                        response[
                                                                            'message'],
                                                                      );
                                                                      Navigator.pop(
                                                                          context);
                                                                      getReminderNotes();
                                                                      noteController
                                                                          .text = '';
                                                                      dateController
                                                                          .text = DateFormat(
                                                                              'dd-MMM-yyyy')
                                                                          .format(
                                                                        DateTime
                                                                            .now(),
                                                                      );
                                                                    }
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "Update",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                    dateController
                                                                        .text = DateFormat(
                                                                            'dd-MMM-yyyy')
                                                                        .format(
                                                                            DateTime.now());
                                                                    noteController
                                                                        .text = '';
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "Cancel",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                              content: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  CustomTextAreaField(
                                                                    labelText:
                                                                        "Note Description",
                                                                    controller:
                                                                        noteController,
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  TextFormField(
                                                                    readOnly:
                                                                        true,
                                                                    onTap:
                                                                        () async {
                                                                      final DateTime? pickedDate = await showDatePicker(
                                                                          context:
                                                                              context,
                                                                          initialDate: DateTime
                                                                              .now(),
                                                                          firstDate: DateTime(
                                                                              1920),
                                                                          lastDate:
                                                                              DateTime(2080));
                                                                      if (pickedDate !=
                                                                          null) {
                                                                        setState(
                                                                            () {
                                                                          dateController.text =
                                                                              DateFormat('dd-MMM-yyyy').format(pickedDate);
                                                                        });
                                                                      }
                                                                    },
                                                                    controller:
                                                                        dateController,
                                                                    decoration: textInputDecoration.copyWith(
                                                                        fillColor:
                                                                            Colors
                                                                                .white,
                                                                        filled:
                                                                            true,
                                                                        labelText:
                                                                            'Note Date'),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          });
                                                    },
                                                    child: const ListTile(
                                                      title: Text(
                                                        "Edit Note",
                                                      ),
                                                      leading: FaIcon(
                                                        FontAwesomeIcons
                                                            .userLarge,
                                                        color: Color.fromARGB(
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
                                                      Navigator.pop(context);
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                "Delete Note",
                                                              ),
                                                              actions: [
                                                                ElevatedButton(
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    var response =
                                                                        await ApiService()
                                                                            .post(
                                                                      '/api/reminder/note/delete',
                                                                      {
                                                                        "noteCode":
                                                                            reminderNotes[index]['noteCode'],
                                                                      },
                                                                      headers,
                                                                      context,
                                                                    );
                                                                    if (response[
                                                                            'errorCode'] ==
                                                                        0) {
                                                                      Navigator.pop(
                                                                          context);

                                                                      showCustomSnackbar(
                                                                        context,
                                                                        Colors
                                                                            .black,
                                                                        response[
                                                                            'message'],
                                                                      );
                                                                      getReminderNotes();
                                                                    }
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "Delete",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                                ElevatedButton(
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
                                                                      color: Colors
                                                                          .black,
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
                                                                    "Are you sure you want to delete this note?",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15,
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
                                                    child: const ListTile(
                                                      title: Text(
                                                        "Delete Note",
                                                      ),
                                                      leading: FaIcon(
                                                        FontAwesomeIcons.trash,
                                                        color: Color.fromARGB(
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
                ],
              ),
            ),
    );
  }
}
