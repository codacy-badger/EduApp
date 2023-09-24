
// Function to retrieve papers
import 'dart:convert';
import 'package:edu_app/dart/paper/paper.dart';
import 'package:http/http.dart' as http;
import '../degree/degree.dart';
import '../major/major.dart';

  Future<String> fetchRecommendedPapers(Degree degree, Major major, int level) async {
    final response = await http.get(Uri.parse('http://localhost:1234/${degree.title}/${major.name}/papers/$level'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load recommended papers');
    }
  }

  Future<String> fetchMatchingPapers(Degree degree, String query) async {
    final response = await http.get(Uri.parse('http://localhost:1234/${degree.title}/papers/$query'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load recommended papers');
    }
  }

  List<Paper> parseJsonPapers(String json) {
    final Map<String, dynamic> jsonData = jsonDecode(json);
    
    final List<Paper> recommendedPapers = jsonData.entries.map((entry) {
      final papercode = entry.key;
      final paperData = entry.value;
      return Paper.fromJson(papercode, paperData);
    }).toList();
    return recommendedPapers;
  }

  Future<String> postPaperData(Degree degree, Major major, List<Paper> papersList) async {
    final url = Uri.parse('http://localhost:1234/${degree.title}/${major.name}');
   
    List<Map<String, dynamic>> jsonPapers = papersListToJson(papersList); 
    String papersJsonString = jsonEncode(jsonPapers);
    
    final response = await http.post(
      url,
      // @CONNOR Using the JSON string as the request body doen't work, I'm working on a fix
      // body: papersJsonString, // Set the JSON string as the request body
      // headers: {
      //   'Content-Type': 'application/json', // Set the Content-Type header
      // }
    );
    
    if (response.statusCode == 200) {
      return response.body;
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to validate pathway');
    }
  }