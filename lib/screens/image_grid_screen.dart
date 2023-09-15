import 'package:flutter/material.dart';
import '../components/image_grid.dart';
import '../models/api_manager.dart';

class ImageGridScreen extends StatefulWidget {
  const ImageGridScreen({super.key});

  @override
  _ImageGridScreenState createState() => _ImageGridScreenState();
}

class _ImageGridScreenState extends State<ImageGridScreen> {
  final ApiManager _apiManager = ApiManager();
  final List<dynamic> _dataList = [];
  int _currentPage = 1;
  bool _isLoading = false;

  Future<void> _fetchData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final dataList = await _apiManager.getData(_currentPage);

    setState(() {
      _dataList.addAll(dataList);
      _isLoading = false;
      _currentPage++;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Grid Demo'),
      ),
      body: ImageGrid(
        dataList: _dataList,
        isLoading: _isLoading,
        onFetchMore: _fetchData,
      ),
    );
  }
}
