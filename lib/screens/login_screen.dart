import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../services/auth_service.dart';
import '../../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  String phoneNumber = '';
  String accessCode = '';
  bool isLoading = false;
  bool isCodeRequested = false;
  int _resendTimer = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 48),
              Icon(
                Icons.admin_panel_settings,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 24),
              Text(
                'Admin Login',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 16),
              Text(
                'Enter your phone number to receive an access code',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 48),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          phoneNumber = number.phoneNumber ?? '';
                        },
                        selectorConfig: SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        ),
                        inputDecoration: InputDecoration(
                          hintText: 'Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        spaceBetweenSelectorAndTextField: 0,
                        isEnabled: !isCodeRequested,
                      ),
                      if (isCodeRequested) ...[
                        SizedBox(height: 24),
                        Text(
                          'Enter the 6-digit code sent to your phone',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 16),
                        PinCodeTextField(
                          appContext: context,
                          length: 6,
                          onChanged: (value) {
                            accessCode = value;
                            if (value.length == 6) {
                              _handleLogin();
                            }
                          },
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(8),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeFillColor: Theme.of(context).cardColor,
                            selectedFillColor: Theme.of(context).cardColor,
                            inactiveFillColor: Theme.of(context).cardColor,
                            activeColor: Theme.of(context).primaryColor,
                            selectedColor: Theme.of(context).primaryColor,
                            inactiveColor: Colors.grey,
                          ),
                          enableActiveFill: true,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16),
                        if (_resendTimer > 0)
                          Text(
                            'Resend code in $_resendTimer seconds',
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        else
                          TextButton(
                            onPressed: _requestCode,
                            child: Text('Resend Code'),
                          ),
                      ],
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : isCodeRequested
                            ? _handleLogin
                            : _requestCode,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          isCodeRequested ? 'Verify Code' : 'Request Code',
                        ),
                      ),
                      if (isCodeRequested) ...[
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isCodeRequested = false;
                              accessCode = '';
                            });
                          },
                          child: Text('Change Phone Number'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestCode() async {
    if (phoneNumber.isEmpty) {
      _showError('Please enter a phone number');
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authService.requestAccessCode(phoneNumber);

      setState(() {
        isCodeRequested = true;
        _resendTimer = 60;
      });

      // Start countdown timer
      _startResendTimer();

    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        if (_resendTimer > 0) _resendTimer--;
      });

      return _resendTimer > 0;
    });
  }

  Future<void> _handleLogin() async {
    if (phoneNumber.isEmpty || accessCode.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await _authService.signInWithPhoneAndCode(
        phoneNumber,
        accessCode,
      );

      if (user != null) {
        // Update UserProvider with current user
        context.read<UserProvider>().setCurrentUser(user);

        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
}