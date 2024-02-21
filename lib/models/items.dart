class ToDo {
  String? id;
  String? todoText;
  bool isDone;
  DateTime? dateTime;
  DateTime? timestamp;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
    this.dateTime,
    this.timestamp,
  });

  static List<ToDo> todoList() {
    return [
      ToDo(
        id: '01',
        todoText: "Morning Exercises",
        isDone: true,
        dateTime: DateTime.now(),
        timestamp: DateTime.now(),
      ),
      ToDo(
        id: '02',
        todoText: "Buy Groceries",
        isDone: false,
        dateTime: DateTime.now(),
        timestamp: DateTime.now(),
      ),
      ToDo(
        id: '03',
        todoText: "Gym",
        isDone: true,
        dateTime: DateTime.now(),
        timestamp: DateTime.now(),
      ),
      ToDo(
        id: '04',
        todoText: "Team building",
        isDone: true,
        dateTime: DateTime.now(),
        timestamp: DateTime.now(),
      ),
      ToDo(
        id: '05',
        todoText: "Working",
        isDone: true,
        dateTime: DateTime.now(),
        timestamp: DateTime.now(),
      ),
      ToDo(
        id: '06',
        todoText: "Dinner",
        isDone: true,
        dateTime: DateTime.now(),
        timestamp: DateTime.now(),
      ),
    ];
  }
}
