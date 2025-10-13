import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/api/helpers/registration_helper.dart';

class SimpleApiTestScreen extends StatefulWidget {
  const SimpleApiTestScreen({super.key});

  @override
  State<SimpleApiTestScreen> createState() => _SimpleApiTestScreenState();
}

class _SimpleApiTestScreenState extends State<SimpleApiTestScreen> {
  // Login controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Registration controllers
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  // Registration form state
  DateTime _selectedDate = DateTime(1990, 1, 1);
  String _selectedGender = 'male';
  double _height = 175.0;
  double _weight = 70.0;
  String _selectedMedication = 'Ozempic®';
  String _selectedDose = '0.25mg';
  String _selectedFrequency = 'Every 7 days (most common)';
  String _selectedMotivation = 'I want to feel more confident in my own skin.';
  List<String> _selectedConcerns = [];
  
  bool _isLoginMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _testLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please enter email and password');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    _showSnackBar(success ? 'Login successful!' : 'Login failed: ${authProvider.errorMessage}');
  }

  Future<void> _testRegister() async {
    if (_regEmailController.text.isEmpty || 
        _regPasswordController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty) {
      _showSnackBar('Please fill in all required fields');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final request = RegistrationHelper.buildRegisterRequest(
      email: _regEmailController.text,
      password: _regPasswordController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      dateOfBirth: _selectedDate,
      gender: _selectedGender,
      height: _height,
      weight: _weight,
      medication: _selectedMedication,
      startingDose: _selectedDose,
      frequency: _selectedFrequency,
      motivation: _selectedMotivation,
      concerns: _selectedConcerns,
    );

    final success = await authProvider.register(request);

    if (success) {
      _showSnackBar('Registration successful!');
      setState(() => _isLoginMode = true);
      // Clear form
      _regEmailController.clear();
      _regPasswordController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
    } else {
      _showSnackBar('Registration failed: ${authProvider.errorMessage}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SemaSync API'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            
            // Login Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _testLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
