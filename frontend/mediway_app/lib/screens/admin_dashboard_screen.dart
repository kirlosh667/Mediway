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

  // Updated to modern medical palette
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "scheduled":
        return const Color(0xFF2563EB);
      case "approved":
      case "completed":
        return const Color(0xFF16A34A);
      case "cancelled":
      case "rejected":
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget buildStatusBadge(String status) {
    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
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
        color: const Color(0xFFF1F5F9),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            m["doctor_name"] ?? "",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            m["message"] ?? "",
            style: const TextStyle(
              color: Color(0xFF334155),
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
          const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
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
                    Color(0xFF2563EB),
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF2563EB),
              onRefresh: load,
              child: data.isEmpty
                  ? const Center(
                      child: Text(
                        "No appointments available",
                        style: TextStyle(
                            color: Color(0xFF64748B)),
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(
                              horizontal: 20,
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
                                  bottom: 22),
                          padding:
                              const EdgeInsets.all(
                                  22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                                    20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.04),
                                blurRadius: 18,
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

                              // HEADER
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
                                            FontWeight.w600,
                                        color:
                                            Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                  buildStatusBadge(
                                      e["status"] ?? ""),
                                ],
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "Doctor: ${e["doctor_name"] ?? ""}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color:
                                      Color(0xFF475569),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                e["appointment_date"]
                                        ?.toString() ??
                                    "",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color:
                                      Color(0xFF64748B),
                                ),
                              ),

                              const SizedBox(height: 22),

                              // MESSAGES
                              if (messages.isNotEmpty) ...[
                                const Text(
                                  "Doctor Notes",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.w600,
                                    color:
                                        Color(0xFF1E293B),
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