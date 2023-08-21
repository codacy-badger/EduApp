import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../degree/degree.dart';
import '../degree/degree_list.dart';
import '../pathway/pathway_state.dart';
import 'display_pathway.dart';

import '../navigation/nav_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Create a list to store selected degrees (up to 3)
  List<Degree?> selectedDegrees = List.filled(3, null);

  void _openDegreesListScreen(BuildContext context) {
    // Sample degree data
    final degreesJson = {
      "degrees": [
        "Bachelor of Applied Science (BAppSc)",
        "Bachelor of Arts (BA)",
        "Bachelor of Arts and Commerce (BACom)",
        "Bachelor of Arts and Science (BASc)",
        "Bachelor of Biomedical Sciences (BBiomedSc)",
        "Bachelor of Commerce (BCom)",
        "Bachelor of Commerce and Science (BComSc)",
        "Bachelor of Entrepreneurship (BEntr)",
        "Bachelor of Health Sciences (BHealSc)",
        "Bachelor of Music (MusB)",
        "Bachelor of Performing Arts (BPA)",
        "Bachelor of Science (BSc)",
        "Bachelor of Theology (BTheol)",
        "Bachelor of Laws (LLB) (first year only)"
      ]
    };

    List<String>? degreesList = (degreesJson['degrees'] as List<dynamic>).cast<String>();
    List<Degree> degrees = Degree.fromJsonList(degreesList);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DegreeListScreen(
          degrees: degrees,
          onSelectDegree: (selectedDegree) {
            setState(() {
              Provider.of<PathwayState>(context, listen: false).addDegree(selectedDegree);
            });
          },
        ),
      ),
    ); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const NavBar(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428C), // Set background color here
        title: const Text("Plan Your Degree"),
      ),
      body: Consumer<PathwayState>(
        builder: (context, state, child) {
          return DisplayPathway(
            pathway: state.savedPathways, // Pass the chosen degree
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFf9c000), // Set background color here
        onPressed: () {
          final state = Provider.of<PathwayState>(context, listen: false);
          int pathwayCount = state.savedPathways.length;

          if (pathwayCount < 3) {
            _openDegreesListScreen(context);
          } else {
            // Display a snackbar to inform the user
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You cannot have more than three degrees.'),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}