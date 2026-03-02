import 'package:flutter/material.dart';
import 'appointment_screen.dart';
import 'dashboard_screen.dart';

class SuggestionScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const SuggestionScreen({
    super.key,
    required this.result,
  });

  Color getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case "high":
      case "emergency":
        return const Color(0xFFD32F2F);
      case "moderate":
      case "medium":
        return const Color(0xFFED6C02);
      case "low":
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF1E88E5);
    }
  }

  IconData getRiskIcon(String risk) {
    switch (risk.toLowerCase()) {
      case "high":
      case "emergency":
        return Icons.warning_amber_rounded;
      case "moderate":
      case "medium":
        return Icons.error_outline;
      case "low":
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {

    final risk = result["risk_level"] ?? "Unknown";
    final specialist =
        result["recommended_specialist"] ?? "General";
    final score =
        result["total_score"]?.toString() ?? "-";

    final riskColor = getRiskColor(risk);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),

      appBar: AppBar(
        title: const Text(
          "Assessment Summary",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [

              // ================= RISK CARD =================
              Container(
                padding:
                    const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.05),
                      blurRadius: 15,
                      offset:
                          const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: riskColor
                        .withOpacity(0.5),
                    width: 1.4,
                  ),
                ),
                child: Column(
                  children: [

                    Icon(
                      getRiskIcon(risk),
                      size: 64,
                      color: riskColor,
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Risk Level",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      risk.toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.bold,
                        color: riskColor,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6),
                      decoration: BoxDecoration(
                        color: riskColor
                            .withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(
                                20),
                      ),
                      child: Text(
                        "Score: $score",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                          color: riskColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================= SPECIALIST CARD =================
              Container(
                padding:
                    const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.04),
                      blurRadius: 12,
                      offset:
                          const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Recommended Specialist",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      specialist,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            Color(0xFF1C1C1C),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ================= PRIMARY BUTTON =================
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AppointmentScreen(
                          specialization:
                              specialist,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),
                  ),
                  child: const Text(
                    "Book Appointment",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ================= SECONDARY BUTTON =================
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const DashboardScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),
                  ),
                  child: const Text(
                    "Back to Dashboard",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}