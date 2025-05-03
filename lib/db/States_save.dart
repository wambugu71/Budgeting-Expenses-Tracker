import 'package:hive_flutter/hive_flutter.dart';

// Fix capital letter in part directive to match your file name
part 'States_save.g.dart';
// In States_save.dart
@HiveType(typeId: 0)
class UserSettings extends HiveObject {
  @HiveField(0)
  bool darkMode;
  
  @HiveField(1)
  bool notificationsEnabled;
  
  @HiveField(2)
  bool biometricEnabled;
  
  @HiveField(3)
  String currency;
  
  @HiveField(4)
  bool balanceAlertsEnabled;
  
  @HiveField(5)
  bool spendingAlertsEnabled;
  
  @HiveField(6)
  double spendingThreshold;

  UserSettings({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.currency = 'Ksh',
    this.balanceAlertsEnabled = false,
    this.spendingAlertsEnabled = false,
    this.spendingThreshold = 1000.0,
  });
}

@HiveType(typeId: 1)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;
  
  @HiveField(1)
  String email;
  
  @HiveField(2)
  String memberSince;
  
  @HiveField(3)
  String country;

  UserProfile({
    this.name = 'set profile',
    this.email = 'set email',
    this.memberSince = 'July 2023',
    this.country = 'Set country',
  });
}

@HiveType(typeId: 2)
class AppState extends HiveObject {
  @HiveField(0)
  double balance;
  
  @HiveField(1)
  int lastPageIndex;

  AppState({
    this.balance = 0.0,
    this.lastPageIndex = 0,
  });
}

@HiveType(typeId: 3)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final double amount;
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  final String category;
  
  @HiveField(5)
  final String type; // income or expense

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
  });
}

class HiveService {
  static const String userSettingsBoxName = 'userSettings';
  static const String userProfileBoxName = 'userProfile';
  static const String appStateBoxName = 'appState';
  static const String transactionsBoxName = 'transactions';
  
  // Initialize Hive and open boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(AppStateAdapter());
    Hive.registerAdapter(TransactionAdapter());
    
    // Open boxes
    await Hive.openBox<UserSettings>(userSettingsBoxName);
    await Hive.openBox<UserProfile>(userProfileBoxName);
    await Hive.openBox<AppState>(appStateBoxName);
    await Hive.openBox<Transaction>(transactionsBoxName);
  }
  
  // Settings methods
  static Future<void> saveSettings(UserSettings settings) async {
    final box = Hive.box<UserSettings>(userSettingsBoxName);
    await box.put('settings', settings);
  }
  
  static UserSettings getSettings() {
    final box = Hive.box<UserSettings>(userSettingsBoxName);
    return box.get('settings') ?? UserSettings();
  }
  
  // Profile methods
  static Future<void> saveProfile(UserProfile profile) async {
    final box = Hive.box<UserProfile>(userProfileBoxName);
    await box.put('profile', profile);
  }
  
  static UserProfile getProfile() {
    final box = Hive.box<UserProfile>(userProfileBoxName);
    return box.get('profile') ?? UserProfile();
  }
  
  // App state methods
  static Future<void> saveAppState(AppState state) async {
    final box = Hive.box<AppState>(appStateBoxName);
    await box.put('state', state);
  }
  
  static AppState getAppState() {
    final box = Hive.box<AppState>(appStateBoxName);
    return box.get('state') ?? AppState();
  }
  
  // Save individual values
  static Future<void> saveBalance(double balance) async {
    final box = Hive.box<AppState>(appStateBoxName);
    final state = box.get('state') ?? AppState();
    state.balance = balance;
    await box.put('state', state);
  }
  
  static Future<void> savePageIndex(int index) async {
    final box = Hive.box<AppState>(appStateBoxName);
    final state = box.get('state') ?? AppState();
    state.lastPageIndex = index;
    await box.put('state', state);
  }
  
  static Future<void> saveThemeMode(bool isDarkMode) async {
    final box = Hive.box<UserSettings>(userSettingsBoxName);
    final settings = box.get('settings') ?? UserSettings();
    settings.darkMode = isDarkMode;
    await box.put('settings', settings);
  }
  
  static Future<void> saveCurrency(String currency) async {
    final box = Hive.box<UserSettings>(userSettingsBoxName);
    final settings = box.get('settings') ?? UserSettings();
    settings.currency = currency;
    await box.put('settings', settings);
  }
  
  // Transaction methods
  static Future<void> addTransaction(Transaction transaction) async {
    final box = Hive.box<Transaction>(transactionsBoxName);
    await box.put(transaction.id, transaction);
  }
  
  static List<Transaction> getAllTransactions() {
    final box = Hive.box<Transaction>(transactionsBoxName);
    return box.values.toList();
  }
  
  static Future<void> deleteTransaction(String id) async {
    final box = Hive.box<Transaction>(transactionsBoxName);
    await box.delete(id);
  }
  
  static List<Transaction> getTransactionsByType(String type) {
    final box = Hive.box<Transaction>(transactionsBoxName);
    return box.values.where((t) => t.type == type).toList();
  }
  
  static List<Transaction> getTransactionsByCategory(String category) {
    final box = Hive.box<Transaction>(transactionsBoxName);
    return box.values.where((t) => t.category == category).toList();
  }
  
  static double getTotalExpense() {
    final transactions = getTransactionsByType('expense');
    return transactions.fold(0, (sum, item) => sum + item.amount);
  }
  
  static double getTotalIncome() {
    final transactions = getTransactionsByType('income');
    return transactions.fold(0, (sum, item) => sum + item.amount);
  }
  
  static Map<String, double> getCategoryTotals() {
    final expenses = getTransactionsByType('expense');
    final Map<String, double> categoryTotals = {};
    
    for (var transaction in expenses) {
      final category = transaction.category;
      final amount = transaction.amount;
      
      if (categoryTotals.containsKey(category)) {
        categoryTotals[category] = categoryTotals[category]! + amount;
      } else {
        categoryTotals[category] = amount;
      }
    }
    
    return categoryTotals;
  }
}