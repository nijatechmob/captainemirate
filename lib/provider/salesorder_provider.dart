import 'package:flutter/material.dart';

import '../data/model/salesordermomodel/salesorderno_model.dart';
import '../data/services/fm_apiservice.dart';


class SalesOrderProvider extends ChangeNotifier {
  final FMapiservice apiService = FMapiservice();



  bool isLoading = false;
  String? errorMessage;

  List<SalesOrderItem> salesOrderList = [];

  Future<void> getAllSalesOrderNo() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await apiService.getAllSalesOrderNo();

      salesOrderList = result.payload ?? [];

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }
  
}


