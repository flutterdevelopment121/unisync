import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'main.dart'; // To access the supabase client instance

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _registerNumberController = TextEditingController();
  final _courseController = TextEditingController();
  final _semesterController = TextEditingController();
  final _yearController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();

  DateTime? _selectedDate;
  bool _isPasswordObscured = true;
  bool _isRePasswordObscured = true;
  bool _isLoading = false; // State variable for loading indicator

  @override
  void initState() {
    super.initState();
    _semesterController.addListener(_updateYearBasedOnSemester);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _registerNumberController.dispose();
    _courseController.dispose();
    _semesterController.dispose();
    _yearController.dispose();
    _birthdayController.dispose();
    _passwordController.dispose();
    _semesterController.removeListener(_updateYearBasedOnSemester);
    _rePasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdayController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(picked); // Format the date
      });
    }
  }

  String _getOrdinal(int number) {
    if (number <= 0) return number.toString(); // Or handle error
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  void _updateYearBasedOnSemester() {
    final semesterText = _semesterController.text;
    final semester = int.tryParse(semesterText);
    if (semester != null && semester >= 1 && semester <= 8) {
      // Assuming 8 semesters max
      final year = (semester - 1) ~/ 2 + 1;
      _yearController.text = '${_getOrdinal(year)} year';
    } else {
      _yearController.clear(); // Clear if semester is invalid or empty
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $labelText';
              }
              return null;
            },
        onTap: onTap,
        readOnly: readOnly,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextField(controller: _nameController, labelText: 'Name'),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _usernameController,
                labelText: 'Username',
              ),
              _buildTextField(
                controller: _registerNumberController,
                labelText: 'Register Number',
              ),
              _buildTextField(
                controller: _courseController,
                labelText: 'Course',
              ),
              _buildTextField(
                controller: _semesterController,
                labelText: 'Semester',
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                // For year, consider if it's admission year or academic year range
                controller: _yearController,
                labelText: 'Academic Year',
                readOnly: true, // Year is autofilled
                validator:
                    null, // No direct validation needed as it's autofilled
              ),
              _buildTextField(
                controller: _birthdayController,
                labelText: 'Birthday',
                readOnly: true,
                onTap: () => _selectDate(context),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              _buildTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: _isPasswordObscured,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _rePasswordController,
                labelText: 'Re-enter Password',
                obscureText: _isRePasswordObscured,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isRePasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isRePasswordObscured = !_isRePasswordObscured;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please re-enter your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  // Make onPressed async
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true; // Show loading indicator
                    });
                    try {
                      final AuthResponse res = await supabase.auth.signUp(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                        // You can pass additional user metadata here if needed,
                        // but custom profile fields are better in their own table.
                        // data: {'username': _usernameController.text.trim()}, // Example
                      );

                      if (res.user != null) {
                        // User signed up successfully. Now, insert/update their profile.
                        // The trigger on Supabase should ideally handle the initial profile creation.
                        // If you are not using the trigger or want to ensure data is set immediately:
                        await supabase
                            .from('profiles')
                            .update({
                              'name': _nameController.text.trim(),
                              'username': _usernameController.text.trim(),
                              'register_number': _registerNumberController.text
                                  .trim(),
                              'course': _courseController.text.trim(),
                              'semester': int.tryParse(
                                _semesterController.text.trim(),
                              ), // Ensure it's an int
                              'academic_year': _yearController.text.trim(),
                              'birthday': _selectedDate
                                  ?.toIso8601String(), // Format for DATE type
                              'updated_at': DateTime.now().toIso8601String(),
                            })
                            .eq('id', res.user!.id); // Match the user ID

                        // Navigate to login or home page
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Registration successful! Please check your email to verify.',
                              ),
                            ),
                          );
                          Navigator.of(context).pop(); // Go back to login page
                        }
                      } else if (res.session == null && res.user == null) {
                        // Handle cases like email confirmation needed
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please check your email to verify your account.',
                              ),
                            ),
                          );
                        }
                      }
                    } on AuthException catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Registration failed: ${e.message}'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('An unexpected error occurred: $e'),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) { // Check if the widget is still in the tree
                        setState(() {
                          _isLoading = false; // Hide loading indicator
                        });
                      }
                    }
                  }
                },
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                      )
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
