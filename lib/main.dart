import 'package:expensetracker/pages/home_page.dart';
import 'package:expensetracker/pages/profile_page.dart';
import 'package:expensetracker/pages/settings_page.dart';
import 'package:expensetracker/providers/balance.dart';
import 'package:expensetracker/providers/pages_state.dart';
import 'package:expensetracker/providers/theme_handler.dart';
import 'package:expensetracker/db/States_save.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:expensetracker/services/notification_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive with proper error handling
  try {
    await HiveService.init();
    print("Hive initialized successfully");
  } catch (e) {
    print("Error initializing Hive: $e");
  }
  
  // Initialize notifications
  await NotificationService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // Get saved app state
    final appState = HiveService.getAppState();
    final userSettings = HiveService.getSettings();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MyBalance()..addToBalance(appState.balance),
        ),
        ChangeNotifierProvider(
          create: (context) => MyThemeHandler()
            ..SWitchState(userSettings.darkMode)
            ..getTheme(userSettings.darkMode),
        ),
        ChangeNotifierProvider(
          create: (context) => MyPageIndex()..getPage(appState.lastPageIndex),
        ),
      ],
      child: Consumer<MyThemeHandler>(
        builder: (context, themeHandler, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeHandler.theme,
            home: BiometricAuthWrapper(
              authEnabled: userSettings.biometricEnabled,
            ),
          );
        },
      ),
    );
  }
}

class BiometricAuthWrapper extends StatefulWidget {
  final bool authEnabled;
  
  const BiometricAuthWrapper({
    super.key, 
    required this.authEnabled,
  });

  @override
  State<BiometricAuthWrapper> createState() => _BiometricAuthWrapperState();
}

class _BiometricAuthWrapperState extends State<BiometricAuthWrapper> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = true;
  bool _authComplete = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.authEnabled) {
      _authenticate();
    } else {
      setState(() {
        _isAuthenticating = false;
        _authComplete = true;
      });
    }
  }
  
  Future<void> _authenticate() async {
    try {
      // Check if device supports biometrics
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      
      if (!canAuthenticate) {
        // Device doesn't support biometrics or no biometrics enrolled
        setState(() {
          _isAuthenticating = false;
          _authComplete = true;  // Still allow access
        });
        return;
      }
      
      // Get available biometrics
      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      
      if (availableBiometrics.isEmpty) {
        // No biometrics enrolled
        setState(() {
          _isAuthenticating = false;
          _authComplete = true;  // Still allow access
        });
        return;
      }
      
      // Attempt authentication
      final bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access your expense tracker',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      
      if (!mounted) return;
      
      setState(() {
        _isAuthenticating = false;
        _authComplete = authenticated;
      });
      
      if (!authenticated) {
        // Show message if authentication failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Try again after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_authComplete) {
            _authenticate();
          }
        });
      }
    } on PlatformException catch (e) {
      print("Error during authentication: $e");
      // If there's an error, allow access
      setState(() {
        _isAuthenticating = false;
        _authComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while authenticating
    if (_isAuthenticating) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fingerprint,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Authenticating...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
              const SizedBox(height: 36),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isAuthenticating = false;
                    _authComplete = true;
                  });
                },
                child: const Text('Skip Authentication'),
              ),
            ],
          ),
        ),
      );
    }
    
    // Authentication failed screen
    if (!_authComplete) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                'Authentication Failed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _authenticate();
                },
                child: const Text('Try Again'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _authComplete = true;
                  });
                },
                child: const Text('Skip Authentication'),
              ),
            ],
          ),
        ),
      );
    }
    
    // If authentication succeeded or was skipped, show main app
    return const MainApp();
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final List<Widget> pages = [
    const MyHomePage(),
    const MyProfilePage(),
    const MySettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MyPageIndex>(
      builder: (context, pageIndex, child) {
        return Scaffold(
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (index) {
              pageIndex.getPage(index);
            },
            selectedIndex: pageIndex.pageNum,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
          body: pages[pageIndex.pageNum],
        );
      },
    );
  }
}