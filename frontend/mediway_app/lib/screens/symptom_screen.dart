import 'package:flutter/material.dart';
import 'package:mediway_app/services/api_service.dart';
import 'question_screen.dart';

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});

  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {

  List symptoms = [];
  List<int> selectedSymptoms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSymptoms();
  }

  void loadSymptoms() async {
    final response = await ApiService.getSymptoms();
    setState(() {
      symptoms = response;
      isLoading = false;
    });
  }

  void toggleSelection(int id) {
    setState(() {
      if (selectedSymptoms.contains(id)) {
        selectedSymptoms.remove(id);
      } else {
        selectedSymptoms.add(id);
      }
    });
  }

  void goToQuestions() {
    if (selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one symptom"),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            QuestionScreen(symptomIds: selectedSymptoms),
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
          "Health Check",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2563EB),
              ),
            )
          : symptoms.isEmpty
              ? const Center(
                  child: Text(
                    "No symptoms available",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      // ================= HEADER =================
                      const Text(
                        "How are you feeling today?",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Select all symptoms that apply to you.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= SELECTION INDICATOR =================
                      if (selectedSymptoms.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB)
                                .withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(30),
                          ),
                          child: Text(
                            "${selectedSymptoms.length} symptom(s) selected",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // ================= SYMPTOM LIST =================
                      Expanded(
                        child: ListView.builder(
                          itemCount: symptoms.length,
                          itemBuilder: (context, index) {
                            final symptom = symptoms[index];
                            final id = symptom["id"];
                            final name = symptom["name"];
                            final isSelected =
                                selectedSymptoms.contains(id);

                            return GestureDetector(
                              onTap: () => toggleSelection(id),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(
                                    bottom: 14),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF2563EB)
                                        : Colors.grey.shade300,
                                    width: isSelected ? 1.6 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.04),
                                      blurRadius: 10,
                                      offset:
                                          const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [

                                    // Selection Circle
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      height: 24,
                                      width: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? const Color(0xFF2563EB)
                                            : Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF2563EB)
                                              : Colors.grey,
                                          width: 1.4,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),

                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color:
                                              const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ================= CONTINUE BUTTON =================
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: goToQuestions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF2563EB),
                            padding:
                                const EdgeInsets.symmetric(
                                    vertical: 18),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            "Continue to Assessment",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}