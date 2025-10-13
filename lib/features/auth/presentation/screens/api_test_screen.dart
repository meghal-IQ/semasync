import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/api/services/health_service.dart';
import '../../../../core/api/models/auth_models.dart';
import '../../../../core/api/helpers/registration_helper.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  DateTime _selectedDate = DateTime(1990, 1, 1);
  String _selectedGender = 'male';
  double _height = 175.0;
  double _weight = 70.0;
  String _selectedMedication = 'Ozempic®';
  String _selectedDose = '0.25mg';
  String _selectedFrequency = 'Every 7 days (most common)';
  String _selectedMotivation = 'I want to feel more confident in my own skin.';
  
  bool _isLoading = false;
  String? _healthStatus;

  @override
  void initState() {
    super.initState();
    // _checkHealth();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }


  Future<void> _testLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${authProvider.errorMessage}')),
      );
    }
  }

  Future<void> _testRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final request = RegistrationHelper.buildRegisterRequest(
      email: _emailController.text,
      password: _passwordController.text,
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
    );

    final success = await authProvider.register(request);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${authProvider.errorMessage}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test Screen'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Health Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.health_and_safety, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'API Health Status',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          if (_isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _healthStatus ?? 'Checking...',
                        style: TextStyle(
                          color: _healthStatus?.contains('healthy') == true 
                              ? Colors.green 
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // ElevatedButton.icon(
                      //   onPressed: _checkHealth,
                      //   icon: const Icon(Icons.refresh),
                      //   label: const Text('Check Health'),
                      // ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Auth Status Card
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                authProvider.isAuthenticated 
                                    ? Icons.check_circle 
                                    : Icons.cancel,
                                color: authProvider.isAuthenticated 
                                    ? Colors.green 
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Authentication Status',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            authProvider.isAuthenticated 
                                ? 'Authenticated as ${authProvider.user?.email ?? "Unknown"}'
                                : 'Not authenticated',
                          ),
                          if (authProvider.user != null) ...[
                            const SizedBox(height: 8),
                            Text('Name: ${authProvider.user!.firstName} ${authProvider.user!.lastName}'),
                            Text('Medication: ${authProvider.user!.glp1Journey.medication}'),
                            Text('Motivation: ${authProvider.user!.motivation}'),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: authProvider.isAuthenticated 
                                    ? () => authProvider.logout()
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Logout'),
                              ),
                              const SizedBox(width: 8),
                              if (authProvider.isAuthenticated)
                                ElevatedButton(
                                  onPressed: () => authProvider.refreshUser(),
                                  child: const Text('Refresh User'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Login Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Login Test',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _testLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Test Login'),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Registration Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Registration Test',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Date of Birth
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Gender
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                        ),
                        items: ['male', 'female', 'other']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedGender = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Height and Weight
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Height: ${_height.toStringAsFixed(1)} cm'),
                                Slider(
                                  value: _height,
                                  min: 50,
                                  max: 300,
                                  divisions: 250,
                                  onChanged: (value) {
                                    setState(() => _height = value);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Weight: ${_weight.toStringAsFixed(1)} kg'),
                                Slider(
                                  value: _weight,
                                  min: 20,
                                  max: 500,
                                  divisions: 480,
                                  onChanged: (value) {
                                    setState(() => _weight = value);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Medication
                      DropdownButtonFormField<String>(
                        value: _selectedMedication,
                        decoration: const InputDecoration(
                          labelText: 'Medication',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          'Zepbound®',
                          'Mounjaro®',
                          'Ozempic®',
                          'Wegovy®',
                          'Trulicity®',
                          'Compounded Semaglutide',
                          'Compounded Tirzepatide'
                        ].map((med) => DropdownMenuItem(
                              value: med,
                              child: Text(med),
                            )).toList(),
                        onChanged: (value) {
                          setState(() => _selectedMedication = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Dose
                      DropdownButtonFormField<String>(
                        value: _selectedDose,
                        decoration: const InputDecoration(
                          labelText: 'Starting Dose',
                          border: OutlineInputBorder(),
                        ),
                        items: ['0.25mg', '0.5mg', '1.0mg', '1.7mg', '2.4mg']
                            .map((dose) => DropdownMenuItem(
                                  value: dose,
                                  child: Text(dose),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedDose = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Frequency
                      DropdownButtonFormField<String>(
                        value: _selectedFrequency,
                        decoration: const InputDecoration(
                          labelText: 'Frequency',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          'Every day',
                          'Every 7 days (most common)',
                          'Every 14 days',
                          'Custom',
                          'Not sure, still figuring it out'
                        ].map((freq) => DropdownMenuItem(
                              value: freq,
                              child: Text(freq),
                            )).toList(),
                        onChanged: (value) {
                          setState(() => _selectedFrequency = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Motivation
                      DropdownButtonFormField<String>(
                        value: _selectedMotivation,
                        decoration: const InputDecoration(
                          labelText: 'Motivation',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          'I want to feel more confident in my own skin.',
                          'I\'m just ready for a fresh start.',
                          'I want to boost my energy and strength.',
                          'To improve my health and manage PCOS.',
                          'I want to show up for the people I love.',
                          'I have a special event or milestone coming up.',
                          'To feel good wearing the clothes I love again.'
                        ].map((motivation) => DropdownMenuItem(
                              value: motivation,
                              child: Text(
                                motivation,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )).toList(),
                        onChanged: (value) {
                          setState(() => _selectedMotivation = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _testRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Test Registration'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
