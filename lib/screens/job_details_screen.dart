import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Job Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Mock Map Background
          Positioned.fill(
            child: Container(
              color: Colors.grey.shade300,
              child: const Center(
                child: Text('Map View', style: TextStyle(color: Colors.grey, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          
          // Job Details Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order #10293', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 16),
                  _buildTimelineItem('Pickup', 'Food Paradise', '123 Restaurant Lane', isCompleted: true),
                  _buildTimelineItem('Dropoff', 'Customer Home', '456 Tech Park, Block C', isCompleted: false, isLast: true),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimated Earnings:', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const Text('₹65', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Swiped to Arrive!')));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('Swipe to Arrive at Dropoff', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ).animate().slideY(begin: 1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
          )
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String type, String title, String address, {bool isCompleted = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(isCompleted ? Icons.check_circle : Icons.radio_button_unchecked, color: isCompleted ? Colors.green : Colors.orange),
            if (!isLast) Container(height: 40, width: 2, color: isCompleted ? Colors.green : Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(address, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 16),
            ],
          ),
        )
      ],
    );
  }
}
