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
        return const Color(0xFF16A34A);
      case "pending":
        return const Color(0xFFEA580C);
      case "rejected":
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
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
          "Doctor Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2563EB),
              ),
            )
          : Column(
              children: [

                // ===== SUMMARY CARD =====
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
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
                        "Today's Appointments",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${data.length}",
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 28,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== LIST =====
                Expanded(
                  child: data.isEmpty
                      ? const Center(
                          child: Text(
                            "No appointments found",
                            style: TextStyle(
                              color: Color(0xFF64748B),
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
                                            0.03),
                                    blurRadius: 12,
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
                                                0xFFEFF6FF),
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
                                                0xFF2563EB),
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
                                                      .w600,
                                              color:
                                                  Color(
                                                      0xFF1E293B),
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
                                                  Color(
                                                      0xFF64748B),
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
                                                          0.10),
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
                                                        .w600,
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
                                          Color(
                                              0xFF94A3B8),
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