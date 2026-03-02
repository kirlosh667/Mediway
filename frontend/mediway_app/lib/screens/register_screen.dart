import 'package:flutter/material.dart';
import 'package:mediway_app/services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final name = TextEditingController();
  final age = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  String selectedAccessibility = "None";

  void register() async {
    if (name.text.isEmpty ||
        age.text.isEmpty ||
        email.text.isEmpty ||
        phone.text.isEmpty ||
        password.text.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
            content:
                Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    bool success =
        await ApiService.registerPatient(
      name.text.trim(),
      int.tryParse(age.text.trim()) ?? 0,
      email.text.trim(),
      phone.text.trim(),
      password.text.trim(),
      selectedAccessibility,
    );

    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>
                const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
            content:
                Text("Registration failed")),
      );
    }
  }

  @override
  void dispose() {
    name.dispose();
    age.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  InputDecoration buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
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
      suffixIcon: suffix,
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
            width: 1.6),
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
          "Create Account",
          style: TextStyle(
              fontWeight: FontWeight.w600),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
                    maxWidth: 500),
            child: Container(
              padding:
                  const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.05),
                    blurRadius: 18,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Join MediWay",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Create your patient account to access medical triage and appointments.",
                    style: TextStyle(
                      color:
                          Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: name,
                    decoration:
                        buildInputDecoration(
                      label: "Full Name",
                      icon:
                          Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: age,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        buildInputDecoration(
                      label: "Age",
                      icon:
                          Icons.cake_outlined,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: email,
                    keyboardType:
                        TextInputType
                            .emailAddress,
                    decoration:
                        buildInputDecoration(
                      label: "Email",
                      icon:
                          Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: phone,
                    keyboardType:
                        TextInputType.phone,
                    decoration:
                        buildInputDecoration(
                      label: "Phone",
                      icon:
                          Icons.phone_outlined,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: password,
                    obscureText:
                        obscurePassword,
                    decoration:
                        buildInputDecoration(
                      label: "Password",
                      icon:
                          Icons.lock_outline,
                      suffix:
                          IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons
                                  .visibility_off
                              : Icons
                                  .visibility,
                          color:
                              const Color(
                                  0xFF64748B),
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword =
                                !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<
                      String>(
                    value:
                        selectedAccessibility,
                    decoration:
                        buildInputDecoration(
                      label:
                          "Accessibility Support (Optional)",
                      icon: Icons
                          .accessibility_new,
                    ),
                    dropdownColor:
                        Colors.white,
                    items: const [
                      DropdownMenuItem(
                        value: "None",
                        child: Text("None"),
                      ),
                      DropdownMenuItem(
                        value: "Blind",
                        child: Text(
                            "Blind / Low Vision"),
                      ),
                      DropdownMenuItem(
                        value: "Deaf",
                        child: Text(
                            "Deaf / Hard of Hearing"),
                      ),
                      DropdownMenuItem(
                        value: "Speech",
                        child: Text(
                            "Speech Impaired"),
                      ),
                      DropdownMenuItem(
                        value: "Motor",
                        child: Text(
                            "Motor Disability"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedAccessibility =
                            value ?? "None";
                      });
                    },
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 54,
                    child:
                        ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : register,
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
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Text(
                              "Register",
                              style:
                                  TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}