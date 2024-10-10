import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import 'home_screen.dart'; // Import HomeScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance

  Future<void> _login() async {
    try {
      // Attempt to sign in the user
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // If successful, navigate to the HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      // Handle various error codes
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password.';
      } else {
        errorMessage = 'Login failed. Please try again.';
      }

      // Display error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo Placeholder
              const Icon(
                Icons.health_and_safety,
                color: Colors.blueAccent,
                size: 100,
              ),
              const SizedBox(height: 40),
              // Title
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please login to your account',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              // Form Fields
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                        filled: true,
                        fillColor: Colors.blue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                        filled: true,
                        fillColor: Colors.blue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Login Button
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _login();  // Call the login function
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 80),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Signup Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Forgot Password
              GestureDetector(
                onTap: () {
                  // Forgot password navigation logic
                },
                child: const Text(
                  'Forgot your password?',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
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
