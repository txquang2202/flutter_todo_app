// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_todo_app/constants/color.dart';
import '../widgets/todo_items.dart';
import '../models/items.dart';
import 'package:intl/intl.dart';
import 'package:flutter_todo_app/widgets/local_noti.dart';

class Home extends StatefulWidget {
  final String? payload;
  const Home({Key? key, this.payload}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<ToDo> todoList = ToDo.todoList();
  List<ToDo> _foundItems = [];
  final TextEditingController todoController = TextEditingController();
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Today', 'Upcoming'];
  final bool _showAddButton = true;

  @override
  void initState() {
    _foundItems = todoList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BGColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  searchBox(),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "To do list",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          //  margin: const EdgeInsets.only(top: 50, bottom: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: DropdownButton<String>(
                            value: selectedFilter,
                            alignment: Alignment.center,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedFilter = newValue!;
                                _filterToDoList(newValue);
                              });
                            },
                            items: filters.map<DropdownMenuItem<String>>(
                              (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _foundItems.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 150),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.info,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Nothing here!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: _foundItems.reversed.map((todo) {
                            return TodoItems(
                              todo: todo,
                              onToDoChanged: _handleToDoChange,
                              onDeleteItem: _handleToDoDelete,
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),
          if (_showAddButton)
            Container(
              padding: EdgeInsets.only(bottom: 10),
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  _showAddToDoDialog(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 34, 140, 246),
                  ),
                ),
                child: Text(
                  "+ Add a new task",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: BGColor,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.menu, size: 30),
          // ignore: sized_box_for_whitespace
          SizedBox(
            height: 40,
            width: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image(
                image: AssetImage('images/elmduy.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _filterToDoList(String filter) {
    setState(() {
      if (filter == 'Today') {
        _foundItems = todoList
            .where((item) => item.dateTime != null && isToday(item.dateTime!))
            .toList();
      } else if (filter == 'Upcoming') {
        _foundItems = todoList
            .where((item) => item.dateTime?.isAfter(DateTime.now()) ?? false)
            .toList();
      } else {
        _foundItems = todoList;
      }
    });
  }

  void _addToDoItem(
      String toDo, DateTime selectedDate, TimeOfDay selectedTime) {
    setState(() {
      todoList.add(ToDo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        todoText: toDo,
        dateTime: selectedDate,
        timestamp: DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, selectedTime.hour, selectedTime.minute),
      ));
      _itemFilter("");
    });
    todoController.clear();

    LocalNotifications.showNotification(
      title: toDo,
      body: "Your task is due soon!",
      payload: "This is schedule data",
      scheduledDate: DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, selectedTime.hour, selectedTime.minute),
    );
  }

  void _handleToDoDelete(String id) {
    setState(() {
      todoList.removeWhere((item) => item.id == id);
      _itemFilter("");
    });
  }

  void _itemFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todoList.where((item) {
        if (selectedFilter == 'Today') {
          return item.dateTime != null && isToday(item.dateTime!);
        } else if (selectedFilter == 'Upcoming') {
          return item.dateTime?.isAfter(DateTime.now()) ?? false;
        }
        return true;
      }).toList();
    } else {
      results = todoList.where((item) {
        final textMatch =
            item.todoText!.toLowerCase().contains(enteredKeyword.toLowerCase());
        if (selectedFilter == 'Today') {
          return textMatch && item.dateTime != null && isToday(item.dateTime!);
        } else if (selectedFilter == 'Upcoming') {
          return textMatch && (item.dateTime?.isAfter(DateTime.now()) ?? false);
        }
        return textMatch;
      }).toList();
    }
    setState(() {
      _foundItems = results;
    });
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _itemFilter(value),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(Icons.search, color: Colors.black, size: 20),
          prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: BGColor),
        ),
      ),
    );
  }

  Future<void> _showAddToDoDialog(BuildContext context) async {
    String newTask = '';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String pickedDateText = 'Pick a date';
    String pickedTimeText = 'Pick a time';

    final screenWidth = MediaQuery.of(context).size.width;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(
                'Add a new task',
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                // ignore: sized_box_for_whitespace
                child: Container(
                  width: screenWidth > 600 ? 400 : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        onChanged: (value) {
                          newTask = value;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Task description',
                          hintText: 'Enter task description',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null &&
                                  pickedDate != selectedDate) {
                                setState(() {
                                  selectedDate = pickedDate;
                                  pickedDateText = DateFormat('dd/MM/yyyy')
                                      .format(pickedDate);
                                });
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromARGB(255, 246, 246, 246),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month),
                                const SizedBox(width: 5),
                                Text(pickedDateText),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8.8),
                          TextButton(
                            onPressed: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (pickedTime != null &&
                                  pickedTime != selectedTime) {
                                setState(() {
                                  selectedTime = pickedTime;
                                  pickedTimeText = pickedTime.format(context);
                                });
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromARGB(255, 246, 246, 246),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.alarm),
                                const SizedBox(width: 5),
                                Text(pickedTimeText),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (newTask.isNotEmpty) {
                      _addToDoItem(newTask, selectedDate, selectedTime);
                      // LocalNotifications.showNotification(
                      //     title: newTask,
                      //     body: "This is a Schedule Notification",
                      //     payload: "This is schedule data");
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Task description cannot be empty',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add task'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
