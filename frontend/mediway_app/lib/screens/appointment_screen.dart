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
              BorderRadius.circular(20),
          border: Border.all(
              color:
                  Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.blue
                  .withOpacity(0.05),
              blurRadius: 15,
              offset:
                  const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon,
                color:
                    const Color(0xFF2563EB)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      Color(0xFF1E293B),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF64748B),
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
          const Color(0xFFF9FBFF),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        foregroundColor:
            const Color(0xFF1E293B),
        centerTitle: true,
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
                    Color(0xFF2563EB),
              ),
            )
          : doctors.isEmpty
              ? const Center(
                  child: Text(
                    "No doctors available",
                    style: TextStyle(
                        fontSize: 16,
                        color:
                            Color(0xFF64748B)),
                  ),
                )
              : SafeArea(
                  child:
                      SingleChildScrollView(
                    padding:
                        const EdgeInsets.all(
                            24),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [

                        const Text(
                          "Specialization",
                          style: TextStyle(
                            color:
                                Color(0xFF64748B),
                          ),
                        ),

                        const SizedBox(
                            height: 6),

                        Text(
                          widget.specialization,
                          style:
                              const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .w600,
                            color:
                                Color(0xFF1E293B),
                          ),
                        ),

                        const SizedBox(
                            height: 30),

                        Theme(
                          data: Theme.of(context)
                              .copyWith(
                            canvasColor:
                                Colors.white,
                          ),
                          child:
                              DropdownButtonFormField<
                                  int>(
                            value:
                                selectedDoctorId,
                            isExpanded: true,
                            dropdownColor:
                                Colors.white,
                            style: const TextStyle(
                              color:
                                  Color(0xFF1E293B),
                              fontWeight:
                                  FontWeight.w500,
                            ),
                            decoration:
                                InputDecoration(
                              filled: true,
                              fillColor:
                                  Colors.white,
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            20),
                              ),
                            ),
                            hint: const Text(
                              "Select Doctor",
                              style: TextStyle(
                                color:
                                    Color(0xFF64748B),
                              ),
                            ),
                            items: doctors.map<
                                    DropdownMenuItem<
                                        int>>(
                                (doc) {
                              return DropdownMenuItem<
                                  int>(
                                value:
                                    doc["id"],
                                child: Text(
                                  doc["name"],
                                  style:
                                      const TextStyle(
                                    color: Color(
                                        0xFF1E293B),
                                  ),
                                ),
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

                        const SizedBox(
                            height: 30),

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

                        const SizedBox(
                            height: 16),

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

                        const SizedBox(
                            height: 40),

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
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                      0xFF2563EB),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        20),
                              ),
                            ),
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
                                          color:
                                              Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        "Confirm Appointment",
                                        style:
                                            TextStyle(
                                          fontWeight:
                                              FontWeight.w600,
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