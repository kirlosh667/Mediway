import 'package:flutter/material.dart';
import 'package:mediway_app/services/api_service.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState
    extends State<AppointmentDetailScreen> {

  bool isCancelling = false;
  bool isProcessing = false;
  final TextEditingController replyController =
      TextEditingController();

  bool get isDoctor =>
      widget.appointment["patient_name"] != null;

  // ================= DELETE =================
  Future<void> confirmCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Appointment"),
        content: const Text(
            "Are you sure you want to delete this appointment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
            ),
            child: const Text("Yes, Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) cancelAppointment();
  }

  void cancelAppointment() async {
    setState(() => isCancelling = true);

    final success =
        await ApiService.cancelAppointment(
      widget.appointment["id"],
    );

    setState(() => isCancelling = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Deletion failed")),
      );
    }
  }

  // ================= APPROVE =================
  Future<void> approveAppointment() async {

    if (replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Write suggestion before approving")),
      );
      return;
    }

    setState(() => isProcessing = true);

    await ApiService.sendMessageToAppointment(
      widget.appointment["id"],
      replyController.text.trim(),
    );

    final success =
        await ApiService.approveAppointment(
            widget.appointment["id"]);

    setState(() => isProcessing = false);

    if (success) {
      setState(() {
        widget.appointment["status"] =
            "Approved";
        widget.appointment["messages"] ??= [];
        widget.appointment["messages"].add({
          "message":
              replyController.text.trim()
        });
      });
      replyController.clear();
    }
  }

  Future<void> rejectAppointment() async {
    setState(() => isProcessing = true);

    final success =
        await ApiService.rejectAppointment(
            widget.appointment["id"]);

    setState(() => isProcessing = false);

    if (success) {
      setState(() {
        widget.appointment["status"] =
            "Rejected";
      });
    }
  }

  // ================= HELPERS =================
  String formatDate(String rawDate) {
    try {
      final parsed =
          DateTime.parse(rawDate).toLocal();

      return
          "${parsed.day}/${parsed.month}/${parsed.year} • "
          "${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return rawDate;
    }
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

    final doctor =
        widget.appointment["doctor_name"] ??
            "Unknown";
    final patient =
        widget.appointment["patient_name"] ??
            "";
    final rawDate =
        widget.appointment["appointment_date"] ??
            "";
    final status =
        widget.appointment["status"] ??
            "Unknown";
    final triage =
        widget.appointment["triage"];
    final List messages =
        widget.appointment["messages"] ?? [];

    final bool isPending =
        status.toLowerCase() == "pending";

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            const Color(0xFF1E88E5),
        title: const Text(
          "Appointment Details",
          style: TextStyle(
              fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // ================= HEADER CARD =================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.05),
                    blurRadius: 12,
                    offset:
                        const Offset(0, 6),
                  )
                ],
              ),
              padding:
                  const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          const Color(
                              0xFFE3F2FD),
                      borderRadius:
                          BorderRadius
                              .circular(14),
                    ),
                    child: const Icon(
                      Icons
                          .medical_services,
                      color: Color(
                          0xFF1E88E5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          isDoctor
                              ? patient
                              : doctor,
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                            height: 6),
                        Text(
                          formatDate(
                              rawDate),
                          style:
                              const TextStyle(
                            color:
                                Colors
                                    .grey,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= STATUS BADGE =================
            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                          horizontal: 18,
                          vertical: 8),
              decoration:
                  BoxDecoration(
                color:
                    getStatusColor(
                            status)
                        .withOpacity(
                            0.12),
                borderRadius:
                    BorderRadius
                        .circular(30),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color:
                      getStatusColor(
                          status),
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ================= TRIAGE =================
            if (triage != null) ...[
              const Text(
                "Patient Triage Analysis",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                  height: 12),
              Container(
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius
                          .circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(
                              0.04),
                      blurRadius: 8,
                      offset:
                          const Offset(
                              0, 4),
                    )
                  ],
                ),
                padding:
                    const EdgeInsets
                        .all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                        "Symptom: ${triage["symptom"] ?? "N/A"}"),
                    const SizedBox(
                        height: 6),
                    Text(
                        "Score: ${triage["total_score"] ?? "N/A"}"),
                    const SizedBox(
                        height: 6),
                    Text(
                        "Risk Level: ${triage["risk_level"] ?? "N/A"}"),
                    const SizedBox(
                        height: 6),
                    Text(
                        "Recommended: ${triage["recommended_specialist"] ?? "N/A"}"),
                  ],
                ),
              ),
              const SizedBox(
                  height: 28),
            ],

            // ================= DOCTOR ACTIONS =================
            if (isDoctor &&
                isPending) ...[
              const Text(
                "Doctor Suggestion",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                  height: 10),
              TextField(
                controller:
                    replyController,
                maxLines: 3,
                decoration:
                    InputDecoration(
                  hintText:
                      "Write medical recommendation...",
                  filled: true,
                  fillColor:
                      Colors.white,
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                14),
                  ),
                ),
              ),
              const SizedBox(
                  height: 15),
              Row(
                children: [
                  Expanded(
                    child:
                        ElevatedButton(
                      onPressed:
                          isProcessing
                              ? null
                              : approveAppointment,
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                                0xFF2E7D32),
                        padding:
                            const EdgeInsets
                                .symmetric(
                                    vertical:
                                        14),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      14),
                        ),
                      ),
                      child:
                          const Text(
                              "Approve"),
                    ),
                  ),
                  const SizedBox(
                      width: 12),
                  Expanded(
                    child:
                        ElevatedButton(
                      onPressed:
                          isProcessing
                              ? null
                              : rejectAppointment,
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                                0xFFD32F2F),
                        padding:
                            const EdgeInsets
                                .symmetric(
                                    vertical:
                                        14),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      14),
                        ),
                      ),
                      child:
                          const Text(
                              "Reject"),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                  height: 28),
            ],

            // ================= MESSAGES =================
            const Text(
              "Doctor Messages",
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            messages.isEmpty
                ? const Text(
                    "No messages yet.")
                : Column(
                    children:
                        messages.map(
                      (msg) {
                        return Container(
                          margin:
                              const EdgeInsets
                                  .only(
                                      bottom:
                                          10),
                          padding:
                              const EdgeInsets
                                  .all(14),
                          decoration:
                              BoxDecoration(
                            color: Colors
                                .white,
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .black
                                    .withOpacity(
                                        0.04),
                                blurRadius:
                                    6,
                              )
                            ],
                          ),
                          child: Text(
                            msg["message"] ??
                                "",
                          ),
                        );
                      },
                    ).toList(),
                  ),

            const SizedBox(height: 30),

            if (!isDoctor &&
                status
                        .toLowerCase() !=
                    "approved")
              SizedBox(
                width:
                    double.infinity,
                child:
                    ElevatedButton
                        .icon(
                  icon: const Icon(
                      Icons
                          .delete_outline),
                  onPressed:
                      isCancelling
                          ? null
                          : confirmCancel,
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                            0xFFD32F2F),
                    padding:
                        const EdgeInsets
                            .symmetric(
                                vertical:
                                    14),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  14),
                    ),
                  ),
                  label:
                      const Text(
                          "Delete Appointment"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}