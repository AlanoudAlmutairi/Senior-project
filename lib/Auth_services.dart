import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final SupabaseClient _supabase = Supabase .instance.client;

  //log in 
  Future<AuthResponse> logInWIthPW(String email , String password)async{
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password);
  }
  // sign in 

  Future <AuthResponse> signUpWithPW(String email , String password )async{
    return await _supabase.auth.signUp(
     
      email: email,
      password: password
      );
      
  }

  // sign out 
  Future<void> signOut()async{
    await _supabase.auth.signOut() ;
  }

}