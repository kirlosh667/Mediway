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
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF4F8FB),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(18),
        borderSide: BorderSide(
            color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(18),
        borderSide: BorderSide(
            color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius:
            BorderRadius.all(
                Radius.circular(18)),
        borderSide: BorderSide(
            color: Color(0xFF1E88E5),
            width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Create Account"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(
                  horizontal: 24),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
                    maxWidth: 500),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),

                const Text(
                  "Join MediWay",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Create your patient account to access medical triage and appointments.",
                  style: TextStyle(
                      color: Colors.grey),
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
                  child:
                      ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : register,
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
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}