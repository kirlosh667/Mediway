import 'package:flutter/material.dart';
import 'package:mediway_app/services/api_service.dart';
import 'symptom_screen.dart';
import 'auth_choice_screen.dart';
import 'appointment_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

  List history = [];
  List appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final h = await ApiService.getHistory();
      final a = await ApiService.getAppointments();

      setState(() {
        history = h;
        appointments = a;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Color getRiskColor(String risk) {
    switch (risk.toUpperCase()) {
      case "HIGH":
        return const Color(0xFFDC2626);
      case "MODERATE":
        return const Color(0xFFEA580C);
      case "LOW":
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return const Color(0xFF16A34A);
      case "pending":
        return const Color(0xFFEA580C);
      case "cancelled":
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Patient Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AuthChoiceScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2563EB),
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF2563EB),
              onRefresh: loadData,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    // ===== SUMMARY CARD =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.04),
                            blurRadius: 14,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome Back 👋",
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You have ${appointments.length} appointments",
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ===== NEW HEALTH CHECK =====
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.health_and_safety),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const SymptomScreen(),
                            ),
                          ).then((_) => loadData());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(
                                  vertical: 18),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                        ),
                        label: const Text(
                          "Start New Health Check",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ===== HISTORY =====
                    sectionTitle("Past Health Checkups"),

                    history.isEmpty
                        ? const Text(
                            "No health checkups yet.",
                            style: TextStyle(
                                color: Color(0xFF64748B)),
                          )
                        : Column(
                            children: history.map(
                              (item) {
                                final risk =
                                    item["risk_level"]
                                            ?.toString() ??
                                        "Unknown";

                                return Container(
                                  margin:
                                      const EdgeInsets.only(
                                          bottom: 14),
                                  padding:
                                      const EdgeInsets.all(
                                          18),
                                  decoration:
                                      BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors
                                            .black
                                            .withOpacity(
                                                0.03),
                                        blurRadius: 10,
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Text(
                                        item["symptom"]
                                                ?.toString() ??
                                            "Unknown",
                                        style:
                                            const TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                          color: Color(
                                              0xFF1E293B),
                                        ),
                                      ),
                                      statusBadge(
                                          risk,
                                          getRiskColor(
                                              risk)),
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                          ),

                    const SizedBox(height: 40),

                    // ===== APPOINTMENTS =====
                    sectionTitle("Appointments"),

                    appointments.isEmpty
                        ? const Text(
                            "No appointments booked.",
                            style: TextStyle(
                                color: Color(0xFF64748B)),
                          )
                        : Column(
                            children:
                                appointments.map(
                              (item) {
                                final status =
                                    item["status"]
                                            ?.toString() ??
                                        "Unknown";

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AppointmentDetailScreen(
                                          appointment:
                                              item,
                                        ),
                                      ),
                                    ).then((_) =>
                                        loadData());
                                  },
                                  child: Container(
                                    margin:
                                        const EdgeInsets
                                            .only(
                                                bottom:
                                                    14),
                                    padding:
                                        const EdgeInsets
                                            .all(18),
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          Colors.white,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors
                                              .black
                                              .withOpacity(
                                                  0.03),
                                          blurRadius:
                                              10,
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              item["doctor_name"]
                                                      ?.toString() ??
                                                  "Unknown Doctor",
                                              style:
                                                  const TextStyle(
                                                fontSize:
                                                    15,
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                                color: Color(
                                                    0xFF1E293B),
                                              ),
                                            ),
                                            const SizedBox(
                                                height: 6),
                                            Text(
                                              item["appointment_date"]
                                                      ?.toString() ??
                                                  "",
                                              style:
                                                  const TextStyle(
                                                color:
                                                    Color(
                                                        0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                        statusBadge(
                                            status,
                                            getStatusColor(
                                                status)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}