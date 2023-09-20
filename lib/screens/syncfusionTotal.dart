import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CombinedApp(),
    );
  }
}

class CombinedApp extends StatefulWidget {
  const CombinedApp({Key? key}) : super(key: key);

  @override
  CombinedAppState createState() => CombinedAppState();
}

class CombinedAppState extends State<CombinedApp> {
  List<_SalesData> chartData = [];
  List<_SalesData> chartDataForDisplay = [];
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  List<int> scores = []; // Firestore에서 가져온 점수 목록
  int filteredScore = 0; // 필터링된 점수 합계

  // Firestore에서 데이터 읽어오기
  Future<void> fetchDataFromFirestore() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('scores')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        scores = [];
        querySnapshot.docs.forEach((doc) {
          final score = doc['score'] as int;
          scores.add(score);
        });
        setState(() {
          filteredScore = _calculateFilteredScore();
        });
      }
    } catch (error) {
      print('Error fetching data from Firestore: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    // 초기 차트 데이터 생성
    chartData = _SalesData.generateRandomData(
        DateTime(2023, 9, 1), DateTime(2023, 9, 30));
    chartDataForDisplay.addAll(chartData);
    fetchDataFromFirestore(); // Firestore에서 데이터 읽어오기
  }

  List<_SalesData> getFilteredChartData() {
    if (_selectedStartDate == null || _selectedEndDate == null) {
      return chartData;
    } else {
      final filteredData = chartData.where((data) {
        final DateTime dataDate = data.year;
        return dataDate.isAfter(_selectedStartDate!) &&
            dataDate.isBefore(_selectedEndDate!);
      }).toList();
      return filteredData;
    }
  }

  void updateChartData() {
    if (_selectedStartDate != null && _selectedEndDate != null) {
      final startDate = _selectedStartDate!;
      final endDate = _selectedEndDate!.add(Duration(days: 1));
      final filteredData =
      _SalesData.generateRandomData(startDate, endDate);

      // Firebase Firestore에 데이터 추가
      FirebaseFirestore.instance
          .collection('chart_data')
          .doc('filtered_data')
          .set({'data': filteredData.map((data) => data.toMap()).toList()})
          .then((_) {
        setState(() {
          chartDataForDisplay.clear();
          chartDataForDisplay.addAll(filteredData);
        });
      }).catchError((error) {
        print('Error adding document: $error');
      });
    }
  }

  int _calculateFilteredScore() {
    if (_selectedStartDate == null || _selectedEndDate == null) {
      // 시작 날짜와 종료 날짜가 없으면 모든 점수를 합산
      return scores.fold(0, (sum, score) => sum + score);
    } else {
      // 시작 날짜와 종료 날짜 사이의 점수만 합산
      return scores
          .where((score) {
        final date = DateTime.fromMillisecondsSinceEpoch(score * 1000);
        return date.isAfter(_selectedStartDate!) &&
            date.isBefore(_selectedEndDate!);
      })
          .fold(0, (sum, score) => sum + score);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: SfCircularChart(
              series: <CircularSeries>[
                PieSeries<_SalesData, String>(
                  dataSource: chartDataForDisplay,
                  xValueMapper: (_SalesData sales, _) =>
                      sales.year.toLocal().toString(),
                  yValueMapper: (_SalesData sales, _) => sales.sales,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _selectedStartDate != null
                  ? Colors.green
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Selected Start Date: ${_selectedStartDate ?? "selected start date"}',
              style: TextStyle(
                fontSize: 16,
                color:
                _selectedStartDate != null ? Colors.white : Colors.black,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _selectedEndDate != null
                  ? Colors.green
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Selected End Date: ${_selectedEndDate ?? "select your end date"}',
              style: TextStyle(
                fontSize: 16,
                color:
                _selectedEndDate != null ? Colors.white : Colors.black,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Filtered Score: $filteredScore',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: SfCalendar(
              view: CalendarView.month,
              onLongPress: (calendarLongPressDetails) {
                setState(() {
                  if (_selectedStartDate == null ||
                      _selectedEndDate != null) {
                    _selectedStartDate = calendarLongPressDetails.date;
                    _selectedEndDate = null;
                  } else {
                    _selectedEndDate = calendarLongPressDetails.date;
                  }
                  print('Selected Start Date: $_selectedStartDate');
                  print('Selected End Date: $_selectedEndDate');
                  updateChartData();
                  // 필터링된 점수 업데이트
                  filteredScore = _calculateFilteredScore();
                });
              },
              viewHeaderStyle: ViewHeaderStyle(
                backgroundColor: Colors.blue,
              ),
              selectionDecoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  DateTime year;
  double sales;

  static List<_SalesData> generateRandomData(
      DateTime startDate, DateTime endDate) {
    final random = Random();
    final data = <_SalesData>[];
    for (var date = startDate;
    date.isBefore(endDate);
    date = date.add(Duration(days: 1))) {
      data.add(_SalesData(date, random.nextDouble() * 100));
    }
    return data;
  }

  // Firestore에서 데이터 읽어오기 위한 생성자
  factory _SalesData.fromMap(Map<String, dynamic> map) {
    return _SalesData(
      DateTime.parse(map['year']),
      map['sales'].toDouble(),
    );
  }

  // Firestore에 데이터 쓰기 위한 Map 변환
  Map<String, dynamic> toMap() {
    return {
      'year': year.toIso8601String(),
      'sales': sales,
    };
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    return meeting as Meeting;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
