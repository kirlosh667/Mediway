import 'package:flutter/material.dart';
import 'package:mediway_app/services/api_service.dart';
import 'suggestion_screen.dart';

class QueryScreen extends StatefulWidget {
  final Map<String, dynamic> triageResult;

  const QueryScreen({
    super.key,
    required this.triageResult,
  });

  @override
  State<QueryScreen> createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {

  final TextEditingController queryController =
      TextEditingController();

  bool isSubmitting = false;

  Color getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case "high":
      case "emergency":
        return const Color(0xFFDC2626);
      case "moderate":
        return const Color(0xFFEA580C);
      case "low":
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF2563EB);
    }
  }

  void submitQuery() async {
    setState(() => isSubmitting = true);

    if (queryController.text.trim().isNotEmpty) {
      await ApiService.submitQuery(
        queryController.text.trim(),
      );
    }

    setState(() => isSubmitting = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SuggestionScreen(result: widget.triageResult),
      ),
    );
  }

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final risk =
        widget.triageResult["risk_level"] ?? "Unknown";
    final specialist =
        widget.triageResult["recommended_specialist"] ?? "Doctor";
    final score =
        widget.triageResult["total_score"]?.toString() ?? "-";

    final riskColor = getRiskColor(risk);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        title: const Text(
          "Assessment Result",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= RESULT CARD =================
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: riskColor.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Risk Level",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.12),
                        borderRadius:
                            BorderRadius.circular(30),
                      ),
                      child: Text(
                        risk.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: riskColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Score: $score",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Recommended Specialist: $specialist",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Additional Information (Optional)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Provide extra details to help the doctor better understand your condition.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 20),

              // ================= FIXED LIGHT TEXT FIELD =================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: queryController,
                  maxLines: 5,
                  maxLength: 300,
                  cursorColor: const Color(0xFF2563EB),
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                  ),
                  decoration: const InputDecoration(
                    filled: false,
                    hintText:
                        "Example: The pain worsens when walking or breathing deeply...",
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    counterText: "",
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${queryController.text.length}/300",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isSubmitting ? null : submitQuery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(
                            vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(22),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed:
                      isSubmitting ? null : submitQuery,
                  child: const Text(
                    "Skip and Continue",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}