import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mandir_app/screens/addTodo.dart';
import 'package:mandir_app/services/todoService.dart';
import 'package:mandir_app/utils/utils.dart';

import '../constants.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen>
    with AutomaticKeepAliveClientMixin<TodoScreen> {
  @override
  bool get wantKeepAlive => true;

  bool isLoading = false;
  searchTodo() async {
    try {
      setState(() {
        isLoading = true;
      });
      var response = await TodoService().searchTodo(
        context,
        todoController.text.trim(),
      );
      setState(() {
        todos = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchTodo();
  }

  final todoController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  List todos = [];
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text(
                "My Todo List",
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                nextScreen(
                    context,
                    const AddTodo(
                      todoCode: '',
                    ));
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                searchTodo();
              },
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
                    TextFormField(
                      controller: todoController,
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
                                  searchTodo();
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
                    const SizedBox(
                      height: 15,
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 80,
                        ),
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  nextScreen(
                                      context,
                                      AddTodo(
                                        todoCode: todos[index]['noteCode'],
                                      ));
                                },
                                child: Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    subtitle: Text(
                                      todos[index]['subTitle'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 1,
                                    ),
                                    title: Text(
                                      todos[index]['title'],
                                      style: const TextStyle(),
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          colors[index % colors.length]
                                              .withOpacity(0.1),
                                      // backgroundColor: Colors.white,
                                      child: Icon(
                                        FontAwesomeIcons.solidNoteSticky,
                                        // color: Colors.white,
                                        color: colors[index % colors.length],
                                      ),
                                    ),
                                    trailing: Container(
                                      alignment: Alignment.center,
                                      color: Colors.white,
                                      width: 30,
                                      child: FaIcon(
                                        FontAwesomeIcons.angleRight,
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
                    )
                  ],
                ),
              ),
            ),
          );
  }

  onTapTodoItem(String code) {
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
                        context,
                        AddTodo(
                          todoCode: code,
                        ));
                  },
                  child: ListTile(
                    title: const Text('View Todo'),
                    leading: FaIcon(
                      FontAwesomeIcons.eye,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
