import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // Current logged-in Firebase user
  User? user = FirebaseAuth.instance.currentUser;

  // Variables to store user data
  String fullName = "";
  String email = "";

  @override
  void initState() {
    super.initState();

    // Fetch user details when screen loads
    getUserDetails();
  }

  /// Fetch user name & email from Firestore
  Future<void> getUserDetails() async {
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      if (!userDoc.exists) {
        debugPrint("User document does not exist");
        return;
      }

      final data = userDoc.data() as Map<String, dynamic>;

      setState(() {
        fullName = data["fullName"] ?? "No Name";
        email = data["email"] ?? "";
      });
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }


  /// Logout user from app
  Future<void> logout(BuildContext context) async {
    // Firebase sign out
    await FirebaseAuth.instance.signOut();

    // Clear saved session data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all stored values

    // Navigate to Login screen and remove previous screens
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // Profile icon
            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.deepPurple,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            // User Name
            Text(
              fullName.isNotEmpty ? fullName : "Loading...",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            // User Email
            Text(
              email,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            // Settings option
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const Divider(),

            // Privacy policy option
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text("Privacy Policy"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const Divider(),

            const Spacer(),

            // Logout button
            ElevatedButton.icon(
              onPressed: () => logout(context),
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
