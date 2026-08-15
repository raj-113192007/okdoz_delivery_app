import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFFF9800),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text("Ramesh Kumar", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("4.9 ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Icon(Icons.star, color: Colors.green, size: 16),
                  ],
                ),
              )
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.1),
        
        const SizedBox(height: 32),
        
        _buildProfileOption(context, Icons.motorcycle, "Vehicle Details", "Honda Activa (KA-01-AB-1234)"),
        _buildProfileOption(context, Icons.history, "Delivery History", "View past trips"),
        _buildProfileOption(context, Icons.settings, "App Settings", "Language, Theme, Notifications", onTap: () => _showSettingsDialog(context)),
        _buildProfileOption(context, Icons.help_outline, "Help & Support", "Contact dispatch or read FAQs"),
        
        const SizedBox(height: 32),
        
        ElevatedButton(
          onPressed: () {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mock Logout Successful!")));
             Navigator.pushReplacementNamed(context, '/auth');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
          ),
          child: const Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ).animate().fadeIn(delay: 500.ms)
      ],
    );
  }

  Widget _buildProfileOption(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () {},
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05);
  }

  void _showSettingsDialog(BuildContext context) {
    String selectedLanguage = 'English';
    String selectedTheme = 'Light';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("App Settings", style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Language", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("English"),
                            value: 'English',
                            // ignore: deprecated_member_use
                            groupValue: selectedLanguage,
                            // ignore: deprecated_member_use
                            onChanged: (val) => setState(() => selectedLanguage = val!),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("हिंदी"),
                            value: 'Hindi',
                            // ignore: deprecated_member_use
                            groupValue: selectedLanguage,
                            // ignore: deprecated_member_use
                            onChanged: (val) => setState(() => selectedLanguage = val!),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    const Text("Theme", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("Light"),
                            value: 'Light',
                            // ignore: deprecated_member_use
                            groupValue: selectedTheme,
                            // ignore: deprecated_member_use
                            onChanged: (val) => setState(() => selectedTheme = val!),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("Dark"),
                            value: 'Dark',
                            // ignore: deprecated_member_use
                            groupValue: selectedTheme,
                            // ignore: deprecated_member_use
                            onChanged: (val) => setState(() => selectedTheme = val!),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Settings Saved: $selectedLanguage, $selectedTheme Theme"),
                    ));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9800)),
                  child: const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
