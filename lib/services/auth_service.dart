import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Get user stream
  Stream<User?> get userStream => _auth.authStateChanges();

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;
  
  // Phone sign-in
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onVerificationComplete,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: onVerificationComplete,
        verificationFailed: (FirebaseAuthException e) {
          print('Phone verification failed: ${e.message}');
          print('Error code: ${e.code}');
          print('Error details: ${e.toString()}');
          onVerificationFailed(e);
        },
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Code auto retrieval timeout for ID: $verificationId');
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('Unexpected error in verifyPhoneNumber: $e');
      throw e;
    }
  }

  // Sign in with phone credential
  Future<UserCredential> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }
  
  // Sign in with OTP verification code
  Future<UserCredential> verifyOTPAndLogin(String verificationId, String smsCode) async {
    try {
      print('AuthService: Creating credential with verification ID and SMS code');
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      print('AuthService: Signing in with credential');
      // Sign in (or link) the user with the credential
      final userCredential = await _auth.signInWithCredential(credential);
      print('AuthService: Sign in successful, user ID: ${userCredential.user?.uid}');
      
      return userCredential;
    } catch (e) {
      print('AuthService: Error in verifyOTPAndLogin: $e');
      print('AuthService: Error details: ${e.toString()}');
      
      if (e is FirebaseAuthException) {
        print('AuthService: Firebase Auth error code: ${e.code}');
      }
      
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
