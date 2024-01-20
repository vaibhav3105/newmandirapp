// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:mandir_app/services/todoService.dart';
import 'package:mandir_app/widgets/custom_textfield.dart';

class AddTodo extends StatefulWidget {
  final String todoCode;
  const AddTodo({
    Key? key,
    required this.todoCode,
  }) : super(key: key);

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  final QuillController _controller = QuillController.basic();
  final titleController = TextEditingController();
  bool isLoading = false;
  @override
  var data = '';
  getTodoJson() async {
    try {
      print(widget.todoCode);
      var response = await TodoService().getTodo(context, widget.todoCode);

      final json = jsonDecode(response['desc']);
      _controller.document = Document.fromJson(json);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.todoCode.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      getTodoJson();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: widget.todoCode.isEmpty
            ? () async {
                await TodoService().addTodo(
                  context,
                  _controller.document.getPlainText(0, 10),
                  jsonEncode(_controller.document.toDelta().toJson()),
                );
              }
            : () async {
                await TodoService().modifyTodo(
                    context,
                    _controller.document.getPlainText(0, 10),
                    jsonEncode(_controller.document.toDelta().toJson()),
                    widget.todoCode);
              },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Text(
          "Save",
          style: TextStyle(color: Colors.white),
        ),
      ),
      appBar: AppBar(
        actions: widget.todoCode.isNotEmpty
            ? [
                IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                "Delete Note",
                              ),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await TodoService()
                                        .deleteTodo(context, widget.todoCode);
                                  },
                                  child: const Text(
                                    "Delete",
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
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Are you sure you want to delete this note?",
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
                    icon: const Icon(
                      Icons.delete,
                    ))
              ]
            : [],
        title: widget.todoCode.isEmpty
            ? const Text('Create Todo')
            : const Text('Edit Todo'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : QuillProvider(
              configurations: QuillConfigurations(
                controller: _controller,
                sharedConfigurations: const QuillSharedConfigurations(
                  locale: Locale('en'),
                ),
              ),
              child: Column(
                children: [
                  const QuillToolbar(
                    configurations: QuillToolbarConfigurations(
                      fontSizesValues: {
                        '10': '10',
                        '15': '15',
                        '20': '20',
                        '25': '25',
                        '30': '30',
                        '35': '35',
                      },
                      showListCheck: true,
                      showInlineCode: false,
                      showQuote: false,
                      showDirection: false,
                      showSmallButton: false,
                      showAlignmentButtons: false,
                      showFontFamily: false,
                      multiRowsDisplay: false,
                      showSuperscript: false,
                      showSubscript: false,
                      showSearchButton: false,
                      showHeaderStyle: false,
                      showLink: false,
                      showIndent: false,
                      showDividers: false,
                      showBackgroundColorButton: false,
                      showClearFormat: false,
                      showJustifyAlignment: false,
                      showLeftAlignment: false,
                      showStrikeThrough: false,
                      showCodeBlock: false,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: QuillEditor.basic(
                        configurations: const QuillEditorConfigurations(
                          readOnly: false,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
