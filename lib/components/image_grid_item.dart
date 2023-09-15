import 'package:flutter/material.dart';

class ImageGridItem extends StatelessWidget {
  final dynamic item;

  const ImageGridItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to detail screen or implement image zoom here
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
              item['imageURL']), // Adjust key according to your API response
          const SizedBox(height: 4),
          Text(item['title']), // Adjust key according to your API response
        ],
      ),
    );
  }
}
