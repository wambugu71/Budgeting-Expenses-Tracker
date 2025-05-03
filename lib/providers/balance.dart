// In balance.dart
import 'package:expensetracker/db/States_save.dart';
import 'package:expensetracker/services/notification_service.dart';
import 'package:flutter/material.dart';

// In balance.dart
class MyBalance with ChangeNotifier {
  double _balance = 0.0;

  double get balance => _balance;

  void addToBalance(double amount) {
    _balance += amount;
    notifyListeners();
    
    // Save to Hive
    final appState = HiveService.getAppState();
    final updatedState = AppState(
      balance: _balance,
      lastPageIndex: appState.lastPageIndex,
    );
    HiveService.saveAppState(updatedState);
    // Check if notifications are enabled and trigger notification
    final settings = HiveService.getSettings();
    if (settings.notificationsEnabled && settings.balanceAlertsEnabled) {
      NotificationService().showBalanceNotification(
        title: 'Balance Updated',
        body: 'Your balance is now ${settings.currency} $_balance',
        balance: _balance,
      );
    }
  }

  void subtractFromBalance(double amount) {
    if (_balance >= amount) {
      _balance -= amount;
      notifyListeners();
      
      // Save to Hive
      final appState = HiveService.getAppState();
      final updatedState = AppState(
        balance: _balance,
        lastPageIndex: appState.lastPageIndex,
      );
      HiveService.saveAppState(updatedState);
      
      // Check if notifications are enabled
      final settings = HiveService.getSettings();
      if (settings.notificationsEnabled && settings.balanceAlertsEnabled) {
        NotificationService().showBalanceNotification(
          title: 'Balance Updated',
          body: 'Your balance is now ${settings.currency} $_balance',
          balance: _balance,
        );
      }
    }
  }
}