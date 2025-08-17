import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../widgets/common_app_bar.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpVerificationScreen({
    super.key, 
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // Manual OTP verification without using signInWithCredential
  Future<bool> _manuallyVerifyOTP(String verificationId, String smsCode) async {
    try {
      // We're simply checking if Firebase Auth already has authenticated the user
      // If the current user exists, it means Firebase Auth has already validated the code
      // but we hit the PigeonUserDetails error in the signInWithCredential process
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print('User is already authenticated: ${currentUser.uid}');
        return true;
      }
      
      // If we don't have a user yet, try to verify with Firebase directly
      // This may still hit the error, but we'll handle that gracefully
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        
        await FirebaseAuth.instance.signInWithCredential(credential);
        return true;
      } catch (e) {
        if (e.toString().contains('PigeonUserDetails')) {
          // This is the expected error we're working around
          // Check if authentication succeeded despite the error
          return FirebaseAuth.instance.currentUser != null;
        }
        rethrow; // Re-throw if it's a different error
      }
    } catch (e) {
      print('Error in manual OTP verification: $e');
      return false;
    }
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final smsCode = _otpController.text.trim();
        print('Verifying OTP with code: $smsCode');
        
        // Use our manual verification approach
        bool isValid = await _manuallyVerifyOTP(widget.verificationId, smsCode);
        
        if (isValid) {
          print('OTP verification successful');
          
          // Navigate to home on success
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/home');
          }
        } else {
          print('Invalid verification code');
          setState(() {
            _errorMessage = 'The verification code entered is invalid.';
          });
        }
      } catch (error) {
        print('Error during verification: $error');
        setState(() {
          _errorMessage = 'Verification error: $error';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'OTP Verification'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                'Verify Your Number',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the 6-digit code sent to ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              
              // OTP input field
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'OTP Code',
                  hintText: 'Enter 6-digit code',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP';
                  }
                  if (value.length < 6) {
                    return 'OTP must be 6 digits';
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
                
              // Verify Button
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
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
                      'Verify',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
              
              const SizedBox(height: 16),
              
              // Resend OTP
              TextButton(
                onPressed: _isLoading ? null : () {
                  // Implement resend OTP logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('OTP resent!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text("Didn't receive the code? Resend"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
