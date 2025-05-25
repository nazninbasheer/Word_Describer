import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<List<String>> fetchDefinition(String word) async {
    final url = 'https://api.dictionaryapi.dev/api/v2/entries/en/$word';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      final List<String> definitions = [];

      for (var meaning in data[0]['meanings']) {
        for (var def in meaning['definitions']) {
          definitions.add(def['definition']);
        }
      }

      return definitions;
    } else {
      throw Exception('Failed to fetch definition');
    }
  }
}
