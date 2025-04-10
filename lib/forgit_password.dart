import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
 url: "https://khexdrhpnxwlpulyaqbk.supabase.co",
 anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtoZXhkcmhwbnh3bHB1bHlhcWJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyOTA0NDQsImV4cCI6MjA1Njg2NjQ0NH0.lGQmtVMiAnEXQJvSL_8SQMaM5eGrNOg8_nqzuk1sHkA",
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ForgotPassword(),
    );
  }
}

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final supabase = Supabase.instance.client;

  void _sendResetCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar("Please enter your email address");
      return;
    }

    try {
      await supabase.auth.resetPasswordForEmail(email);
      _showSnackBar("Password reset email sent. Check your inbox.");
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7EFE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(209, 71, 102, 59)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Forgot password ?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F6A47),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Don't worry! It happens. Please enter the email associated with your account.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 40),
            _buildTextField("Email address", "Enter your email address"),
            SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                onPressed: _sendResetCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4F6A47),
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Send code", style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black87),
                  children: [
                    TextSpan(text: "Remember password? "),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to login screen if needed
                        },
                        child: Text(
                          "Log in",
                          style: TextStyle(
                            color: Color(0xFF4F6A47),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 5),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.black26),
            ),
          ),
        ),
      ],
    );
  }
}