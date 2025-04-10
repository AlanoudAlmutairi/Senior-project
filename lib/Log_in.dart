import 'package:flutter/material.dart';
import 'package:senior_project_axajah/Admin_addSensor.dart';
import 'package:senior_project_axajah/Admin_profile.dart';
import 'package:senior_project_axajah/Auth_services.dart';
import 'package:senior_project_axajah/firstAccess.dart';
import  'package:senior_project_axajah/signUp.dart';
import 'package:senior_project_axajah/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
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
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String role ="";
  //Text controllers 
  TextEditingController emailController =TextEditingController();
  TextEditingController passwordController =TextEditingController();
  //
      String Email = " ";
      String  PW = " " ;
       final authService = AuthServices();
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7EFE7), // Light beige background
      appBar: AppBar(    backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(209, 71, 102, 59),),
          onPressed: () {
             Navigator.push(context,MaterialPageRoute(builder: (context) =>firstAccess()));
          },
        ),),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Welcome text
            Text(
              "Hi, Welcome! 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F6A47), // Greenish color
              ),
            ),
            SizedBox(height: 20),

            // Email Field
            _buildTextField("Email address", "Your email", false , emailController),

            SizedBox(height: 15),

            // Password Field
            _buildTextField("Password", "Password", true , passwordController),

            SizedBox(height: 10),

            // Remember Me & Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      activeColor: Color(0xFF4F6A47), // Green check color
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                    Text("Remember me"),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Forgot password action
                  },
                  child: Text("Forgot password?",
                      style: TextStyle(color: Colors.black87)),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Login Button
            Center(
              child: ElevatedButton(
                onPressed: () async{
                  Email = emailController.text;
                  PW = passwordController.text;
                  login();
                
                     },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4F6A47), // Greenish button color
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 120, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Log in", style: TextStyle(fontSize: 16)),
              ),
            ),

            SizedBox(height:70),

            SizedBox(height: 30),

            // Social Login Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //_buildSocialButton("Facebook", Icons.facebook, Colors.blue),
                //SizedBox(width: 10),
                //_buildSocialButton("Google", Icons.g_mobiledata, Colors.red),
              ],
            ),

            //SizedBox(height: 80),

            // Signup Prompt
            Center(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black87),
                  children: [
                    TextSpan(text: "Don't have an account? "),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          // Handle sign-up action
                            Navigator.push(context,MaterialPageRoute(builder: (context) =>SignUp() ) );

                        },
                        child: Text(
                          "Sign up",
                          style: TextStyle(
                            color: Color(0xFF4F6A47), // Greenish color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TextField Widget
  Widget _buildTextField(String label, String hint, bool isPassword , TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 5),
        TextFormField(
          obscureText: isPassword ? _obscurePassword : false,
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.black26),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }

  // Social Login Button
  Widget _buildSocialButton(String text, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {
        // Handle social login
      },
      icon: Icon(icon, color: color),
      label: Text(text, style: TextStyle(color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.black26),
        ),
      ),
    );
  }

void login()async{
    final authService = AuthServices();
     try{
      final respons =   await authService.logInWIthPW(Email, PW);
      final user = respons.user ;
      
     if ( user != null ){
      final userID = user.id;  
      final response2 = await Supabase.instance.client.from("Users").select('"user_id","User permission"').eq("user_id", userID);
       role = response2[0]["User permission"];
      //  print("(1)$userID + $role");
       if(role == "Admin"){
         Navigator.push(context,MaterialPageRoute(builder: (context) => AdminProfile(user: user)) );
        }
        else if(role == "User"){
          final User? user = Supabase.instance.client.auth.currentUser;
           Navigator.push(context,MaterialPageRoute(builder: (context) => UserProfile(current_user: user!,))) ;
        }
         }
     else {
      showMessageDialog(context, "Email or password is NOT correct");
     }   

     }on AuthException catch (e){
        if(e.message == "Invalid login credentials" ){
              showMessageDialog(context, "Email or password is NOT correct");
        }
        else{
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${e.message}")));
        }
        }catch(e){
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error $e")));
                  }

}

 void showMessageDialog(BuildContext context , String msg ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 50, color:Colors.red),
              SizedBox(height: 10),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("OK", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
