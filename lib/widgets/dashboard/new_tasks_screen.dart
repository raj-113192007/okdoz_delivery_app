import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/job_details_screen.dart';

class NewTasksScreen extends StatefulWidget {
  const NewTasksScreen({super.key});

  @override
  State<NewTasksScreen> createState() => _NewTasksScreenState();
}

class _NewTasksScreenState extends State<NewTasksScreen> {
  bool _isOnline = false;

  void _toggleStatus() {
    setState(() {
      _isOnline = !_isOnline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Top Status Toggle Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            children: [
              Text(
                _isOnline ? "You're Online" : "You're Offline",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _isOnline ? Colors.green : Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                _isOnline ? "Waiting for new delivery requests..." : "Go online to start earning.",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _toggleStatus,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.redAccent : Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _isOnline ? "GO OFFLINE" : "GO ONLINE",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

        const SizedBox(height: 20),

        // Quick Metrics
        Row(
          children: [
            Expanded(child: _buildMetricCard("Hours Logged", "5.5 Hrs", Icons.access_time, Colors.blue)),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard("Trips Completed", "8", Icons.check_circle, Colors.orange)),
          ],
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 24),

        // Assigned Courier Orders from Firestore
        if (_isOnline) ...[
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('courier_orders')
                .where('status', isEqualTo: 'price_set')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
              final currentUid = FirebaseAuth.instance.currentUser?.uid;
              final docs = snapshot.data!.docs.where((d) {
                final data = d.data() as Map<String, dynamic>;
                final agentId = data['delivery_agent_id']?.toString();
                return agentId == null || agentId.isEmpty || agentId == currentUid;
              }).toList();

              if (docs.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      'Assigned Courier Requests',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF9800)),
                    ),
                  ),
                  ...docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final price = data['delivery_price'] ?? data['total_amount'] ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFF9800), width: 2),
                        boxShadow: [BoxShadow(color: const Color(0xFFFF9800).withValues(alpha: 0.15), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(20)),
                                child: Text('COURIER #${doc.id.substring(0, 5).toUpperCase()}', style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              Text('₹$price', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTimelineRow('Pickup', '${data['sender_name'] ?? 'Sender'} (${data['pickup_address'] ?? 'No Address'})', 'Pickup'),
                          const Padding(
                            padding: EdgeInsets.only(left: 12.0),
                            child: SizedBox(height: 16, child: VerticalDivider(color: Colors.grey, thickness: 2)),
                          ),
                          _buildTimelineRow('Drop', '${data['receiver_name'] ?? 'Receiver'} (${data['drop_address'] ?? 'No Address'})', 'Drop-off'),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.two_wheeler, color: Colors.white),
                              label: const Text('Accept & Start Delivery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF9800),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () async {
                                await FirebaseFirestore.instance.collection('courier_orders').doc(doc.id).update({
                                  'status': 'out_for_delivery',
                                  'picked_up_at': FieldValue.serverTimestamp(),
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Courier trip started! Track delivery in Active tab.')),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.1);
                  }),
                  const Divider(height: 32),
                ],
              );
            },
          ),
        ],

        // Incoming Food & Store Orders from Firestore
        if (_isOnline)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').where('status', isEqualTo: 'Ready').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("No new requests at the moment.", style: TextStyle(color: Colors.grey)),
                );
              }
              
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const JobDetailsScreen()));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFF9800), width: 2),
                        boxShadow: [BoxShadow(color: const Color(0xFFFF9800).withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 2)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(20)),
                                child: Text("NEW REQUEST #${doc.id.substring(0, 5)}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              const Text("Delivery", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTimelineRow("Pickup", "Restaurant ID: ${data['vendor_id']}", "2.5 km away"),
                          const Padding(
                            padding: EdgeInsets.only(left: 12.0),
                            child: SizedBox(height: 20, child: VerticalDivider(color: Colors.grey, thickness: 2)),
                          ),
                          _buildTimelineRow("Drop-off", "User ID: ${data['user_id']}", "4.0 km total"),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {}, // Optional: ignore/decline locally
                                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.red)),
                                  child: const Text("Decline", style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance.collection('orders').doc(doc.id).update({
                                      'status': 'picked_up',
                                      'picked_up_at': FieldValue.serverTimestamp(),
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Picked Up! Check Active tab.")));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text("Accept & Pick Up", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2).shakeX(amount: 3),
                  );
                }).toList(),
              );
            },
          )
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(String title, String subtitle, String distance) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.grey, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
        Text(distance, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
