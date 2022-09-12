import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:my_todo_app/pages/center.dart';
import 'package:my_todo_app/pages/edit_todo.dart';
import 'package:my_todo_app/pages/home.dart';
import 'package:my_todo_app/pages/login.dart';
import 'package:my_todo_app/pages/register.dart';
import 'package:my_todo_app/request/api.dart';
import 'package:my_todo_app/store/controller.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: [
        GetPage(name: "/", page: () => const MainPage()),
        GetPage(name: "/home", page: () => const Home()),
        GetPage(name: "/center", page: () => CenterPage()),
        GetPage(name: "/edit", page: () => const EditTodo()),
        GetPage(name: "/login", page: () => LoginPage()),
        GetPage(name: "/register", page: () => RegisterPage()),
      ],
      home: const MainPage(),
      // initialRoute: "/login",
      theme: ThemeData(primarySwatch: Colors.red),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _currentIndex = 0;
  final List<Widget> _pages = [const Home(), CenterPage()];

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => StoreController());
    Get.lazyPut(() => GlobalApi(), fenix: true);

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "首页"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "我的"),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
