import 'package:expensetracker/db/States_save.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  late UserProfile userProfile;
  late UserSettings userSettings;
  late List<Transaction> transactions;
  Map<String, double> categoryTotals = {};
  double totalSpent = 0;
  int transactionCount = 0;
  int categoryCount = 0;
  
  // Monthly spending data
  List<double> monthlySpending = List.filled(12, 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _loadData() {
    // Load user profile and settings
    userProfile = HiveService.getProfile();
    userSettings = HiveService.getSettings();
    
    // Load transactions
    transactions = HiveService.getAllTransactions();
    transactionCount = transactions.length;
    
    // Calculate total spent
    totalSpent = HiveService.getTotalExpense();
    
    // Get category totals and count
    categoryTotals = HiveService.getCategoryTotals();
    categoryCount = categoryTotals.keys.length;
    
    // Calculate monthly spending
    _calculateMonthlySpending();
    
    setState(() {});
  }
  
  void _calculateMonthlySpending() {
    // Initialize monthly spending array with zeros
    monthlySpending = List.filled(12, 0);
    
    // Only include expenses, not income
    final expenseTransactions = transactions.where((t) => t.type == 'expense').toList();
    
    // Group transactions by month and sum
    for (var transaction in expenseTransactions) {
      final month = transaction.date.month - 1; // 0-based index
      monthlySpending[month] += transaction.amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current theme and check if it's dark mode
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Define colors based on theme
    final backgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100;
    final cardColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final primaryColor = theme.colorScheme.primary;
    final dividerColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    
    // Format currency
    final currencyFormatter = NumberFormat.currency(
      symbol: '${userSettings.currency} ',
      decimalDigits: 2,
    );
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadData();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: EdgeInsets.only(top: 30, bottom: 20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode 
                            ? Colors.black.withOpacity(0.3) 
                            : Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      Stack(
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: primaryColor, width: 3),
                              color: cardColor,
                            ),
                            child: Icon(
                              Icons.person_outline,
                              size: 70,
                              color: primaryColor,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: primaryColor,
                                border: Border.all(color: cardColor, width: 3),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(
                        userProfile.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: textColor,
                        ),
                      ),
                      Text(
                        userProfile.email,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Summary Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSummaryCard(
                              currencyFormatter.format(totalSpent), 
                              'Total Spent', 
                              Icons.payments_outlined, 
                              Colors.blue, 
                              isDarkMode
                            ),
                            _buildSummaryCard(
                              transactionCount.toString(), 
                              'Transactions', 
                              Icons.receipt_long_outlined, 
                              Colors.orange, 
                              isDarkMode
                            ),
                            _buildSummaryCard(
                              categoryCount.toString(), 
                              'Categories', 
                              Icons.category_outlined, 
                              Colors.green, 
                              isDarkMode
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // User Info Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildInfoCard('Name', userProfile.name, Icons.person_outline, context),
                      _buildInfoCard('Currency', userSettings.currency, Icons.currency_exchange, context),
                      _buildInfoCard('Country', userProfile.country, Icons.location_on_outlined, context),
                      _buildInfoCard('Member Since', userProfile.memberSince, Icons.calendar_today_outlined, context),
                      
                      SizedBox(height: 25),
                      
                      // Spending Chart Section
                      Text(
                        'Monthly Spending Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 260,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode 
                                  ? Colors.black.withOpacity(0.3) 
                                  : Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Annual Overview',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            Text(
                              'Spending pattern throughout the year',
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 15),
                            Expanded(
                              child: _buildMonthlyChart(isDarkMode),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Category Overview
                      Text(
                        'Spending by Category',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 260,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode 
                                  ? Colors.black.withOpacity(0.3) 
                                  : Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category Breakdown',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            Text(
                              'How your expenses are distributed',
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 15),
                            Expanded(
                              child: _buildCategoryChart(isDarkMode),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Account Actions
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode 
                                  ? Colors.black.withOpacity(0.3) 
                                  : Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Actions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: 10),
                            _buildActionButton('Edit Profile', Icons.edit, primaryColor, textColor, isDarkMode, () {
                              _showEditProfileSheet(context);
                            }),
                            Divider(color: dividerColor),
                            _buildActionButton('Export Data', Icons.cloud_download_outlined, Colors.orange, textColor, isDarkMode, () {}),
                            Divider(color: dividerColor),
                            _buildActionButton('Clear All Data', Icons.delete_outline, Colors.red, textColor, isDarkMode, () {
                              _showClearDataDialog(context);
                            }),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String value, String label, IconData icon, Color color, bool isDarkMode) {
    // Adjust color opacity and background based on theme
    final bgColor = isDarkMode ? color.withOpacity(0.2) : color.withOpacity(0.1);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    
    return Container(
      width: 100,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final primaryColor = theme.colorScheme.primary;
    
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, Color textColor, bool isDarkMode, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios, 
              size: 16, 
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(bool isDarkMode) {
    // Find max value for scaling
    double maxValue = monthlySpending.isNotEmpty 
        ? monthlySpending.reduce((a, b) => a > b ? a : b) 
        : 20000;
    
    // Add 20% padding to max value
    maxValue = maxValue * 1.2;
    
    // If maxValue is zero, set a default
    if (maxValue == 0) maxValue = 10000;
    
    // Adjust chart colors based on theme
    final gridLineColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    final textColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final barColor = isDarkMode ? Colors.tealAccent : Colors.teal;
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: gridLineColor, strokeWidth: 1);
          },
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String month;
              switch (group.x.toInt()) {
                case 0: month = 'Jan'; break;
                case 1: month = 'Feb'; break;
                case 2: month = 'Mar'; break;
                case 3: month = 'Apr'; break;
                case 4: month = 'May'; break;
                case 5: month = 'Jun'; break;
                case 6: month = 'Jul'; break;
                case 7: month = 'Aug'; break;
                case 8: month = 'Sep'; break;
                case 9: month = 'Oct'; break;
                case 10: month = 'Nov'; break;
                case 11: month = 'Dec'; break;
                default: month = '';
              }
              return BarTooltipItem(
                '$month\n${userSettings.currency} ${rod.toY.round()}',
                TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                return value >= 0 && value < titles.length 
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        titles[value.toInt()],
                        style: TextStyle(
                          color: textColor,
                          fontSize: 10,
                        ),
                      ),
                    )
                  : const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return Text(
                    '0',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                    ),
                  );
                }
                
                if (value == maxValue / 4 || value == maxValue / 2 || value == 3 * maxValue / 4 || value == maxValue) {
                  String valueText;
                  if (value >= 1000) {
                    valueText = '${(value / 1000).toStringAsFixed(0)}K';
                  } else {
                    valueText = value.toStringAsFixed(0);
                  }
                  
                  return Text(
                    valueText,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                    ),
                  );
                }
                
                return const Text('');
              },
            ),
          ),
        ),
        barGroups: List.generate(12, (index) {
          return _createBarData(index, monthlySpending[index], barColor);
        }),
      ),
    );
  }
  
  Widget _buildCategoryChart(bool isDarkMode) {
  if (categoryTotals.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No category data available',
            style: TextStyle(
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  // Define category colors
  final Map<String, Color> categoryColors = {
    'Food': Colors.orange,
    'Transport': Colors.blue,
    'Entertainment': Colors.purple,
    'Shopping': Colors.pink,
    'Bills': Colors.red,
    'Health': Colors.green,
    'Education': Colors.indigo,
    'Other': Colors.grey,
  };
  
  // Calculate total for percentage
  final total = categoryTotals.values.fold(0.0, (sum, value) => sum + value);
  
  // Build legend entries
  List<Widget> legendItems = [];
  for (var entry in categoryTotals.entries) {
    final category = entry.key;
    final amount = entry.value;
    final percentage = total > 0 ? (amount / total * 100) : 0;
    
    legendItems.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: categoryColors[category] ?? Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  return Row(
    children: [
      // Pie chart on the left
      Expanded(
        flex: 5,
        child: AspectRatio(
          aspectRatio: 1,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40, // Adjust hole size for donut chart
              sections: categoryTotals.entries.map((entry) {
                final category = entry.key;
                final amount = entry.value;
                
                return PieChartSectionData(
                  color: categoryColors[category] ?? Colors.grey,
                  value: amount,
                  title: '', // Remove titles from sections to clean up appearance
                  radius: 50, // Smaller radius makes it more compact
                  titleStyle: TextStyle(
                    fontSize: 0, // Hide text - we'll use the legend instead
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  badgeWidget: null,
                  badgePositionPercentageOffset: 0,
                );
              }).toList(),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
      
      // Legend on the right
      Expanded(
        flex: 5,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: legendItems,
          ),
        ),
      ),
    ],
  );
}
  
  BarChartGroupData _createBarData(int x, double y, Color barColor) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: barColor,
          width: 12,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }
  
  void _showEditProfileSheet(BuildContext context) {
    final nameController = TextEditingController(text: userProfile.name);
    final emailController = TextEditingController(text: userProfile.email);
    final countryController = TextEditingController(text: userProfile.country);
    
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: theme.colorScheme.primary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  TextField(
                    controller: countryController,
                    decoration: InputDecoration(
                      labelText: "Country",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        final updatedProfile = UserProfile(
                          name: nameController.text,
                          email: emailController.text,
                          memberSince: userProfile.memberSince,
                          country: countryController.text,
                        );
                        
                        HiveService.saveProfile(updatedProfile);
                        _loadData();
                        Navigator.pop(context);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Profile updated successfully")),
                        );
                      },
                      child: Text(
                        "SAVE",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _showClearDataDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear All Data"),
        content: Text("This will delete all your transactions and reset your balance. This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL"),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              // Clear transactions logic would go here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("All data has been cleared")),
              );
              _loadData();
            },
            child: Text("CLEAR"),
          ),
        ],
      ),
    );
  }
}