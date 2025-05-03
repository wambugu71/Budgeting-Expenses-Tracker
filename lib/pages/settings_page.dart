import 'dart:io';

import 'package:expensetracker/db/States_save.dart';
import 'package:expensetracker/providers/pages_state.dart';
import 'package:expensetracker/providers/theme_handler.dart';
import 'package:expensetracker/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/utils/constants.dart';
import 'package:provider/provider.dart';

class MySettingsPage extends StatefulWidget {
  const MySettingsPage({super.key});

  @override
  State<MySettingsPage> createState() => _MySettingsPageState();
}

class _MySettingsPageState extends State<MySettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  String _currency = 'Ksh';
  var  _userProfile = HiveService.getProfile(); 

 // In settings_page.dart, update initState
bool _balanceAlertsEnabled = false;
bool _spendingAlertsEnabled = false;
double _spendingThreshold = 1000.0;

@override
void initState() {
  super.initState();
  final userSettings = HiveService.getSettings();
  setState(() {
    _currency = userSettings.currency;
    _darkModeEnabled = userSettings.darkMode;
    _notificationsEnabled = userSettings.notificationsEnabled;
    _biometricEnabled = userSettings.biometricEnabled;
    _balanceAlertsEnabled = userSettings.balanceAlertsEnabled;
    _spendingAlertsEnabled = userSettings.spendingAlertsEnabled;
    _spendingThreshold = userSettings.spendingThreshold;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  // Account Section
                  _buildSectionHeader('Account'),
                  _buildProfileTile(),
                  _buildDivider(),
                  
                  // Preferences Section
                  _buildSectionHeader('Preferences'),
                 // Replace this in settings_page.dart
_buildSettingsSwitchTile(
  'Notifications',
  'Receive alerts about spending limits',
  _notificationsEnabled, // Use the local state variable
  (value) {
    setState(() {
      _notificationsEnabled = value;
    });
    
    // Update in Hive
    final settings = HiveService.getSettings();
    final updatedSettings = UserSettings(
      darkMode: settings.darkMode,
      notificationsEnabled: value,
      biometricEnabled: settings.biometricEnabled,
      currency: settings.currency,
      balanceAlertsEnabled: settings.balanceAlertsEnabled,
      spendingAlertsEnabled: settings.spendingAlertsEnabled,
      spendingThreshold: settings.spendingThreshold,
    );
    HiveService.saveSettings(updatedSettings);
    
    // Test notification
    if (value) {
      NotificationService().showBalanceNotification(
        title: 'Notifications Enabled',
        body: 'You will now receive notifications about your finances',
        balance: 0.0,
      );
    }
  },
  Icons.notifications_outlined,
),// Add this after the existing notifications switch in settings_page.dart
if (_notificationsEnabled) ...[
  _buildSettingsSwitchTile(
    'Balance Alerts',
    'Get notified about balance changes',
    _balanceAlertsEnabled,
    (value) {
      setState(() {
        _balanceAlertsEnabled = value;
      });
      // Update in storage
      final settings = HiveService.getSettings();
      final updatedSettings = UserSettings(
        darkMode: settings.darkMode,
        notificationsEnabled: settings.notificationsEnabled,
        biometricEnabled: settings.biometricEnabled,
        currency: settings.currency,
        balanceAlertsEnabled: value,
        spendingAlertsEnabled: settings.spendingAlertsEnabled,
        spendingThreshold: settings.spendingThreshold,
      );
      HiveService.saveSettings(updatedSettings);
    },
    Icons.account_balance_wallet_outlined,
  ),
  _buildSettingsSwitchTile(
    'Spending Alerts',
    'Get notified when you exceed spending thresholds',
    _spendingAlertsEnabled,
    (value) {
      setState(() {
        _spendingAlertsEnabled = value;
      });
      // Update in storage
      final settings = HiveService.getSettings();
      final updatedSettings = UserSettings(
        darkMode: settings.darkMode,
        notificationsEnabled: settings.notificationsEnabled,
        biometricEnabled: settings.biometricEnabled,
        currency: settings.currency,
        balanceAlertsEnabled: settings.balanceAlertsEnabled,
        spendingAlertsEnabled: value,
        spendingThreshold: settings.spendingThreshold,
      );
      HiveService.saveSettings(updatedSettings);
    },
    Icons.money_off_outlined,
  ),
  if (_spendingAlertsEnabled)
    ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: pry_color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.warning_amber_outlined, color: pry_color),
      ),
      title: Text('Spending Threshold'),
      subtitle: Text('Alert when spending exceeds $_spendingThreshold ${_currency}'),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showThresholdSetter();
      },
    ),
],
                  _buildSettingsSwitchTile(
                    'Dark Mode',
                    'Switch between light and dark themes',
                    Provider.of<MyThemeHandler>(context).switchstate,
                    (value) {
                      setState(() {
                        _darkModeEnabled = value;
                      });
                      context.read<MyThemeHandler>().getTheme(_darkModeEnabled); 
                      Provider.of<MyThemeHandler>(context, listen: false).SWitchState(_darkModeEnabled);
                    },
                    Icons.dark_mode_outlined,
                  ),
                  _buildCurrencyTile(),
                  _buildDivider(),
                  
                  // Security Section
                  _buildSectionHeader('Security'),
                   ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: pry_color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.fingerprint, color: pry_color),
      ),
      title: Text('Biometrics'),
      subtitle: Text('Login using  biometrics for privacy'),
      trailing: Switch(
        value: _biometricEnabled,
        onChanged: (value) {
    setState(() {
      _biometricEnabled = value;
    });
    
    // Get current settings
    final settings = HiveService.getSettings();
    
    // Update biometric setting
    final updatedSettings = UserSettings(
      darkMode: settings.darkMode,
      notificationsEnabled: settings.notificationsEnabled,
      biometricEnabled: value,
      currency: settings.currency,
    );
    
    // Save to Hive
    HiveService.saveSettings(updatedSettings);
  },
        activeColor: pry_color,
      ),
    ),
                  ListTile(
                    enabled: false,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.lock_outlined, color: Colors.red),
                    ),
                    title: Text('Change Password'),
                    subtitle: Text('Update your security credentials'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  _buildDivider(),
                  
                  // App Info Section
                  _buildSectionHeader('App Info'),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.info_outline, color: Colors.grey),
                    ),
                    title: Text('About'),
                    subtitle: Text('App version and information'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showModalBottomSheet(context: context, builder: (context){
                         final theme = Theme.of(context);
                        final isDarkMode = theme.brightness == Brightness.dark;
    
                        return SafeArea(child: 
                        Column(
                          children: [
                            const SizedBox(height: 20,), 
                            Row(children: [
                              Text('About', style: TextStyle(
                                fontSize: 24, 
                                fontWeight:  FontWeight.bold, 
                                color:  isDarkMode ? Colors.white : Colors.black
                              ),)
                            ], mainAxisAlignment: MainAxisAlignment.center,), 
                            Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: Text('This  Software is free and made  with Love  for  you to use.', 
                              style:  TextStyle(color:  isDarkMode ? Colors.white : Colors.black),),
                            ), 
                            ListTile(
                              title: Text('Developer', style:  TextStyle(
                                fontWeight: FontWeight.bold, 
                                color:   isDarkMode ? Colors.white : Colors.black
                              ),),
                              subtitle:  Text('Wambugu Kinyua', style: TextStyle(
                                 color:  isDarkMode ? Colors.white : Colors.black
                              ),),
                              leading:  Icon(Icons.person),
                            ), 
                            ListTile(
                              title: Text('Email', style:  TextStyle(
                                fontWeight: FontWeight.bold,
                                color:  isDarkMode ? Colors.white : Colors.black
                              ),),
                              subtitle:  SelectableText('wambugukinyua125@duck.com'),
                              leading:  Icon(Icons.email),
                            ),
                            ListTile(
                              title: Text('Portfolio', style:  TextStyle(
                                fontWeight: FontWeight.bold,
                                color:  isDarkMode ? Colors.white : Colors.black
                              ),),
                              subtitle: 
                              SelectableText(" https://wambugukinyua.site", style:  TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black)),
                              leading:  Icon(Icons.web),
                            ), 
                            Row(children: [ MaterialButton(onPressed: ()=> Navigator.pop(context), 
                            child: Text('close', style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black),),
                            color: pry_color,)
                            ],mainAxisAlignment: MainAxisAlignment.center,)
                          ],
                        ));
                      });
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.help_outline, color: Colors.blue),
                    ),
                    title: Text('Help & Support'),
                    subtitle: Text('Get assistance and provide feedback'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showDialog(context: context, builder: (context){
                        return AlertDialog( 
                          icon: const Icon(Icons.support_agent),
                          title: Text('Comming  soon...'),
                        actions: [
                          TextButton(onPressed: (){
                            Navigator.pop(context);
                          }, child: Text('Close'))
                        ],);
                      }
                      );
                    },
                  ),
                  _buildDivider(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add this method to _MySettingsPageState
void _showThresholdSetter() {
  TextEditingController _thresholdController = 
    TextEditingController(text: _spendingThreshold.toString());
  
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Set Spending Threshold'),
        content: TextField(
          controller: _thresholdController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Threshold Amount',
            prefixText: '$_currency ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              double? newThreshold = double.tryParse(_thresholdController.text);
              if (newThreshold != null && newThreshold > 0) {
                setState(() {
                  _spendingThreshold = newThreshold;
                });
                
                // Save to settings
                final settings = HiveService.getSettings();
                final updatedSettings = UserSettings(
                  darkMode: settings.darkMode,
                  notificationsEnabled: settings.notificationsEnabled,
                  biometricEnabled: settings.biometricEnabled,
                  currency: settings.currency,
                  balanceAlertsEnabled: settings.balanceAlertsEnabled,
                  spendingAlertsEnabled: settings.spendingAlertsEnabled,
                  spendingThreshold: newThreshold,
                );
                HiveService.saveSettings(updatedSettings);
                
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      );
    }
  );
}

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: pry_color,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildProfileTile() {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: pry_color,
        radius: 20,
        child: Text(
          _userProfile.name.substring(0,1),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(_userProfile.name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(_userProfile.email),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        context.read<MyPageIndex>().getPage(1);
      },
    );
  }

  Widget _buildSettingsSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: pry_color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: pry_color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: pry_color,
      ),
    );
  }

  Widget _buildCurrencyTile() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.currency_exchange, color: Colors.green),
      ),
      title: Text('Currency'),
      subtitle: Text('Change your default currency'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_currency, style: TextStyle(color: Colors.grey)),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: () {
        _showCurrencyPicker();
      },
    );
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Currency',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildCurrencyOption('Ksh', 'Kenyan Shilling'),
                    _buildCurrencyOption('USD', 'US Dollar'),
                    _buildCurrencyOption('EUR', 'Euro'),
                    _buildCurrencyOption('GBP', 'British Pound'),
                    _buildCurrencyOption('JPY', 'Japanese Yen'),
                    _buildCurrencyOption('CNY', 'Chinese Yuan'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

Widget _buildCurrencyOption(String code, String name) {
  return ListTile(
    title: Text(code),
    subtitle: Text(name),
    trailing: _currency == code ? Icon(Icons.check, color: pry_color) : null,
    onTap: () {
      setState(() {
        _currency = code;
      });
      // Save to Hive
      HiveService.saveCurrency(code);
      Navigator.pop(context);
    },
  );
}
}