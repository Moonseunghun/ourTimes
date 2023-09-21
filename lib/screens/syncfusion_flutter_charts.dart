import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyAppHome(),
    );
  }
}

class MyAppHome extends StatefulWidget {
  @override
  _MyAppHomeState createState() => _MyAppHomeState();
}

class _MyAppHomeState extends State<MyAppHome> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DataPoint> dataPoints = [];
  String selectedSubject = ''; // 사용자가 선택한 과목을 추적합니다.

  @override
  Widget build(BuildContext context) {
    final subjects = ['국어', '영어', '수학', '과학'];

    return Scaffold(
      appBar: null, // 상단 바 제거
      bottomNavigationBar: null, // 바텀 위젯 제거
      body: Column(
        children: [
          SfCalendar(
            view: CalendarView.month,
            onTap: (calendarTapDetails) async {
              // 날짜를 선택하면 랜덤한 과목과 점수를 Firestore에 저장합니다.
              final selectedDate = calendarTapDetails.date!;
              final randomSubject = subjects[Random().nextInt(subjects.length)];
              final randomScore = Random().nextInt(101); // 0에서 100 사이의 랜덤한 점수

              try {
                // Firestore에 데이터 저장 (색상은 저장하지 않음)
                await firestore.collection('scores').add({
                  'date': selectedDate.toString(),
                  'subject': randomSubject,
                  'score': randomScore,
                });
              } catch (e) {
                print('Firestore에 데이터 저장 중 오류 발생: $e');
              }
            },
          ),
          // 과목 선택 버튼 목록
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: subjects.map((subject) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedSubject = subject;
                  });
                },
                child: Text(subject),
              );
            }).toList(),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('scores').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                dataPoints.clear();
                final scores = snapshot.data!.docs;
                for (var score in scores) {
                  final subject = score['subject'];
                  final scoreValue = score['score'];

                  // 필터링된 데이터만 추가합니다.
                  if (subject != null && scoreValue != null && subject == selectedSubject) {
                    final randomColor = Color.fromRGBO(
                      Random().nextInt(256),
                      Random().nextInt(256),
                      Random().nextInt(256),
                      1.0,
                    );

                    dataPoints.add(DataPoint(
                      subject: subject,
                      score: scoreValue,
                      color: randomColor,
                    ));
                  }
                }

                return SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  series: <ChartSeries<DataPoint, String>>[
                    LineSeries<DataPoint, String>(
                      dataSource: dataPoints,
                      xValueMapper: (DataPoint data, _) => data.subject,
                      yValueMapper: (DataPoint data, _) => data.score,
                      pointColorMapper: (DataPoint data, _) => data.color,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DataPoint {
  DataPoint({required this.subject, required this.score, required this.color});

  final String subject;
  final int score;
  final Color color;
}
