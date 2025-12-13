import 'package:flutter/material.dart';
import '../auth/login.dart'; // Import Login screen for redirect
import '../auth/verify_email.dart'; // Import Verify Email screen after signup
import 'package:pathshala/services/auth_service.dart'; // Import AuthService to handle Firebase signup

// ----------------------------- Signup Screen Stateful Widget -----------------------------
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

// ----------------------------- Signup Screen State -----------------------------
class _SignupScreenState extends State<SignupScreen> {
  // Controllers to get input from TextFields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false; // Loading indicator for signup button

  // ----------------------------- Email Validation -----------------------------
  bool isValidEmail(String email) {
    // Regular expression to check if email format is valid
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  // ----------------------------- Signup Function -----------------------------
  signupUser() async {
    final name = nameController.text.trim(); // Get name input
    final email = emailController.text.trim(); // Get email input
    final password = passwordController.text.trim(); // Get password input
    final confirmPassword = confirmPasswordController.text.trim(); // Get confirm password input

    // ----------------------------- Input Validations -----------------------------
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter your full name")));
      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter valid email")));
      return;
    }

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password fields cannot be empty")));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password must be 6+ characters")));
      return;
    }

    setState(() => loading = true); // Show loading indicator

    // Call registerUser from AuthService (Firebase)
    final result = await AuthService().registerUser(
      fullName: name,
      email: email,
      password: password,
    );

    setState(() => loading = false); // Hide loading indicator

    // ----------------------------- Handle Result -----------------------------
    if (result == "success") {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created! (Check your Gmail to verify.)"),
        ),
      );

      // Redirect user to Verify Email page
     /* Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
      );  */
    } else {
      // Show error message if signup fails
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result!)));
    }
  }

  // ----------------------------- Build UI -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title
              const Text(
                "Sign up to start learning!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // ---------------- Full Name Input ----------------
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // ---------------- Email Input ----------------
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // ---------------- Password Input ----------------
              TextField(
                controller: passwordController,
                obscureText: true, // Hide password
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // ---------------- Confirm Password Input ----------------
              TextField(
                controller: confirmPasswordController,
                obscureText: true, // Hide password
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // ---------------- Signup Button ----------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: signupUser, // Call signup function
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white) // Show loader
                      : const Text("Create Account"),
                ),
              ),
              const SizedBox(height: 20),

              // ---------------- Redirect to Login ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()), // Go to Login page
                      );
                    },
                    child: const Text("Login"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
