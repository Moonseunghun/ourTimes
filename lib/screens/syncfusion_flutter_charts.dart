import 'dart:math';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyAppHome(),
    );
  }
}

class MyAppHome extends StatefulWidget {
  const MyAppHome({Key? key}) : super(key: key);

  @override
  _MyAppHomeState createState() => _MyAppHomeState();
}

class _MyAppHomeState extends State<MyAppHome> {
  DateTime? _selectedStartDate; // Nullable
  DateTime? _selectedEndDate; // Nullable
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Appointment>> _events = {}; // Nullable
  DateTimeRange? _selectedDateRange; // 추가: 선택한 범위의 날짜

  @override
  void initState() {
    super.initState();
    _initializeEvents();
  }

  void _initializeEvents() {
    // Initialize your events data here
    _events = {
      DateTime(2023, 9, 1): [
        Appointment(
          'Event A',
          85, // 국어 점수
          90, // 영어 점수
          78, // 수학 점수
        ),
        Appointment(
          'Event B',
          88, // 국어 점수
          84, // 영어 점수
          76, // 수학 점수
        ),
      ],
      DateTime(2023, 9, 2): [
        Appointment(
          'Event C',
          90, // 국어 점수
          92, // 영어 점수
          80, // 수학 점수
        ),
      ],
      // Add more events here
    };
  }

  Future<void> saveSelectedDateRange(
      DateTimeRange dateRange, Map<String, Map<String, int>> dailyScores) async {
    final collection = FirebaseFirestore.instance.collection('score_data');
    final startDate = dateRange.start;
    final endDate = dateRange.end;

    // 선택한 범위에 해당하는 데이터를 Firestore에 저장
    await collection.doc('selected_range').set({
      'start_date': startDate,
      'end_date': endDate,
    });

    // 일별 점수 데이터를 Firestore에 저장
    for (final entry in dailyScores.entries) {
      final date = entry.key;
      final scores = entry.value;

      await collection.doc('daily_scores').collection(date).doc('scores').set({
        'scores': scores,
      });
    }
  }

  Future<DateTimeRange?> loadSelectedDateRange() async {
    final collection = FirebaseFirestore.instance.collection('score_data');
    final document = await collection.doc('selected_range').get();
    if (document.exists) {
      final startDate = (document['start_date'] as Timestamp).toDate();
      final endDate = (document['end_date'] as Timestamp).toDate();
      return DateTimeRange(start: startDate, end: endDate);
    } else {
      return null;
    }
  }

  Future<Map<String, Map<String, int>>> loadDailyScores(
      DateTime startDate, DateTime endDate) async {
    final collection = FirebaseFirestore.instance.collection('score_data').doc('daily_scores').collection('scores');
    final querySnapshot = await collection.where('date', isGreaterThanOrEqualTo: startDate, isLessThanOrEqualTo: endDate).get();
    final dailyScores = <String, Map<String, int>>{};
    for (final doc in querySnapshot.docs) {
      final date = doc['date'] as String;
      final scores = Map<String, int>.from(doc['scores']);
      dailyScores[date] = scores;
    }
    return dailyScores;
  }

