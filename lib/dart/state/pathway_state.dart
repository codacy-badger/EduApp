import 'package:flutter/material.dart';

import '../degree/degree.dart';
import '../major/major.dart';
import '../paper/paper.dart';

class PathwayState extends ChangeNotifier {
  List<Degree?> selectedDegrees = List.filled(3, null);
  Degree? chosenDegree;
  List<Major> chosenMajors = [];
  List<Paper> chosenPapers = [];

  void addDegree(Degree degree, int index) {
    selectedDegrees[index] = degree;
    notifyListeners();
  }

  void updateDegree(Degree degree) {
    chosenDegree = degree;
    chosenMajors.clear(); // Reset major when degree changes
    chosenPapers.clear(); // Reset papers when degree changes
    notifyListeners();
  }

  void updateMajor(Major major) {
    if (chosenMajors.isEmpty) {
      chosenMajors.add(major);
    } else {
      chosenMajors[0] = major;
    }

    chosenPapers.clear(); // Reset papers when major changes
    notifyListeners();
  }


  void addPaper(Paper paper) {
    chosenPapers.add(paper);
    notifyListeners();
  }

  // Other methods for removing papers, updating majors, etc.
}
