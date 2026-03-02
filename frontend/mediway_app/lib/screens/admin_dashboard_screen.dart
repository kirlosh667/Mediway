import 'package:flutter/material.dart';
import 'package:mediway_app/services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {

  List data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      data = await ApiService.getAdminDashboard();
    } catch (_) {}

    setState(() {
      isLoading = false;
    });
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "scheduled":
        return const Color(0xFF1E88E5);
      case "approved":
      case "completed":
        return const Color(0xFF2E7D32);
      case "cancelled":
      case "rejected":
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }

  Widget buildStatusBadge(String status) {
    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget buildMessageBlock(Map m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FB),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            m["doctor_name"] ?? "",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            m["message"] ?? "",
            style: const TextStyle(
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F8FB),

      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
              fontWeight:
                  FontWeight.w600),
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xFF1E88E5),
              ),
            )
          : RefreshIndicator(
              onRefresh: load,
              child: data.isEmpty
                  ? const Center(
                      child: Text(
                        "No appointments available",
                        style: TextStyle(
                            color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20),
                      itemCount: data.length,
                      itemBuilder:
                          (context, index) {

                        final e = data[index];
                        final messages =
                            e["messages"] ?? [];

                        return Container(
                          margin:
                              const EdgeInsets.only(
                                  bottom: 24),
                          padding:
                              const EdgeInsets.all(
                                  22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                                    24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.05),
                                blurRadius: 15,
                                offset:
                                    const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              // ================= HEADER =================
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      e["patient_name"] ?? "",
                                      style:
                                          const TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  buildStatusBadge(
                                      e["status"] ?? ""),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Doctor: ${e["doctor_name"] ?? ""}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                e["appointment_date"]
                                        ?.toString() ??
                                    "",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 22),

                              // ================= MESSAGES =================
                              if (messages.isNotEmpty) ...[
                                const Text(
                                  "Doctor Notes",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                    height: 12),
                                ...messages.map<Widget>(
                                    (m) =>
                                        buildMessageBlock(
                                            m)),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}