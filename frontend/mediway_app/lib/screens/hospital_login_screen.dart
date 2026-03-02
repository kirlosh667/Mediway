import 'package:flutter/material.dart';
import 'package:mediway_app/services/api_service.dart';
import 'doctor_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class HospitalLoginScreen extends StatefulWidget {
  const HospitalLoginScreen({super.key});

  @override
  State<HospitalLoginScreen> createState() =>
      _HospitalLoginScreenState();
}

class _HospitalLoginScreenState
    extends State<HospitalLoginScreen> {

  List users = [];
  String? selectedUsername;
  String? selectedRole;

  final passwordController =
      TextEditingController();

  bool isLoading = true;
  bool isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      users =
          await ApiService.getHospitalUsers();
    } catch (_) {}

    setState(() {
      isLoading = false;
    });
  }

  void login() async {

    if (selectedUsername == null ||
        passwordController.text.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "Select user and enter password"),
        ),
      );
      return;
    }

    setState(() => isLoggingIn = true);

    final data =
        await ApiService.hospitalLogin(
      selectedUsername!,
      passwordController.text,
    );

    setState(() => isLoggingIn = false);

    if (data == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
            content:
                Text("Login failed")),
      );
      return;
    }

    final role = data["role"];

    if (role == "admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const AdminDashboardScreen(),
        ),
      );
    } else if (role == "doctor") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const DoctorDashboardScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
            content:
                Text("Invalid role")),
      );
    }
  }

  InputDecoration buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF334155),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF2563EB),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            BorderSide(
                color:
                    Colors.grey.shade300),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            BorderSide(
                color:
                    Colors.grey.shade300),
      ),
      focusedBorder:
          const OutlineInputBorder(
        borderRadius:
            BorderRadius.all(
                Radius.circular(16)),
        borderSide: BorderSide(
          color: Color(0xFF2563EB),
          width: 1.6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xFF2563EB),
              ),
            )
          : Center(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                        24),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                          maxWidth: 520),
                  child: Container(
                    padding:
                        const EdgeInsets.all(
                            30),
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                                  24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black
                              .withOpacity(
                                  0.05),
                          blurRadius:
                              20,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [

                        // HEADER
                        Row(
                          children: const [
                            Icon(
                              Icons
                                  .local_hospital_rounded,
                              size: 36,
                              color:
                                  Color(
                                      0xFF2563EB),
                            ),
                            SizedBox(
                                width: 12),
                            Text(
                              "Hospital Portal",
                              style:
                                  TextStyle(
                                fontSize:
                                    22,
                                fontWeight:
                                    FontWeight
                                        .w600,
                                color:
                                    Color(
                                        0xFF1E293B),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 10),

                        const Text(
                          "Secure login for doctors and administrators.",
                          style: TextStyle(
                            color:
                                Color(
                                    0xFF64748B),
                          ),
                        ),

                        const SizedBox(
                            height: 35),

                        // USER DROPDOWN
                        DropdownButtonFormField<
                            String>(
                          value:
                              selectedUsername,
                          decoration:
                              buildInputDecoration(
                            label:
                                "Select User",
                            icon: Icons
                                .person_outline,
                          ),
                          dropdownColor:
                              Colors.white,
                          items: users.map<
                                  DropdownMenuItem<
                                      String>>(
                              (user) {
                            return DropdownMenuItem<
                                String>(
                              value:
                                  user["username"],
                              child: Text(
                                user["role"] ==
                                        "admin"
                                    ? "Admin (${user["username"]})"
                                    : user["name"],
                                style: const TextStyle(
                                    color: Color(
                                        0xFF1E293B)),
                              ),
                            );
                          }).toList(),
                          onChanged:
                              (value) {
                            final selected =
                                users
                                    .firstWhere(
                              (u) =>
                                  u["username"] ==
                                  value,
                            );

                            setState(() {
                              selectedUsername =
                                  value;
                              selectedRole =
                                  selected["role"];
                            });
                          },
                        ),

                        const SizedBox(
                            height: 20),

                        // PASSWORD
                        TextField(
                          controller:
                              passwordController,
                          obscureText:
                              true,
                          style: const TextStyle(
                            color:
                                Color(
                                    0xFF1E293B),
                          ),
                          decoration:
                              buildInputDecoration(
                            label:
                                "Password",
                            icon: Icons
                                .lock_outline,
                          ),
                        ),

                        const SizedBox(
                            height: 35),

                        // LOGIN BUTTON
                        SizedBox(
                          width:
                              double.infinity,
                          height: 54,
                          child:
                              ElevatedButton(
                            onPressed:
                                isLoggingIn
                                    ? null
                                    : login,
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                      0xFF2563EB),
                              foregroundColor:
                                  Colors.white,
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        16),
                              ),
                            ),
                            child:
                                isLoggingIn
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
                                        "Secure Login",
                                        style:
                                            TextStyle(
                                          fontSize:
                                              16,
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
              ),
            ),
    );
  }
}