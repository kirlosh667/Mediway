import 'package:flutter/material.dart';
import 'package:mediway_app/services/api_service.dart';
import 'dashboard_screen.dart';

class AppointmentScreen extends StatefulWidget {
  final String specialization;

  const AppointmentScreen({
    super.key,
    required this.specialization,
  });

  @override
  State<AppointmentScreen> createState() =>
      _AppointmentScreenState();
}

class _AppointmentScreenState
    extends State<AppointmentScreen> {

  List doctors = [];
  int? selectedDoctorId;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool isLoading = true;
  bool isBooking = false;

  @override
  void initState() {
    super.initState();
    loadDoctors();
  }

  void loadDoctors() async {
    try {
      final response =
          await ApiService.getDoctors();

      final filtered =
          response.where((doc) {
        final docSpec =
            doc["specialization"]
                .toString()
                .toLowerCase();

        final incomingSpec =
            widget.specialization
                .toLowerCase();

        return docSpec
                .contains(incomingSpec) ||
            incomingSpec
                .contains(docSpec);
      }).toList();

      setState(() {
        doctors =
            filtered.isEmpty
                ? response
                : filtered;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now()
              .add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  void bookAppointment() async {

    if (selectedDoctorId == null ||
        selectedDate == null ||
        selectedTime == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "Please select doctor, date and time"),
        ),
      );
      return;
    }

    final DateTime combined =
        DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    setState(() => isBooking = true);

    final success =
        await ApiService.bookAppointment(
      selectedDoctorId!,
      combined,
    );

    setState(() => isBooking = false);

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const DashboardScreen(),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
            content:
                Text("Booking failed")),
      );
    }
  }

  Widget buildSelectionCard({
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
              color:
                  Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.04),
              blurRadius: 8,
              offset:
                  const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon,
                color:
                    const Color(0xFF1E88E5)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F8FB),

      appBar: AppBar(
        title: const Text(
          "Book Appointment",
          style: TextStyle(
              fontWeight:
                  FontWeight.w600),
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xFF1E88E5),
              ),
            )
          : doctors.isEmpty
              ? const Center(
                  child: Text(
                    "No doctors available",
                    style: TextStyle(
                        fontSize: 16),
                  ),
                )
              : SafeArea(
                  child:
                      SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [

                        // HEADER
                        const Text(
                          "Specialization",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          widget.specialization,
                          style:
                              const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // DOCTOR SELECT
                        const Text(
                          "Select Doctor",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal:
                                      14),
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white,
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        18),
                            border: Border.all(
                                color: Colors
                                    .grey
                                    .shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .black
                                    .withOpacity(
                                        0.04),
                                blurRadius:
                                    8,
                              )
                            ],
                          ),
                          child:
                              DropdownButtonFormField<
                                  int>(
                            value:
                                selectedDoctorId,
                            isExpanded: true,
                            decoration:
                                const InputDecoration(
                              border:
                                  InputBorder
                                      .none,
                            ),
                            hint: const Text(
                                "Choose Doctor"),
                            items: doctors.map<
                                    DropdownMenuItem<
                                        int>>(
                                (doc) {
                              return DropdownMenuItem<
                                  int>(
                                value:
                                    doc["id"],
                                child: Text(
                                    doc["name"]),
                              );
                            }).toList(),
                            onChanged:
                                (value) {
                              setState(() {
                                selectedDoctorId =
                                    value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          "Select Date & Time",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        buildSelectionCard(
                          icon: Icons
                              .calendar_today_outlined,
                          value: selectedDate ==
                                  null
                              ? "Select Date"
                              : selectedDate!
                                  .toLocal()
                                  .toString()
                                  .split(
                                      ' ')[0],
                          onTap: pickDate,
                        ),

                        const SizedBox(height: 14),

                        buildSelectionCard(
                          icon: Icons
                              .access_time_outlined,
                          value: selectedTime ==
                                  null
                              ? "Select Time"
                              : selectedTime!
                                  .format(
                                      context),
                          onTap: pickTime,
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width:
                              double.infinity,
                          height: 56,
                          child:
                              ElevatedButton(
                            onPressed:
                                isBooking
                                    ? null
                                    : bookAppointment,
                            child:
                                isBooking
                                    ? const SizedBox(
                                        height:
                                            20,
                                        width:
                                            20,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2,
                                          color: Colors
                                              .white,
                                        ),
                                      )
                                    : const Text(
                                        "Confirm Appointment",
                                        style:
                                            TextStyle(
                                          fontSize:
                                              16,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
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