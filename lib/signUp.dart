import 'package:flutter/material.dart';
import 'package:senior_project_axajah/Admin_addSensor.dart';
import 'package:senior_project_axajah/Admin_profile.dart';
import 'package:senior_project_axajah/Auth_services.dart';
import 'package:senior_project_axajah/Main.dart';
import 'package:senior_project_axajah/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:senior_project_axajah/Log_in.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _isAdmin = false;
  bool _isUser = false;
  bool _obscurePassword = true;
  //text controllers 
  TextEditingController email_controller = TextEditingController();
  TextEditingController PW_controller = TextEditingController();
  TextEditingController username_controller = TextEditingController();
  
    String username ="";
    String email="" ;
    String password="" ;
    String role="";
   late User user  ;

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7EFE7), 
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
           
            // Create Account Title
            Text(
              "Create account",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F6A47), // Greenish color
              ),
            ),
            SizedBox(height: 20),

            // Role Selection (Admin / User)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildRoleCheckbox("Admin", _isAdmin, (value) {
                  setState(() {
                    _isAdmin = value!;
                    _isUser = !value; // Uncheck other option
                  });
                }),
                SizedBox(width: 20),
                _buildRoleCheckbox("User", _isUser, (value) {
                  setState(() {
                    _isUser = value!;
                    _isAdmin = !value; // Uncheck other option
                  });
                }),
              ],
            ),

            SizedBox(height: 15),

            // Username Field
            _buildTextField("Username", "Your username", false , username_controller),

            SizedBox(height: 15),

            // Email Field
            _buildTextField("Email", "Your email", false ,email_controller),

            SizedBox(height: 15),

            // Password Field
            _buildTextField("Password", "Password", true , PW_controller),

            SizedBox(height: 40),

            // Sign Up Button
            Center(
              child: ElevatedButton(
                onPressed: () async{
                   role = _isAdmin ? "Admin" : _isUser ? "User" : "None";
                  // Handle signup action
                  user = await signUp(role);
                  if(role == "Admin"){
                       Navigator.push(context,MaterialPageRoute(builder: (context) => AdminProfile(user: user)) );
                  }
                  else if(role =="User"){
                     Navigator.push(context,MaterialPageRoute(builder: (context) => UserProfile(current_user: user)) );
                  }
                
                   //;
           
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4F6A47), // Greenish button color
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 120, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("create an account", style: TextStyle(fontSize: 16)),
              ),
            ),

            SizedBox(height: 50),

            // Already have an account? Log in
            Center(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black87),
                  children: [
                    TextSpan(text: "Already have an account? "),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          // Handle login navigation
                          Navigator.push(context,MaterialPageRoute(builder: (context) =>Login()));
                          
                        },
                        child: Text(
                          "Log in",
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

  // Checkbox Widget
  Widget _buildRoleCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          activeColor: Color(0xFF4F6A47), // Green check color
          onChanged: onChanged,
        ),
        Text(label),
      ],
    );
  }

  // TextField Widget
  Widget _buildTextField(String label, String hint, bool isPassword , TextEditingController controller ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 5),
        TextField(
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

// sign up method with supabase
Future<User> signUp(String role)async{
  final authService = AuthServices();
  username = username_controller.text;
  email = email_controller.text;
  password = PW_controller.text;

  try{
    var response = await authService.signUpWithPW( email, password);
   user = response.user!;

     if (user != null){
    await Supabase.instance.client.from('Users').insert({
     'user_id' : user.id ,
     'Username' : username ,
     'Password':password ,
     'Email' : user.email ,
     'User permission' : role ,
      } ) ;
        return user;
   }
   else{
   throw Exception("User sign-up failed.");
   }

  }on AuthException catch (e){
        if(e.message == "Unable to validate email address: invalid format" ){
              showMessageDialog(context, "Email is NOT correct");
        }
        else{
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${e.message}"))); 
        }
       throw Exception("Sign-up failed: ${e.message}");
        }catch(e){
    if(mounted){
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error $e")));
        }    
        throw Exception("Sign-up failed: $e");
    
  }

}

// show ui dialog for any masseges 
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
