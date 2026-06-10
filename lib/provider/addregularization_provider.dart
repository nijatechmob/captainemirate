import 'package:flutter/material.dart';

import '../data/model/regularization/addregularizationmodel.dart';
import '../data/services/fm_apiservice.dart';

class AddRegularizationProvider extends ChangeNotifier {
  final FMapiservice apiService = FMapiservice();


  bool isLoading = false;
  AddRegularizationModel? addregularizationmodel;
  String? errorMessage;

  Future<bool> addRegularization(Map<String, dynamic> body) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await apiService.addRegularization(body);

      addregularizationmodel = res;
      isLoading = false;
      notifyListeners();

      return res.status; // success/failure
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clear() {
    addregularizationmodel = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }
}


