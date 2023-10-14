import 'package:flutter/material.dart';
import 'package:mandir_app/screens/reminderList.dart';
import 'package:mandir_app/screens/todo.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen>
    with SingleTickerProviderStateMixin {
  TabBar get _tabBar => TabBar(
        tabs: tabBars!,
        controller: controller,
      );
  TabController? controller;
  List<Tab>? tabBars;
  List<Widget>? tabBarViews;
  final tabIconSize = 30.0;
  @override
  void initState() {
    controller = TabController(vsync: this, length: 2);
    controller!.index = 0;
    tabBars = [
      const Tab(
        text: 'Reminders',
      ),
      const Tab(
        text: 'Todo List',
      )
    ];
    tabBarViews = [const ReminderList(), const TodoScreen()];

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Assistant"),
        bottom: PreferredSize(
          preferredSize: _tabBar.preferredSize,
          child: Material(child: _tabBar),
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: tabBarViews!,
      ),
    );
  }
}
