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
        return const Color(0xFFD32F2F);
      case "moderate":
        return const Color(0xFFED6C02);
      case "low":
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF1E88E5);
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
      backgroundColor: const Color(0xFFF4F8FB),

      appBar: AppBar(
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
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: riskColor.withOpacity(0.4),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

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
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Text(
                          "Score: ",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          score,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Text(
                          "Recommended Specialist: ",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            specialist,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================= HEADER =================
              const Text(
                "Additional Information (Optional)",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Provide extra details to help the doctor better understand your condition.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              // ================= TEXT FIELD =================
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: queryController,
                  maxLines: 5,
                  maxLength: 300,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText:
                        "Example: The pain worsens when walking or breathing deeply...",
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
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ================= ACTION BUTTONS =================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isSubmitting ? null : submitQuery,
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
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

              const SizedBox(height: 10),

              Center(
                child: TextButton(
                  onPressed:
                      isSubmitting ? null : submitQuery,
                  child: const Text(
                    "Skip and Continue",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
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