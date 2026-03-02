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
        return const Color(0xFFD32F2F);
      case "MODERATE":
        return const Color(0xFFED6C02);
      case "LOW":
        return const Color(0xFF2E7D32);
      default:
        return Colors.grey;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return const Color(0xFF2E7D32);
      case "pending":
        return const Color(0xFFED6C02);
      case "cancelled":
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1C1C1C),
        ),
      ),
    );
  }

  Widget statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
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
      backgroundColor: const Color(0xFFF4F8FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E88E5),
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
                color: Color(0xFF1E88E5),
              ),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    // ================= WELCOME CARD =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1E88E5),
                            Color(0xFF1565C0),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome Back 👋",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You have ${appointments.length} appointments",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ================= NEW HEALTH CHECK =================
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                            Icons.health_and_safety),
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
                              const Color(0xFF2E7D32),
                          padding:
                              const EdgeInsets.symmetric(
                                  vertical: 18),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    18),
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

                    // ================= HISTORY =================
                    sectionTitle("Past Health Checkups"),

                    history.isEmpty
                        ? const Text(
                            "No health checkups yet.",
                            style: TextStyle(
                                color: Colors.grey),
                          )
                        : Column(
                            children: history.map(
                              (item) {
                                final risk =
                                    item["risk_level"]
                                            ?.toString() ??
                                        "Unknown";

                                return Card(
                                  elevation: 2,
                                  margin:
                                      const EdgeInsets.only(
                                          bottom: 14),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(18),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets
                                            .all(18),
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
                                          ),
                                        ),
                                        statusBadge(
                                            risk,
                                            getRiskColor(
                                                risk)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          ),

                    const SizedBox(height: 40),

                    // ================= APPOINTMENTS =================
                    sectionTitle("Appointments"),

                    appointments.isEmpty
                        ? const Text(
                            "No appointments booked.",
                            style: TextStyle(
                                color: Colors.grey),
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
                                  child: Card(
                                    elevation: 2,
                                    margin:
                                        const EdgeInsets
                                            .only(
                                                bottom:
                                                    14),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  18),
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets
                                              .all(
                                                  18),
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
                                                ),
                                              ),
                                              const SizedBox(
                                                  height:
                                                      6),
                                              Text(
                                                item["appointment_date"]
                                                        ?.toString() ??
                                                    "",
                                                style:
                                                    const TextStyle(
                                                  color:
                                                      Colors.grey,
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