import 'dart:math'; // Random 클래스를 사용하기 위해 수학 라이브러리를 임포트합니다.
import 'package:flutter/material.dart'; // Flutter UI 라이브러리를 임포트합니다.
import 'package:syncfusion_flutter_charts/charts.dart'; // Syncfusion 차트 라이브러리를 임포트합니다.
import 'package:syncfusion_flutter_calendar/calendar.dart'; // Syncfusion 캘린더 라이브러리를 임포트합니다.

void main() {
  runApp(const MyApp()); // 앱 실행을 시작합니다.
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue), // 앱의 테마를 설정합니다.
      home: const CombinedApp(), // 홈 화면으로 CombinedApp 위젯을 사용합니다.
    );
  }
}

class CombinedApp extends StatefulWidget {
  const CombinedApp({Key? key}) : super(key: key);

  @override
  CombinedAppState createState() =>
      CombinedAppState(); // CombinedApp 위젯의 상태를 관리할 CombinedAppState를 생성합니다.
}

class CombinedAppState extends State<CombinedApp> {
  List<_SalesData> chartData = []; // 차트 데이터를 저장할 리스트입니다.
  List<_SalesData> chartDataForDisplay = []; // 표시할 차트 데이터를 저장할 리스트입니다.

  DateTime? _selectedStartDate; // 선택한 시작 날짜를 저장합니다.
  DateTime? _selectedEndDate; // 선택한 끝 날짜를 저장합니다.

  @override
  void initState() {
    super.initState();
    // 초기 차트 데이터 생성
    chartData = _SalesData.generateRandomData(DateTime(2023, 9, 1),
        DateTime(2023, 9, 30)); // 초기 차트 데이터를 생성하고 리스트에 추가합니다.
    chartDataForDisplay.addAll(chartData); // 표시할 차트 데이터 리스트에 추가합니다.
  }

  List<_SalesData> getFilteredChartData() {
    if (_selectedStartDate == null || _selectedEndDate == null) {
      return chartData; // 선택한 날짜가 없으면 전체 데이터를 반환합니다.
    } else {
      final filteredData = chartData.where((data) {
        final DateTime dataDate = data.year;
        return dataDate.isAfter(_selectedStartDate!) &&
            dataDate.isBefore(_selectedEndDate!);
      }).toList(); // 선택한 날짜 범위에 해당하는 데이터만 필터링합니다.
      return filteredData; // 필터링된 데이터를 반환합니다.
    }
  }

  void updateChartData() {
    if (_selectedStartDate != null && _selectedEndDate != null) {
      final startDate = _selectedStartDate!;
      final endDate = _selectedEndDate!.add(Duration(days: 1));
      final filteredData = _SalesData.generateRandomData(startDate, endDate);
      setState(() {
        chartDataForDisplay.clear();
        chartDataForDisplay
            .addAll(filteredData); // 선택한 날짜 범위에 따라 차트 데이터를 업데이트합니다.
      });
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
                  : Colors.transparent, // 선택한 시작 날짜에 따라 색상을 변경하는 컨테이너입니다.
              borderRadius: BorderRadius.circular(10), // 컨테이너의 모서리를 둥글게 만듭니다.
            ),
            child: Text(
              'Selected Start Date: ${_selectedStartDate ?? "selected start date"}',
              style: TextStyle(
                fontSize: 16,
                color: _selectedStartDate != null ? Colors.white : Colors.black,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _selectedEndDate != null
                  ? Colors.green
                  : Colors.transparent, // 선택한 끝 날짜에 따라 색상을 변경하는 컨테이너입니다.
              borderRadius: BorderRadius.circular(10), // 컨테이너의 모서리를 둥글게 만듭니다.
            ),
            child: Text(
              'Selected End Date: ${_selectedEndDate ?? "select your end date"}',
              style: TextStyle(
                fontSize: 16,
                color: _selectedEndDate != null ? Colors.white : Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: SfCalendar(
              view: CalendarView.month,
              onLongPress: (calendarLongPressDetails) {
                setState(() {
                  if (_selectedStartDate == null || _selectedEndDate != null) {
                    _selectedStartDate = calendarLongPressDetails.date;
                    _selectedEndDate = null;
                  } else {
                    _selectedEndDate = calendarLongPressDetails.date;
                  }
                  print('Selected Start Date: $_selectedStartDate');
                  print('Selected End Date: $_selectedEndDate');
                  updateChartData(); // 캘린더에서 날짜를 선택하여 차트를 업데이트합니다.
                });
              },
              viewHeaderStyle: ViewHeaderStyle(
                backgroundColor: Colors.blue, // 달력 머리글의 배경색을 설정합니다.
              ),
              selectionDecoration: BoxDecoration(
                color: Colors.lightBlueAccent, // 선택한 날짜의 배경색을 설정합니다.
                shape: BoxShape.circle, // 선택한 날짜의 모양을 원형으로 설정합니다.
              ),
              dataSource: MeetingDataSource(_getDataSource()),
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime = DateTime(today.year, today.month, today.day, 9);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting(
        'Work Today', startTime, endTime, const Color(0xFF0F8644), false));
    return meetings; // 캘린더에 표시할 회의 데이터를 생성하고 반환합니다.
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final DateTime year;
  final double sales;

  static List<_SalesData> generateRandomData(
      DateTime startDate, DateTime endDate) {
    final random = Random();
    final data = <_SalesData>[];
    for (var date = startDate;
        date.isBefore(endDate);
        date = date.add(Duration(days: 1))) {
      data.add(_SalesData(date, random.nextDouble() * 100));
    }
    return data; // 무작위로 생성된 차트 데이터를 반환합니다.
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
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }
    return meetingData; // 캘린더 데이터 소스에서 회의 데이터를 반환합니다.
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
