
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentService {
  // Spring Boot backend address for Android emulator
  static const String baseUrl = 'http://10.0.2.2:8080/api/students';

  // 1. GET: Fetch all students
  Future<List<dynamic>> getStudents() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load students');
    }
  }

  // 2. POST: Add a new student
  Future<void> createStudent(
      String name, String email, String course) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'course': course,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create student: ${response.body}');
    }
  }

  // 3. PUT: Update an existing student
  Future<void> updateStudent(
      int id, String name, String email, String course) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'course': course,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update student: ${response.body}');
    }
  }

  // 4. DELETE: Delete a student
  Future<void> deleteStudent(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete student: ${response.body}');
    }
  }
}
