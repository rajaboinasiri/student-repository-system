
import 'package:flutter/material.dart';
import 'services/student_service.dart';

void main() {
  runApp(const MyApp());
}

// MAIN APPLICATION
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StudentListScreen(),
    );
  }
}

// STUDENT LIST SCREEN
class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() =>
      _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final StudentService studentService = StudentService();

  late Future<List<dynamic>> studentsFuture;

  @override
  void initState() {
    super.initState();
    studentsFuture = studentService.getStudents();
  }

  // REFRESH STUDENT LIST
  void refreshStudents() {
    setState(() {
      studentsFuture = studentService.getStudents();
    });
  }

  // ADD STUDENT
  Future<void> _showAddStudentDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final courseController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Add Student'),

            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Student Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Enter student name'
                              : null,
                    ),

                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) =>
                          value == null ||
                                  !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                      .hasMatch(value.trim())
                              ? 'Enter a valid email'
                              : null,
                    ),

                    TextFormField(
                      controller: courseController,
                      decoration: const InputDecoration(
                        labelText: 'Course',
                        prefixIcon: Icon(Icons.school),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Enter course'
                              : null,
                    ),
                  ],
                ),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),

              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(dialogContext, true);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (result != true || !mounted) return;

      await studentService.createStudent(
        nameController.text.trim(),
        emailController.text.trim(),
        courseController.text.trim(),
      );

      if (!mounted) return;

      refreshStudents();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      nameController.dispose();
      emailController.dispose();
      courseController.dispose();
    }
  }

  // EDIT STUDENT
  Future<void> _showEditStudentDialog(
      Map<String, dynamic> student) async {
    final nameController =
        TextEditingController(text: student['name'] ?? '');

    final emailController =
        TextEditingController(text: student['email'] ?? '');

    final courseController =
        TextEditingController(text: student['course'] ?? '');

    final formKey = GlobalKey<FormState>();

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Edit Student'),

            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Student Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Enter student name'
                              : null,
                    ),

                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) =>
                          value == null ||
                                  !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                      .hasMatch(value.trim())
                              ? 'Enter a valid email'
                              : null,
                    ),

                    TextFormField(
                      controller: courseController,
                      decoration: const InputDecoration(
                        labelText: 'Course',
                        prefixIcon: Icon(Icons.school),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Enter course'
                              : null,
                    ),
                  ],
                ),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),

              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(dialogContext, true);
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      );

      if (result != true || !mounted) return;

      await studentService.updateStudent(
        (student['id'] as num).toInt(),
        nameController.text.trim(),
        emailController.text.trim(),
        courseController.text.trim(),
      );

      if (!mounted) return;

      refreshStudents();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      nameController.dispose();
      emailController.dispose();
      courseController.dispose();
    }
  }

  // DELETE STUDENT
  Future<void> _deleteStudent(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Student'),

          content: Text(
            'Are you sure you want to delete $name?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    try {
      await studentService.deleteStudent(id);

      if (!mounted) return;

      refreshStudents();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // BUILD SCREEN
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshStudents,
          ),
        ],
      ),

      // ADD STUDENT BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),

      // DISPLAY STUDENTS
      body: FutureBuilder<List<dynamic>>(
        future: studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return const Center(
              child: Text('No students found'),
            );
          }

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student =
                  Map<String, dynamic>.from(students[index]);

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    child: Text('${student['id']}'),
                  ),

                  title: Text(
                    student['name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    '${student['email']}\n'
                    'Course: ${student['course']}',
                  ),

                  isThreeLine: true,

                  // EDIT AND DELETE BUTTONS
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // EDIT BUTTON
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          _showEditStudentDialog(student);
                        },
                      ),

                      // DELETE BUTTON
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _deleteStudent(
                            (student['id'] as num).toInt(),
                            student['name'] ?? '',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
