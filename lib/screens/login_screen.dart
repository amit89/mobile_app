import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../widgets/common_app_bar.dart';
import 'phone_login_screen.dart';
import '../config/config.dart';

// Define the enum at the top level
enum LoginMode { selection, admin, retail }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginMode _loginMode = LoginMode.selection;
  
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitAdminLoginForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // For admin, only allow specific phone number and password from config
      if (FirebaseConfig.validateAdminCredentials(
          phoneOrEmail: _phoneController.text, 
          password: _passwordController.text)) {
        final success = authProvider.login(
          emailOrMobile: _phoneController.text,
          password: _passwordController.text,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin login successful!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/home');
        } else {
          setState(() {
            _errorMessage = 'Authentication failed. Please try again.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid admin credentials. Only authorized admin users can login.';
        });
      }
    }
  }
  
  void _goToRetailUserLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PhoneLoginScreen(),
      ),
    );
  }
  
  void _resetToSelectionMode() {
    setState(() {
      _loginMode = LoginMode.selection;
      _errorMessage = null;
      _phoneController.clear();
      _passwordController.clear();
    });
  }

  Widget _buildLoginOptionsScreen() {
    return Column(
      children: [
        const Text(
          'Choose Login Type',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        
        // Admin Login Option
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _loginMode = LoginMode.admin;
            });
          },
          icon: const Icon(Icons.admin_panel_settings),
          label: const Text('Login as Admin User'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        const Center(child: Text('OR')),
        const SizedBox(height: 16),
        
        // Retail User Login Option
        ElevatedButton.icon(
          onPressed: _goToRetailUserLogin,
          icon: const Icon(Icons.person),
          label: const Text('Login as Retail User'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        const SizedBox(height: 40),
      ],
    );
  }
  
  Widget _buildAdminLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Admin Login',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          // Phone Number Field
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter admin phone number',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter admin phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter admin password',
              prefixIcon: const Icon(Icons.lock),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible 
                    ? Icons.visibility_off 
                    : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            obscureText: !_isPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter admin password';
              }
              return null;
            },
          ),
          
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            
          const SizedBox(height: 24),

          // Login Button
          ElevatedButton(
            onPressed: () => _submitAdminLoginForm(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Back to selection
          TextButton(
            onPressed: _resetToSelectionMode,
            child: const Text('Back to Login Options'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Login',
        showBackButton: false, // Don't show back button on login screen
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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

            if (_loginMode == LoginMode.selection) 
              _buildLoginOptionsScreen()
            else if (_loginMode == LoginMode.admin) 
              _buildAdminLoginForm(),
              
            // Return to home link
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Continue shopping without login'),
            ),
          ],
        ),
      ),
    );
  }
}