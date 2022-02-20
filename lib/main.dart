// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';

import 'db/db_provider.dart';
import 'model/task_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(Color(0xFF98B4AA)),
          ),
        ), // Here Im having the error
      ),
      home: const MyTodoList(),
    );
  }
}

class MyTodoList extends StatefulWidget {
  const MyTodoList({Key? key}) : super(key: key);

  @override
  _MyTodoListState createState() => _MyTodoListState();
}

class _MyTodoListState extends State<MyTodoList> {
  Color mainColor = const Color(0xFF495371);
  Color secColor = const Color(0xFF74959A);
  Color btnColor = const Color(0xFF98B4AA);
  Color editorColor = const Color(0xFFF1E0AC);

  TextEditingController inputController = TextEditingController();
  String newTaskTxt = "";

  getTask() async {
    final tasks = await DBProvider.dataBase.getTask();
    print(tasks);
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        elevation: 0.0,
        backgroundColor: mainColor,
      ),
      backgroundColor: mainColor,
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<dynamic>(
              future: getTask(),
              builder: (_, taskData) {
                switch (taskData.connectionState) {
                  case ConnectionState.waiting:
                    {
                      return Center(child: CircularProgressIndicator());
                    }
                  case ConnectionState.done:
                    {
                      if (taskData.data != null) {
                        return Padding(
                          padding: EdgeInsets.all(8),
                          child: ListView.builder(
                            itemCount: taskData.data.length,
                            itemBuilder: (context, int index) {
                              String task =
                                  taskData.data[index]['task'].toString();
                              String day = DateTime.parse(
                                      taskData.data[index]['creationDate'])
                                  .day
                                  .toString();
                              return Card(
                                color: secColor,
                                child: InkWell(
                                  child: IntrinsicHeight(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(right: 12),
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: btnColor,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              day,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              task,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return Center(child: Text('No Tasks'));
                      }
                    }
                  default:
                }
                return Container();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: editorColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(8.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        flex: 5,
                        child: TextField(
                          controller: inputController,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'What needs to be done?',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                newTaskTxt = inputController.text;
                                inputController.clear();
                              });
                              Task newTask = Task(
                                  task: newTaskTxt, dateTime: DateTime.now());
                              DBProvider.dataBase.addNewTask(newTask);
                            },
                            child: Icon(
                              Icons.add,
                            ),
                          ),
                        ),
                      )
                    ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
