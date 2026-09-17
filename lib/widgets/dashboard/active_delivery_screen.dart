import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    if (_positionStream != null && _activeOrderId == orderId) return; // Already tracking this order
    _activeOrderId = orderId;
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // update every 10 meters
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
  }

  void _stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _activeOrderId = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mock Map Placeholder
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            color: Colors.blueGrey[100],
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.map, size: 100, color: Colors.white),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: () {},
                    child: const Icon(Icons.my_location, color: Colors.black),
                  ),
                )
              ],
            ),
          ),
        ),
        
        // Active Order Details
        Expanded(
          flex: 5,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').where('status', isEqualTo: 'picked_up').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('courier_orders')
                      .where('status', isEqualTo: 'out_for_delivery')
                      .snapshots(),
                  builder: (context, courierSnapshot) {
                    if (courierSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final currentUid = FirebaseAuth.instance.currentUser?.uid;
                    final courierDocs = (courierSnapshot.data?.docs ?? []).where((d) {
                      final cData = d.data() as Map<String, dynamic>;
                      final agentId = cData['delivery_agent_id']?.toString();
                      return agentId == null || agentId.isEmpty || agentId == currentUid;
                    }).toList();

                    if (courierDocs.isEmpty) {
                      _stopLocationTracking();
                      return const Center(child: Text("No active deliveries.", style: TextStyle(color: Colors.grey)));
                    }

                    final cDoc = courierDocs.first;
                    final cData = cDoc.data() as Map<String, dynamic>;
                    final price = cData['delivery_price'] ?? cData['total_amount'] ?? 0;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Courier in Transit", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(10)),
                                child: Text("COURIER #${cDoc.id.substring(0, 5).toUpperCase()}", style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(backgroundColor: Colors.amber.shade800, child: const Icon(Icons.local_shipping, color: Colors.white)),
                            title: Text("Receiver: ${cData['receiver_name'] ?? 'Recipient'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Drop: ${cData['drop_address'] ?? 'Address'}\nPhone: ${cData['receiver_phone'] ?? 'N/A'}"),
                            trailing: Text("₹$price", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                          ),
                          const Divider(),
                          Text("Status: Out for Delivery | Sender: ${cData['sender_name'] ?? 'N/A'}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance.collection('courier_orders').doc(cDoc.id).update({
                                  'status': 'delivered',
                                  'delivered_at': FieldValue.serverTimestamp(),
                                });
                                _stopLocationTracking();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Courier Marked as Delivered! Great job!")));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text("Mark Courier Delivered", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              
              final doc = docs.first;
              final data = doc.data() as Map<String, dynamic>;
              
              // Start tracking for this order
              _startLocationTracking(doc.id);

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("On the way to Customer", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(10)),
                          child: Text("Order #${doc.id.substring(0, 5)}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
                      title: Text("User ID: ${data['user_id'] ?? 'Unknown'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Deliver to user location"),
                      trailing: const Icon(Icons.phone, color: Colors.green),
                    ),
                    const Divider(),
                    const Text("Status: Picked Up", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const Spacer(),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                           FirebaseFirestore.instance.collection('orders').doc(doc.id).update({
                             'status': 'Delivered',
                             'delivered_at': FieldValue.serverTimestamp(),
                           });
                           _stopLocationTracking();
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Marked as Delivered!")));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("Mark as Delivered", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ).animate().slideY(begin: 1.0, duration: 500.ms, curve: Curves.easeOutCubic),
        ),
      ],
    );
  }
}
