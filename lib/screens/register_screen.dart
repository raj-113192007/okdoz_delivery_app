import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  String? _verificationId;

  // Password condition states
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  void _sendOTP() async {
    // Disabled validation for UI testing
    /*
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid phone number with country code (e.g., +91)')));
      return;
    }

    if (!_isPasswordValid()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please meet all password requirements.')));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }
    */

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Mock delay
    
    setState(() {
      _verificationId = 'mock_verification_id';
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mock OTP Sent!')));
    }
  }

  void _verifyAndRegister() async {
    if (_verificationId == null) return;
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Mock delay
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registered Successfully (UI Only)')));
      Navigator.pop(context); // Go back to login
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFFF9800)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildConditionRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Partner Registration', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Join OK DOZ Delivery Team!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9800),
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
            
            const SizedBox(height: 10),
            const Text(
              'Fill in your details to start earning.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2, end: 0),
            
            const SizedBox(height: 32),

            if (_verificationId == null) ...[
              _buildTextField(controller: _nameController, label: 'Full Name', icon: Icons.person).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2, end: 0),
              const SizedBox(height: 16),
              _buildTextField(controller: _emailController, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2, end: 0),
              const SizedBox(height: 16),
              _buildTextField(controller: _phoneController, label: 'Mobile Number (e.g. +91...)', icon: Icons.phone, keyboardType: TextInputType.phone).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2, end: 0),
              const SizedBox(height: 16),
              _buildTextField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline, isPassword: true).animate().fadeIn(delay: 600.ms).slideX(begin: 0.2, end: 0),
              
              // Dynamic Password Strength Checker
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConditionRow('At least 8 characters', _hasMinLength),
                  _buildConditionRow('At least 1 uppercase letter', _hasUppercase),
                  _buildConditionRow('At least 1 number', _hasNumber),
                  _buildConditionRow('At least 1 special character', _hasSpecialChar),
                ],
              ).animate().fadeIn(delay: 650.ms),

              const SizedBox(height: 16),
              _buildTextField(controller: _confirmPasswordController, label: 'Confirm Password', icon: Icons.lock_outline, isPassword: true).animate().fadeIn(delay: 700.ms).slideX(begin: 0.2, end: 0),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black))
                    : const Text('Send OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ).animate().fadeIn(delay: 800.ms).scale(),
            ] else ...[
              const Text(
                'Enter the OTP sent to your mobile number.',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ).animate().fadeIn(),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _otpController, 
                label: 'OTP Code', 
                icon: Icons.message, 
                keyboardType: TextInputType.number
              ).animate().fadeIn().slideX(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyAndRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black))
                    : const Text('Verify & Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ).animate().fadeIn().scale(),
            ]
          ],
        ),
      ),
    );
  }
}
