import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  const ActiveDeliveryScreen({super.key});

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  StreamSubscription<Position>? _positionStream;
  String? _activeOrderId;

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _startLocationTracking(String orderId) async {
    if (_positionStream != null && _activeOrderId == orderId) return; // Already tracking
    _activeOrderId = orderId;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        _positionStream = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          if (_activeOrderId != null) {
            FirebaseFirestore.instance.collection('orders').doc(_activeOrderId).update({
              'delivery_location': {
                'lat': position.latitude,
                'lng': position.longitude,
                'heading': position.heading,
              }
            });
          }
        });
      }
    } catch (_) {}
  }

  void _stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _activeOrderId = null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      children: [
        // Map Placeholder / Header
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delivery_dining, size: 64, color: Color(0xFFFF9800)),
                    const SizedBox(height: 8),
                    Text(
                      'Live GPS Navigation & Delivery Route',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bhabua, Kaimur District',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Active Order Details
        Expanded(
          flex: 6,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('status', isEqualTo: 'picked_up')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

              final allPickedUpDocs = snapshot.data?.docs ?? [];
              
              // Filter for current user if set, or allow fallback to all picked_up orders
              final docs = allPickedUpDocs.where((doc) {
                final d = doc.data() as Map<String, dynamic>;
                final partnerId = d['delivery_partner_id'] as String?;
                if (partnerId == null || partnerId.isEmpty || currentUserId == null) return true;
                return partnerId == currentUserId || partnerId == 'delivery_boy_1';
              }).toList();

              if (docs.isEmpty) {
                _stopLocationTracking();
                return Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 56, color: Colors.green.shade400),
                        const SizedBox(height: 12),
                        const Text("No active deliveries in progress", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text("Go to 'Home' tab to pick up newly prepared orders.", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              }

              final doc = docs.first;
              final data = doc.data() as Map<String, dynamic>;
              final orderId = data['order_id'] ?? '#${doc.id.substring(0, doc.id.length > 8 ? 8 : doc.id.length)}';
              final customerName = data['customerName'] ?? 'Customer';
              final customerPhone = data['customerPhone'] ?? 'Not provided';
              final customerAddress = data['customerAddress'] ?? 'Bhabua, Bihar';
              final merchantName = data['merchantName'] ?? data['vendor_name'] ?? 'Restaurant';
              final amount = (data['total_amount'] ?? data['amount'] ?? 0).toDouble();
              final paymentMethod = data['payment_method'] ?? 'Cash on Delivery';
              final isCod = paymentMethod.toLowerCase().contains('cash');

              final rawItems = (data['items'] as List<dynamic>?) ?? [];
              final itemsSummary = rawItems.map((e) {
                if (e is Map<String, dynamic>) {
                  return '${e['qty'] ?? 1}x ${e['name'] ?? 'Item'}';
                }
                return e.toString();
              }).join(', ');

              _startLocationTracking(doc.id);

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Out For Delivery 🛵", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            Text("From: $merchantName", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(10)),
                          child: Text(orderId, style: const TextStyle(color: Color(0xFFFF6D00), fontWeight: FontWeight.bold, fontSize: 12)),
                        )
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Customer details
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.blue.shade100,
                                child: const Icon(Icons.person, color: Colors.blue, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text("Phone: $customerPhone", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                                child: const Icon(Icons.phone, color: Colors.green, size: 20),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  customerAddress,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (itemsSummary.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text("Items: $itemsSummary", style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],

                    const SizedBox(height: 12),

                    // Cash Collection Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCod ? Colors.amber.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isCod ? Colors.amber.shade300 : Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(isCod ? Icons.monetization_on : Icons.check_circle, color: isCod ? Colors.amber.shade900 : Colors.green, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                isCod ? 'Collect Cash on Delivery:' : 'Prepaid Order:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isCod ? Colors.amber.shade900 : Colors.green.shade900),
                              ),
                            ],
                          ),
                          Text(
                            '₹${amount.toStringAsFixed(0)}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isCod ? Colors.amber.shade900 : Colors.green.shade900),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection('orders').doc(doc.id).update({
                            'status': 'Delivered',
                            'delivered_at': FieldValue.serverTimestamp(),
                            'payment_status': 'Paid',
                          });
                          _stopLocationTracking();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Order marked as Delivered successfully!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.done_all, color: Colors.white),
                        label: const Text("Mark as Delivered", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ).animate().slideY(begin: 0.5, duration: 400.ms, curve: Curves.easeOutCubic),
        ),
      ],
    );
  }
}
