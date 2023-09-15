import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
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
          DateTime(2023, 9, 1, 9, 20),
          DateTime(2023, 9, 1, 10, 30),
          85, // 국어 점수
          90, // 영어 점수
          78, // 수학 점수
        ),
        Appointment(
          'Event B',
          DateTime(2023, 9, 1, 11, 20),
          DateTime(2023, 9, 1, 12, 30),
          88, // 국어 점수
          84, // 영어 점수
          76, // 수학 점수
        ),
      ],
      DateTime(2023, 9, 2): [
        Appointment(
          'Event C',
          DateTime(2023, 9, 2, 14, 40),
          DateTime(2023, 9, 2, 15, 60),
          90, // 국어 점수
          92, // 영어 점수
          80, // 수학 점수
        ),
      ],
      // Add more events here
    };
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
            eventLoader: (date) => _events[date] ?? [], // Null check here
            onRangeSelected: (start, end, focusedDay) {
              setState(() {
                _selectedStartDate = start;
                _selectedEndDate = end;
                _focusedDay = focusedDay;
                _selectedDateRange = DateTimeRange(start: start!, end: end!);
              });
            },
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
        ],
      ),
    );
  }

  // Day cell widget with background color
  Widget _buildDayCell(DateTime date, bool isSelected) {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return Container(
      color: isSelected ? Colors.blue : null, // 배경색 적용
      child: Center(
        child: Text(
          date.day.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : null, // 선택된 경우 텍스트 색상 변경
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
          : events
              .map((event) => event.koreanScore.toInt())
              .reduce((a, b) => a + b);
      final englishScore = events.isEmpty
          ? 0
          : events
              .map((event) => event.englishScore.toInt())
              .reduce((a, b) => a + b);
      final mathScore = events.isEmpty
          ? 0
          : events
              .map((event) => event.mathScore.toInt())
              .reduce((a, b) => a + b);

      filteredData.add(
          _DailyScoreData(dateString, koreanScore, englishScore, mathScore));
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
  final int koreanScore;
  final int englishScore;
  final int mathScore;
}

class Appointment {
  final String eventName;
  final DateTime startTime;
  final DateTime endTime;
  final double koreanScore;
  final double englishScore;
  final double mathScore;

  Appointment(this.eventName, this.startTime, this.endTime, this.koreanScore,
      this.englishScore, this.mathScore);
}
