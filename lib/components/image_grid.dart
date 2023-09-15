import 'package:flutter/material.dart';
import './image_grid_item.dart';

class ImageGrid extends StatelessWidget {
  final List<dynamic> dataList;
  final bool isLoading;
  final VoidCallback onFetchMore;

  const ImageGrid(
      {super.key,
      required this.dataList,
      required this.isLoading,
      required this.onFetchMore});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: dataList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index < dataList.length) {
          final item = dataList[index];
          return ImageGridItem(item: item);
        } else if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Container(); // Placeholder for end of the list
        }
      },
    );
  }
}
