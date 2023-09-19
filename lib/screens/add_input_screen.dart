import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDataViewer extends StatefulWidget {
  @override
  _FirestoreDataViewerState createState() => _FirestoreDataViewerState();
}

class _FirestoreDataViewerState extends State<FirestoreDataViewer> {
  final TextEditingController _messageController = TextEditingController();

  void _addMessage() async {
    final messageText = _messageController.text;
    final timestamp = DateTime.now();

    // Firestore에 메시지 추가
    await FirebaseFirestore.instance.collection('messages').add({
      'text': messageText,
      'timestamp': timestamp,
    });

    // 입력 창 비우기
    _messageController.clear();
  }

  Widget _buildMessageList(QuerySnapshot? snapshot) {
    if (snapshot == null) {
      return CircularProgressIndicator();
    // } else if (snapshot.hasError) {
    //   return Text('Error: ${snapshot.error}');
    // } else if (snapshot.isEmpty) {
    //   return Text('No data available.');
    // } else {
      final data = snapshot.docs;
      List<Widget> messageWidgets = [];
      data.forEach((document) {
        final text = document['text'];
        final timestamp = document['timestamp'];
        messageWidgets.add(
          ListTile(
            title: Text(text),
            subtitle: Text('Timestamp: $timestamp'),
          ),
        );
      });
      return ListView(
        children: messageWidgets,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('messages').snapshots(),
            builder: (context, snapshot) {
              return _buildMessageList(snapshot.data);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Enter your message...',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _addMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

