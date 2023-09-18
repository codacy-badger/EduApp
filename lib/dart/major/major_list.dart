import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../degree/degree.dart';
import '../major/major.dart';
import '../paper/paper.dart';
import '../paper/paper_list.dart';
import '../pathway/pathway_state.dart'; // Import the SecondListScreen class

/// Represents a screen where users can select their majors.
class MajorListScreen extends StatelessWidget {
  final Degree degree;
  final List<Major> majors;

  /// Constructs a [MajorListScreen].
  ///
  /// [majors]: The list of available majors to display.
  const MajorListScreen({Key? key, required this.degree, required this.majors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Majors'),
        backgroundColor: const Color(0xFF10428C),
      ),
      body: Consumer<PathwayState>(
        builder: (context, state, child) {
          return ListView.builder(
            itemCount: majors.length + 1, // Add 1 for SizedBox
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SizedBox(height: 16.0); // Add padding at the top
              }
              final majorIndex = index - 1; // Adjust index for SizedBox
              return ListTile(
                title: Row(
                  children: [
                    Checkbox(
                      value: majors[majorIndex].isSelected,
                      onChanged: (value) {
                        // Toggle the checkbox and update the state
                        majors[majorIndex].isSelected = !majors[majorIndex].isSelected;
                        List<Major> selectedMajors =
                            majors.where((major) => major.isSelected).toList();
                        navigateToPapersListScreen(
                            context, context.read<PathwayState>(), degree, selectedMajors);
                      },
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return const Color(0xFFF9C000); // Set checkbox background color here
                          }
                          return Colors.grey[600]!; // Default background color
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(majors[majorIndex].name),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Navigates to the papers list screen.
  ///
  /// [context]: The build context for navigation.
  /// [state]: The state containing pathway information.
  /// [selectedMajors]: The list of selected majors.
  Future<void> navigateToPapersListScreen(BuildContext context, PathwayState state, Degree degree, List<Major> majors) async {
    state.addMajors(majors);
    // const String papersJson = '''
    // [
    //   {
    //     "papercode": "CS 101",
    //     "subject_code": "COMPSCI",
    //     "year": "2023",
    //     "title": "Introduction to Computer Science",
    //     "points": 18,
    //     "efts": 0.125,
    //     "teaching_periods": ["Semester 1"],
    //     "description": "An introduction to...",
    //     "prerequisites": [],
    //     "restrictions": [],
    //     "schedule": "Lecture 1: Monday 9:00 AM"
    //   },
    //   {
    //     "papercode": "CS 162",
    //     "subject_code": "COMPSCI",
    //     "year": "2023",
    //     "title": "Computer Programming",
    //     "points": 18,
    //     "efts": 0.125,
    //     "teaching_periods": ["Semester 1"],
    //     "description": "An introduction to...",
    //     "prerequisites": [],
    //     "restrictions": [],
    //     "schedule": "Lecture 1: Monday 9:00 AM"
    //   }
    // ]
    // ''';

    String jsonData;
    try {
      jsonData = await fetchPaperData(degree, majors[0]); // TODO: Make dynamic
      // Now you have the degrees from the server, use them to navigate to the next screen
    } catch (error) {
      // Handle error, perhaps show a dialog to the user
      print('Error fetching papers: $error');
      return; // Early return to exit the function if fetching degrees fails
    }

    List<Paper> papers = getPaperData(jsonData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PapersListScreen(degree: degree, major: majors[0], compulsoryPapers: papers, optionalPapers: papers, level: "100"),
      ),
    );
  }

  // Function to retrieve papers
  List<Paper> getLevelPapers(Map<String, dynamic> parsedData, String levelKey, String paperKey) {
    List<Paper> papers = [];
    for (var level in parsedData['levels']) {
      if (level['level'] == levelKey) {
        var paperList = level[paperKey] as List<dynamic>?; // Use null-safe List
        if (paperList != null) {
          for (var paperData in paperList) {
            for (var entry in paperData.entries) {
              final paperCode = entry.key;
              final attributes = entry.value as Map<String, dynamic>;
              final teachingPeriods = (attributes['teaching_periods'] as List<dynamic>)
                ?.map<String>((period) => period.toString())
                ?.toList() ?? []; // Provide a default value if needed

              papers.add(Paper.withName(
                papercode: paperCode,
                title: attributes['title'] ?? '', // Provide a default value if needed
                teachingPeriods: teachingPeriods, // Provide a default value if needed
              ));
            }
          }
        }
      }
    }
    return papers;
  }

  // Function to retrieve and display paper data for each level
  List<Paper> getPaperData(String jsonData) {
    Map<String, dynamic> parsedData = json.decode(jsonData);

    List<dynamic> levels = parsedData['levels'];
    for (var level in levels) {
      if(level["level"] == "100-level") {
        // print('Level: ${level['level']}');
        // print('Compulsory Papers: ${getLevelPapers(parsedData, level['level'], 'compulsory_papers')}');
        // print('One of Papers: ${getLevelPapers(parsedData, level['level'], 'one_of_papers')}');
        // print('');
        return getLevelPapers(parsedData, level['level'], 'compulsory_papers');
      }
    }
    return [];
  }


  Future<String> fetchPaperData(Degree degree, Major major) async {
    final response = await http.get(Uri.parse('http://localhost:1234/${degree.title}/${major.name}'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load majors');
    }
  }
}
