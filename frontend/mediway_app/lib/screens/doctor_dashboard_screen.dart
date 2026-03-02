import 'package:flutter/material.dart';
import 'package:mediway_app/services/api_service.dart';
import 'appointment_detail_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState
    extends State<DoctorDashboardScreen> {
  List data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final response =
        await ApiService.getDoctorDashboard();

    setState(() {
      data = response;
      isLoading = false;
    });
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return const Color(0xFF2E7D32);
      case "pending":
        return const Color(0xFFED6C02);
      case "rejected":
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E88E5),
        title: const Text(
          "Doctor Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1E88E5),
              ),
            )
          : Column(
              children: [

                // ================= HEADER SUMMARY =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E88E5),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Today's Appointments",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${data.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ================= LIST =================
                Expanded(
                  child: data.isEmpty
                      ? const Center(
                          child: Text(
                            "No appointments found",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 20),
                          itemCount: data.length,
                          itemBuilder:
                              (context, index) {

                            final appointment =
                                data[index];
                            final patientName =
                                appointment[
                                        "patient_name"] ??
                                    "Unknown";
                            final status =
                                appointment["status"] ??
                                    "Unknown";
                            final date =
                                appointment[
                                        "appointment_date"] ??
                                    "";

                            return Container(
                              margin:
                                  const EdgeInsets.only(
                                      bottom: 16),
                              padding:
                                  const EdgeInsets.all(
                                      18),
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
                                            0.04),
                                    blurRadius: 10,
                                    offset:
                                        const Offset(
                                            0, 6),
                                  )
                                ],
                              ),
                              child: InkWell(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            18),
                                onTap: () async {
                                  await Navigator
                                      .push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AppointmentDetailScreen(
                                        appointment:
                                            appointment,
                                      ),
                                    ),
                                  );

                                  load();
                                },
                                child: Row(
                                  children: [

                                    // Avatar
                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .all(
                                                  14),
                                      decoration:
                                          BoxDecoration(
                                        color: const Color(
                                                0xFFE3F2FD),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    14),
                                      ),
                                      child:
                                          const Icon(
                                        Icons.person,
                                        color:
                                            Color(
                                                0xFF1E88E5),
                                      ),
                                    ),

                                    const SizedBox(
                                        width: 16),

                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            patientName,
                                            style:
                                                const TextStyle(
                                              fontSize:
                                                  16,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                          const SizedBox(
                                              height:
                                                  6),
                                          Text(
                                            date,
                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors
                                                      .grey,
                                            ),
                                          ),
                                          const SizedBox(
                                              height:
                                                  10),

                                          // Status Chip
                                          Container(
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                                        horizontal:
                                                            14,
                                                        vertical:
                                                            6),
                                            decoration:
                                                BoxDecoration(
                                              color:
                                                  getStatusColor(
                                                          status)
                                                      .withOpacity(
                                                          0.12),
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          30),
                                            ),
                                            child: Text(
                                              status
                                                  .toUpperCase(),
                                              style:
                                                  TextStyle(
                                                color:
                                                    getStatusColor(
                                                        status),
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                fontSize:
                                                    12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const Icon(
                                      Icons
                                          .arrow_forward_ios,
                                      size: 16,
                                      color:
                                          Colors.grey,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}