import 'package:flutter/material.dart';
import 'package:fluttertil/screens/syncfusionTotal.dart';
import 'package:fluttertil/screens/syncfusion_flutter_calendar.dart';
import 'package:fluttertil/screens/syncfusion_flutter_charts.dart';
import 'package:fluttertil/screens/login_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertil/screens/realtime_db_data_viewer.dart';
import 'package:firebase_database/firebase_database.dart'; // Firebase Realtime Database에 필요한 패키지 추가
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:fluttertil/screens/add_input_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BottomNavBar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
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

  final List<Widget> _pages = [
    MyAppHome(),
    CalendarApp(),
    CombinedApp(),
    RealtimeDbDataViewer(), // Firebase Realtime Database 데이터 뷰어 추가
    FirestoreDataViewer(),
  ];

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
          BottomNavigationBarItem(
            icon: Icon(Icons.message), // Firebase Realtime Database 데이터 뷰어 아이콘
            label: 'Realtime DB',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud), // Firestore 데이터 뷰어 아이콘
            label: 'Firestore',
          ),
        ],
      ),
    );
  }
}
