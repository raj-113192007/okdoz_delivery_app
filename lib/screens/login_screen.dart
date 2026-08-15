import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isEmailLogin = true;
  String? _verificationId;

  void _loginWithEmail() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Mock delay
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Successful (UI Only)')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    }
  }

  void _sendOTP() async {
    final phone = _identifierController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid phone number or email')));
      return;
    }

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

  void _verifyOTP() async {
    if (_verificationId == null) return;
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(seconds: 1)); // Mock delay
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP Verified Successfully (UI Only)')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6D9),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      child: SafeArea(
                        bottom: false,
                        child: Stack(
                          children: [
                             Center(
                               child: Padding(
                                 padding: const EdgeInsets.all(20.0),
                                 child: Image.asset('assets/delivery_illustration.png')
                                    .animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                               ),
                             ),
                             Positioned(
                               top: 16,
                               right: 16,
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                 decoration: BoxDecoration(
                                   color: const Color(0xFFFF9800),
                                   borderRadius: BorderRadius.circular(8),
                                 ),
                                 child: const Text('A/अ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                               ).animate().fadeIn(delay: 400.ms),
                             ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Start delivering orders\nwith OK DOZ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 32),
                          
                          // 1. Identifier Input (Email or Phone)
                          _buildTextField(
                            controller: _identifierController, 
                            label: 'Phone Number or Email', 
                            icon: Icons.person_outline, 
                          ).animate().fadeIn(delay: 200.ms),
                          
                          const SizedBox(height: 20),
                          
                          // 2. Options for Sign In Method
                          const Text(
                            'Sign in using:',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ).animate().fadeIn(delay: 300.ms),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: const Center(child: Text('Password')),
                                  selected: _isEmailLogin,
                                  selectedColor: const Color(0xFFFF9800),
                                  labelStyle: TextStyle(
                                    color: _isEmailLogin ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  backgroundColor: Colors.grey[200],
                                  onSelected: (val) => setState(() {
                                    _isEmailLogin = true;
                                    _verificationId = null;
                                  }),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Center(child: Text('OTP')),
                                  selected: !_isEmailLogin,
                                  selectedColor: const Color(0xFFFF9800),
                                  labelStyle: TextStyle(
                                    color: !_isEmailLogin ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  backgroundColor: Colors.grey[200],
                                  onSelected: (val) => setState(() {
                                    _isEmailLogin = false;
                                  }),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 400.ms),
                          
                          const SizedBox(height: 24),

                          // 3. Dynamic Fields based on selection
                          if (_isEmailLogin) ...[
                            _buildTextField(
                              controller: _passwordController, 
                              label: 'Password', 
                              icon: Icons.lock_outline, 
                              isPassword: true
                            ).animate().fadeIn(),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _loginWithEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF9800),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading 
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black))
                                  : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ).animate().fadeIn().scale(),
                          ] else ...[
                            if (_verificationId == null) ...[
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
                                    : const Text('Get OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ).animate().fadeIn().scale(),
                            ] else ...[
                              _buildTextField(
                                controller: _otpController, 
                                label: 'Enter OTP', 
                                icon: Icons.message, 
                                keyboardType: TextInputType.number
                              ).animate().fadeIn(),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _verifyOTP,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9800),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isLoading 
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black))
                                    : const Text('Verify & Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ).animate().fadeIn().scale(),
                            ]
                          ],
                          
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                            },
                            child: const Text(
                              "Don't have an account? Register",
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ).animate().fadeIn(delay: 600.ms),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
