import 'package:flutter/material.dart';

import 'database_data_file.dart';

class DataManagementPageState extends ChangeNotifier {
  final DatabaseDataFile dataFile;
  final String pageKey;
  bool isPreviewing = false;
  bool showImagesOnly = false;
  
  DataManagementPageState({
    required this.dataFile,
    required this.pageKey});

  void togglePreview() {
    isPreviewing = !isPreviewing;
    notifyListeners();
  }

  void toggleShowImagesOnly() {
    showImagesOnly = !showImagesOnly;
    notifyListeners();
  }
}