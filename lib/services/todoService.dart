import 'package:flutter/material.dart';
import 'package:mandir_app/service/api_service.dart';
import 'package:mandir_app/utils/utils.dart';

class TodoService {
  static String searchTodoUrl = '/api/todo-note/search';
  static String addTodoUrl = '/api/todo-note/create';

  Future<dynamic> searchTodo(BuildContext context, String searchText) async {
    try {
      var response = await ApiService().post(
        searchTodoUrl,
        {
          'title': searchText,
        },
        headers,
        context,
      );
      return response;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> addTodo(
      BuildContext context, String title, String desc) async {
    try {
      var response = await ApiService().post(
        addTodoUrl,
        {'title': title, 'desc': desc},
        headers,
        context,
      );
      if (response['errorCode'] == 0) {
        showCustomSnackbar(
          context,
          Colors.black,
          response['message'],
        );
      }
      Navigator.of(context).pop();
    } catch (e) {
      print(e.toString());
    }
  }
}
