import 'package:flutter/material.dart';

import '../data/model/regularization/getsingleregularizationlistmodel.dart';
import '../data/services/fm_apiservice.dart';

class SingleRegularizationProvider extends ChangeNotifier {
  final FMapiservice apiService = FMapiservice();

  bool isLoading = false;
  String? errorMessage;

  List<RegularizationItem> singleRegularizationList = [];

  Future<void> getSingleRegularizationList(String timesheetId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result =
          await apiService.getSingleregularizationlist(timesheetId);

      // ✅ Ensure correct mapping
      singleRegularizationList = result.data;

    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
