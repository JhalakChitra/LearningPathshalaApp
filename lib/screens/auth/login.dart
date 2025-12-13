import 'package:flutter/material.dart';
import 'forgotpassword.dart'; // Import Forgot Password screen
import 'signup.dart'; // Import Signup screen
import 'package:pathshala/screens/home/homescreen.dart'; // Import Home screen
import 'package:pathshala/screens/auth/verify_email.dart'; // Import Email verification screen
import 'package:pathshala/services/auth_service.dart'; // Import AuthService for Firebase auth functions
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication package

// ----------------------------- Login Screen Stateful Widget -----------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// ----------------------------- Login Screen State -----------------------------
class _LoginScreenState extends State<LoginScreen> {
  // Controllers to get input from text fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Loading indicators for login buttons
  bool loading = false;
  bool googleLoading = false;
  bool facebookLoading = false; // For Facebook login

  // ----------------------------- Email Validation -----------------------------
  bool isValidEmail(String email) {
    // Regular expression to validate email format
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  // ----------------------------- Login with Email & Password -----------------------------
  loginUser() async {
    final email = emailController.text.trim(); // Get email input
    final password = passwordController.text.trim(); // Get password input

    // Check if email is valid
    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter valid email")));
      return;
    }

    // Check if password is empty
    if (password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter password")));
      return;
    }

    setState(() => loading = true); // Show loading indicator

    // Call loginUser function from AuthService
    final result = await AuthService().loginUser(
      email: email,
      password: password,
    );

    setState(() => loading = false); // Hide loading indicator

    if (result == "success") {
      final user = FirebaseAuth.instance.currentUser;

      // If email is not verified, navigate to VerifyEmailScreen
     /* if (user != null && !user.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please verify your email before login"),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
        );
        return;
      }*/

      // If verified, navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // If login fails, show error message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result!)));
    }
  }

  // ----------------------------- Google Login -----------------------------
  _googleLogin() async {
    setState(() => googleLoading = true); // Show Google loader

    final result = await AuthService().signInWithGoogle();

    setState(() => googleLoading = false); // Hide Google loader

    if (result == "success") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (result != "Cancelled") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  // ----------------------------- Facebook Login -----------------------------
  _facebookLogin() async {
    setState(() => facebookLoading = true); // Show Facebook loader

    final result = await AuthService().signInWithFacebook();

    setState(() => facebookLoading = false); // Hide Facebook loader

    if (result == "success") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (result != "Cancelled") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  // ----------------------------- Build UI -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Text
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text("Login to continue your courses"),
                const SizedBox(height: 40),

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
                  obscureText: true, // Hide password input
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                // Forgot Password Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text("Forgot Password?"),
                  ),
                ),
                const SizedBox(height: 30),

                // ---------------- Login Button ----------------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : loginUser, // Disable button if loading
                    child: loading
                        ? const CircularProgressIndicator(
                        color: Colors.white)
                        : const Text("Login"),
                  ),
                ),
                const SizedBox(height: 20),

                // ---------------- Divider ----------------
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Or"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                // ---------------- Google Login Button ----------------
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Image.asset("assets/google.png", height: 24),
                    onPressed: googleLoading ? null : _googleLogin,
                    label: googleLoading
                        ? const Text("Loading...")
                        : const Text("Sign in with Google"),
                  ),
                ),
                const SizedBox(height: 15),

                // ---------------- Facebook Login Button ----------------
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Image.asset("assets/facebook.png", height: 24),
                    onPressed: facebookLoading ? null : _facebookLogin,
                    label: facebookLoading
                        ? const Text("Loading...")
                        : const Text("Sign in with Facebook"),
                  ),
                ),
                const SizedBox(height: 30),

                // ---------------- Sign Up Redirect ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text("Sign Up"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
