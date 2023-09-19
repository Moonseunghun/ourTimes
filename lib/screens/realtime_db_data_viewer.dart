import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RealtimeDbDataViewer extends StatefulWidget {
  @override
  _RealtimeDbDataViewerState createState() => _RealtimeDbDataViewerState();
}

class _RealtimeDbDataViewerState extends State<RealtimeDbDataViewer> {
  final TextEditingController _messageController = TextEditingController();

  // Firebase 데이터베이스 참조를 가져옵니다.
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child('realtime_messages');

  void _sendMessage() {
    final messageText = _messageController.text;

    if (messageText.isNotEmpty) { // 메시지가 비어 있지 않은 경우에만 전송
      final timestamp = DateTime.now().toUtc().toString();

      // Firebase 데이터베이스에 메시지를 추가합니다.
      _databaseReference.push().set({
        'text': messageText,
        'timestamp': timestamp,
      });

      // 입력 창 비우기
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<Event>(
            stream: _databaseReference.onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return Text('No data available.');
              } else {
                final data = snapshot.data!.snapshot.value;
                List<Widget> messageWidgets = [];

                if (data != null) {
                  data.forEach((key, value) {
                    final text = value['text'];
                    final timestamp = value['timestamp'];
                    messageWidgets.add(
                      ListTile(
                        title: Text(text),
                        subtitle: Text('Timestamp: $timestamp'),
                      ),
                    );
                  });
                }
                return ListView(
                  children: messageWidgets,
                );
              }
            },
          )
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
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
