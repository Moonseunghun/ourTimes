import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() {
  return runApp(_CalendarApp());
}

class _CalendarApp extends StatelessWidget {
  const _CalendarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalendarApp(),
    );
  }
}

class CalendarApp extends StatefulWidget {
  const CalendarApp({Key? key}) : super(key: key);

  @override
  CalendarAppState createState() => CalendarAppState();
}

class CalendarAppState extends State<CalendarApp> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        view: CalendarView.month,
        onLongPress: (calendarLongPressDetails) {
          setState(() {
            if (_selectedStartDate == null || _selectedEndDate != null) {
              _selectedStartDate = calendarLongPressDetails.date!;
              _selectedEndDate = null;
            } else {
              _selectedEndDate = calendarLongPressDetails.date!;
            }
            print('Selected Start Date: $_selectedStartDate');
            print('Selected End Date: $_selectedEndDate');
          });
        },
        dataSource: MeetingDataSource(_getDataSource()),
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
      ),
    );
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime = DateTime(today.year, today.month, today.day, 9);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting(
        'work today', startTime, endTime, const Color(0xFF0F8644), false));

    // 선택한 기간에 해당하는 회의를 생성하여 추가합니다.
    if (_selectedStartDate != null && _selectedEndDate != null) {
      final DateTime selectedStartTime = _selectedStartDate!;
      final DateTime selectedEndTime = _selectedEndDate!;
      meetings.add(Meeting('selected period', selectedStartTime,
          selectedEndTime, Colors.blue, false));
    }

    return meetings;
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

    return meetingData;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  /// Event name which is equivalent to the subject property of [Appointment].
  String eventName;

  /// From which is equivalent to the start time property of [Appointment].
  DateTime from;

  /// To which is equivalent to the end time property of [Appointment].
  DateTime to;

  /// Background which is equivalent to the color property of [Appointment].
  Color background;

  /// IsAllDay which is equivalent to the isAllDay property of [Appointment].
  bool isAllDay;
}
