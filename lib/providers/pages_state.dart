// In pages_state.dart
import 'package:flutter/material.dart';
import 'package:expensetracker/db/States_save.dart';

class MyPageIndex extends ChangeNotifier {
  int _pageNum = 0;
  bool _addExpenseClicked = false;

  int get pageNum => _pageNum;
  bool get addExpenseClicked => _addExpenseClicked;

  void expenseClicked(bool clicked) {
    _addExpenseClicked = clicked;
    notifyListeners();
  }

  void getPage(int n) {
    _pageNum = n;
    // Save to Hive
    HiveService.savePageIndex(_pageNum);
    notifyListeners();
  }
}