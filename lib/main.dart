import 'package:flutter/material.dart';
import 'package:senior_project_axajah/Log_in.dart';
import 'package:senior_project_axajah/signUp.dart';
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
      home: firstAccess(),
    );
  }
}

class firstAccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7EFE7), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome Card
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Welcome!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F6A47), // Greenish color
                    ),
                  ),
                  SizedBox(height: 20),
                   Image.asset(
                  'lib/assets/axajah_logo2.png',
                  width: 220,
                  height: 180,
                  fit: BoxFit.cover,
                ),
                  Text(
                    "Indoor CO2 monitoring system.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
            SizedBox(height: 110),

            // Login Button
            ElevatedButton(
              onPressed: () {
               Navigator.push(context,MaterialPageRoute(builder: (context) =>Login()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4F6A47), // Greenish button color
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Log In", style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 15),

            // Create Account Button
            OutlinedButton(
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) =>SignUp()));
                // Handle create account action
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF4F6A47), // Text color
                side: BorderSide(color: Color(0xFF4F6A47)), // Border color
                padding: EdgeInsets.symmetric(horizontal: 65, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Create account", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
