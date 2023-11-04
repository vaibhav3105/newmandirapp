import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mandir_app/services/todoService.dart';
import 'package:mandir_app/widgets/custom_textfield.dart';

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
                showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.38,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  child: Center(
                                    child: Container(
                                      height: 6,
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(
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
                                  height: 20,
                                ),
                                CustomTextField(
                                  labelText: 'Title',
                                  controller: titleController,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                CustomTextAreaField(
                                  labelText: 'Description',
                                  controller: descriptionController,
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Center(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await TodoService().addTodo(
                                          context,
                                          titleController.text.trim(),
                                          descriptionController.text.trim(),
                                        );
                                        searchTodo();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        fixedSize: const Size(170, 45),
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          106,
                                          78,
                                          179,
                                        ),
                                      ),
                                      child: const Text(
                                        "Create",
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
                      );
                    });
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            body: Padding(
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
                            Container(
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
                                      colors[index % colors.length],
                                  child: const Icon(
                                    FontAwesomeIcons.solidNoteSticky,
                                    color: Colors.white,
                                  ),
                                ),
                                trailing: GestureDetector(
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
                  )
                ],
              ),
            ),
          );
  }
}
