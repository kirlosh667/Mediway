import 'package:flutter/material.dart';
import 'package:mediway_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:mediway_app/services/accessibility_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final emailController =
      TextEditingController();
  final passwordController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  void login() async {

    if (emailController.text
            .trim()
            .isEmpty ||
        passwordController.text
            .trim()
            .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
            content: Text(
                "Please enter email and password")),
      );
      return;
    }

    setState(() => isLoading = true);

    final success =
        await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (success) {

      final profile =
          await ApiService.getMyProfile();
      final type =
          profile["accessibility_type"] ??
              "None";

      final accessibility =
          context
              .read<AccessibilityService>();

      if (type == "Blind") {
        await accessibility
            .setAccessibility(blind: true);
      } else if (type == "Deaf") {
        await accessibility
            .setAccessibility(deaf: true);
      } else if (type == "Mute") {
        await accessibility
            .setAccessibility(mute: true);
      }

      setState(() => isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const DashboardScreen(),
        ),
      );

    } else {

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
            content: Text("Invalid Login")),
      );
    }
  }

  InputDecoration buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF1E88E5),
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
            BorderRadius.circular(18),
        borderSide:
            BorderSide(
                color:
                    Colors.grey.shade300),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(18),
        borderSide:
            BorderSide(
                color:
                    Colors.grey.shade300),
      ),
      focusedBorder:
          const OutlineInputBorder(
        borderRadius:
            BorderRadius.all(
                Radius.circular(18)),
        borderSide: BorderSide(
          color: Color(0xFF1E88E5),
          width: 1.6,
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F8FB),

      body: Stack(
        children: [

          // ================= GRADIENT HEADER =================
          Container(
            height: 320,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E88E5),
                  Color(0xFF1565C0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ================= CONTENT =================
          Center(
            child:
                SingleChildScrollView(
              padding:
                  const EdgeInsets
                      .symmetric(
                          horizontal: 24),
              child:
                  ConstrainedBox(
                constraints:
                    const BoxConstraints(
                        maxWidth: 430),
                child: Container(
                  margin:
                      const EdgeInsets
                          .only(top: 120),
                  padding:
                      const EdgeInsets
                          .all(32),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(
                                28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .black
                            .withOpacity(
                                0.08),
                        blurRadius:
                            25,
                        offset:
                            const Offset(
                                0, 12),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [

                      // Logo
                      Container(
                        padding:
                            const EdgeInsets
                                .all(18),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                                  0xFFE3F2FD),
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      24),
                        ),
                        child: const Icon(
                          Icons
                              .local_hospital,
                          size: 52,
                          color:
                              Color(
                                  0xFF1E88E5),
                        ),
                      ),

                      const SizedBox(
                          height: 20),

                      const Text(
                        "Welcome Back",
                        style:
                            TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                          height: 6),

                      const Text(
                        "Login to continue to MediWay",
                        style: TextStyle(
                            color:
                                Colors.grey),
                      ),

                      const SizedBox(
                          height: 35),

                      // Email
                      TextField(
                        controller:
                            emailController,
                        keyboardType:
                            TextInputType
                                .emailAddress,
                        decoration:
                            buildInputDecoration(
                          label: "Email",
                          icon: Icons
                              .email_outlined,
                        ),
                      ),

                      const SizedBox(
                          height: 20),

                      // Password
                      TextField(
                        controller:
                            passwordController,
                        obscureText:
                            obscurePassword,
                        decoration:
                            buildInputDecoration(
                          label:
                              "Password",
                          icon: Icons
                              .lock_outline,
                          suffix:
                              IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons
                                      .visibility_off
                                  : Icons
                                      .visibility,
                              color: Colors
                                  .grey,
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

                      const SizedBox(
                          height: 35),

                      SizedBox(
                        width:
                            double.infinity,
                        height: 54,
                        child:
                            ElevatedButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : login,
                          style:
                              ElevatedButton
                                  .styleFrom(
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          18),
                            ),
                          ),
                          child:
                              isLoading
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
                                      "Login",
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
            ),
          ),
        ],
      ),
    );
  }
}