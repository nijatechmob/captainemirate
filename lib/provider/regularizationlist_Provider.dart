import 'package:flutter/material.dart';

import '../data/model/regularization/getregularizationlistmodel.dart';
import '../data/services/fm_apiservice.dart';

class RegularizationProvider extends ChangeNotifier {
  final FMapiservice apiService = FMapiservice();

  bool isLoading = false;
  String? errorMessage;

  List<RegularizationList> regularizationList = [];

  Future<void> getRegularizationList(String employeeId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await apiService.getRegularizationlist(employeeId);

      regularizationList = result.data;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}

