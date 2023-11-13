import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class AddTodo extends StatefulWidget {
  const AddTodo({super.key});

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  final QuillController _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Todo'),
      ),
      body: QuillProvider(
        configurations: QuillConfigurations(
          controller: _controller,
          sharedConfigurations: const QuillSharedConfigurations(
            locale: Locale('en'),
          ),
        ),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                var json = jsonEncode(_controller.document.toDelta().toJson());
                print(json);
              },
              child: const Text('Save'),
            ),
            const QuillToolbar(
              configurations: QuillToolbarConfigurations(
                fontSizesValues: {'8': '8', '24.5': '24.5', '46': '46'},
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Expanded(
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
