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

  late List<dynamic> messages;

  @override
  void initState() {
    super.initState();
    messages =
        (widget.appointment["messages"] as List?) ?? [];
  }

  bool get isDoctor =>
      widget.appointment["patient_name"] != null;

  // ================= CANCEL =================
  Future<void> confirmCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Delete Appointment",
          style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600),
        ),
        content: const Text(
          "Are you sure you want to delete this appointment?",
          style: TextStyle(color: Color(0xFF334155)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
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
    }
  }

  // ================= DOCTOR ACTIONS =================

  Future<void> approveAppointment() async {
    setState(() => isProcessing = true);

    final success =
        await ApiService.approveAppointment(
      widget.appointment["id"],
    );

    setState(() => isProcessing = false);

    if (success) {
      setState(() {
        widget.appointment["status"] = "approved";
      });
    }
  }

  Future<void> rejectAppointment() async {
    setState(() => isProcessing = true);

    final success =
        await ApiService.rejectAppointment(
      widget.appointment["id"],
    );

    setState(() => isProcessing = false);

    if (success) {
      setState(() {
        widget.appointment["status"] = "rejected";
      });
    }
  }

  Future<void> sendReply() async {
    if (replyController.text.isEmpty) return;

    final success =
        await ApiService.sendMessageToAppointment(
      widget.appointment["id"],
      replyController.text,
    );

    if (success) {
      setState(() {
        messages.add({
          "message": replyController.text
        });
        replyController.clear();
      });
    }
  }

  // ================= UTIL =================

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
        return const Color(0xFF16A34A);
      case "pending":
        return const Color(0xFFEA580C);
      case "rejected":
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color getRiskColor(String? risk) {
    switch (risk?.toLowerCase()) {
      case "low":
        return const Color(0xFF16A34A);
      case "moderate":
        return const Color(0xFFEAB308);
      case "high":
        return const Color(0xFFEA580C);
      case "emergency":
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF1E293B);
    }
  }

  Widget triageRow(String label, String value,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color:
                valueColor ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    final doctor =
        widget.appointment["doctor_name"] ?? "Unknown";
    final patient =
        widget.appointment["patient_name"] ?? "";
    final rawDate =
        widget.appointment["appointment_date"] ?? "";
    final status =
        widget.appointment["status"] ?? "Unknown";

    // 🧠 TRIAGE DATA
    final symptom =
        widget.appointment["symptom_name"];
    final riskLevel =
        widget.appointment["risk_level"];
    final totalScore =
        widget.appointment["total_score"];
    final specialist =
        widget.appointment["recommended_specialist"];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Appointment Details",
          style:
              TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.04),
                    blurRadius: 14,
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFEFF6FF),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.isNotEmpty
                              ? patient
                              : doctor,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w600,
                            color:
                                Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatDate(rawDate),
                          style: const TextStyle(
                            color:
                                Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 22),

            // STATUS
            Container(
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8),
              decoration: BoxDecoration(
                color:
                    getStatusColor(status)
                        .withOpacity(0.10),
                borderRadius:
                    BorderRadius.circular(30),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color:
                      getStatusColor(status),
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),

            // ================= TRIAGE SECTION =================
            if (symptom != null)
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  const Text(
                    "Triage Analysis",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.04),
                          blurRadius: 12,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        triageRow(
                            "Symptom",
                            symptom ?? "N/A"),
                        const SizedBox(height: 10),
                        triageRow(
                          "Risk Level",
                          riskLevel ?? "N/A",
                          valueColor:
                              getRiskColor(riskLevel),
                        ),
                        const SizedBox(height: 10),
                        triageRow(
                            "Total Score",
                            totalScore?.toString() ??
                                "0"),
                        const SizedBox(height: 10),
                        triageRow(
                            "Recommended Specialist",
                            specialist ?? "N/A"),
                      ],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 28),

            const Text(
              "Doctor Messages",
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w600,
                color:
                    Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 12),

            messages.isEmpty
                ? const Text(
                    "No messages yet.",
                    style: TextStyle(
                        color:
                            Color(0xFF64748B)),
                  )
                : Column(
                    children: messages.map(
                      (msg) {
                        return Container(
                          margin:
                              const EdgeInsets.only(
                                  bottom: 10),
                          padding:
                              const EdgeInsets.all(
                                  14),
                          decoration:
                              BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius
                                    .circular(14),
                          ),
                          child: Text(
                            msg["message"] ?? "",
                            style: const TextStyle(
                                color:
                                    Color(0xFF334155)),
                          ),
                        );
                      },
                    ).toList(),
                  ),

            const SizedBox(height: 30),

            // DOCTOR CONTROLS
            if (isDoctor &&
                status.toLowerCase() ==
                    "pending")
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : approveAppointment,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                                0xFF16A34A),
                      ),
                      child:
                          const Text("Accept"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : rejectAppointment,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                                0xFFDC2626),
                      ),
                      child:
                          const Text("Reject"),
                    ),
                  ),
                ],
              ),

            if (isDoctor &&
                status.toLowerCase() ==
                    "approved")
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  const Text(
                    "Reply to Patient",
                    style: TextStyle(
                        fontWeight:
                            FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller:
                        replyController,
                    maxLines: 3,
                    decoration:
                        InputDecoration(
                      hintText:
                          "Type your message...",
                      filled: true,
                      fillColor:
                          Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: sendReply,
                    child:
                        const Text("Send"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}