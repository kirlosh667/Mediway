import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static const String baseUrl = "http://127.0.0.1:8000";
  static String? token;

  // ================= REGISTER =================
  static Future<bool> registerPatient(
    String name,
    int age,
    String email,
    String phone,
    String password,
    String accessibilityType,
  ) async {

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/register/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "age": age,
          "email": email,
          "phone": phone,
          "password": password,
          "accessibility_type": accessibilityType,
        }),
      );

      return response.statusCode == 200 ||
          response.statusCode == 201;

    } catch (e) {
      return false;
    }
  }

  // ================= LOGIN =================
  static Future<bool> login(
      String email,
      String password,
      ) async {

    final response = await http.post(
      Uri.parse("$baseUrl/api/token/"),
      body: {
        "username": email,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      token = data["access"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("jwt_token", token!);

      return true;
    }

    return false;
  }

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("jwt_token");
  }

  static Future<void> logout() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
  }

  // ================= SYMPTOMS =================
  static Future<List<dynamic>> getSymptoms() async {
    final response =
    await http.get(Uri.parse("$baseUrl/api/symptoms/"));

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getQuestions(
      int symptomId,
      ) async {

    final response =
    await http.get(
        Uri.parse("$baseUrl/api/questions/$symptomId/"));

    return jsonDecode(response.body);
  }

  // ================= TRIAGE =================
  static Future<Map<String, dynamic>> evaluateTriage(
      int symptomId,
      List<int> answers,
      ) async {

    final response = await http.post(
      Uri.parse("$baseUrl/api/evaluate/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "symptom_id": symptomId,
        "answers": answers,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getHistory() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/history/"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  // ================= DOCTORS =================
  static Future<List<dynamic>> getDoctors() async {
    final response =
    await http.get(Uri.parse("$baseUrl/api/doctors/"));

    return jsonDecode(response.body);
  }

  // ================= DASHBOARDS =================
  static Future<List<dynamic>> getDoctorDashboard() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/doctor-dashboard/"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getAdminDashboard() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/admin-dashboard/"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  // ================= APPOINTMENTS =================
  static Future<bool> bookAppointment(
      int doctorId,
      DateTime dateTime,
      ) async {

    final response = await http.post(
      Uri.parse("$baseUrl/api/appointments/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "doctor": doctorId,
        "appointment_date": dateTime.toIso8601String(),
      }),
    );

    return response.statusCode == 200 ||
        response.statusCode == 201;
  }

  static Future<bool> cancelAppointment(
      int appointmentId,
      ) async {

    final response = await http.post(
      Uri.parse(
          "$baseUrl/api/appointments/$appointmentId/cancel/"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }

  // ================= QUERY =================
  static Future<bool> submitQuery(
      String message,
      ) async {

    final response = await http.post(
      Uri.parse("$baseUrl/api/queries/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "title": "Patient Query",
        "category": "General",
        "description": message,
        "status": "Pending",
      }),
    );

    return response.statusCode == 200 ||
        response.statusCode == 201;
  }

  // ================= HOSPITAL =================
  static Future<Map<String, dynamic>?> hospitalLogin(
      String username,
      String password,
      ) async {

    final response = await http.post(
      Uri.parse("$baseUrl/api/custom-login/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      token = data["access"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("jwt_token", token!);

      return data;
    }

    return null;
  }

  static Future<List<dynamic>> getHospitalUsers() async {
    final response =
    await http.get(Uri.parse("$baseUrl/api/hospital-users/"));

    return jsonDecode(response.body);
  }
  // ================= GET APPOINTMENTS =================
static Future<List<dynamic>> getAppointments() async {

  final response = await http.get(
    Uri.parse("$baseUrl/api/appointments/"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to load appointments");
  }
}
// ===============================
// 🆕 GET MY PROFILE (JWT Protected)
// ===============================
static Future<Map<String, dynamic>> getMyProfile() async {

  final response = await http.get(
    Uri.parse("$baseUrl/api/my-profile/"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to load profile");
  }
}
// ================= DOCTOR ACTIONS =================

// ✅ Approve Appointment
static Future<bool> approveAppointment(
    int appointmentId,
    ) async {

  final response = await http.post(
    Uri.parse(
        "$baseUrl/api/appointments/$appointmentId/approve/"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}

// ❌ Reject Appointment
static Future<bool> rejectAppointment(
    int appointmentId,
    ) async {

  final response = await http.post(
    Uri.parse(
        "$baseUrl/api/appointments/$appointmentId/reject/"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return response.statusCode == 200;
}

// 💬 Send Message to Appointment
static Future<bool> sendMessageToAppointment(
    int appointmentId,
    String message,
    ) async {

  final response = await http.post(
    Uri.parse(
        "$baseUrl/api/appointments/$appointmentId/message/"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "message": message,
    }),
  );

  return response.statusCode == 200 ||
      response.statusCode == 201;
}

}