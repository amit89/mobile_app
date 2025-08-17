import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../widgets/common_app_bar.dart';
import 'otp_verification_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phoneNumber) {
    // Format phone number to E.164 format (e.g., +91XXXXXXXXXX)
    // This assumes an Indian phone number format
    if (!phoneNumber.startsWith('+')) {
      if (phoneNumber.startsWith('0')) {
        phoneNumber = '+91${phoneNumber.substring(1)}';
      } else {
        phoneNumber = '+91$phoneNumber';
      }
    }
    return phoneNumber;
  }

  Future<void> _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final formattedPhoneNumber = _formatPhoneNumber(_phoneController.text.trim());
      print('Sending OTP to: $formattedPhoneNumber');

      try {
        // Use the Firebase Auth directly instead of through the service
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: formattedPhoneNumber,
          timeout: const Duration(seconds: 60),
          forceResendingToken: null,
          codeAutoRetrievalTimeout: (String verificationId) {
            print('Auto retrieval timeout: $verificationId');
          },
          verificationCompleted: (PhoneAuthCredential credential) async {
            print('Auto-verification completed');
            // Auto-verification completed (mostly on Android)
            setState(() {
              _isLoading = false;
            });
            
            try {
              final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
              if (mounted && userCredential.user != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Login successful!'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.go('/home');
              }
            } catch (e) {
              print('Error in auto-verification: $e');
              setState(() {
                _errorMessage = 'Error signing in: $e';
              });
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            print('Verification failed: ${e.code} - ${e.message}');
            print('Error details: ${e.toString()}');
            setState(() {
              _isLoading = false;
              if (e.code == 'invalid-phone-number') {
                _errorMessage = 'The provided phone number is not valid.';
              } else if (e.code == 'too-many-requests') {
                _errorMessage = 'Too many requests. Try again later.';
              } else if (e.code == 'app-not-authorized') {
                _errorMessage = 'This app is not authorized to use Firebase Authentication with the provided API key. Add your SHA-1 certificate to Firebase console.';
              } else if (e.message?.contains('region enabled') ?? false) {
                _errorMessage = 'Phone authentication for this region (India) requires upgrading to the Blaze plan in Firebase.';
              } else {
                _errorMessage = 'Error: ${e.message}';
              }
            });
          },
          codeSent: (String verificationId, int? resendToken) {
            print('OTP code sent to $formattedPhoneNumber');
            setState(() {
              _isLoading = false;
            });
            
            // Navigate to OTP verification screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(
                  phoneNumber: formattedPhoneNumber,
                  verificationId: verificationId,
                ),
              ),
            );
          },
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error sending OTP: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Retail User Login'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo or App Name
              const SizedBox(height: 40),
              Text(
                'GreenGrab',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 40),

              const Text(
                'Retail User Login',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              Text(
                'Enter your phone number to receive a verification code',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '10-digit mobile number',
                  prefixIcon: Icon(Icons.phone),
                  prefixText: '+91 ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  // Basic validation for Indian mobile numbers
                  if (value.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                    return 'Enter a valid 10-digit mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Send OTP Button
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Send OTP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              // Back to Email Login
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Login Options'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
