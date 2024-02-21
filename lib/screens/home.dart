// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_todo_app/constants/color.dart';
import '../widgets/todo_items.dart';
import '../models/items.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<ToDo> todoList = ToDo.todoList();
  List<ToDo> _foundItems = [];
  final TextEditingController todoController = TextEditingController();
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Today', 'Upcoming'];

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                searchBox(),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 50, bottom: 20),
                            child: Text(
                              "To do list",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 50, bottom: 20, left: 120),
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
                      _foundItems.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 150),
                                child: Expanded(
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
                              ),
                            )
                          : Expanded(
                              child: ListView(
                                children: _foundItems.reversed.map((todo) {
                                  return TodoItems(
                                    todo: todo,
                                    onToDoChanged: _handleToDoChange,
                                    onDeleteItem: _handleToDoDelete,
                                  );
                                }).toList(),
                              ),
                            ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showAddToDoDialog(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 34, 140, 246),
                    ),
                  ),
                  child: const Text(
                    "+ Add a new task",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
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
    });
    todoController.clear();
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

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add a new task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      newTask = value;
                    },
                    decoration:
                        const InputDecoration(labelText: 'Task description'),
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
                              pickedDateText =
                                  DateFormat('dd/MM/yyyy').format(pickedDate);
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
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          //  print(selectedTime);
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
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addToDoItem(newTask, selectedDate, selectedTime);
                    Navigator.of(context).pop();
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
