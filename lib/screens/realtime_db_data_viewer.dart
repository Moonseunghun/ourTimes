import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NameListApp extends StatefulWidget {
  @override
  _NameListAppState createState() => _NameListAppState();
}

class _NameListAppState extends State<NameListApp> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  List<String> nameList = [];
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNames();
  }

  void _fetchNames() {
    _databaseReference.child('names').once().then((DatabaseEvent event) {
      final dynamic data = event.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        setState(() {
          nameList = data.values.toList().cast<String>();
        });
      }
    });
  }


  void _addName(String newName) {
    if (newName.isNotEmpty) {
      _databaseReference.child('names').push().set(newName);
      _nameController.clear();
      _fetchNames();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Enter a Name',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _addName(_nameController.text);
              },
              child: Text('Add Name'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: nameList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(nameList[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(NameListApp());
}