  // 선택한 범위가 유효한 경우에만 _selectedDateRange를 설정하고 오류 처리를 추가합니다.
  void _handleDateRangeSelection(
      DateTime? start, DateTime? end, DateTime focusedDay) async {
    setState(() {
      if (start != null && end != null) {
        if (!start.isAfter(end)) {
          _selectedStartDate = start;
          _selectedEndDate = end;
          _focusedDay = focusedDay;
          _selectedDateRange = DateTimeRange(
            start: start,
            end: end,
          );
        } else {
          // 오류 처리: start가 end보다 늦을 경우
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Invalid Date Range'),
                content: Text('시작한 날짜 보다 끝나는 날짜가 끝나는 날짜가 늦습니다 다시 선택해주세요'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('확인'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        // 오류 처리: start 또는 end가 null인 경우
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Invalid Date Range'),
              content: Text('날짜 범위를 선택하세요'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2023, 1, 1),
            lastDay: DateTime(2023, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            eventLoader: (date) => _events[date] ?? [],
            // 수정된 부분: onRangeSelected 콜백 함수 대신 _handleDateRangeSelection 함수를 호출합니다.
            onRangeSelected: (start, end, focusedDay) async {
              final dateRange = DateTimeRange(start: start!, end: end!);
              final dailyScores = await loadDailyScores(start, end);
              await saveSelectedDateRange(dateRange, dailyScores);
              setState(() {
                _handleDateRangeSelection(start, end, focusedDay);
              });
            },
            // 수정된 부분: calendarBuilders를 사용하여 기간 범위 색상을 설정합니다.
            calendarBuilders: CalendarBuilders(
              selectedBuilder: (context, date, focusedDate) {
                // 기간 범위에 포함된 날짜인 경우 선택된 스타일을 적용
                if (_selectedDateRange != null &&
                    date.isAfter(_selectedDateRange!.start.subtract(Duration(days: 1))) &&
                    date.isBefore(_selectedDateRange!.end.add(Duration(days: 1)))) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue, // 원하는 색상으로 변경
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                } else {
                  return null; // 다른 날짜는 기본 스타일을 사용
                }
              },
              todayBuilder: (context, date, focusedDate) {
                // 오늘 날짜 스타일 지정
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.red, // 오늘 날짜의 배경색을 변경
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Selected Period: ${_selectedStartDate?.toLocal() ?? ''} - ${_selectedEndDate?.toLocal() ?? ''}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              title: ChartTitle(text: 'Daily Scores'),
              legend: const Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<_DailyScoreData, String>>[
                if (_selectedStartDate != null && _selectedEndDate != null)
                  LineSeries<_DailyScoreData, String>(
                    dataSource: getChartDataForDateRange(
                        _selectedStartDate, _selectedEndDate),
                    xValueMapper: (_DailyScoreData score, _) {
                      return score.day;
                    },
                    yValueMapper: (_DailyScoreData score, _) {
                      return score.koreanScore;
                    },
                    name: '국어',
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                if (_selectedStartDate != null && _selectedEndDate != null)
                  LineSeries<_DailyScoreData, String>(
                    dataSource: getChartDataForDateRange(
                        _selectedStartDate, _selectedEndDate),
                    xValueMapper: (_DailyScoreData score, _) => score.day,
                    yValueMapper: (_DailyScoreData score, _) =>
                    score.englishScore,
                    name: '영어',
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                if (_selectedStartDate != null && _selectedEndDate != null)
                  LineSeries<_DailyScoreData, String>(
                    dataSource: getChartDataForDateRange(
                        _selectedStartDate, _selectedEndDate),
                    xValueMapper: (_DailyScoreData score, _) => score.day,
                    yValueMapper: (_DailyScoreData score, _) => score.mathScore,
                    name: '수학',
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final dateRange = await loadSelectedDateRange();
              final dailyScores = await loadDailyScores(
                  dateRange!.start, dateRange.end);
              // 선택한 범위와 일별 점수를 사용하여 원하는 작업을 수행
              // 예: Firestore에서 불러온 데이터를 활용한 작업 수행
              print('Selected Date Range: $dateRange');
              print('Daily Scores: $dailyScores');
            },
            child: Text('데이터 불러오기'),
          ),
        ],
      ),
    );
  }

  // Day cell widget with background color
  Widget _buildDayCell(DateTime date, bool isSelected) {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return Container(
      color: isSelected ? Colors.blue : null,
      child: Center(
        child: Text(
          date.day.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : null,
          ),
        ),
      ),
    );
  }

  List<_DailyScoreData> getChartDataForDateRange(
      DateTime? startDate, DateTime? endDate) {
    final List<_DailyScoreData> filteredData = [];

    if (startDate == null || endDate == null) {
      return filteredData;
    }

    for (DateTime date = startDate;
    date.isBefore(endDate.add(Duration(days: 1)));
    date = date.add(Duration(days: 1))) {
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final events = _events[date] ?? [];
      final koreanScore = events.isEmpty
          ? 0
          : events.map((event) => event.koreanScore.toDouble()).reduce((a, b) => a + b);

      final englishScore = events.isEmpty
          ? 0
          : events.map((event) => event.englishScore.toDouble()).reduce((a, b) => a + b);

      final mathScore = events.isEmpty
          ? 0
          : events.map((event) => event.mathScore.toDouble()).reduce((a, b) => a + b);


      filteredData.add(
          _DailyScoreData(dateString, koreanScore.toDouble(), englishScore.toDouble(), mathScore.toDouble()));

    }

    return filteredData;
  }
}

class _DailyScoreData {
  _DailyScoreData(
      this.day,
      this.koreanScore,
      this.englishScore,
      this.mathScore,
      );

  final String day;
  final double koreanScore;
  final double englishScore;
  final double mathScore;
}

class Appointment {
  final String eventName;
  final double koreanScore;
  final double englishScore;
  final double mathScore;

  Appointment(
      this.eventName,
      this.koreanScore,
      this.englishScore,
      this.mathScore,
      );
}
