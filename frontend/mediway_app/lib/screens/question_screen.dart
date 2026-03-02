import 'package:flutter/material.dart';
import 'package:mediway_app/services/api_service.dart';
import 'query_screen.dart';

class QuestionScreen extends StatefulWidget {
  final List<int> symptomIds;

  const QuestionScreen({
    super.key,
    required this.symptomIds,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {

  List questions = [];
  Map<int, int> selectedAnswers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    List allQuestions = [];

    for (int id in widget.symptomIds) {
      final response = await ApiService.getQuestions(id);
      allQuestions.addAll(response);
    }

    setState(() {
      questions = allQuestions;
      isLoading = false;
    });
  }

  void submit() async {
    if (selectedAnswers.length < questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please answer all questions"),
        ),
      );
      return;
    }

    final result = await ApiService.evaluateTriage(
      widget.symptomIds.first,
      selectedAnswers.values.toList(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QueryScreen(
          triageResult: result,
        ),
      ),
    );
  }

  Widget buildChoice(
      int questionId,
      Map choice,
  ) {
    bool isSelected =
        selectedAnswers[questionId] == choice["id"];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAnswers[questionId] = choice["id"];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E88E5).withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1E88E5)
                : Colors.grey.shade300,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [

            // Radio Circle
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1E88E5)
                      : Colors.grey,
                  width: 1.5,
                ),
                color: isSelected
                    ? const Color(0xFF1E88E5)
                    : Colors.white,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                choice["text"],
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1C1C1C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    int answeredCount = selectedAnswers.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),

      appBar: AppBar(
        title: const Text(
          "Medical Questionnaire",
          style: TextStyle(fontWeight: FontWeight.w600),
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

                // ================= PROGRESS SECTION =================
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Answered $answeredCount of ${questions.length} questions",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: questions.isEmpty
                              ? 0
                              : answeredCount /
                                  questions.length,
                          minHeight: 8,
                          backgroundColor:
                              Colors.grey.shade200,
                          color:
                              const Color(0xFF1E88E5),
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= QUESTION LIST =================
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(
                            horizontal: 20),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {

                      final q = questions[index];
                      final questionId = q["id"];

                      return Card(
                        elevation: 2,
                        margin:
                            const EdgeInsets.only(
                                bottom: 18),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  18),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                                  20),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              Text(
                                "Question ${index + 1}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                q["text"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w600,
                                  color:
                                      Color(0xFF1C1C1C),
                                ),
                              ),

                              const SizedBox(height: 16),

                              ...q["choices"]
                                  .map<Widget>((choice) =>
                                      buildChoice(
                                        questionId,
                                        choice,
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ================= SUBMIT BUTTON =================
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                          20, 10, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submit,
                      style:
                          ElevatedButton.styleFrom(
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
                      child: const Text(
                        "Submit Evaluation",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}