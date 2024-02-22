import 'package:flutter/material.dart';
import 'package:flutter_todo_app/screens/home.dart';
import 'package:flutter_todo_app/widgets/local_noti.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotifications.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Todo app",
      home: Home(),
      // routes: {
      //   '/home': (context) => const Home(),
      // },
    );
  }
}
