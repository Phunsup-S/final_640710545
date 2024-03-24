import 'dart:convert';

import 'package:final_640710545/helpers/api_caller.dart';
import 'package:final_640710545/helpers/dialog_utils.dart';
import 'package:final_640710545/helpers/my_list_tile.dart';
import 'package:final_640710545/helpers/my_text_field.dart';
import 'package:final_640710545/models/todo_item.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TodoItem> todos = [];
  var _UrlController = TextEditingController();
  var _otherController = TextEditingController();
  List<bool> isSelectedList = List.generate(5, (index) => false);
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  Future<void> _loadTodoItems() async {
    final data = await ApiCaller().get('api/2_2566/final/web_types');
    List list = jsonDecode(data);
    print("test");
    setState(() {
      todos = list.map((e) => TodoItem.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    //var Len = todos.length;
    //List<bool> isSelectedList = List.generate(5, (index) => false);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('Webby FonDue', style: TextStyle(fontSize: 18.0)),
            Text('ระบบราบงานเว็ปเลวๆ', style: TextStyle(fontSize: 16.0)),
          ],
        ),
      ),
      body: Column(
        children: [
          MyTextField(
            controller: _UrlController,
            hintText: 'URL *',
            keyboardType: TextInputType.url,
          ),
          SizedBox(height: 15.0),
          MyTextField(
            controller: _otherController,
            hintText: 'รายละเอียด',
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 15.0),
          Text("ระบุประเภทเว็บเลว *"),
          SizedBox(height: 15.0),
          for (var i = 0; i < todos.length; i++)
            Expanded(
              child: MyListTile(
                title: todos[i].title,
                subtitle: todos[i].subtitle,
                imageUrl: todos[i].image,
                selected: isSelectedList[i],
                onTap: () {
                  setState(() {
                    for (var j = 0; j < isSelectedList.length; j++) {
                      isSelectedList[j] = false;
                    }
                    isSelectedList[i] = true;
                  });
                },
              ),
            ),
          SizedBox(height: 15.0),
          ElevatedButton(
            onPressed: () {
              setState(() async {
                String checkurl = _UrlController.text;
                String other = _otherController.text;
                bool allUnselected =
                    isSelectedList.every((isSelected) => isSelected == false);
                if (checkurl.isEmpty || allUnselected) {
                  showOkDialog(
                      context: context,
                      title: "Error",
                      message: "ต้องกรอก URL และเลือกประเภทเว็ป");
                } else {
                  int selectedIndex = isSelectedList.indexOf(true);
                  final data = await ApiCaller().post(
                    'report_web',
                    params: {
                      "url": checkurl,
                      "description": other,
                      "type": todos[selectedIndex].id
                    },
                  );
                  Map map = jsonDecode(data);
                  print(map['insertItem']);
                  print("sdsdsdsds");
                  print(map['summary']);
                  String message =
                      "ขอบคุณสำหรับการแจ้งของมูล รหัสข้อมูลของคุณคือ " +
                          map['insertItem']['id'].toString() +
                          "\n\nสถิติรายงาน\n=====\n";

                  for (var summary in map['summary']) {
                    message += "${summary['title']} : ${summary['count']}\n";
                  }
                  showOkDialog(
                      context: context,
                      title: "Success",
                      message: message);
                }
              });
            },
            child: const Text('ส่งข้อมูล'),
          ),
          SizedBox(height: 15.0),
        ],
      ),
    );
  }
}
