import 'package:flutter/material.dart';
import 'package:fluttertil/screens/syncfusionTotal.dart';
// ignore: unused_import
import 'package:fluttertil/screens/syncfusion_flutter_calendar.dart';
import 'package:fluttertil/screens/syncfusion_flutter_charts.dart';
// ignore: unused_import
import 'package:fluttertil/routes/my_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BottomNavBar',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [MyAppHome(), CalendarApp(), CombinedApp()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ourtimes'),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ChartApp',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'CalendarApp',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'TotalApp',
          ),
        ],
      ),
    );
  }
}