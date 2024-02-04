import 'package:flutter/material.dart';
import 'package:mandir_app/screens/todo.dart';
import 'package:mandir_app/service/api_service.dart';
import 'package:mandir_app/utils/app_enums.dart';
import 'package:mandir_app/utils/utils.dart';

class TodoService {
  static String searchTodoUrl = '/api/todo-note/search';
  static String addTodoUrl = '/api/todo-note/create';
  static String getTodoUrl = '/api/todo-note/item';
  static String updateTodoUrl = '/api/todo-note/update';
  static String deleteTodoUrl = '/api/todo-note/delete';

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

  Future<dynamic> addTodo(BuildContext context, String noteDesc) async {
    try {
      var response = await ApiService().post2(
        context,
        addTodoUrl,
        {'desc': noteDesc},
        headers,
      );

      if (response.success == true) {
        showCustomSnackbar(
          context,
          Colors.black,
          response.data['message'],
        );
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        nextScreen(context, const TodoScreen());
      }

      // if (response['errorCode'] == 0) {
      //   showCustomSnackbar(
      //     context,
      //     Colors.black,
      //     response['message'],
      //   );
      // }
      // Navigator.of(context).pop();
      // Navigator.of(context).pop();
      // nextScreen(context, const TodoScreen());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> modifyTodo(
      BuildContext context, String noteCode, String noteDesc) async {
    try {
      var response = await ApiService().post2(
        context,
        updateTodoUrl,
        {
          'noteCode': noteCode,
          'desc': noteDesc,
        },
        headers,
      );

      if (response.success == true) {
        showToast(context, ToastTypes.SUCCESS, response.data['message']);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        nextScreen(context, const TodoScreen());
      } else {
        showToast(context, ToastTypes.WARN, response.data['errorMessage']);
      }

      // if (response['errorCode'] == 0) {
      //   showCustomSnackbar(
      //     context,
      //     Colors.black,
      //     response['message'],
      //   );
      // }
      // Navigator.of(context).pop();
      // Navigator.of(context).pop();
      // nextScreen(context, const TodoScreen());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> getTodo(BuildContext context, String todoCode) async {
    try {
      var response = await ApiService().post(
        getTodoUrl,
        {'noteCode': todoCode},
        headers,
        context,
      );

      return response;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> deleteTodo(BuildContext context, String todoCode) async {
    try {
      var response = await ApiService().post(
        deleteTodoUrl,
        {'noteCode': todoCode},
        headers,
        context,
      );
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      nextScreen(context, const TodoScreen());
      showToast(context, ToastTypes.SUCCESS, "Todo Note deleted successfully.");
    } catch (e) {
      print(e.toString());
    }
  }
}
