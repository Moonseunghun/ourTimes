import 'package:flutter/material.dart';
import 'package:fluttertil/screens/syncfusionTotal.dart';
// ignore: unused_import
import 'package:fluttertil/screens/syncfusion_flutter_calendar.dart';
import 'package:fluttertil/screens/syncfusion_flutter_charts.dart';
// ignore: unused_import
import 'package:fluttertil/routes/my_routes.dart';
import 'package:fluttertil/screens/login_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//파이어베이스 초기화
// await Firebase.initializeApp(
//   options: FirebaseOptions(
//     apiKey: 'AIzaSyAaZQsSVz3Qgzh5biqkTkUDeWoCM0PFcc8',
//     authDomain: 'https://ourtimes-fd937-default-rtdb.firebaseio.com',
//     projectId: 'ourtimes-fd937',
//     storageBucket: 'ourtimes-fd937.appspot.com',
//     messagingSenderId: '733610952290',
//     appId: '1:733610952290:android:4a7564a65ff667dd84333b',
//     // measurementId: 'YOUR_MEASUREMENT_ID',
//   ),
// );


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
      home: LogIn(),

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

  final List<Widget> _pages = [MyAppHome(), CalendarApp(), CombinedApp() , AddInputScreen() ,  FirestoreDataViewer(),];

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
            icon: Icon(Icons.add), // 새로 추가한 아이콘
            label: 'Add Input',
          ),
        ],
      ),
    );
  }
}

class AddInputScreen extends StatefulWidget {
  @override
  _AddInputScreenState createState() => _AddInputScreenState();
}

class _AddInputScreenState extends State<AddInputScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _displayText = ""; // 데이터를 표시할 변수

  Future<void> _submitData(String inputText) async {
    try {
      final collection = FirebaseFirestore.instance.collection('messages');
      await collection.add({
        'text': inputText,
        'timestamp': FieldValue.serverTimestamp(),
      });
      // 데이터가 성공적으로 추가되었습니다.
      print('Data submitted successfully.');
      // 입력 필드 초기화
      _inputController.clear();
      // 데이터 표시 업데이트
      setState(() {
        _displayText = inputText;
      });
    } catch (e) {
      // 오류 처리
      print('Error submitting data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            // 데이터를 표시할 Text 위젯
            _displayText,
            style: TextStyle(fontSize: 18),
          ),
          TextField(
            controller: _inputController,
            decoration: InputDecoration(
              labelText: 'Enter something',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final inputText = _inputController.text;
              if (inputText.isNotEmpty) {
                _submitData(inputText);
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class FirestoreDataViewer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null) {
          return Text('No data available.');
        } else {
          final data = snapshot.data!.docs;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final document = data[index];
              final text = document['text'];
              final timestamp = document['timestamp'];
              return ListTile(
                title: Text(text),
                subtitle: Text('Timestamp: $timestamp'),
              );
            },
          );
        }
      },
    );
  }
}
