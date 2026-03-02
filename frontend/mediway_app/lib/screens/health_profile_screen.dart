import 'package:flutter/material.dart';

class HealthProfileScreen extends StatelessWidget {
  const HealthProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Profile")),
      body: const Center(
        child: Text("Health Profile Form Here"),
      ),
    );
  }
}