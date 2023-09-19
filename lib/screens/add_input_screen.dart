import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Firestore에 데이터 추가 함수
  Future<void> _addDataToFirestore(String dataType) async {
    await _firestore.collection('message').add({'dataType': dataType});
  }

  // Firestore에서 모든 데이터 가져오기 함수
  Future<List<String>> _getAllDataFromFirestore() async {
    QuerySnapshot querySnapshot =
    await _firestore.collection('message').get();

    List<String> dataList = [];
    querySnapshot.docs.forEach((doc) {
      dataList.add(doc['dataType']);
    });

    return dataList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
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
                List<String> dataTypeList = await _getAllDataFromFirestore();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('모든 데이터 타입'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: dataTypeList
                            .map((dataType) => Text(dataType))
                            .toList(),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('닫기'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('모든 데이터 타입 가져오기'),
            ),
          ],
        ),
      ),
    );
  }
}



