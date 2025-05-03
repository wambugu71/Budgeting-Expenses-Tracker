import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricAuthService extends StatefulWidget {
  final String title;
  final Function(bool) onAuthentication;
  final Widget authSuccessScreen;
  final bool authOnStartup;

  const BiometricAuthService({
    super.key,
    required this.title,
    required this.onAuthentication,
    required this.authSuccessScreen,
    this.authOnStartup = true,
  });

  @override
  State<BiometricAuthService> createState() => _BiometricAuthServiceState();
}

class _BiometricAuthServiceState extends State<BiometricAuthService> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isAuthenticating = false;
  String _authStatus = 'Not authenticated';
  bool _supportState = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _getAvailableBiometrics();
    _checkSupport();
    
    if (widget.authOnStartup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _authenticate();
      });
    }
  }

  Future<void> _checkSupport() async {
    bool supportState;
    try {
      supportState = await auth.isDeviceSupported();
    } on PlatformException catch (e) {
      supportState = false;
      print("Error checking device support: $e");
    }
    if (!mounted) return;

    setState(() {
      _supportState = supportState;
    });
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print("Error checking biometrics: $e");
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print("Error getting available biometrics: $e");
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    if (!_supportState || !_canCheckBiometrics) {
      // If biometrics not supported, succeed by default for usability
      if (mounted) {
        widget.onAuthentication(true);
      }
      return;
    }

    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authStatus = 'Authenticating...';
      });
      
      authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access your expense tracker',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      
      setState(() {
        _isAuthenticating = false;
        _authStatus = authenticated ? 'Authenticated' : 'Not authenticated';
      });
    } on PlatformException catch (e) {
      print("Authentication error: $e");
      setState(() {
        _isAuthenticating = false;
        _authStatus = 'Error: ${e.message}';
      });
      
      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled ||
          e.code == auth_error.passcodeNotSet) {
        // If biometrics not enrolled, succeed by default for usability
        authenticated = true;
      }
    }

    if (mounted) {
      widget.onAuthentication(authenticated);
    }
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() {
      _isAuthenticating = false;
      _authStatus = 'Authentication canceled';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Icon(
              _getBiometricIcon(),
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 30),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Please authenticate to continue',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 50),
            if (!_isAuthenticating)
              ElevatedButton(
                onPressed: _authenticate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Authenticate'),
              ),
            if (_isAuthenticating)
              ElevatedButton(
                onPressed: _cancelAuthentication,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                widget.onAuthentication(true);
              },
              child: Text(
                'Skip authentication',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else {
      return Icons.lock;
    }
  }
}