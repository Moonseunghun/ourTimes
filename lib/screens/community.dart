import 'package:flutter/material.dart';

//provider 상태관리

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CommunityPage(),
    );
  }
}

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to the Communityr'),
      ),
      body: ListView.builder(
        itemCount: 10, // 예시로 10개의 게시물을 보여줍니다.
        itemBuilder: (context, index) {
          return CommunityPostCard(
            username: 'User ${index + 1}',
            postTitle: 'Post Title ${index + 1}',
            postContent: 'This is the content of post ${index + 1}.',
          );
        },
      ),
    );
  }
}

class CommunityPostCard extends StatelessWidget {
  final String username;
  final String postTitle;
  final String postContent;

  const CommunityPostCard(
      {super.key,
      required this.username,
      required this.postTitle,
      required this.postContent});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  postTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                const SizedBox(height: 8.0),
                Text(postContent),
              ],
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // Implement functionality for liking a post.
                },
                child: const Text('Like'),
              ),
              TextButton(
                onPressed: () {
                  // Implement functionality for commenting on a post.
                },
                child: const Text('Comment'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
