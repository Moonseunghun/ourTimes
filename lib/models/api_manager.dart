import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class ApiManager {
  final String apiKey =
      '/VspOxdv5gAMv07cVCEdPqyAmKUGiClkJUsl/kPehP2BKDno6KgncYzHO8s0G+uRoiE3RdzmzQqWJdfMl+bMng==';
  final String baseUrl = 'http://apis.data.go.kr/B551011/PhotoGalleryService1';

  Future<List<Map<String, String>>> getData(int page) async {
    final response = await http
        .get(Uri.parse('$baseUrl/galleryList1?page=$page&serviceKey=$apiKey'));

    if (response.statusCode == 200) {
      final xmlString = response.body;
      final document = xml.XmlDocument.parse(xmlString); // Parse the XML data
      final itemsData = document.findAllElements('item');

      final itemsList = itemsData.map((node) {
        final itemMap = <String, String>{};
        for (var child in node.children) {
          if (child is xml.XmlElement) {
            itemMap[child.name.local] = child.text;
          }
        }
        return itemMap;
      }).toList();

      return itemsList;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
