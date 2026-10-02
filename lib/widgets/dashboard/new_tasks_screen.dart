import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NewTasksScreen extends StatefulWidget {
  const NewTasksScreen({super.key});

  @override
  State<NewTasksScreen> createState() => _NewTasksScreenState();
}

class _NewTasksScreenState extends State<NewTasksScreen> {
  bool _isOnline = true;

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
                _isOnline ? "Listening for ready delivery orders in Bhabua..." : "Go online to start receiving orders.",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _toggleStatus,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.redAccent : Colors.green,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _isOnline ? "GO OFFLINE" : "GO ONLINE",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

        const SizedBox(height: 16),

        // Quick Metrics
        Row(
          children: [
            Expanded(child: _buildMetricCard("Hours Logged", "5.5 Hrs", Icons.access_time, Colors.blue)),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard("Trips Completed", "8", Icons.check_circle, Colors.orange)),
          ],
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 20),

        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Available Pickups (Ready)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            if (_isOnline)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text("LIVE", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

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
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('status', isEqualTo: 'Ready')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()));
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.delivery_dining_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text("No ready orders waiting right now.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Orders marked 'Ready' by restaurants will appear here automatically.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final orderId = data['order_id'] ?? '#${doc.id.substring(0, doc.id.length > 8 ? 8 : doc.id.length)}';
                  final merchantName = data['merchantName'] ?? data['vendor_name'] ?? 'Restaurant';
                  final merchantAddress = data['vendor_address'] ?? 'Bhabua Market';
                  final customerName = data['customerName'] ?? 'Customer';
                  final customerAddress = data['customerAddress'] ?? 'Bhabua';
                  final customerPhone = data['customerPhone'] ?? '';
                  final amount = (data['total_amount'] ?? data['amount'] ?? 0).toDouble();
                  final paymentMethod = data['payment_method'] ?? 'Cash on Delivery';

                  final rawItems = (data['items'] as List<dynamic>?) ?? [];
                  final itemsSummary = rawItems.map((e) {
                    if (e is Map<String, dynamic>) {
                      return '${e['qty'] ?? 1}x ${e['name'] ?? 'Item'}';
                    }
                    return e.toString();
                  }).join(', ');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
                      boxShadow: [BoxShadow(color: const Color(0xFFFF9800).withValues(alpha: 0.15), blurRadius: 12, spreadRadius: 1)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                orderId,
                                style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                'Food Ready 🍲',
                                style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Timeline (Pickup from Restaurant -> Drop at Customer)
                        _buildTimelineRow(
                          Icons.storefront_outlined,
                          Colors.blue,
                          "Pickup: $merchantName",
                          merchantAddress,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 11.0),
                          child: SizedBox(height: 16, child: VerticalDivider(color: Colors.grey, thickness: 1.5)),
                        ),
                        _buildTimelineRow(
                          Icons.location_on,
                          Colors.redAccent,
                          "Drop-off: $customerName",
                          customerAddress,
                        ),

                        if (itemsSummary.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.blueGrey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    itemsSummary,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Order Total ($paymentMethod)', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF6D00))),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final user = FirebaseAuth.instance.currentUser;
                                  await FirebaseFirestore.instance.collection('orders').doc(doc.id).update({
                                    'status': 'picked_up',
                                    'delivery_partner_id': user?.uid ?? 'delivery_boy_1',
                                    'delivery_partner_name': user?.displayName ?? 'Ankit Kumar (Rider)',
                                    'delivery_partner_phone': user?.phoneNumber ?? customerPhone,
                                    'picked_up_at': FieldValue.serverTimestamp(),
                                  });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Order Picked Up! Navigate to Active Delivery tab."),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.two_wheeler, color: Colors.white),
                                label: const Text("Accept & Pick Up", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
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

  Widget _buildTimelineRow(IconData icon, Color iconColor, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
