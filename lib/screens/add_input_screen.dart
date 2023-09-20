import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

void main() {
  runApp(FirestoreDataViewerApp());
}

class FirestoreDataViewerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore 데이터 뷰어',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirestoreDataViewer(),
    );
  }
}

class FirestoreDataViewer extends StatefulWidget {
  @override
  _FirestoreDataViewerState createState() => _FirestoreDataViewerState();
}

class _FirestoreDataViewerState extends State<FirestoreDataViewer> {
  final TextEditingController _dataTextFieldController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DataModel> dataTypeList = [];
  List<int> filteredScores = []; // 필터링된 국영수 점수 목록

  @override
  void initState() {
    super.initState();
    _loadDataFromFirestore();
  }

  Future<void> _addDataToFirestore(String dataType) async {
    await _firestore.collection('message').add({'dataType': dataType});
    _loadDataFromFirestore();
  }

  Future<void> _loadDataFromFirestore() async {
    QuerySnapshot querySnapshot = await _firestore.collection('message').get();

    setState(() {
      dataTypeList = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DataModel(
          id: doc.id,
          dataType: data['dataType'] ?? '',
          date: data['date'] != null ? (data['date'] as Timestamp).toDate() : DateTime.now(), // 날짜 설정
        );
      }).toList();
    });
  }

  Future<void> _deleteDataFromFirestore(String id) async {
    await _firestore.collection('message').doc(id).delete();
    _loadDataFromFirestore();
  }

  Future<void> _updateDataInFirestore(String id, String newText) async {
    try {
      final documentReference = _firestore.collection('message').doc(id);

      // 데이터를 업데이트합니다.
      await documentReference.update({
        'dataType': newText,
      });

      // 업데이트 후 데이터를 다시 불러옵니다.
      _loadDataFromFirestore();
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  // 국영수 점수를 필터링하는 함수
  void filterScores(DateTime startDate, DateTime endDate) {
    setState(() {
      // 기존 점수 목록을 초기화
      filteredScores.clear();

      // 필터링된 점수를 계산하여 추가
      for (var data in dataTypeList) {
        // data에서 국영수 점수를 추출
        int? score = int.tryParse(data.dataType);

        // 국영수 점수가 시작 날짜와 종료 날짜 사이에 있는지 확인
        if (score != null && data.date.isAfter(startDate) && data.date.isBefore(endDate)) {
          filteredScores.add(score);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: _dataTextFieldController,
            decoration: InputDecoration(labelText: '데이터 타입 입력'),
          ),
          ElevatedButton(
            onPressed: () async {
              String dataType = _dataTextFieldController.text;
              if (dataType.isNotEmpty) {
                await _addDataToFirestore(dataType);
                _dataTextFieldController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('데이터 타입이 Firestore에 추가되었습니다.'),
                  ),
                );
              }
            },
            child: Text('데이터 타입 추가'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final selectedRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2023, 1, 1), // 시작 날짜
                lastDate: DateTime(2023, 12, 31), // 종료 날짜
              );
              if (selectedRange != null) {
                filterScores(selectedRange.start, selectedRange.end);
              }
            },
            child: Text('날짜 범위 선택'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: filteredScores.length,
              itemBuilder: (context, index) {
                final score = filteredScores[index];
                return ListTile(
                  title: Text('시험: $score'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DataModel {
  final String id;
  final String dataType;
  final DateTime date; // 날짜를 저장하는 속성 추가

  DataModel({
    required this.id,
    required this.dataType,
    required this.date, // 생성자에서 날짜를 받도록 수정
  });
}


