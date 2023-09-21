import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DataPoint> dataPoints = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore(selectedDate);
  }

  Future<void> fetchDataFromFirestore(DateTime date) async {
    final CollectionReference scoresCollection =
    FirebaseFirestore.instance.collection('scores');

    final QuerySnapshot querySnapshot = await scoresCollection
        .where('date', isEqualTo: date)
        .get();

    List<DataPoint> fetchedData = []; // Firestore에서 가져온 데이터를 저장할 리스트

    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      final String subject = document['subject'];
      final double score = document['score'].toDouble();

      fetchedData.add(DataPoint(subject, score));
    }

    setState(() {
      dataPoints = fetchedData; // 데이터 업데이트
    });
  }

  Future<void> addRandomScoreToFirestore(DateTime date, String subject) async {
    final CollectionReference scoresCollection =
    FirebaseFirestore.instance.collection('scores');

    final random = Random();
    final double score = random.nextDouble() * 100;

    await scoresCollection.add({
      'date': date,
      'subject': subject,
      'score': score,
    });

    // Firestore에 데이터를 추가한 후에 데이터를 다시 가져옵니다.
    fetchDataFromFirestore(selectedDate);
  }

  Future<String?> showSubjectSelectionDialog(BuildContext context) async {
    String? selectedSubject;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Subject'),
          content: DropdownButton<String>(
            value: selectedSubject,
            items: ['국어', '영어', '수학'].map((String subject) {
              return DropdownMenuItem<String>(
                value: subject,
                child: Text(subject),
              );
            }).toList(),
            onChanged: (String? value) {
              selectedSubject = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(selectedSubject);
              },
            ),
          ],
        );
      },
    );

    return selectedSubject;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score Dashboard'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SfCalendar(
              view: CalendarView.month,
              initialSelectedDate: selectedDate,
              onTap: (CalendarTapDetails details) async {
                if (details.date != null) {
                  setState(() {
                    selectedDate = details.date!;
                  });

                  String? selectedSubject =
                  await showSubjectSelectionDialog(context);

                  if (selectedSubject != null) {
                    addRandomScoreToFirestore(selectedDate, selectedSubject);
                  }
                }
              },
            ),
          ),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              series: <ChartSeries>[
                ColumnSeries<DataPoint, String>(
                  dataSource: dataPoints,
                  xValueMapper: (DataPoint data, _) => data.subject,
                  yValueMapper: (DataPoint data, _) => data.score,
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DataPoint {
  final String subject;
  final double score;

  DataPoint(this.subject, this.score);
}
